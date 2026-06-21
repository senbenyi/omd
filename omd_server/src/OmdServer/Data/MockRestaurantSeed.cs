using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using OmdServer.Data.Entities;

namespace OmdServer.Data;

/// <summary>
/// 启动时从 mock/*.json 同步演示用户、店铺、分类、菜品与套餐（幂等 upsert）。
/// </summary>
public static class MockRestaurantSeed
{
    public static async Task SeedAsync(AppDbContext db, ILogger? logger = null)
    {
        MockDataLoader.LogScanSummary(logger ?? Microsoft.Extensions.Logging.Abstractions.NullLogger.Instance);

        var userStats = await SyncMockUsersAsync(db);
        logger?.LogInformation(
            "Mock 用户同步完成：新增 {Created}，更新 {Updated}",
            userStats.Created,
            userStats.Updated);

        await TasteLibrarySeed.SeedAsync(db);

        var document = await MockDataLoader.LoadAsync<MockStoresDocument>("stores.json");
        if (document?.Stores is not { Count: > 0 })
        {
            logger?.LogWarning("mock/stores.json 为空或不存在，跳过店铺同步");
            return;
        }

        await EnsureMockStoreOwnershipAsync(db, document.Stores);

        var storeCreated = 0;
        var storeUpdated = 0;
        foreach (var definition in document.Stores)
        {
            var (created, updated) = await SyncStoreAsync(db, definition);
            if (created) storeCreated++;
            if (updated) storeUpdated++;
        }

        logger?.LogInformation(
            "Mock 店铺同步完成：新增 {Created}，更新 {Updated}（共 {Total} 家）",
            storeCreated,
            storeUpdated,
            document.Stores.Count);
    }

    private static async Task<(int Created, int Updated)> SyncMockUsersAsync(AppDbContext db)
    {
        var created = 0;
        var updated = 0;
        var users = await MockDataLoader.LoadAsync<List<MockUserDefinition>>("users.json") ?? [];

        foreach (var mockUser in users.OrderBy(u => u.UserId))
        {
            if (mockUser.UserId <= 0) continue;

            var phone = mockUser.Phone.Trim();
            if (string.IsNullOrWhiteSpace(phone)) continue;

            var username = string.IsNullOrWhiteSpace(mockUser.Username)
                ? $"用户{phone[^4..]}"
                : mockUser.Username.Trim();
            var passwordHash = BCrypt.Net.BCrypt.HashPassword(mockUser.Password);

            // 登录以手机号为准，优先按手机号匹配，避免相同 userId 互相覆盖。
            var user = await db.Users.FirstOrDefaultAsync(u => u.Phone == phone);

            if (user is null)
            {
                var canUseMockId = !await db.Users.AnyAsync(u => u.Id == mockUser.UserId);
                var newUser = new User
                {
                    Phone = phone,
                    PasswordHash = passwordHash,
                    Username = username,
                    CreatedAt = DateTime.UtcNow
                };
                if (canUseMockId)
                    newUser.Id = mockUser.UserId;

                db.Users.Add(newUser);
                await db.SaveChangesAsync();
                if (canUseMockId)
                    await ResetIdentitySequenceAsync(db, "users", "id");
                created++;
                continue;
            }

            var changed = false;
            if (user.Username != username)
            {
                user.Username = username;
                changed = true;
            }

            if (!BCrypt.Net.BCrypt.Verify(mockUser.Password, user.PasswordHash))
            {
                user.PasswordHash = passwordHash;
                changed = true;
            }

            if (changed)
            {
                await db.SaveChangesAsync();
                updated++;
            }
        }

        return (created, updated);
    }

    private static async Task EnsureMockStoreOwnershipAsync(
        AppDbContext db,
        IReadOnlyList<MockStoreDefinition> definitions)
    {
        var changed = false;
        foreach (var definition in definitions)
        {
            if (!await db.Users.AnyAsync(u => u.Id == definition.UserId))
                continue;

            var store = await db.Stores.FirstOrDefaultAsync(s => s.Name == definition.Name);
            if (store is null || store.OwnerUserId == definition.UserId) continue;
            store.OwnerUserId = definition.UserId;
            changed = true;
        }

        if (changed)
            await db.SaveChangesAsync();
    }

    private static async Task<(bool Created, bool Updated)> SyncStoreAsync(
        AppDbContext db,
        MockStoreDefinition definition)
    {
        if (!await db.Users.AnyAsync(u => u.Id == definition.UserId))
            return (false, false);

        var store = await db.Stores
            .FirstOrDefaultAsync(s => s.OwnerUserId == definition.UserId && s.Name == definition.Name);

        var created = false;
        var updated = false;
        if (store is null)
        {
            store = CreateStore(definition);
            db.Stores.Add(store);
            await db.SaveChangesAsync();
            created = true;
        }
        else if (ApplyStoreFields(store, definition))
        {
            await db.SaveChangesAsync();
            updated = true;
        }

        var menuChanged = await SyncMenuAsync(db, store, definition.Menu);
        var comboChanged = await SyncCombosAsync(db, store.Id, definition.Menu.Combos);
        if (menuChanged || comboChanged)
            updated = true;

        return (created, updated);
    }

    private static Store CreateStore(MockStoreDefinition definition)
    {
        var now = DateTime.UtcNow;
        return new Store
        {
            OwnerUserId = definition.UserId,
            Name = definition.Name,
            Status = definition.Status,
            Address = definition.Address,
            Phone = definition.Phone,
            ContactName = definition.ContactName,
            IsOpen24Hours = definition.IsOpen24Hours,
            BusinessOpenTime = definition.BusinessOpenTime,
            BusinessCloseTime = definition.BusinessCloseTime,
            ClosedWeekdays = definition.ClosedWeekdays.ToList(),
            ServiceExpireAt = now.AddYears(1),
            VipLevel = definition.VipLevel,
            ReferrerId = definition.ReferrerId,
            AdditionalPeriod = definition.AdditionalPeriod,
            CreatedAt = now
        };
    }

    private static bool ApplyStoreFields(Store store, MockStoreDefinition definition)
    {
        var changed = false;

        void Set<T>(Func<T> getter, Action<T> setter, T value)
        {
            if (EqualityComparer<T>.Default.Equals(getter(), value)) return;
            setter(value);
            changed = true;
        }

        Set(() => store.OwnerUserId, v => store.OwnerUserId = v, definition.UserId);
        Set(() => store.Status, v => store.Status = v, definition.Status);
        Set(() => store.Address, v => store.Address = v, definition.Address);
        Set(() => store.Phone, v => store.Phone = v, definition.Phone);
        Set(() => store.ContactName, v => store.ContactName = v, definition.ContactName);
        Set(() => store.IsOpen24Hours, v => store.IsOpen24Hours = v, definition.IsOpen24Hours);
        Set(() => store.BusinessOpenTime, v => store.BusinessOpenTime = v, definition.BusinessOpenTime);
        Set(() => store.BusinessCloseTime, v => store.BusinessCloseTime = v, definition.BusinessCloseTime);
        Set(() => store.VipLevel, v => store.VipLevel = v, definition.VipLevel);
        Set(() => store.ReferrerId, v => store.ReferrerId = v, definition.ReferrerId);
        Set(() => store.AdditionalPeriod, v => store.AdditionalPeriod = v, definition.AdditionalPeriod);

        var weekdays = definition.ClosedWeekdays.ToList();
        if (!store.ClosedWeekdays.SequenceEqual(weekdays))
        {
            store.ClosedWeekdays = weekdays;
            changed = true;
        }

        return changed;
    }

    private static async Task<bool> SyncMenuAsync(AppDbContext db, Store store, MockMenuDefinition menu)
    {
        var now = DateTime.UtcNow;
        var changed = false;
        var categoryMap = new Dictionary<string, MenuCategory>();

        foreach (var categoryDef in menu.Categories)
        {
            var category = await db.MenuCategories
                .FirstOrDefaultAsync(c => c.StoreId == store.Id && c.Name == categoryDef.Name);
            if (category is null)
            {
                category = new MenuCategory
                {
                    StoreId = store.Id,
                    Name = categoryDef.Name,
                    Sort = categoryDef.Sort,
                    CreatedAt = now
                };
                db.MenuCategories.Add(category);
                await db.SaveChangesAsync();
                changed = true;
            }
            else if (category.Sort != categoryDef.Sort)
            {
                category.Sort = categoryDef.Sort;
                changed = true;
            }

            categoryMap[categoryDef.Name] = category;
        }

        foreach (var itemDef in menu.Items)
        {
            if (!categoryMap.TryGetValue(itemDef.CategoryName, out var category)) continue;

            var item = await db.MenuItems
                .FirstOrDefaultAsync(i => i.StoreId == store.Id && i.Name == itemDef.Name);
            if (item is null)
            {
                db.MenuItems.Add(CreateMenuItem(store.Id, category.Id, itemDef, now));
                changed = true;
                continue;
            }

            if (ApplyMenuItemFields(item, itemDef, category.Id, now))
                changed = true;
        }

        if (changed)
            await db.SaveChangesAsync();

        return changed;
    }

    private static MenuItem CreateMenuItem(long storeId, long categoryId, MockItemDefinition itemDef, DateTime now) =>
        new()
        {
            StoreId = storeId,
            CategoryId = categoryId,
            Name = itemDef.Name,
            Description = itemDef.Description,
            Price = itemDef.Price,
            OriginalPrice = itemDef.OriginalPrice,
            Unit = itemDef.Unit,
            MinQty = itemDef.MinQty,
            Tags = itemDef.Tags.ToList(),
            SpicyLevel = itemDef.SpicyLevel,
            Stock = itemDef.Stock,
            SoldOut = itemDef.SoldOut,
            Status = itemDef.Status,
            Sort = itemDef.Sort,
            DurationMinutes = itemDef.DurationMinutes,
            CreatedAt = now,
            UpdatedAt = now
        };

    private static bool ApplyMenuItemFields(
        MenuItem item,
        MockItemDefinition itemDef,
        long categoryId,
        DateTime now)
    {
        var changed = false;

        void Set<T>(Func<T> getter, Action<T> setter, T value)
        {
            if (EqualityComparer<T>.Default.Equals(getter(), value)) return;
            setter(value);
            changed = true;
        }

        Set(() => item.CategoryId, v => item.CategoryId = v, categoryId);
        Set(() => item.Description, v => item.Description = v, itemDef.Description);
        Set(() => item.Price, v => item.Price = v, itemDef.Price);
        Set(() => item.OriginalPrice, v => item.OriginalPrice = v, itemDef.OriginalPrice);
        Set(() => item.Unit, v => item.Unit = v, itemDef.Unit);
        Set(() => item.MinQty, v => item.MinQty = v, itemDef.MinQty);
        Set(() => item.SpicyLevel, v => item.SpicyLevel = v, itemDef.SpicyLevel);
        Set(() => item.Stock, v => item.Stock = v, itemDef.Stock);
        Set(() => item.SoldOut, v => item.SoldOut = v, itemDef.SoldOut);
        Set(() => item.Status, v => item.Status = v, itemDef.Status);
        Set(() => item.Sort, v => item.Sort = v, itemDef.Sort);
        Set(() => item.DurationMinutes, v => item.DurationMinutes = v, itemDef.DurationMinutes);

        var tags = itemDef.Tags.ToList();
        if (!item.Tags.SequenceEqual(tags))
        {
            item.Tags = tags;
            changed = true;
        }

        if (changed)
            item.UpdatedAt = now;

        return changed;
    }

    private static async Task<bool> SyncCombosAsync(
        AppDbContext db,
        long storeId,
        IReadOnlyList<MockComboDefinition> combos)
    {
        var changed = false;

        foreach (var comboDef in combos)
        {
            var lineItems = await ResolveComboLineItemsAsync(db, storeId, comboDef.Lines);
            if (lineItems.Count == 0) continue;

            var combo = await db.MenuCombos
                .Include(c => c.Items)
                .FirstOrDefaultAsync(c => c.StoreId == storeId && c.Name == comboDef.Name);

            if (combo is null)
            {
                combo = new MenuCombo
                {
                    StoreId = storeId,
                    Name = comboDef.Name,
                    Price = comboDef.Price,
                    Sort = comboDef.Sort,
                    CreatedAt = DateTime.UtcNow
                };
                db.MenuCombos.Add(combo);
                await db.SaveChangesAsync();
                await AddComboLinesAsync(db, combo, lineItems);
                changed = true;
                continue;
            }

            var comboChanged = false;
            if (combo.Price != comboDef.Price)
            {
                combo.Price = comboDef.Price;
                comboChanged = true;
            }

            if (combo.Sort != comboDef.Sort)
            {
                combo.Sort = comboDef.Sort;
                comboChanged = true;
            }

            if (await ReplaceComboLinesAsync(db, combo, lineItems))
                comboChanged = true;

            if (comboChanged)
            {
                await db.SaveChangesAsync();
                changed = true;
            }
        }

        return changed;
    }

    private static async Task<List<(MenuItem Item, int Qty)>> ResolveComboLineItemsAsync(
        AppDbContext db,
        long storeId,
        IReadOnlyList<MockComboLineDefinition> lines)
    {
        var result = new List<(MenuItem Item, int Qty)>();
        foreach (var line in lines)
        {
            var item = await db.MenuItems
                .Where(i => i.StoreId == storeId && i.Name == line.ItemName)
                .OrderBy(i => i.Id)
                .FirstOrDefaultAsync();
            if (item is null) continue;

            result.Add((item, line.Qty <= 0 ? 1 : line.Qty));
        }

        return result;
    }

    private static async Task AddComboLinesAsync(
        AppDbContext db,
        MenuCombo combo,
        IReadOnlyList<(MenuItem Item, int Qty)> lineItems)
    {
        var sort = 0;
        foreach (var (item, qty) in lineItems)
        {
            db.MenuComboItems.Add(new MenuComboItem
            {
                ComboId = combo.Id,
                MenuItemId = item.Id,
                Qty = qty,
                Sort = sort++
            });
        }

        await db.SaveChangesAsync();
    }

    private static async Task<bool> ReplaceComboLinesAsync(
        AppDbContext db,
        MenuCombo combo,
        IReadOnlyList<(MenuItem Item, int Qty)> lineItems)
    {
        var existing = combo.Items
            .OrderBy(i => i.Sort)
            .ThenBy(i => i.Id)
            .Select(i => (i.MenuItemId, i.Qty))
            .ToList();
        var desired = lineItems.Select(l => (l.Item.Id, l.Qty)).ToList();
        if (existing.SequenceEqual(desired))
            return false;

        db.MenuComboItems.RemoveRange(combo.Items);
        await db.SaveChangesAsync();

        var sort = 0;
        foreach (var (item, qty) in lineItems)
        {
            db.MenuComboItems.Add(new MenuComboItem
            {
                ComboId = combo.Id,
                MenuItemId = item.Id,
                Qty = qty,
                Sort = sort++
            });
        }

        return true;
    }

    private static Task ResetIdentitySequenceAsync(AppDbContext db, string table, string column) =>
        table switch
        {
            "users" when column == "id" => db.Database.ExecuteSqlRawAsync(
                "SELECT setval(pg_get_serial_sequence('users', 'id'), GREATEST((SELECT COALESCE(MAX(id), 1) FROM users), 1))"),
            _ => Task.CompletedTask
        };
}

using Microsoft.EntityFrameworkCore;
using OmdServer.Common;
using OmdServer.Data;
using OmdServer.Data.Entities;
using OmdServer.Dtos;

namespace OmdServer.Services;

public class MenuComboService
{
    private readonly AppDbContext _db;
    private readonly StoreAccessService _access;

    public MenuComboService(AppDbContext db, StoreAccessService access)
    {
        _db = db;
        _access = access;
    }

    public async Task<(List<MenuComboDto>? Ok, ApiResponse<object?>? Fail)> ListAsync(long userId, long storeId)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return (null, ApiResponse<object?>.Fail(ApiCodes.NoStorePermission, "无门店权限"));

        var list = await _db.MenuCombos
            .Where(c => c.StoreId == storeId)
            .OrderBy(c => c.Sort)
            .ThenBy(c => c.Id)
            .Select(c => new MenuComboDto(
                c.Id,
                c.Name,
                c.Sort,
                c.Price,
                c.Items.Sum(i => i.Qty)))
            .ToListAsync();

        return (list, null);
    }

    public async Task<(MenuComboDetailDto? Ok, ApiResponse<object?>? Fail)> GetDetailAsync(
        long userId,
        long storeId,
        long comboId)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return (null, ApiResponse<object?>.Fail(ApiCodes.NoStorePermission, "无门店权限"));

        var combo = await _db.MenuCombos
            .AsNoTracking()
            .FirstOrDefaultAsync(c => c.Id == comboId && c.StoreId == storeId);
        if (combo is null)
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "套餐不存在"));

        var items = await _db.MenuComboItems
            .AsNoTracking()
            .Where(ci => ci.ComboId == comboId)
            .OrderBy(ci => ci.Sort)
            .ThenBy(ci => ci.Id)
            .Select(ci => new MenuComboItemDto(
                ci.MenuItem.Id,
                ci.MenuItem.CategoryId,
                ci.MenuItem.Category.Name,
                ci.MenuItem.Name,
                ci.MenuItem.Price,
                ci.MenuItem.Status,
                ci.Qty))
            .ToListAsync();

        return (new MenuComboDetailDto(combo.Id, combo.Name, combo.Price, items), null);
    }

    public async Task<(MenuComboDetailDto? Ok, ApiResponse<MenuComboDetailDto>? Fail)> SaveAsync(
        long userId,
        long storeId,
        SaveMenuComboRequest request)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return (null, ApiResponse<MenuComboDetailDto>.Fail(ApiCodes.NoStorePermission, "无门店权限"));

        var name = request.Name?.Trim() ?? "";
        if (string.IsNullOrWhiteSpace(name))
            return (null, ApiResponse<MenuComboDetailDto>.Fail(ApiCodes.InvalidParams, "套餐名称不能为空"));

        if (request.Price < 0)
            return (null, ApiResponse<MenuComboDetailDto>.Fail(ApiCodes.InvalidParams, "套餐价格无效"));

        var entries = NormalizeComboItems(request);
        if (entries.Any(e => e.Qty < 1))
            return (null, ApiResponse<MenuComboDetailDto>.Fail(ApiCodes.InvalidParams, "菜品份数至少为 1"));

        MenuCombo combo;
        var isUpdate = request.Id is > 0;
        if (!isUpdate)
        {
            if (await _db.MenuCombos.AnyAsync(c => c.StoreId == storeId && c.Name == name))
                return (null, ApiResponse<MenuComboDetailDto>.Fail(ApiCodes.InvalidParams, "套餐名称已存在"));

            combo = new MenuCombo
            {
                StoreId = storeId,
                Name = name,
                Sort = 0,
                Price = request.Price,
                CreatedAt = DateTimeHelper.UtcNow
            };
            _db.MenuCombos.Add(combo);

            try
            {
                await _db.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                return (null, ApiResponse<MenuComboDetailDto>.Fail(ApiCodes.InvalidParams, "套餐名称已存在"));
            }
        }
        else
        {
            var existing = await _db.MenuCombos
                .Include(c => c.Items)
                .FirstOrDefaultAsync(c => c.Id == request.Id && c.StoreId == storeId);
            if (existing is null)
                return (null, ApiResponse<MenuComboDetailDto>.Fail(ApiCodes.InvalidParams, "套餐不存在"));

            combo = existing;

            if (await _db.MenuCombos.AnyAsync(c =>
                    c.StoreId == storeId && c.Name == name && c.Id != combo.Id))
                return (null, ApiResponse<MenuComboDetailDto>.Fail(ApiCodes.InvalidParams, "套餐名称已存在"));

            combo.Name = name;
            combo.Price = request.Price;
        }

        if (isUpdate || entries.Count > 0)
        {
            var replaceFail = await ReplaceComboItemsAsync(combo, storeId, entries);
            if (replaceFail is not null)
                return (null, replaceFail);
        }

        try
        {
            await _db.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            return (null, ApiResponse<MenuComboDetailDto>.Fail(ApiCodes.InvalidParams, "套餐名称已存在"));
        }

        var (detail, fail) = await GetDetailAsync(userId, storeId, combo.Id);
        if (fail is not null)
            return (null, ApiResponse<MenuComboDetailDto>.Fail(fail.Code, fail.Message));
        return (detail, null);
    }

    public async Task<ApiResponse<object?>?> RemoveAsync(long userId, long storeId, RemoveMenuComboRequest request)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return ApiResponse<object?>.Fail(ApiCodes.NoStorePermission, "无门店权限");

        var combo = await _db.MenuCombos
            .FirstOrDefaultAsync(c => c.Id == request.ComboId && c.StoreId == storeId);
        if (combo is null)
            return ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "套餐不存在");

        _db.MenuCombos.Remove(combo);
        await _db.SaveChangesAsync();
        return null;
    }

    static List<SaveMenuComboItemEntry> NormalizeComboItems(SaveMenuComboRequest request)
    {
        if (request.Items is { Count: > 0 })
        {
            return request.Items
                .GroupBy(i => i.ItemId)
                .Select(g => new SaveMenuComboItemEntry(g.Key, g.Last().Qty < 1 ? 1 : g.Last().Qty))
                .ToList();
        }

        return request.ItemIds?
            .Distinct()
            .Select(id => new SaveMenuComboItemEntry(id, 1))
            .ToList() ?? [];
    }

    static List<SaveMenuComboItemEntry> NormalizeComboItems(SaveMenuComboContentRequest request)
    {
        if (request.Items is { Count: > 0 })
        {
            return request.Items
                .GroupBy(i => i.ItemId)
                .Select(g => new SaveMenuComboItemEntry(g.Key, g.Last().Qty < 1 ? 1 : g.Last().Qty))
                .ToList();
        }

        return request.ItemIds?
            .Distinct()
            .Select(id => new SaveMenuComboItemEntry(id, 1))
            .ToList() ?? [];
    }

    async Task<ApiResponse<MenuComboDetailDto>?> ReplaceComboItemsAsync(
        MenuCombo combo,
        long storeId,
        List<SaveMenuComboItemEntry> entries)
    {
        if (entries.Count > 0)
        {
            var itemIds = entries.Select(e => e.ItemId).ToList();
            var validItemIds = await _db.MenuItems
                .Where(i => i.StoreId == storeId && itemIds.Contains(i.Id))
                .Select(i => i.Id)
                .ToListAsync();
            if (validItemIds.Count != itemIds.Count)
                return ApiResponse<MenuComboDetailDto>.Fail(ApiCodes.InvalidParams, "包含无效菜品");
        }

        if (combo.Items.Count > 0)
            _db.MenuComboItems.RemoveRange(combo.Items);

        var sort = 0;
        foreach (var entry in entries)
        {
            _db.MenuComboItems.Add(new MenuComboItem
            {
                ComboId = combo.Id,
                MenuItemId = entry.ItemId,
                Qty = entry.Qty < 1 ? 1 : entry.Qty,
                Sort = sort++
            });
        }

        return null;
    }

    public async Task<(MenuComboDetailDto? Ok, ApiResponse<MenuComboDetailDto>? Fail)> SaveContentAsync(
        long userId,
        long storeId,
        long comboId,
        SaveMenuComboContentRequest request)
    {
        var combo = await _db.MenuCombos
            .AsNoTracking()
            .FirstOrDefaultAsync(c => c.Id == comboId && c.StoreId == storeId);
        if (combo is null)
            return (null, ApiResponse<MenuComboDetailDto>.Fail(ApiCodes.InvalidParams, "套餐不存在"));

        var entries = NormalizeComboItems(request);
        return await SaveAsync(
            userId,
            storeId,
            new SaveMenuComboRequest(comboId, combo.Name, request.Price, null, entries));
    }
}

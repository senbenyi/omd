using Microsoft.EntityFrameworkCore;
using OmdServer.Common;
using OmdServer.Data.Entities;

namespace OmdServer.Data;

public static class DbSeed
{
    public static async Task SeedAsync(AppDbContext db)
    {
        await db.Database.EnsureCreatedAsync();
        await ApplyStoreSchemaPatchesAsync(db);
        await ApplyMenuSchemaPatchesAsync(db);

        if (!await db.Users.AnyAsync())
        {
        var user = new User
        {
            Phone = "13800138000",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("abc123456"),
            Username = "王老板",
            CreatedAt = DateTime.UtcNow
        };
        db.Users.Add(user);
        await db.SaveChangesAsync();

        var store = new Store
        {
            OwnerUserId = user.Id,
            Name = "老王牛肉面（人民路店）",
            Status = "open",
            Address = "东京都台东区上野 1-2-3",
            Phone = "03-1234-5678",
            ContactName = "王小明",
            IsOpen24Hours = false,
            BusinessOpenTime = TimeOfDayMsHelper.DefaultOpenMs,
            BusinessCloseTime = TimeOfDayMsHelper.DefaultCloseMs,
            ClosedWeekdays = new List<int> { 2 },
            ServiceExpireAt = new DateTime(2027, 12, 31, 23, 59, 59, DateTimeKind.Utc),
            VipLevel = 2,
            ReferrerId = "80001",
            AdditionalPeriod = 30,
            CreatedAt = DateTime.UtcNow
        };
        db.Stores.Add(store);
        await db.SaveChangesAsync();

        var category = new MenuCategory
        {
            StoreId = store.Id,
            Name = "招牌热菜",
            Sort = 10,
            CreatedAt = DateTime.UtcNow
        };
        db.MenuCategories.Add(category);
        await db.SaveChangesAsync();

        var now = DateTime.UtcNow;
        db.MenuItems.Add(new MenuItem
        {
            StoreId = store.Id,
            CategoryId = category.Id,
            Name = "秘制红烧牛肉面",
            Description = "每日现熬牛骨汤",
            Price = 3800,
            SpicyLevel = 1,
            Stock = -1,
            Status = "on_sale",
            Sort = 100,
            Tags = new List<string> { "招牌" },
            CreatedAt = now,
            UpdatedAt = now
        });
        await db.SaveChangesAsync();
        }

        await TasteLibrarySeed.SeedAsync(db);
    }

    private static async Task ApplyStoreSchemaPatchesAsync(AppDbContext db)
    {
        await db.Database.ExecuteSqlRawAsync("""
            ALTER TABLE stores ADD COLUMN IF NOT EXISTS is_open_24_hours BOOLEAN NOT NULL DEFAULT FALSE;
            ALTER TABLE stores ADD COLUMN IF NOT EXISTS business_open_time TIME NOT NULL DEFAULT '09:00';
            ALTER TABLE stores ADD COLUMN IF NOT EXISTS business_close_time TIME NOT NULL DEFAULT '22:00';
            ALTER TABLE stores ADD COLUMN IF NOT EXISTS closed_weekdays JSONB NOT NULL DEFAULT '[]';
            """);

        await db.Database.ExecuteSqlRawAsync("""
            DO $$
            BEGIN
                IF EXISTS (
                    SELECT 1
                    FROM information_schema.columns
                    WHERE table_name = 'stores'
                      AND column_name = 'business_open_time'
                      AND data_type = 'time without time zone'
                ) THEN
                    ALTER TABLE stores
                        ALTER COLUMN business_open_time DROP DEFAULT,
                        ALTER COLUMN business_open_time TYPE BIGINT
                        USING (
                            (
                                EXTRACT(HOUR FROM business_open_time) * 3600
                                + EXTRACT(MINUTE FROM business_open_time) * 60
                                + EXTRACT(SECOND FROM business_open_time)
                            ) * 1000
                        )::BIGINT,
                        ALTER COLUMN business_open_time SET DEFAULT 32400000;
                END IF;

                IF EXISTS (
                    SELECT 1
                    FROM information_schema.columns
                    WHERE table_name = 'stores'
                      AND column_name = 'business_close_time'
                      AND data_type = 'time without time zone'
                ) THEN
                    ALTER TABLE stores
                        ALTER COLUMN business_close_time DROP DEFAULT,
                        ALTER COLUMN business_close_time TYPE BIGINT
                        USING (
                            (
                                EXTRACT(HOUR FROM business_close_time) * 3600
                                + EXTRACT(MINUTE FROM business_close_time) * 60
                                + EXTRACT(SECOND FROM business_close_time)
                            ) * 1000
                        )::BIGINT,
                        ALTER COLUMN business_close_time SET DEFAULT 79200000;
                END IF;
            END $$;
            """);
    }

    private static async Task ApplyMenuSchemaPatchesAsync(AppDbContext db)
    {
        await db.Database.ExecuteSqlRawAsync("""
            ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS duration_minutes INT NOT NULL DEFAULT 0;
            ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS min_qty INT NOT NULL DEFAULT 1;
            ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS remark TEXT;
            ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS remark_tags JSONB NOT NULL DEFAULT '{{}}';
            ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS sold_out BOOLEAN NOT NULL DEFAULT FALSE;

            CREATE TABLE IF NOT EXISTS menu_tag_groups (
                id              BIGSERIAL PRIMARY KEY,
                owner_user_id   BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                name            VARCHAR(100) NOT NULL,
                sort            INT NOT NULL DEFAULT 0,
                created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                UNIQUE (owner_user_id, name)
            );

            CREATE INDEX IF NOT EXISTS idx_menu_tag_groups_owner ON menu_tag_groups(owner_user_id);

            CREATE TABLE IF NOT EXISTS menu_tag_options (
                id              BIGSERIAL PRIMARY KEY,
                group_id        BIGINT NOT NULL REFERENCES menu_tag_groups(id) ON DELETE CASCADE,
                value           VARCHAR(100) NOT NULL,
                sort            INT NOT NULL DEFAULT 0,
                created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                UNIQUE (group_id, value)
            );

            CREATE INDEX IF NOT EXISTS idx_menu_tag_options_group ON menu_tag_options(group_id);

            CREATE TABLE IF NOT EXISTS menu_combos (
                id              BIGSERIAL PRIMARY KEY,
                store_id        BIGINT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
                name            VARCHAR(100) NOT NULL,
                sort            INT NOT NULL DEFAULT 0,
                created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                UNIQUE (store_id, name)
            );

            CREATE INDEX IF NOT EXISTS idx_menu_combos_store ON menu_combos(store_id);

            ALTER TABLE menu_combos ADD COLUMN IF NOT EXISTS price INT NOT NULL DEFAULT 0;

            CREATE TABLE IF NOT EXISTS menu_combo_items (
                id              BIGSERIAL PRIMARY KEY,
                combo_id        BIGINT NOT NULL REFERENCES menu_combos(id) ON DELETE CASCADE,
                menu_item_id    BIGINT NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
                qty             INT NOT NULL DEFAULT 1,
                sort            INT NOT NULL DEFAULT 0,
                UNIQUE (combo_id, menu_item_id)
            );

            ALTER TABLE menu_combo_items ADD COLUMN IF NOT EXISTS qty INT NOT NULL DEFAULT 1;

            CREATE INDEX IF NOT EXISTS idx_menu_combo_items_combo ON menu_combo_items(combo_id);
            CREATE INDEX IF NOT EXISTS idx_menu_combo_items_item ON menu_combo_items(menu_item_id);
            CREATE INDEX IF NOT EXISTS idx_menu_items_category_sort ON menu_items(category_id, sort);
            """);
    }
}

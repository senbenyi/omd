using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace OmdServer.Data;

/// <summary>
/// 数据库初始化：建表/补丁 + 启动时从 mock/*.json 同步演示数据。
/// </summary>
public static class DbSeed
{
    public static async Task SeedAsync(AppDbContext db, ILogger? logger = null)
    {
        logger?.LogInformation("开始数据库初始化与 Mock 数据同步…");

        await db.Database.EnsureCreatedAsync();
        await ApplyStoreSchemaPatchesAsync(db);
        await ApplyMenuSchemaPatchesAsync(db);
        await ApplyCustomerOrderSchemaPatchesAsync(db);

        await MockRestaurantSeed.SeedAsync(db, logger);

        logger?.LogInformation("数据库初始化与 Mock 数据同步完成");
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

    private static async Task ApplyCustomerOrderSchemaPatchesAsync(AppDbContext db)
    {
        await db.Database.ExecuteSqlRawAsync("""
            CREATE TABLE IF NOT EXISTS customer_orders (
                id              BIGSERIAL PRIMARY KEY,
                store_id        BIGINT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
                table_number    INT NOT NULL,
                total_amount    INT NOT NULL DEFAULT 0,
                status          VARCHAR(20) NOT NULL DEFAULT 'pending',
                remark          TEXT,
                created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                updated_at      TIMESTAMPTZ
            );

            CREATE INDEX IF NOT EXISTS idx_customer_orders_store_created
                ON customer_orders(store_id, created_at DESC);

            CREATE TABLE IF NOT EXISTS customer_order_lines (
                id              BIGSERIAL PRIMARY KEY,
                order_id        BIGINT NOT NULL REFERENCES customer_orders(id) ON DELETE CASCADE,
                line_type       VARCHAR(20) NOT NULL,
                ref_id          BIGINT NOT NULL,
                name            VARCHAR(200) NOT NULL,
                unit_price      INT NOT NULL,
                qty             INT NOT NULL,
                subtotal        INT NOT NULL
            );

            CREATE INDEX IF NOT EXISTS idx_customer_order_lines_order
                ON customer_order_lines(order_id);

            ALTER TABLE customer_orders ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;
            """);
    }
}

-- 完整 PostgreSQL 表结构（与 EF 模型一致，可手工执行）

CREATE TABLE IF NOT EXISTS users (
    id              BIGSERIAL PRIMARY KEY,
    phone           VARCHAR(20) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    username        VARCHAR(100) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS stores (
    id                  BIGSERIAL PRIMARY KEY,
    owner_user_id       BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name                VARCHAR(200) NOT NULL,
    status              VARCHAR(20) NOT NULL DEFAULT 'rest',
    address             VARCHAR(500) NOT NULL,
    phone               VARCHAR(50) NOT NULL,
    contact_name        VARCHAR(100) NOT NULL,
    is_open_24_hours    BOOLEAN NOT NULL DEFAULT FALSE,
    business_open_time  TIME NOT NULL DEFAULT '09:00',
    business_close_time TIME NOT NULL DEFAULT '22:00',
    closed_weekdays     JSONB NOT NULL DEFAULT '[]',
    service_expire_at   TIMESTAMPTZ NOT NULL,
    vip_level           INT NOT NULL DEFAULT 1,
    referrer_id         VARCHAR(50),
    additional_period   INT NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_stores_owner ON stores(owner_user_id);

CREATE TABLE IF NOT EXISTS menu_categories (
    id          BIGSERIAL PRIMARY KEY,
    store_id    BIGINT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    name        VARCHAR(100) NOT NULL,
    sort        INT NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (store_id, name)
);

CREATE INDEX IF NOT EXISTS idx_menu_categories_store ON menu_categories(store_id);

CREATE TABLE IF NOT EXISTS menu_items (
    id              BIGSERIAL PRIMARY KEY,
    store_id        BIGINT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    category_id     BIGINT NOT NULL REFERENCES menu_categories(id) ON DELETE RESTRICT,
    name            VARCHAR(200) NOT NULL,
    description     TEXT,
    price           INT NOT NULL,
    original_price  INT,
    unit            VARCHAR(20) NOT NULL DEFAULT '份',
    image_url       VARCHAR(1000),
    tags            JSONB NOT NULL DEFAULT '[]',
    spicy_level     INT NOT NULL DEFAULT 0,
    stock           INT NOT NULL DEFAULT -1,
    status          VARCHAR(20) NOT NULL DEFAULT 'off_sale',
    sort            INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_menu_items_store ON menu_items(store_id);
CREATE INDEX IF NOT EXISTS idx_menu_items_category ON menu_items(category_id);
CREATE INDEX IF NOT EXISTS idx_menu_items_status ON menu_items(store_id, status);
CREATE INDEX IF NOT EXISTS idx_menu_items_category_sort ON menu_items(category_id, sort);

-- 扩展字段（与 DbSeed.ApplyMenuSchemaPatchesAsync 一致）
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS duration_minutes INT NOT NULL DEFAULT 0;
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS min_qty INT NOT NULL DEFAULT 1;
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS remark TEXT;
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS remark_tags JSONB NOT NULL DEFAULT '{}';
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
    price           INT NOT NULL DEFAULT 0,
    sort            INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (store_id, name)
);

CREATE INDEX IF NOT EXISTS idx_menu_combos_store ON menu_combos(store_id);

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

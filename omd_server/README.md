# 餐饮店菜单管理服务端

基于 `omd_api.openapi.yaml` 实现的 **ASP.NET Core 8 + PostgreSQL** API。

## 技术栈

- C# / ASP.NET Core 8
- Entity Framework Core + Npgsql
- JWT Bearer 鉴权
- 统一响应：`{ "code", "message", "data" }`

## 项目结构

```
omd_server/
├── omd_api.openapi.yaml    # API 契约
├── docker-compose.yml      # PostgreSQL
├── scripts/init.sql
├── OmdServer.sln
└── src/OmdServer/
    ├── Controllers/        # 接口层
    ├── Services/           # 业务逻辑
    ├── Data/               # EF 实体与 DbContext
    └── Dtos/               # 请求/响应模型
```

## 快速启动

### 1. 数据库

**本机已有 PostgreSQL（推荐）**：项目已创建库 `omd_restaurant`、用户 `omd` / `omd_secret`。

```bash
brew services start postgresql@16   # 若未运行
```

或使用 Docker：`docker compose up -d`

### 2. .NET 8 SDK

若未安装全局 `dotnet`，可用官方脚本安装到用户目录（无需 sudo）：

```bash
curl -sSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 8.0
export PATH="$HOME/.dotnet:$PATH"
```

### 3. 运行 API

```bash
./scripts/start.sh
# 或
export PATH="$HOME/.dotnet:$PATH"
cd src/OmdServer && dotnet run
```

- Swagger: http://localhost:5080/swagger
- Base URL: `http://localhost:5080/restaurant/v1`

### 3. 演示账号

| 手机号 | 密码 |
|--------|------|
| `13800138000` | `abc123456` |

首次启动会自动 `EnsureCreated` 并写入演示用户、门店、分类、菜品。

## 已实现接口

| 方法 | 路径 |
|------|------|
| GET | `/restaurant/v1/app/config` |
| POST | `/restaurant/v1/auth/login` |
| POST | `/restaurant/v1/auth/register` |
| GET | `/restaurant/v1/stores` |
| GET | `/restaurant/v1/stores/{storeId}` |
| POST | `/restaurant/v1/stores/save` |
| GET | `/restaurant/v1/stores/{storeId}/menu/categories` |
| POST | `/restaurant/v1/stores/{storeId}/menu/categories/save` |
| POST | `/restaurant/v1/stores/{storeId}/menu/categories/remove` |
| GET | `/restaurant/v1/stores/{storeId}/menu/items` |
| GET | `/restaurant/v1/stores/{storeId}/menu/items/{itemId}` |
| POST | `/restaurant/v1/stores/{storeId}/menu/items/save` |
| POST | `/restaurant/v1/stores/{storeId}/menu/items/remove` |
| POST | `/restaurant/v1/stores/{storeId}/menu/items/status` |
| POST | `/restaurant/v1/stores/{storeId}/menu/items/sort` |

## 业务错误码

| code | 说明 |
|------|------|
| `0` | 成功 |
| `1001` | 参数错误 |
| `1002` | Token 失效 |
| `4001` | 分类下有菜不可删 |
| `4002` | 上架中不可删 |
| `4010` | 无门店权限 |

## 配置

`src/OmdServer/appsettings.json`：

- `ConnectionStrings:Default` — PostgreSQL 连接串
- `Jwt` — 签发 Token 的密钥与过期时间
- `AppConfig` — `/app/config` 返回的全局配置

## 生产建议

1. 将 `Jwt:Secret` 改为足够长的随机密钥并放入环境变量。
2. 使用 `dotnet ef migrations add InitialCreate` 替代 `EnsureCreated`。

## 示例请求

```bash
# 登录
curl -s -X POST http://localhost:5080/restaurant/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"13800138000","password":"abc123456"}'

# 门店列表（替换 TOKEN）
curl -s http://localhost:5080/restaurant/v1/stores \
  -H "Authorization: Bearer TOKEN"
```

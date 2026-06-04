# OMD

单体仓库：服务端与 Flutter 客户端同仓维护。

| 目录 | 说明 |
|------|------|
| `omd_server/` | ASP.NET Core 后端 |
| `omd_app/` | Flutter / Melos 多端应用（含商家端 `apps/store`） |
| `omd_api.openapi.yaml` | API 契约（根目录副本，与 app 内定义保持同步） |

## Git

仅使用本仓库根目录的远程地址（`origin`），不要在 `omd_app/` 下再初始化独立 Git 仓库。

```bash
cd /Users/tom/Documents/work/omd
git status
git push origin dev
```

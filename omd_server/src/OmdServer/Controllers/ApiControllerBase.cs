using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using OmdServer.Common;
using OmdServer.Services;

namespace OmdServer.Controllers;

[ApiController]
public abstract class ApiControllerBase : ControllerBase
{
    protected long? CurrentUserId =>
        HttpContext.RequestServices.GetRequiredService<IJwtTokenService>()
            .GetUserIdFromClaims(User);

    /// <summary>Demo：路由中的 storeId 仅保留兼容，实际固定为默认门店。</summary>
    protected static long DemoStoreId(long _) => DemoConstants.DefaultStoreId;
}

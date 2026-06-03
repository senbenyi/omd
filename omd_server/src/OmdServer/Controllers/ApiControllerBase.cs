using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using OmdServer.Services;

namespace OmdServer.Controllers;

[ApiController]
public abstract class ApiControllerBase : ControllerBase
{
    protected long? CurrentUserId =>
        HttpContext.RequestServices.GetRequiredService<IJwtTokenService>()
            .GetUserIdFromClaims(User);
}

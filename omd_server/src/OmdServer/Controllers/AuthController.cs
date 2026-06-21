using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OmdServer.Common;
using OmdServer.Dtos;
using OmdServer.Services;

namespace OmdServer.Controllers;

[Route("restaurant/v1/auth")]
public class AuthController : ApiControllerBase
{
    private readonly AuthService _auth;

    public AuthController(AuthService auth) => _auth = auth;

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<LoginResponse>>> Login([FromBody] LoginRequest request)
    {
        var (ok, fail) = await _auth.LoginAsync(request);
        if (fail is not null) return Ok(fail);
        return Ok(ok);
    }

    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<LoginResponse>>> Register([FromBody] RegisterRequest request)
    {
        var (ok, fail) = await _auth.RegisterAsync(request);
        if (fail is not null) return Ok(fail);
        return Ok(ok);
    }

    /// <summary>获取当前登录用户的注册与账号信息。</summary>
    [HttpGet("me")]
    [Authorize]
    public async Task<ActionResult<ApiResponse<UserProfileDto>>> Me()
    {
        var userId = CurrentUserId;
        if (userId is null)
            return Ok(ApiResponse<UserProfileDto>.Fail(ApiCodes.TokenInvalid, "Token 失效"));

        var (ok, fail) = await _auth.GetProfileAsync(userId.Value);
        if (fail is not null) return Ok(fail);
        return Ok(ok);
    }
}

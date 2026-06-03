using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OmdServer.Common;
using OmdServer.Dtos;
using OmdServer.Services;

namespace OmdServer.Controllers;

[Route("restaurant/v1/auth")]
public class AuthController : ControllerBase
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
}

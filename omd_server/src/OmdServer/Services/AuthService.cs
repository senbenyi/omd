using Microsoft.EntityFrameworkCore;
using OmdServer.Common;
using OmdServer.Data;
using OmdServer.Dtos;

namespace OmdServer.Services;

public class AuthService
{
    private readonly AppDbContext _db;
    private readonly IJwtTokenService _jwt;

    public AuthService(AppDbContext db, IJwtTokenService jwt)
    {
        _db = db;
        _jwt = jwt;
    }

    public async Task<(ApiResponse<LoginResponse>? Ok, ApiResponse<LoginResponse>? Fail)> LoginAsync(LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Phone))
            return (null, ApiResponse<LoginResponse>.Fail(ApiCodes.InvalidParams, "手机号不能为空"));

        if (string.IsNullOrEmpty(request.Password))
            return (null, ApiResponse<LoginResponse>.Fail(ApiCodes.InvalidParams, "密码不能为空"));

        var user = await _db.Users.FirstOrDefaultAsync(u => u.Phone == request.Phone);
        if (user is null)
            return (null, ApiResponse<LoginResponse>.Fail(ApiCodes.InvalidParams, "用户不存在"));

        if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            return (null, ApiResponse<LoginResponse>.Fail(ApiCodes.InvalidParams, "密码错误"));

        return (BuildLoginResponse(user), null);
    }

    public async Task<(ApiResponse<LoginResponse>? Ok, ApiResponse<LoginResponse>? Fail)> RegisterAsync(RegisterRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Phone))
            return (null, ApiResponse<LoginResponse>.Fail(ApiCodes.InvalidParams, "手机号不能为空"));

        if (string.IsNullOrEmpty(request.Password))
            return (null, ApiResponse<LoginResponse>.Fail(ApiCodes.InvalidParams, "密码不能为空"));

        if (request.Password.Length < 6)
            return (null, ApiResponse<LoginResponse>.Fail(ApiCodes.InvalidParams, "密码至少 6 位"));

        if (await _db.Users.AnyAsync(u => u.Phone == request.Phone))
            return (null, ApiResponse<LoginResponse>.Fail(ApiCodes.InvalidParams, "该手机号已注册"));

        var username = string.IsNullOrWhiteSpace(request.Username)
            ? $"用户{request.Phone[^4..]}"
            : request.Username.Trim();

        var user = new Data.Entities.User
        {
            Phone = request.Phone.Trim(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            Username = username,
            CreatedAt = DateTime.UtcNow
        };
        _db.Users.Add(user);
        await _db.SaveChangesAsync();

        await TasteLibrarySeed.SeedForUserAsync(_db, user.Id);

        return (BuildLoginResponse(user), null);
    }

    private ApiResponse<LoginResponse> BuildLoginResponse(Data.Entities.User user)
    {
        var token = _jwt.GenerateToken(user);
        var response = new LoginResponse(
            token,
            user.Id.ToString(),
            user.Username,
            PhoneMaskHelper.Mask(user.Phone));
        return ApiResponse<LoginResponse>.Ok(response);
    }
}

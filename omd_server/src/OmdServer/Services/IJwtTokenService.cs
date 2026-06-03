using OmdServer.Data.Entities;

namespace OmdServer.Services;

public interface IJwtTokenService
{
    string GenerateToken(User user);
    long? GetUserIdFromClaims(System.Security.Claims.ClaimsPrincipal user);
}

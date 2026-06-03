namespace OmdServer.Options;

public class JwtOptions
{
    public const string SectionName = "Jwt";
    public string Secret { get; set; } = "OmdRestaurantDevSecretKey_ChangeInProduction_32chars!";
    public string Issuer { get; set; } = "omd-restaurant";
    public string Audience { get; set; } = "omd-app";
    public int ExpirationHours { get; set; } = 168;
}

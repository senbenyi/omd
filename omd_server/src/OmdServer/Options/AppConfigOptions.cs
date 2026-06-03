namespace OmdServer.Options;

public class AppConfigOptions
{
    public const string SectionName = "AppConfig";
    public string CustomerServicePhone { get; set; } = "400-800-1234";
    public string ImageDomain { get; set; } = "https://cdn.offergo.com";
    public string OfficialWebsite { get; set; } = "https://www.offergo.com";
    public string CustomerServiceEmail { get; set; } = "support@offergo.com";
    public string TechnicalSupportPhone { get; set; } = "400-800-5678";
}

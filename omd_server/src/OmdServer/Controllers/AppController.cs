using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using OmdServer.Common;
using OmdServer.Dtos;
using OmdServer.Options;

namespace OmdServer.Controllers;

[Route("restaurant/v1/app")]
public class AppController : ControllerBase
{
    private readonly AppConfigOptions _config;

    public AppController(IOptions<AppConfigOptions> config) => _config = config.Value;

    [HttpGet("config")]
    [AllowAnonymous]
    public ActionResult<ApiResponse<AppConfigDto>> GetConfig()
    {
        var dto = new AppConfigDto(
            _config.CustomerServicePhone,
            _config.ImageDomain,
            _config.OfficialWebsite,
            _config.CustomerServiceEmail,
            _config.TechnicalSupportPhone);
        return Ok(ApiResponse<AppConfigDto>.Ok(dto));
    }
}

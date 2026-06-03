using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OmdServer.Common;
using OmdServer.Dtos;
using OmdServer.Services;

namespace OmdServer.Controllers;

[Route("restaurant/v1/menu/tag-library")]
[Authorize]
public class MenuTagLibraryController : ApiControllerBase
{
    private readonly MenuTagLibraryService _service;

    public MenuTagLibraryController(MenuTagLibraryService service) => _service = service;

    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<MenuTagGroupDto>>>> List()
    {
        var userId = CurrentUserId;
        if (userId is null)
            return Ok(ApiResponse<List<MenuTagGroupDto>>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var list = await _service.ListAsync(userId.Value);
        return Ok(ApiResponse<List<MenuTagGroupDto>>.Ok(list));
    }

    [HttpPost("groups/save")]
    public async Task<ActionResult<ApiResponse<MenuTagGroupDto>>> SaveGroup(
        [FromBody] SaveMenuTagGroupRequest request)
    {
        var userId = CurrentUserId;
        if (userId is null)
            return Ok(ApiResponse<MenuTagGroupDto>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var (result, fail) = await _service.SaveGroupAsync(userId.Value, request);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<MenuTagGroupDto>.Ok(result));
    }

    [HttpPost("options/save")]
    public async Task<ActionResult<ApiResponse<MenuTagOptionDto>>> SaveOption(
        [FromBody] SaveMenuTagOptionRequest request)
    {
        var userId = CurrentUserId;
        if (userId is null)
            return Ok(ApiResponse<MenuTagOptionDto>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var (result, fail) = await _service.SaveOptionAsync(userId.Value, request);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<MenuTagOptionDto>.Ok(result));
    }
}

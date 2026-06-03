using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OmdServer.Common;
using OmdServer.Dtos;
using OmdServer.Services;

namespace OmdServer.Controllers;

[Route("restaurant/v1/stores/{storeId:long}/menu/combos")]
[Authorize]
public class MenuCombosController : ApiControllerBase
{
    private readonly MenuComboService _service;

    public MenuCombosController(MenuComboService service) => _service = service;

    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<MenuComboDto>>>> List(long storeId)
    {
        var userId = CurrentUserId;
        if (userId is null)
            return Ok(ApiResponse<List<MenuComboDto>>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var (ok, fail) = await _service.ListAsync(userId.Value, storeId);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<List<MenuComboDto>>.Ok(ok));
    }

    [HttpGet("{comboId:long}")]
    public async Task<ActionResult<ApiResponse<MenuComboDetailDto>>> Detail(long storeId, long comboId)
    {
        var userId = CurrentUserId;
        if (userId is null)
            return Ok(ApiResponse<MenuComboDetailDto>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var (ok, fail) = await _service.GetDetailAsync(userId.Value, storeId, comboId);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<MenuComboDetailDto>.Ok(ok));
    }

    [HttpPost("save")]
    public async Task<ActionResult<ApiResponse<MenuComboDetailDto>>> Save(
        long storeId,
        [FromBody] SaveMenuComboRequest request)
    {
        var userId = CurrentUserId;
        if (userId is null)
            return Ok(ApiResponse<MenuComboDetailDto>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var (ok, fail) = await _service.SaveAsync(userId.Value, storeId, request);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<MenuComboDetailDto>.Ok(ok));
    }

    [HttpPost("{comboId:long}/save-content")]
    public async Task<ActionResult<ApiResponse<MenuComboDetailDto>>> SaveContent(
        long storeId,
        long comboId,
        [FromBody] SaveMenuComboContentRequest request)
    {
        var userId = CurrentUserId;
        if (userId is null)
            return Ok(ApiResponse<MenuComboDetailDto>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var (ok, fail) = await _service.SaveContentAsync(userId.Value, storeId, comboId, request);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<MenuComboDetailDto>.Ok(ok));
    }

    [HttpPost("remove")]
    public async Task<ActionResult<ApiResponse<object?>>> Remove(
        long storeId,
        [FromBody] RemoveMenuComboRequest request)
    {
        var userId = CurrentUserId;
        if (userId is null)
            return Ok(ApiResponse<object?>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var fail = await _service.RemoveAsync(userId.Value, storeId, request);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<object?>.Ok(null));
    }
}

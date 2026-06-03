using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OmdServer.Common;
using OmdServer.Dtos;
using OmdServer.Services;

namespace OmdServer.Controllers;

[Route("restaurant/v1/stores/{storeId:long}/menu/items")]
[Authorize]
public class MenuItemsController : ApiControllerBase
{
    private readonly MenuItemService _service;

    public MenuItemsController(MenuItemService service) => _service = service;

    [HttpGet]
    public async Task<ActionResult<ApiResponse<PagedListDto<MenuItemListDto>>>> List(
        long storeId,
        [FromQuery] long? categoryId,
        [FromQuery] string? status,
        [FromQuery] bool? soldOut,
        [FromQuery] string? keyword,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        var userId = CurrentUserId;
        if (userId is null) return Ok(ApiResponse<PagedListDto<MenuItemListDto>>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var (ok, fail) = await _service.ListAsync(userId.Value, storeId, categoryId, status, soldOut, keyword, page, pageSize);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<PagedListDto<MenuItemListDto>>.Ok(ok));
    }

    [HttpGet("{itemId:long}")]
    public async Task<ActionResult<ApiResponse<MenuItemDetailDto>>> Detail(long storeId, long itemId)
    {
        var userId = CurrentUserId;
        if (userId is null) return Ok(ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var (ok, fail) = await _service.GetDetailAsync(userId.Value, storeId, itemId);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<MenuItemDetailDto>.Ok(ok));
    }

    [HttpPost("save")]
    public async Task<ActionResult<ApiResponse<MenuItemDetailDto>>> Save(long storeId, [FromBody] SaveMenuItemRequest request)
    {
        var userId = CurrentUserId;
        if (userId is null) return Ok(ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var (ok, fail) = await _service.SaveAsync(userId.Value, storeId, request);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<MenuItemDetailDto>.Ok(ok));
    }

    [HttpPost("remove")]
    public async Task<ActionResult<ApiResponse<object?>>> Remove(long storeId, [FromBody] RemoveMenuItemRequest request)
    {
        var userId = CurrentUserId;
        if (userId is null) return Ok(ApiResponse<object?>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var result = await _service.RemoveAsync(userId.Value, storeId, request);
        return Ok(result);
    }

    [HttpPost("status")]
    public async Task<ActionResult<ApiResponse<MenuItemDetailDto>>> UpdateStatus(
        long storeId, [FromBody] UpdateMenuItemStatusRequest request)
    {
        var userId = CurrentUserId;
        if (userId is null) return Ok(ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var (ok, fail) = await _service.UpdateStatusAsync(userId.Value, storeId, request);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<MenuItemDetailDto>.Ok(ok));
    }

    [HttpPost("sold-out")]
    public async Task<ActionResult<ApiResponse<MenuItemDetailDto>>> UpdateSoldOut(
        long storeId, [FromBody] UpdateMenuItemSoldOutRequest request)
    {
        var userId = CurrentUserId;
        if (userId is null) return Ok(ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var (ok, fail) = await _service.UpdateSoldOutAsync(userId.Value, storeId, request);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<MenuItemDetailDto>.Ok(ok));
    }

    [HttpPost("sort")]
    public async Task<ActionResult<ApiResponse<object?>>> Sort(long storeId, [FromBody] BatchSortMenuItemsRequest request)
    {
        var userId = CurrentUserId;
        if (userId is null) return Ok(ApiResponse<object?>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var result = await _service.BatchSortAsync(userId.Value, storeId, request);
        return Ok(result);
    }
}

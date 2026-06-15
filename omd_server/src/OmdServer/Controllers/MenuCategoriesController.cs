using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OmdServer.Common;
using OmdServer.Dtos;
using OmdServer.Services;

namespace OmdServer.Controllers;

[Route("restaurant/v1/stores/{storeId:long}/menu/categories")]
[Authorize]
public class MenuCategoriesController : ApiControllerBase
{
    private readonly MenuCategoryService _service;

    public MenuCategoriesController(MenuCategoryService service) => _service = service;

    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<MenuCategoryDto>>>> List(long storeId)
    {
        var userId = CurrentUserId;
        if (userId is null) return Ok(ApiResponse<List<MenuCategoryDto>>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        storeId = DemoStoreId(storeId);
        var (ok, fail) = await _service.ListAsync(userId.Value, storeId);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<List<MenuCategoryDto>>.Ok(ok));
    }

    [HttpPost("save")]
    public async Task<ActionResult<ApiResponse<MenuCategoryDto>>> Save(long storeId, [FromBody] SaveMenuCategoryRequest request)
    {
        var userId = CurrentUserId;
        if (userId is null) return Ok(ApiResponse<MenuCategoryDto>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        storeId = DemoStoreId(storeId);
        var (ok, fail) = await _service.SaveAsync(userId.Value, storeId, request);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<MenuCategoryDto>.Ok(ok));
    }

    [HttpPost("remove")]
    public async Task<ActionResult<ApiResponse<object?>>> Remove(long storeId, [FromBody] RemoveMenuCategoryRequest request)
    {
        var userId = CurrentUserId;
        if (userId is null) return Ok(ApiResponse<object?>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        storeId = DemoStoreId(storeId);
        var result = await _service.RemoveAsync(userId.Value, storeId, request);
        return Ok(result);
    }
}

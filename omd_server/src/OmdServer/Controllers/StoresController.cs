using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OmdServer.Common;
using OmdServer.Dtos;
using OmdServer.Services;

namespace OmdServer.Controllers;

[Route("restaurant/v1/stores")]
[Authorize]
public class StoresController : ApiControllerBase
{
    private readonly StoreService _stores;

    public StoresController(StoreService stores) => _stores = stores;

    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<StoreDto>>>> List()
    {
        var userId = CurrentUserId;
        if (userId is null) return Ok(ApiResponse<List<StoreDto>>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var list = await _stores.ListStoresAsync(userId.Value);
        return Ok(ApiResponse<List<StoreDto>>.Ok(list));
    }

    [HttpGet("{storeId:long}")]
    public async Task<ActionResult<ApiResponse<StoreDto>>> Get(long storeId)
    {
        var userId = CurrentUserId;
        if (userId is null) return Ok(ApiResponse<StoreDto>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var store = await _stores.GetStoreAsync(userId.Value, storeId);
        if (store is null)
            return Ok(ApiResponse<StoreDto>.Fail(ApiCodes.NoStorePermission, "无门店权限"));
        return Ok(ApiResponse<StoreDto>.Ok(store));
    }

    [HttpPost("save")]
    public async Task<ActionResult<ApiResponse<StoreDto>>> Save([FromBody] SaveStoreRequest request)
    {
        var userId = CurrentUserId;
        if (userId is null) return Ok(ApiResponse<StoreDto>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var (result, fail) = await _stores.SaveStoreAsync(userId.Value, request);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<StoreDto>.Ok(result));
    }

    [HttpDelete("{storeId:long}")]
    public async Task<ActionResult<ApiResponse<object?>>> Delete(long storeId)
    {
        var userId = CurrentUserId;
        if (userId is null) return Ok(ApiResponse<object?>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        var (ok, fail) = await _stores.DeleteStoreAsync(userId.Value, storeId);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<object?>.Ok(null));
    }
}

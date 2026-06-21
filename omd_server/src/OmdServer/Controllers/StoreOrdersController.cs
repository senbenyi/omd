using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OmdServer.Common;
using OmdServer.Dtos;
using OmdServer.Services;

namespace OmdServer.Controllers;

[Route("restaurant/v1/stores/{storeId:long}/orders")]
[Authorize]
public class StoreOrdersController : ApiControllerBase
{
    private readonly CustomerOrderService _orders;

    public StoreOrdersController(CustomerOrderService orders) => _orders = orders;

    [HttpGet]
    public async Task<ActionResult<ApiResponse<PagedListDto<StoreOrderListItemDto>>>> List(
        long storeId,
        [FromQuery] string? status,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        var userId = CurrentUserId;
        if (userId is null)
            return Ok(ApiResponse<PagedListDto<StoreOrderListItemDto>>.Fail(ApiCodes.TokenInvalid, "Token 失效"));

        var (ok, fail) = await _orders.ListStoreOrdersAsync(userId.Value, storeId, status, page, pageSize);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<PagedListDto<StoreOrderListItemDto>>.Ok(ok!));
    }

    [HttpGet("{orderId:long}")]
    public async Task<ActionResult<ApiResponse<CustomerOrderDto>>> Detail(long storeId, long orderId)
    {
        var userId = CurrentUserId;
        if (userId is null)
            return Ok(ApiResponse<CustomerOrderDto>.Fail(ApiCodes.TokenInvalid, "Token 失效"));

        var (ok, fail) = await _orders.GetStoreOrderAsync(userId.Value, storeId, orderId);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<CustomerOrderDto>.Ok(ok!));
    }

    [HttpPost("{orderId:long}/settle")]
    public async Task<ActionResult<ApiResponse<CustomerOrderDto>>> Settle(long storeId, long orderId)
    {
        var userId = CurrentUserId;
        if (userId is null)
            return Ok(ApiResponse<CustomerOrderDto>.Fail(ApiCodes.TokenInvalid, "Token 失效"));

        var (ok, fail) = await _orders.SettleOrderAsync(userId.Value, storeId, orderId);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<CustomerOrderDto>.Ok(ok!));
    }
}

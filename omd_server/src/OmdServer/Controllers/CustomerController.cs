using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OmdServer.Common;
using OmdServer.Dtos;
using OmdServer.Services;

namespace OmdServer.Controllers;

/// <summary>顾客端点餐接口（无需登录）。</summary>
[Route("restaurant/v1/customer/stores/{storeId:long}")]
[AllowAnonymous]
public class CustomerController : ControllerBase
{
    private readonly CustomerMenuService _menu;
    private readonly CustomerOrderService _orders;

    public CustomerController(CustomerMenuService menu, CustomerOrderService orders)
    {
        _menu = menu;
        _orders = orders;
    }

    /// <summary>获取门店全部在售菜品。</summary>
    [HttpGet("menu/items")]
    public async Task<ActionResult<ApiResponse<List<MenuItemListDto>>>> ListItems(long storeId)
    {
        storeId = DemoConstants.DefaultStoreId;
        var (ok, fail) = await _menu.ListItemsAsync(storeId);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<List<MenuItemListDto>>.Ok(ok!));
    }

    /// <summary>获取门店套餐列表。</summary>
    [HttpGet("menu/combos")]
    public async Task<ActionResult<ApiResponse<List<MenuComboDto>>>> ListCombos(long storeId)
    {
        storeId = DemoConstants.DefaultStoreId;
        var (ok, fail) = await _menu.ListCombosAsync(storeId);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<List<MenuComboDto>>.Ok(ok!));
    }

    /// <summary>获取套餐详情。</summary>
    [HttpGet("menu/combos/{comboId:long}")]
    public async Task<ActionResult<ApiResponse<MenuComboDetailDto>>> GetCombo(long storeId, long comboId)
    {
        storeId = DemoConstants.DefaultStoreId;
        var (ok, fail) = await _menu.GetComboDetailAsync(storeId, comboId);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<MenuComboDetailDto>.Ok(ok!));
    }

    /// <summary>提交订单（含桌号）。</summary>
    [HttpPost("orders")]
    public async Task<ActionResult<ApiResponse<CustomerOrderDto>>> CreateOrder(
        long storeId,
        [FromBody] CreateCustomerOrderRequest request)
    {
        storeId = DemoConstants.DefaultStoreId;
        var (ok, fail) = await _orders.CreateOrderAsync(storeId, request);
        if (fail is not null) return Ok(fail);
        return Ok(ApiResponse<CustomerOrderDto>.Ok(ok!));
    }
}

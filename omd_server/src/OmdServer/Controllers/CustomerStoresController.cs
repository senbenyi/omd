using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OmdServer.Common;
using OmdServer.Dtos;
using OmdServer.Services;

namespace OmdServer.Controllers;

/// <summary>顾客端门店列表（无需登录）。</summary>
[Route("restaurant/v1/customer/stores")]
[AllowAnonymous]
public class CustomerStoresController : ControllerBase
{
    private readonly StoreService _stores;

    public CustomerStoresController(StoreService stores) => _stores = stores;

    /// <summary>获取全部可点餐门店。</summary>
    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<CustomerStoreDto>>>> List()
    {
        var list = await _stores.ListCustomerStoresAsync();
        return Ok(ApiResponse<List<CustomerStoreDto>>.Ok(list));
    }
}

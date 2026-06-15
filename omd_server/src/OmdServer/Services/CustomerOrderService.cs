using Microsoft.EntityFrameworkCore;
using OmdServer.Common;
using OmdServer.Data;
using OmdServer.Data.Entities;
using OmdServer.Dtos;

namespace OmdServer.Services;

public class CustomerOrderService
{
    private readonly AppDbContext _db;

    public CustomerOrderService(AppDbContext db) => _db = db;

    public async Task<(CustomerOrderDto? Ok, ApiResponse<object?>? Fail)> CreateOrderAsync(
        long storeId,
        CreateCustomerOrderRequest request)
    {
        if (!await _db.Stores.AnyAsync(s => s.Id == storeId))
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "门店不存在"));

        if (request.TableNumber < 1)
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "桌号无效"));

        if (request.Items is null || request.Items.Count == 0)
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "请选择菜品"));

        var lines = new List<CustomerOrderLine>();
        var lineDtos = new List<CustomerOrderLineDto>();
        var total = 0;

        foreach (var entry in request.Items)
        {
            if (entry.Qty < 1)
                return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "份数至少为 1"));

            var type = entry.Type?.Trim().ToLowerInvariant() ?? "";
            if (type is not ("item" or "combo"))
                return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "无效的订单项类型"));

            string name;
            int unitPrice;

            if (type == "item")
            {
                var item = await _db.MenuItems
                    .AsNoTracking()
                    .FirstOrDefaultAsync(i =>
                        i.Id == entry.Id &&
                        i.StoreId == storeId &&
                        i.Status == "on_sale" &&
                        !i.SoldOut);
                if (item is null)
                    return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, $"菜品不存在或已下架: {entry.Id}"));

                name = item.Name;
                unitPrice = item.Price;
            }
            else
            {
                var combo = await _db.MenuCombos
                    .AsNoTracking()
                    .FirstOrDefaultAsync(c => c.Id == entry.Id && c.StoreId == storeId);
                if (combo is null)
                    return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, $"套餐不存在: {entry.Id}"));

                name = combo.Name;
                unitPrice = combo.Price;
            }

            var subtotal = unitPrice * entry.Qty;
            total += subtotal;
            lines.Add(new CustomerOrderLine
            {
                LineType = type,
                RefId = entry.Id,
                Name = name,
                UnitPrice = unitPrice,
                Qty = entry.Qty,
                Subtotal = subtotal
            });
            lineDtos.Add(new CustomerOrderLineDto(type, entry.Id, name, unitPrice, entry.Qty, subtotal));
        }

        var order = new CustomerOrder
        {
            StoreId = storeId,
            TableNumber = request.TableNumber,
            TotalAmount = total,
            Status = "pending",
            Remark = string.IsNullOrWhiteSpace(request.Remark) ? null : request.Remark.Trim(),
            CreatedAt = DateTime.UtcNow,
            Lines = lines
        };

        _db.CustomerOrders.Add(order);
        await _db.SaveChangesAsync();

        return (new CustomerOrderDto(order.Id, order.TableNumber, order.TotalAmount, order.Status, lineDtos), null);
    }
}

using Microsoft.EntityFrameworkCore;
using OmdServer.Common;
using OmdServer.Data;
using OmdServer.Data.Entities;
using OmdServer.Dtos;

namespace OmdServer.Services;

public class CustomerOrderService
{
    private readonly AppDbContext _db;
    private readonly StoreAccessService _access;

    public CustomerOrderService(AppDbContext db, StoreAccessService access)
    {
        _db = db;
        _access = access;
    }

    public async Task<(CustomerOrderDto? Ok, ApiResponse<object?>? Fail)> SubmitOrderAsync(
        long storeId,
        CreateCustomerOrderRequest request)
    {
        if (request.StoreId is > 0 && request.StoreId.Value != storeId)
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "门店 Id 不匹配"));

        if (request.OrderId is > 0)
            return await AppendOrderAsync(storeId, request.OrderId.Value, request);

        var pending = await FindPendingOrderAsync(storeId, request.TableNumber);
        if (pending is not null)
            return await AppendOrderAsync(storeId, pending.Id, request);

        return await CreateOrderAsync(storeId, request);
    }

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

        var (lines, lineDtos, total, fail) = await ResolveLinesAsync(storeId, request.Items);
        if (fail is not null) return (null, fail);

        var now = DateTime.UtcNow;
        var order = new CustomerOrder
        {
            StoreId = storeId,
            TableNumber = request.TableNumber,
            TotalAmount = total,
            Status = "pending",
            Remark = string.IsNullOrWhiteSpace(request.Remark) ? null : request.Remark.Trim(),
            CreatedAt = now,
            UpdatedAt = now,
            Lines = lines
        };

        _db.CustomerOrders.Add(order);
        await _db.SaveChangesAsync();

        return (MapOrder(order, lineDtos), null);
    }

    public async Task<(CustomerOrderDto? Ok, ApiResponse<object?>? Fail)> AppendOrderAsync(
        long storeId,
        long orderId,
        CreateCustomerOrderRequest request)
    {
        if (request.Items is null || request.Items.Count == 0)
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "请选择菜品"));

        var order = await _db.CustomerOrders
            .Include(o => o.Lines)
            .FirstOrDefaultAsync(o => o.Id == orderId && o.StoreId == storeId);
        if (order is null)
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "订单不存在"));

        if (order.Status != "pending")
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "订单已结算，无法加菜"));

        if (request.TableNumber > 0 && order.TableNumber != request.TableNumber)
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "桌号与订单不匹配"));

        var (newLines, _, _, fail) = await ResolveLinesAsync(storeId, request.Items);
        if (fail is not null) return (null, fail);

        foreach (var newLine in newLines)
        {
            var existing = order.Lines.FirstOrDefault(l =>
                l.LineType == newLine.LineType && l.RefId == newLine.RefId);
            if (existing is null)
            {
                newLine.OrderId = order.Id;
                order.Lines.Add(newLine);
                continue;
            }

            existing.Qty += newLine.Qty;
            existing.Subtotal = existing.UnitPrice * existing.Qty;
        }

        order.TotalAmount = order.Lines.Sum(l => l.Subtotal);
        order.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return (MapOrder(order, order.Lines.Select(MapLine).ToList()), null);
    }

    public async Task<(CustomerOrderDto? Ok, ApiResponse<object?>? Fail)> GetPendingOrderAsync(long storeId, long orderId)
    {
        var order = await _db.CustomerOrders
            .AsNoTracking()
            .Include(o => o.Lines)
            .FirstOrDefaultAsync(o =>
                o.Id == orderId && o.StoreId == storeId && o.Status == "pending");
        if (order is null)
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "订单不存在或已结算"));

        return (MapOrder(order, order.Lines.Select(MapLine).ToList()), null);
    }

    public async Task<(CustomerOrderDto? Ok, ApiResponse<object?>? Fail)> GetOrderAsync(long storeId, long orderId)
    {
        var order = await _db.CustomerOrders
            .AsNoTracking()
            .Include(o => o.Lines)
            .FirstOrDefaultAsync(o => o.Id == orderId && o.StoreId == storeId);
        if (order is null)
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "订单不存在"));

        return (MapOrder(order, order.Lines.Select(MapLine).ToList()), null);
    }

    public async Task<CustomerOrderDto?> GetCurrentOrderAsync(long storeId, int tableNumber) =>
        await GetActiveOrderAsync(storeId, tableNumber);

    public async Task<CustomerOrderDto?> GetActiveOrderAsync(long storeId, int tableNumber)
    {
        if (tableNumber < 1) return null;

        var order = await _db.CustomerOrders
            .AsNoTracking()
            .Include(o => o.Lines)
            .Where(o => o.StoreId == storeId && o.TableNumber == tableNumber && o.Status == "pending")
            .OrderByDescending(o => o.UpdatedAt ?? o.CreatedAt)
            .FirstOrDefaultAsync();

        return order is null ? null : MapOrder(order, order.Lines.Select(MapLine).ToList());
    }

    public async Task<(PagedListDto<StoreOrderListItemDto>? Ok, ApiResponse<object?>? Fail)> ListStoreOrdersAsync(
        long userId,
        long storeId,
        string? status,
        int page,
        int pageSize)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return (null, ApiResponse<object?>.Fail(ApiCodes.NoStorePermission, "无门店权限"));

        page = page < 1 ? 1 : page;
        pageSize = pageSize < 1 ? 20 : Math.Min(pageSize, 100);

        var query = _db.CustomerOrders.AsNoTracking().Where(o => o.StoreId == storeId);
        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(o => o.Status == status.Trim());

        var total = await query.CountAsync();
        var orders = await query
            .OrderByDescending(o => o.UpdatedAt ?? o.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(o => new StoreOrderListItemDto(
                o.Id,
                o.TableNumber,
                o.TotalAmount,
                o.Status,
                DateTimeHelper.FormatDateTime(o.CreatedAt),
                o.Lines.Count))
            .ToListAsync();

        return (new PagedListDto<StoreOrderListItemDto>(orders, new PageMetaDto(page, pageSize, total)), null);
    }

    public async Task<(CustomerOrderDto? Ok, ApiResponse<object?>? Fail)> GetStoreOrderAsync(
        long userId,
        long storeId,
        long orderId)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return (null, ApiResponse<object?>.Fail(ApiCodes.NoStorePermission, "无门店权限"));

        return await GetOrderAsync(storeId, orderId);
    }

    public async Task<(CustomerOrderDto? Ok, ApiResponse<object?>? Fail)> SettleOrderAsync(
        long userId,
        long storeId,
        long orderId)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return (null, ApiResponse<object?>.Fail(ApiCodes.NoStorePermission, "无门店权限"));

        var order = await _db.CustomerOrders
            .Include(o => o.Lines)
            .FirstOrDefaultAsync(o => o.Id == orderId && o.StoreId == storeId);
        if (order is null)
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "订单不存在"));

        if (order.Status == "settled")
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "订单已结算"));

        order.Status = "settled";
        order.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return (MapOrder(order, order.Lines.Select(MapLine).ToList()), null);
    }

    private async Task<CustomerOrder?> FindPendingOrderAsync(long storeId, int tableNumber)
    {
        if (tableNumber < 1) return null;

        return await _db.CustomerOrders
            .Include(o => o.Lines)
            .Where(o => o.StoreId == storeId && o.TableNumber == tableNumber && o.Status == "pending")
            .OrderByDescending(o => o.UpdatedAt ?? o.CreatedAt)
            .FirstOrDefaultAsync();
    }

    private async Task<(List<CustomerOrderLine> Lines, List<CustomerOrderLineDto> Dtos, int Total, ApiResponse<object?>? Fail)>
        ResolveLinesAsync(long storeId, List<CustomerOrderLineRequest> items)
    {
        var lines = new List<CustomerOrderLine>();
        var lineDtos = new List<CustomerOrderLineDto>();
        var total = 0;

        foreach (var entry in items)
        {
            if (entry.Qty < 1)
                return ([], [], 0, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "份数至少为 1"));

            var type = entry.Type?.Trim().ToLowerInvariant() ?? "";
            if (type is not ("item" or "combo"))
                return ([], [], 0, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "无效的订单项类型"));

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
                    return ([], [], 0, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, $"菜品不存在或已下架: {entry.Id}"));

                name = item.Name;
                unitPrice = item.Price;
            }
            else
            {
                var combo = await _db.MenuCombos
                    .AsNoTracking()
                    .FirstOrDefaultAsync(c => c.Id == entry.Id && c.StoreId == storeId);
                if (combo is null)
                    return ([], [], 0, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, $"套餐不存在: {entry.Id}"));

                name = combo.Name;
                unitPrice = combo.Price;
            }

            var subtotal = unitPrice * entry.Qty;
            total += subtotal;
            var line = new CustomerOrderLine
            {
                LineType = type,
                RefId = entry.Id,
                Name = name,
                UnitPrice = unitPrice,
                Qty = entry.Qty,
                Subtotal = subtotal
            };
            lines.Add(line);
            lineDtos.Add(MapLine(line));
        }

        return (lines, lineDtos, total, null);
    }

    private static CustomerOrderLineDto MapLine(CustomerOrderLine line) =>
        new(line.LineType, line.RefId, line.Name, line.UnitPrice, line.Qty, line.Subtotal);

    private static CustomerOrderDto MapOrder(CustomerOrder order, List<CustomerOrderLineDto> lines) =>
        new(
            order.Id,
            order.StoreId,
            order.TableNumber,
            order.TotalAmount,
            order.Status,
            DateTimeHelper.FormatDateTime(order.CreatedAt),
            order.UpdatedAt is null ? null : DateTimeHelper.FormatDateTime(order.UpdatedAt.Value),
            lines);
}

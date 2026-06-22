namespace OmdServer.Dtos;

public record CustomerStoreDto(
    long Id,
    string Name,
    string Status,
    string Address,
    string Phone);

public record CustomerOrderLineRequest(string Type, long Id, int Qty);

public record CreateCustomerOrderRequest(
    int TableNumber,
    string? Remark,
    List<CustomerOrderLineRequest> Items,
    long? OrderId = null);

public record CustomerOrderLineDto(
    string Type,
    long Id,
    string Name,
    int UnitPrice,
    int Qty,
    int Subtotal);

public record CustomerOrderDto(
    long OrderId,
    long StoreId,
    int TableNumber,
    int TotalAmount,
    string Status,
    string CreatedAt,
    string? UpdatedAt,
    List<CustomerOrderLineDto> Items);

public record StoreOrderListItemDto(
    long OrderId,
    int TableNumber,
    int TotalAmount,
    string Status,
    string CreatedAt,
    int ItemCount);

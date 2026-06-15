namespace OmdServer.Dtos;

public record CustomerOrderLineRequest(string Type, long Id, int Qty);

public record CreateCustomerOrderRequest(
    int TableNumber,
    string? Remark,
    List<CustomerOrderLineRequest> Items);

public record CustomerOrderLineDto(
    string Type,
    long Id,
    string Name,
    int UnitPrice,
    int Qty,
    int Subtotal);

public record CustomerOrderDto(
    long OrderId,
    int TableNumber,
    int TotalAmount,
    string Status,
    List<CustomerOrderLineDto> Items);

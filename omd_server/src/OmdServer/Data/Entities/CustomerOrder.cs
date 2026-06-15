namespace OmdServer.Data.Entities;

public class CustomerOrder
{
    public long Id { get; set; }
    public long StoreId { get; set; }
    public int TableNumber { get; set; }
    public int TotalAmount { get; set; }
    public string Status { get; set; } = "pending";
    public string? Remark { get; set; }
    public DateTime CreatedAt { get; set; }

    public Store Store { get; set; } = null!;
    public ICollection<CustomerOrderLine> Lines { get; set; } = new List<CustomerOrderLine>();
}

public class CustomerOrderLine
{
    public long Id { get; set; }
    public long OrderId { get; set; }
    public string LineType { get; set; } = "item";
    public long RefId { get; set; }
    public string Name { get; set; } = "";
    public int UnitPrice { get; set; }
    public int Qty { get; set; }
    public int Subtotal { get; set; }

    public CustomerOrder Order { get; set; } = null!;
}

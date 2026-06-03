namespace OmdServer.Data.Entities;

public class MenuCategory
{
    public long Id { get; set; }
    public long StoreId { get; set; }
    public string Name { get; set; } = string.Empty;
    public int Sort { get; set; }
    public DateTime CreatedAt { get; set; }

    public Store Store { get; set; } = null!;
    public ICollection<MenuItem> Items { get; set; } = new List<MenuItem>();
}

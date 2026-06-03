namespace OmdServer.Data.Entities;

public class MenuCombo
{
    public long Id { get; set; }
    public long StoreId { get; set; }
    public string Name { get; set; } = string.Empty;
    public int Price { get; set; }
    public int Sort { get; set; }
    public DateTime CreatedAt { get; set; }

    public Store Store { get; set; } = null!;
    public ICollection<MenuComboItem> Items { get; set; } = new List<MenuComboItem>();
}

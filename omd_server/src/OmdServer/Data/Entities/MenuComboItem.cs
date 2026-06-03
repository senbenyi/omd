namespace OmdServer.Data.Entities;

public class MenuComboItem
{
    public long Id { get; set; }
    public long ComboId { get; set; }
    public long MenuItemId { get; set; }
    /// <summary>套餐内该菜品份数，默认 1。</summary>
    public int Qty { get; set; } = 1;
    public int Sort { get; set; }

    public MenuCombo Combo { get; set; } = null!;
    public MenuItem MenuItem { get; set; } = null!;
}

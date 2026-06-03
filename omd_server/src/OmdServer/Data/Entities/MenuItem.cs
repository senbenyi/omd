namespace OmdServer.Data.Entities;

public class MenuItem
{
    public long Id { get; set; }
    public long StoreId { get; set; }
    public long CategoryId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int Price { get; set; }
    public int? OriginalPrice { get; set; }
    public string Unit { get; set; } = "份";
    /// <summary>起订份数，默认 1 份。</summary>
    public int MinQty { get; set; } = 1;
    public string? ImageUrl { get; set; }
    public List<string> Tags { get; set; } = new();
    /// <summary>制作/供应时长（分钟）。</summary>
    public int DurationMinutes { get; set; }
    /// <summary>备注说明。</summary>
    public string? Remark { get; set; }
    /// <summary>备注 Tag，如 {"辣度":["少辣","中辣"]}。</summary>
    public Dictionary<string, List<string>> RemarkTags { get; set; } = new();
    public int SpicyLevel { get; set; }
    public int Stock { get; set; } = -1;
    /// <summary>是否售罄。</summary>
    public bool SoldOut { get; set; }
    public string Status { get; set; } = "off_sale";
    public int Sort { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public Store Store { get; set; } = null!;
    public MenuCategory Category { get; set; } = null!;
}

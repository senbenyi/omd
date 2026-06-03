namespace OmdServer.Data.Entities;

public class MenuTagOption
{
    public long Id { get; set; }
    public long GroupId { get; set; }
    public string Value { get; set; } = string.Empty;
    public int Sort { get; set; }
    public DateTime CreatedAt { get; set; }

    public MenuTagGroup Group { get; set; } = null!;
}

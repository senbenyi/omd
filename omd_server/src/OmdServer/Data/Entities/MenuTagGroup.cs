namespace OmdServer.Data.Entities;

public class MenuTagGroup
{
    public long Id { get; set; }
    public long OwnerUserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public int Sort { get; set; }
    public DateTime CreatedAt { get; set; }

    public User Owner { get; set; } = null!;
    public ICollection<MenuTagOption> Options { get; set; } = new List<MenuTagOption>();
}

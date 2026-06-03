namespace OmdServer.Data.Entities;

public class User
{
    public long Id { get; set; }
    public string Phone { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }

    public ICollection<Store> Stores { get; set; } = new List<Store>();
}

using OmdServer.Common;

namespace OmdServer.Data.Entities;

public class Store
{
    public long Id { get; set; }
    public long OwnerUserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Status { get; set; } = "rest";
    public string Address { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string ContactName { get; set; } = string.Empty;
    public bool IsOpen24Hours { get; set; }
    /// <summary>距本地 00:00 的毫秒数。</summary>
    public long BusinessOpenTime { get; set; } = TimeOfDayMsHelper.DefaultOpenMs;
    /// <summary>距本地 00:00 的毫秒数。</summary>
    public long BusinessCloseTime { get; set; } = TimeOfDayMsHelper.DefaultCloseMs;
    public List<int> ClosedWeekdays { get; set; } = new();
    public DateTime ServiceExpireAt { get; set; }
    public int VipLevel { get; set; } = 1;
    public string? ReferrerId { get; set; }
    public int AdditionalPeriod { get; set; }
    public DateTime CreatedAt { get; set; }

    public User Owner { get; set; } = null!;
    public ICollection<MenuCategory> Categories { get; set; } = new List<MenuCategory>();
    public ICollection<MenuItem> MenuItems { get; set; } = new List<MenuItem>();
}

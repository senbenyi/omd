using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using OmdServer.Data.Entities;

namespace OmdServer.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<Store> Stores => Set<Store>();
    public DbSet<MenuCategory> MenuCategories => Set<MenuCategory>();
    public DbSet<MenuItem> MenuItems => Set<MenuItem>();
    public DbSet<MenuTagGroup> MenuTagGroups => Set<MenuTagGroup>();
    public DbSet<MenuTagOption> MenuTagOptions => Set<MenuTagOption>();
    public DbSet<MenuCombo> MenuCombos => Set<MenuCombo>();
    public DbSet<MenuComboItem> MenuComboItems => Set<MenuComboItem>();
    public DbSet<CustomerOrder> CustomerOrders => Set<CustomerOrder>();
    public DbSet<CustomerOrderLine> CustomerOrderLines => Set<CustomerOrderLine>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        var tagsConverter = new ValueConverter<List<string>, string>(
            v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
            v => JsonSerializer.Deserialize<List<string>>(v, (JsonSerializerOptions?)null) ?? new List<string>());

        var tagsComparer = new ValueComparer<List<string>>(
            (a, b) => (a ?? new List<string>()).SequenceEqual(b ?? new List<string>()),
            v => v.Aggregate(0, (h, s) => HashCode.Combine(h, s.GetHashCode())),
            v => v.ToList());

        var remarkTagsConverter = new ValueConverter<Dictionary<string, List<string>>, string>(
            v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
            v => JsonSerializer.Deserialize<Dictionary<string, List<string>>>(v, (JsonSerializerOptions?)null)
                 ?? new Dictionary<string, List<string>>());

        var remarkTagsComparer = new ValueComparer<Dictionary<string, List<string>>>(
            (a, b) => JsonSerializer.Serialize(a ?? new Dictionary<string, List<string>>(), (JsonSerializerOptions?)null)
                      == JsonSerializer.Serialize(b ?? new Dictionary<string, List<string>>(), (JsonSerializerOptions?)null),
            v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null).GetHashCode(),
            v => JsonSerializer.Deserialize<Dictionary<string, List<string>>>(
                JsonSerializer.Serialize(v, (JsonSerializerOptions?)null), (JsonSerializerOptions?)null)
                ?? new Dictionary<string, List<string>>());

        var intListConverter = new ValueConverter<List<int>, string>(
            v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
            v => JsonSerializer.Deserialize<List<int>>(v, (JsonSerializerOptions?)null) ?? new List<int>());

        var intListComparer = new ValueComparer<List<int>>(
            (a, b) => (a ?? new List<int>()).SequenceEqual(b ?? new List<int>()),
            v => v.Aggregate(0, (h, i) => HashCode.Combine(h, i)),
            v => v.ToList());

        modelBuilder.Entity<User>(e =>
        {
            e.ToTable("users");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.Phone).HasColumnName("phone").HasMaxLength(20);
            e.Property(x => x.PasswordHash).HasColumnName("password_hash").HasMaxLength(255);
            e.Property(x => x.Username).HasColumnName("username").HasMaxLength(100);
            e.Property(x => x.CreatedAt).HasColumnName("created_at");
            e.HasIndex(x => x.Phone).IsUnique();
        });

        modelBuilder.Entity<Store>(e =>
        {
            e.ToTable("stores");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.OwnerUserId).HasColumnName("owner_user_id");
            e.Property(x => x.Name).HasColumnName("name").HasMaxLength(200);
            e.Property(x => x.Status).HasColumnName("status").HasMaxLength(20);
            e.Property(x => x.Address).HasColumnName("address").HasMaxLength(500);
            e.Property(x => x.Phone).HasColumnName("phone").HasMaxLength(50);
            e.Property(x => x.ContactName).HasColumnName("contact_name").HasMaxLength(100);
            e.Property(x => x.IsOpen24Hours).HasColumnName("is_open_24_hours");
            e.Property(x => x.BusinessOpenTime).HasColumnName("business_open_time");
            e.Property(x => x.BusinessCloseTime).HasColumnName("business_close_time");
            e.Property(x => x.ClosedWeekdays).HasColumnName("closed_weekdays").HasColumnType("jsonb")
                .HasConversion(intListConverter).Metadata.SetValueComparer(intListComparer);
            e.Property(x => x.ServiceExpireAt).HasColumnName("service_expire_at");
            e.Property(x => x.VipLevel).HasColumnName("vip_level");
            e.Property(x => x.ReferrerId).HasColumnName("referrer_id").HasMaxLength(50);
            e.Property(x => x.AdditionalPeriod).HasColumnName("additional_period");
            e.Property(x => x.CreatedAt).HasColumnName("created_at");
            e.HasOne(x => x.Owner).WithMany(u => u.Stores).HasForeignKey(x => x.OwnerUserId);
        });

        modelBuilder.Entity<MenuCategory>(e =>
        {
            e.ToTable("menu_categories");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.StoreId).HasColumnName("store_id");
            e.Property(x => x.Name).HasColumnName("name").HasMaxLength(100);
            e.Property(x => x.Sort).HasColumnName("sort");
            e.Property(x => x.CreatedAt).HasColumnName("created_at");
            e.HasOne(x => x.Store).WithMany(s => s.Categories).HasForeignKey(x => x.StoreId);
            e.HasIndex(x => new { x.StoreId, x.Name }).IsUnique();
        });

        modelBuilder.Entity<MenuItem>(e =>
        {
            e.ToTable("menu_items");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.StoreId).HasColumnName("store_id");
            e.Property(x => x.CategoryId).HasColumnName("category_id");
            e.Property(x => x.Name).HasColumnName("name").HasMaxLength(200);
            e.Property(x => x.Description).HasColumnName("description");
            e.Property(x => x.Price).HasColumnName("price");
            e.Property(x => x.OriginalPrice).HasColumnName("original_price");
            e.Property(x => x.Unit).HasColumnName("unit").HasMaxLength(20);
            e.Property(x => x.ImageUrl).HasColumnName("image_url").HasMaxLength(1000);
            e.Property(x => x.Tags).HasColumnName("tags").HasColumnType("jsonb")
                .HasConversion(tagsConverter).Metadata.SetValueComparer(tagsComparer);
            e.Property(x => x.DurationMinutes).HasColumnName("duration_minutes");
            e.Property(x => x.MinQty).HasColumnName("min_qty");
            e.Property(x => x.Remark).HasColumnName("remark");
            e.Property(x => x.RemarkTags).HasColumnName("remark_tags").HasColumnType("jsonb")
                .HasConversion(remarkTagsConverter).Metadata.SetValueComparer(remarkTagsComparer);
            e.Property(x => x.SpicyLevel).HasColumnName("spicy_level");
            e.Property(x => x.Stock).HasColumnName("stock");
            e.Property(x => x.SoldOut).HasColumnName("sold_out");
            e.Property(x => x.Status).HasColumnName("status").HasMaxLength(20);
            e.Property(x => x.Sort).HasColumnName("sort");
            e.Property(x => x.CreatedAt).HasColumnName("created_at");
            e.Property(x => x.UpdatedAt).HasColumnName("updated_at");
            e.HasOne(x => x.Store).WithMany(s => s.MenuItems).HasForeignKey(x => x.StoreId);
            e.HasOne(x => x.Category).WithMany(c => c.Items).HasForeignKey(x => x.CategoryId);
        });

        modelBuilder.Entity<MenuTagGroup>(e =>
        {
            e.ToTable("menu_tag_groups");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.OwnerUserId).HasColumnName("owner_user_id");
            e.Property(x => x.Name).HasColumnName("name").HasMaxLength(100);
            e.Property(x => x.Sort).HasColumnName("sort");
            e.Property(x => x.CreatedAt).HasColumnName("created_at");
            e.HasOne(x => x.Owner).WithMany().HasForeignKey(x => x.OwnerUserId);
            e.HasIndex(x => new { x.OwnerUserId, x.Name }).IsUnique();
        });

        modelBuilder.Entity<MenuTagOption>(e =>
        {
            e.ToTable("menu_tag_options");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.GroupId).HasColumnName("group_id");
            e.Property(x => x.Value).HasColumnName("value").HasMaxLength(100);
            e.Property(x => x.Sort).HasColumnName("sort");
            e.Property(x => x.CreatedAt).HasColumnName("created_at");
            e.HasOne(x => x.Group).WithMany(g => g.Options).HasForeignKey(x => x.GroupId);
            e.HasIndex(x => new { x.GroupId, x.Value }).IsUnique();
        });

        modelBuilder.Entity<MenuCombo>(e =>
        {
            e.ToTable("menu_combos");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.StoreId).HasColumnName("store_id");
            e.Property(x => x.Name).HasColumnName("name").HasMaxLength(100);
            e.Property(x => x.Price).HasColumnName("price");
            e.Property(x => x.Sort).HasColumnName("sort");
            e.Property(x => x.CreatedAt).HasColumnName("created_at");
            e.HasOne(x => x.Store).WithMany().HasForeignKey(x => x.StoreId);
            e.HasIndex(x => new { x.StoreId, x.Name }).IsUnique();
        });

        modelBuilder.Entity<MenuComboItem>(e =>
        {
            e.ToTable("menu_combo_items");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.ComboId).HasColumnName("combo_id");
            e.Property(x => x.MenuItemId).HasColumnName("menu_item_id");
            e.Property(x => x.Qty).HasColumnName("qty");
            e.Property(x => x.Sort).HasColumnName("sort");
            e.HasOne(x => x.Combo).WithMany(c => c.Items).HasForeignKey(x => x.ComboId);
            e.HasOne(x => x.MenuItem).WithMany().HasForeignKey(x => x.MenuItemId);
            e.HasIndex(x => new { x.ComboId, x.MenuItemId }).IsUnique();
        });

        modelBuilder.Entity<CustomerOrder>(e =>
        {
            e.ToTable("customer_orders");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.StoreId).HasColumnName("store_id");
            e.Property(x => x.TableNumber).HasColumnName("table_number");
            e.Property(x => x.TotalAmount).HasColumnName("total_amount");
            e.Property(x => x.Status).HasColumnName("status").HasMaxLength(20);
            e.Property(x => x.Remark).HasColumnName("remark");
            e.Property(x => x.CreatedAt).HasColumnName("created_at");
            e.Property(x => x.UpdatedAt).HasColumnName("updated_at");
            e.HasOne(x => x.Store).WithMany().HasForeignKey(x => x.StoreId);
            e.HasIndex(x => new { x.StoreId, x.CreatedAt });
        });

        modelBuilder.Entity<CustomerOrderLine>(e =>
        {
            e.ToTable("customer_order_lines");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.OrderId).HasColumnName("order_id");
            e.Property(x => x.LineType).HasColumnName("line_type").HasMaxLength(20);
            e.Property(x => x.RefId).HasColumnName("ref_id");
            e.Property(x => x.Name).HasColumnName("name").HasMaxLength(200);
            e.Property(x => x.UnitPrice).HasColumnName("unit_price");
            e.Property(x => x.Qty).HasColumnName("qty");
            e.Property(x => x.Subtotal).HasColumnName("subtotal");
            e.HasOne(x => x.Order).WithMany(o => o.Lines).HasForeignKey(x => x.OrderId);
            e.HasIndex(x => x.OrderId);
        });
    }
}

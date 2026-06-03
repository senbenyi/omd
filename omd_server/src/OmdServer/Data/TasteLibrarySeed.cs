using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.EntityFrameworkCore;
using OmdServer.Common;
using OmdServer.Data.Entities;

namespace OmdServer.Data;

/// <summary>
/// 从 resource/taste.json 注入用户级口味偏好（Tag 维度）库。
/// </summary>
public static class TasteLibrarySeed
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    };

    public static async Task SeedAsync(AppDbContext db)
    {
        var entries = await LoadEntriesAsync();
        if (entries.Count == 0) return;

        var userIds = await db.Users.AsNoTracking().Select(u => u.Id).ToListAsync();
        foreach (var userId in userIds)
        {
            await SeedForUserAsync(db, userId, entries);
        }
    }

    public static async Task SeedForUserAsync(AppDbContext db, long userId)
    {
        var entries = await LoadEntriesAsync();
        if (entries.Count == 0) return;
        await SeedForUserAsync(db, userId, entries);
    }

    private static async Task<List<TasteSeedEntry>> LoadEntriesAsync()
    {
        var path = Path.Combine(AppContext.BaseDirectory, "resource", "taste.json");
        if (!File.Exists(path))
        {
            return [];
        }

        await using var stream = File.OpenRead(path);
        var entries = await JsonSerializer.DeserializeAsync<List<TasteSeedEntry>>(stream, JsonOptions);
        return entries ?? [];
    }

    private static async Task SeedForUserAsync(
        AppDbContext db,
        long userId,
        IReadOnlyList<TasteSeedEntry> entries)
    {
        var groupSort = 0;
        foreach (var entry in entries)
        {
            var groupName = entry.Name?.Trim() ?? "";
            if (string.IsNullOrWhiteSpace(groupName)) continue;

            var sort = entry.Id > 0 ? entry.Id : ++groupSort * 10;

            var group = await db.MenuTagGroups
                .FirstOrDefaultAsync(g => g.OwnerUserId == userId && g.Name == groupName);

            if (group is null)
            {
                group = new MenuTagGroup
                {
                    OwnerUserId = userId,
                    Name = groupName,
                    Sort = sort,
                    CreatedAt = DateTimeHelper.UtcNow
                };
                db.MenuTagGroups.Add(group);
                await db.SaveChangesAsync();
            }
            else if (group.Sort != sort)
            {
                group.Sort = sort;
            }

            var optionSort = 0;
            foreach (var raw in entry.Tastes)
            {
                var value = raw?.Trim() ?? "";
                if (string.IsNullOrWhiteSpace(value)) continue;

                var exists = await db.MenuTagOptions
                    .AnyAsync(o => o.GroupId == group.Id && o.Value == value);
                if (exists) continue;

                db.MenuTagOptions.Add(new MenuTagOption
                {
                    GroupId = group.Id,
                    Value = value,
                    Sort = ++optionSort * 10,
                    CreatedAt = DateTimeHelper.UtcNow
                });
            }
        }

        await db.SaveChangesAsync();
    }

    private sealed class TasteSeedEntry
    {
        public string Name { get; set; } = string.Empty;

        public int Id { get; set; }

        [JsonPropertyName("tastes")]
        public List<string> Tastes { get; set; } = [];
    }
}

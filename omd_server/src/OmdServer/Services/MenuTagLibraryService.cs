using Microsoft.EntityFrameworkCore;
using OmdServer.Common;
using OmdServer.Data;
using OmdServer.Data.Entities;
using OmdServer.Dtos;

namespace OmdServer.Services;

public class MenuTagLibraryService
{
    private readonly AppDbContext _db;

    public MenuTagLibraryService(AppDbContext db) => _db = db;

    public async Task<List<MenuTagGroupDto>> ListAsync(long userId)
    {
        var groups = await _db.MenuTagGroups
            .Where(g => g.OwnerUserId == userId)
            .OrderBy(g => g.Sort)
            .ThenBy(g => g.Id)
            .Include(g => g.Options.OrderBy(o => o.Sort).ThenBy(o => o.Id))
            .ToListAsync();

        return groups.Select(MapGroup).ToList();
    }

    public async Task<(MenuTagGroupDto? Result, ApiResponse<MenuTagGroupDto>? Fail)> SaveGroupAsync(
        long userId,
        SaveMenuTagGroupRequest request)
    {
        var name = request.Name?.Trim() ?? "";
        if (string.IsNullOrWhiteSpace(name))
            return (null, ApiResponse<MenuTagGroupDto>.Fail(ApiCodes.InvalidParams, "口味偏好名称不能为空"));

        var exists = await _db.MenuTagGroups
            .AnyAsync(g => g.OwnerUserId == userId && g.Name == name);
        if (exists)
        {
            var group = await _db.MenuTagGroups
                .Include(g => g.Options.OrderBy(o => o.Sort).ThenBy(o => o.Id))
                .FirstAsync(g => g.OwnerUserId == userId && g.Name == name);
            return (MapGroup(group), null);
        }

        var entity = new MenuTagGroup
        {
            OwnerUserId = userId,
            Name = name,
            Sort = 0,
            CreatedAt = DateTimeHelper.UtcNow
        };
        _db.MenuTagGroups.Add(entity);
        await _db.SaveChangesAsync();
        return (MapGroup(entity), null);
    }

    public async Task<(MenuTagOptionDto? Result, ApiResponse<MenuTagOptionDto>? Fail)> SaveOptionAsync(
        long userId,
        SaveMenuTagOptionRequest request)
    {
        var value = request.Value?.Trim() ?? "";
        if (string.IsNullOrWhiteSpace(value))
            return (null, ApiResponse<MenuTagOptionDto>.Fail(ApiCodes.InvalidParams, "选项值不能为空"));

        var group = await _db.MenuTagGroups
            .FirstOrDefaultAsync(g => g.Id == request.GroupId && g.OwnerUserId == userId);
        if (group is null)
            return (null, ApiResponse<MenuTagOptionDto>.Fail(ApiCodes.InvalidParams, "口味偏好不存在"));

        var exists = await _db.MenuTagOptions
            .AnyAsync(o => o.GroupId == group.Id && o.Value == value);
        if (exists)
        {
            var option = await _db.MenuTagOptions
                .FirstAsync(o => o.GroupId == group.Id && o.Value == value);
            return (new MenuTagOptionDto(option.Id, option.Value), null);
        }

        var entity = new MenuTagOption
        {
            GroupId = group.Id,
            Value = value,
            Sort = 0,
            CreatedAt = DateTimeHelper.UtcNow
        };
        _db.MenuTagOptions.Add(entity);
        await _db.SaveChangesAsync();
        return (new MenuTagOptionDto(entity.Id, entity.Value), null);
    }

    public async Task UpsertFromRemarkTagsAsync(long userId, Dictionary<string, List<string>>? remarkTags)
    {
        if (remarkTags is null || remarkTags.Count == 0) return;

        foreach (var (groupName, values) in remarkTags)
        {
            var name = groupName.Trim();
            if (string.IsNullOrWhiteSpace(name)) continue;

            var group = await _db.MenuTagGroups
                .FirstOrDefaultAsync(g => g.OwnerUserId == userId && g.Name == name);
            if (group is null)
            {
                group = new MenuTagGroup
                {
                    OwnerUserId = userId,
                    Name = name,
                    Sort = 0,
                    CreatedAt = DateTimeHelper.UtcNow
                };
                _db.MenuTagGroups.Add(group);
                await _db.SaveChangesAsync();
            }

            foreach (var raw in values)
            {
                var value = raw.Trim();
                if (string.IsNullOrWhiteSpace(value)) continue;

                var exists = await _db.MenuTagOptions
                    .AnyAsync(o => o.GroupId == group.Id && o.Value == value);
                if (exists) continue;

                _db.MenuTagOptions.Add(new MenuTagOption
                {
                    GroupId = group.Id,
                    Value = value,
                    Sort = 0,
                    CreatedAt = DateTimeHelper.UtcNow
                });
            }
        }

        await _db.SaveChangesAsync();
    }

    private static MenuTagGroupDto MapGroup(MenuTagGroup group) => new(
        group.Id,
        group.Name,
        group.Options.Select(o => new MenuTagOptionDto(o.Id, o.Value)).ToList());
}

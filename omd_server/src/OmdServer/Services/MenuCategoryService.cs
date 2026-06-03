using Microsoft.EntityFrameworkCore;
using OmdServer.Common;
using OmdServer.Data;
using OmdServer.Data.Entities;
using OmdServer.Dtos;

namespace OmdServer.Services;

public class MenuCategoryService
{
    private readonly AppDbContext _db;
    private readonly StoreAccessService _access;

    public MenuCategoryService(AppDbContext db, StoreAccessService access)
    {
        _db = db;
        _access = access;
    }

    public async Task<(List<MenuCategoryDto>? Ok, ApiResponse<object?>? Fail)> ListAsync(long userId, long storeId)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return (null, ApiResponse<object?>.Fail(ApiCodes.NoStorePermission, "无门店权限"));

        var categories = await _db.MenuCategories
            .Where(c => c.StoreId == storeId)
            .OrderBy(c => c.Sort)
            .ThenBy(c => c.Id)
            .Select(c => new MenuCategoryDto(
                c.Id,
                c.Name,
                c.Sort,
                c.Items.Count))
            .ToListAsync();
        return (categories, null);
    }

    public async Task<(MenuCategoryDto? Ok, ApiResponse<MenuCategoryDto>? Fail)> SaveAsync(
        long userId, long storeId, SaveMenuCategoryRequest request)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return (null, ApiResponse<MenuCategoryDto>.Fail(ApiCodes.NoStorePermission, "无门店权限"));
        if (string.IsNullOrWhiteSpace(request.Name))
            return (null, ApiResponse<MenuCategoryDto>.Fail(ApiCodes.InvalidParams, "分类名称不能为空"));

        MenuCategory? category = null;
        if (request.Id is > 0)
        {
            var id = request.Id!.Value;
            category = await _db.MenuCategories.FirstOrDefaultAsync(c => c.Id == id && c.StoreId == storeId);
            if (category is null)
                return (null, ApiResponse<MenuCategoryDto>.Fail(ApiCodes.InvalidParams, "分类不存在"));
            category.Name = request.Name.Trim();
            if (request.Sort.HasValue) category.Sort = request.Sort.Value;
        }
        else
        {
            category = new MenuCategory
            {
                StoreId = storeId,
                Name = request.Name.Trim(),
                Sort = request.Sort ?? 0,
                CreatedAt = DateTimeHelper.UtcNow
            };
            _db.MenuCategories.Add(category);
        }

        try
        {
            await _db.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            return (null, ApiResponse<MenuCategoryDto>.Fail(ApiCodes.InvalidParams, "分类名称已存在"));
        }

        var itemCount = await _db.MenuItems.CountAsync(i => i.CategoryId == category.Id);
        return (new MenuCategoryDto(category.Id, category.Name, category.Sort, itemCount), null);
    }

    public async Task<ApiResponse<object?>?> RemoveAsync(long userId, long storeId, RemoveMenuCategoryRequest request)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return ApiResponse<object?>.Fail(ApiCodes.NoStorePermission, "无门店权限");

        var category = await _db.MenuCategories.FirstOrDefaultAsync(c => c.Id == request.CategoryId && c.StoreId == storeId);
        if (category is null)
            return ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "分类不存在");

        var hasItems = await _db.MenuItems.AnyAsync(i => i.CategoryId == category.Id);
        if (hasItems)
            return ApiResponse<object?>.Fail(ApiCodes.CategoryHasItems, "分类下有菜品，不可删除");

        _db.MenuCategories.Remove(category);
        await _db.SaveChangesAsync();
        return ApiResponse<object?>.Ok(null);
    }
}

using Microsoft.EntityFrameworkCore;
using OmdServer.Common;
using OmdServer.Data;
using OmdServer.Data.Entities;
using OmdServer.Dtos;

namespace OmdServer.Services;

public class MenuItemService
{
    private readonly AppDbContext _db;
    private readonly StoreAccessService _access;
    private readonly MenuTagLibraryService _tagLibrary;

    public MenuItemService(AppDbContext db, StoreAccessService access, MenuTagLibraryService tagLibrary)
    {
        _db = db;
        _access = access;
        _tagLibrary = tagLibrary;
    }

    public async Task<(PagedListDto<MenuItemListDto>? Ok, ApiResponse<object?>? Fail)> ListAsync(
        long userId, long storeId, long? categoryId, string? status, bool? soldOut, string? keyword, int page, int pageSize)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return (null, ApiResponse<object?>.Fail(ApiCodes.NoStorePermission, "无门店权限"));

        page = page < 1 ? 1 : page;
        pageSize = pageSize < 1 ? 20 : Math.Min(pageSize, 100);

        var query = _db.MenuItems.Where(i => i.StoreId == storeId);
        if (categoryId.HasValue) query = query.Where(i => i.CategoryId == categoryId);
        if (!string.IsNullOrWhiteSpace(status)) query = query.Where(i => i.Status == status);
        if (soldOut.HasValue) query = query.Where(i => i.SoldOut == soldOut.Value);
        if (!string.IsNullOrWhiteSpace(keyword)) query = query.Where(i => i.Name.Contains(keyword));

        var total = await query.CountAsync();
        var list = await query
            .OrderBy(i => i.Sort)
            .ThenByDescending(i => i.Id)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(i => new MenuItemListDto(
                i.Id,
                i.CategoryId,
                i.Category.Name,
                i.Name,
                i.Price,
                i.Status,
                i.SoldOut,
                i.Tags,
                DateTimeHelper.FormatDateTime(i.CreatedAt)))
            .ToListAsync();

        return (new PagedListDto<MenuItemListDto>(list, new PageMetaDto(page, pageSize, total)), null);
    }

    public async Task<(MenuItemDetailDto? Ok, ApiResponse<object?>? Fail)> GetDetailAsync(
        long userId, long storeId, long itemId)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return (null, ApiResponse<object?>.Fail(ApiCodes.NoStorePermission, "无门店权限"));

        var item = await _db.MenuItems
            .Include(i => i.Category)
            .FirstOrDefaultAsync(i => i.Id == itemId && i.StoreId == storeId);
        if (item is null)
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "菜品不存在"));

        return (MapDetail(item), null);
    }

    public async Task<(MenuItemDetailDto? Ok, ApiResponse<MenuItemDetailDto>? Fail)> SaveAsync(
        long userId, long storeId, SaveMenuItemRequest request)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return (null, ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.NoStorePermission, "无门店权限"));

        MenuItem? item = null;
        if (request.Id is > 0)
        {
            var editId = request.Id!.Value;
            item = await _db.MenuItems
                .Include(i => i.Category)
                .FirstOrDefaultAsync(i => i.Id == editId && i.StoreId == storeId);
            if (item is null)
                return (null, ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.InvalidParams, "菜品不存在"));

            if (request.CategoryId.HasValue)
            {
                if (!await CategoryBelongsToStore(request.CategoryId.Value, storeId))
                    return (null, ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.InvalidParams, "分类不存在"));
                item.CategoryId = request.CategoryId.Value;
            }
            if (!string.IsNullOrWhiteSpace(request.Name)) item.Name = request.Name.Trim();
            if (request.Description is not null) item.Description = request.Description;
            if (request.Price.HasValue) item.Price = request.Price.Value;
            if (request.OriginalPrice.HasValue) item.OriginalPrice = request.OriginalPrice;
            if (!string.IsNullOrWhiteSpace(request.Unit)) item.Unit = request.Unit;
            if (request.ImageUrl is not null) item.ImageUrl = request.ImageUrl;
            if (request.Tags is not null) item.Tags = request.Tags;
            if (request.DurationMinutes.HasValue) item.DurationMinutes = request.DurationMinutes.Value;
            if (request.MinQty.HasValue)
            {
                if (request.MinQty.Value < 1)
                    return (null, ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.InvalidParams, "份数起点至少为 1"));
                item.MinQty = request.MinQty.Value;
            }
            if (request.Remark is not null) item.Remark = request.Remark;
            if (request.RemarkTags is not null) item.RemarkTags = request.RemarkTags;
            if (request.SpicyLevel.HasValue) item.SpicyLevel = request.SpicyLevel.Value;
            if (request.Stock.HasValue) item.Stock = request.Stock.Value;
            if (request.SoldOut.HasValue) item.SoldOut = request.SoldOut.Value;
            if (request.Sort.HasValue) item.Sort = request.Sort.Value;
            if (!string.IsNullOrWhiteSpace(request.Status))
            {
                if (request.Status is not ("on_sale" or "off_sale"))
                    return (null, ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.InvalidParams, "状态无效"));
                item.Status = request.Status;
            }
            item.UpdatedAt = DateTimeHelper.UtcNow;
            await _tagLibrary.UpsertFromRemarkTagsAsync(userId, request.RemarkTags);
        }
        else
        {
            if (!request.CategoryId.HasValue || string.IsNullOrWhiteSpace(request.Name))
                return (null, ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.InvalidParams, "新增菜品缺少必填参数"));
            if (!await CategoryBelongsToStore(request.CategoryId.Value, storeId))
                return (null, ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.InvalidParams, "分类不存在"));

            await _tagLibrary.UpsertFromRemarkTagsAsync(userId, request.RemarkTags);

            var status = string.IsNullOrWhiteSpace(request.Status) ? "off_sale" : request.Status.Trim();
            if (status is not ("on_sale" or "off_sale"))
                return (null, ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.InvalidParams, "状态无效"));

            var now = DateTimeHelper.UtcNow;
            item = new MenuItem
            {
                StoreId = storeId,
                CategoryId = request.CategoryId.Value,
                Name = request.Name.Trim(),
                Description = request.Description,
                Price = request.Price ?? 0,
                OriginalPrice = request.OriginalPrice,
                Unit = string.IsNullOrWhiteSpace(request.Unit) ? "份" : request.Unit,
                ImageUrl = request.ImageUrl,
                Tags = request.Tags ?? new List<string>(),
                DurationMinutes = request.DurationMinutes ?? 0,
                MinQty = request.MinQty is > 0 ? request.MinQty.Value : 1,
                Remark = request.Remark,
                RemarkTags = request.RemarkTags ?? new Dictionary<string, List<string>>(),
                SpicyLevel = request.SpicyLevel ?? 0,
                Stock = request.Stock ?? -1,
                SoldOut = request.SoldOut ?? false,
                Status = status,
                Sort = request.Sort ?? 0,
                CreatedAt = now,
                UpdatedAt = now
            };
            _db.MenuItems.Add(item);
        }

        await _db.SaveChangesAsync();
        await _db.Entry(item!).Reference(i => i.Category).LoadAsync();
        return (MapDetail(item!), null);
    }

    public async Task<ApiResponse<object?>?> RemoveAsync(long userId, long storeId, RemoveMenuItemRequest request)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return ApiResponse<object?>.Fail(ApiCodes.NoStorePermission, "无门店权限");

        var item = await _db.MenuItems.FirstOrDefaultAsync(i => i.Id == request.ItemId && i.StoreId == storeId);
        if (item is null)
            return ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "菜品不存在");
        if (item.Status == "on_sale")
            return ApiResponse<object?>.Fail(ApiCodes.ItemOnSaleCannotDelete, "上架中的菜品不可删除");

        _db.MenuItems.Remove(item);
        await _db.SaveChangesAsync();
        return ApiResponse<object?>.Ok(null);
    }

    public async Task<(MenuItemDetailDto? Ok, ApiResponse<MenuItemDetailDto>? Fail)> UpdateStatusAsync(
        long userId, long storeId, UpdateMenuItemStatusRequest request)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return (null, ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.NoStorePermission, "无门店权限"));
        if (request.Status is not ("on_sale" or "off_sale"))
            return (null, ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.InvalidParams, "状态无效"));

        var item = await _db.MenuItems
            .Include(i => i.Category)
            .FirstOrDefaultAsync(i => i.Id == request.ItemId && i.StoreId == storeId);
        if (item is null)
            return (null, ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.InvalidParams, "菜品不存在"));

        item.Status = request.Status;
        item.UpdatedAt = DateTimeHelper.UtcNow;
        await _db.SaveChangesAsync();
        return (MapDetail(item), null);
    }

    public async Task<(MenuItemDetailDto? Ok, ApiResponse<MenuItemDetailDto>? Fail)> UpdateSoldOutAsync(
        long userId, long storeId, UpdateMenuItemSoldOutRequest request)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return (null, ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.NoStorePermission, "无门店权限"));

        var item = await _db.MenuItems
            .Include(i => i.Category)
            .FirstOrDefaultAsync(i => i.Id == request.ItemId && i.StoreId == storeId);
        if (item is null)
            return (null, ApiResponse<MenuItemDetailDto>.Fail(ApiCodes.InvalidParams, "菜品不存在"));

        item.SoldOut = request.SoldOut;
        item.UpdatedAt = DateTimeHelper.UtcNow;
        await _db.SaveChangesAsync();
        return (MapDetail(item), null);
    }

    public async Task<ApiResponse<object?>?> BatchSortAsync(
        long userId, long storeId, BatchSortMenuItemsRequest request)
    {
        if (!await _access.UserOwnsStoreAsync(userId, storeId))
            return ApiResponse<object?>.Fail(ApiCodes.NoStorePermission, "无门店权限");
        if (request.ItemIds is null or { Count: 0 })
            return ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "itemIds 不能为空");

        var items = await _db.MenuItems
            .Where(i => i.StoreId == storeId && request.ItemIds.Contains(i.Id))
            .ToListAsync();
        if (items.Count != request.ItemIds.Count)
            return ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "部分菜品不存在");

        for (var i = 0; i < request.ItemIds.Count; i++)
        {
            var item = items.First(x => x.Id == request.ItemIds[i]);
            item.Sort = (i + 1) * 10;
            item.UpdatedAt = DateTimeHelper.UtcNow;
        }
        await _db.SaveChangesAsync();
        return ApiResponse<object?>.Ok(null);
    }

    private async Task<bool> CategoryBelongsToStore(long categoryId, long storeId) =>
        await _db.MenuCategories.AnyAsync(c => c.Id == categoryId && c.StoreId == storeId);

    private static MenuItemDetailDto MapDetail(MenuItem item) => new(
        item.Id,
        item.CategoryId,
        item.Category?.Name ?? "",
        item.Name,
        item.Description,
        item.Price,
        item.OriginalPrice,
        item.Unit,
        item.ImageUrl,
        item.Tags,
        item.DurationMinutes,
        item.MinQty,
        item.Remark,
        item.RemarkTags,
        item.SpicyLevel,
        item.Stock,
        item.SoldOut,
        item.Status,
        item.Sort,
        DateTimeHelper.FormatDateTime(item.CreatedAt),
        DateTimeHelper.FormatDateTime(item.UpdatedAt));
}

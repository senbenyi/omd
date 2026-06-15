using Microsoft.EntityFrameworkCore;
using OmdServer.Common;
using OmdServer.Data;
using OmdServer.Dtos;

namespace OmdServer.Services;

public class CustomerMenuService
{
    private readonly AppDbContext _db;

    public CustomerMenuService(AppDbContext db) => _db = db;

    public async Task<(List<MenuItemListDto>? Ok, ApiResponse<object?>? Fail)> ListItemsAsync(long storeId)
    {
        if (!await _db.Stores.AnyAsync(s => s.Id == storeId))
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "门店不存在"));

        var list = await _db.MenuItems
            .Where(i => i.StoreId == storeId && i.Status == "on_sale" && !i.SoldOut)
            .OrderBy(i => i.Sort)
            .ThenByDescending(i => i.Id)
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

        return (list, null);
    }

    public async Task<(List<MenuComboDto>? Ok, ApiResponse<object?>? Fail)> ListCombosAsync(long storeId)
    {
        if (!await _db.Stores.AnyAsync(s => s.Id == storeId))
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "门店不存在"));

        var list = await _db.MenuCombos
            .Where(c => c.StoreId == storeId)
            .OrderBy(c => c.Sort)
            .ThenBy(c => c.Id)
            .Select(c => new MenuComboDto(
                c.Id,
                c.Name,
                c.Sort,
                c.Price,
                c.Items.Sum(i => i.Qty)))
            .ToListAsync();

        return (list, null);
    }

    public async Task<(MenuComboDetailDto? Ok, ApiResponse<object?>? Fail)> GetComboDetailAsync(
        long storeId,
        long comboId)
    {
        if (!await _db.Stores.AnyAsync(s => s.Id == storeId))
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "门店不存在"));

        var combo = await _db.MenuCombos
            .AsNoTracking()
            .FirstOrDefaultAsync(c => c.Id == comboId && c.StoreId == storeId);
        if (combo is null)
            return (null, ApiResponse<object?>.Fail(ApiCodes.InvalidParams, "套餐不存在"));

        var items = await _db.MenuComboItems
            .AsNoTracking()
            .Where(ci => ci.ComboId == comboId)
            .OrderBy(ci => ci.Sort)
            .ThenBy(ci => ci.Id)
            .Select(ci => new MenuComboItemDto(
                ci.MenuItem.Id,
                ci.MenuItem.CategoryId,
                ci.MenuItem.Category.Name,
                ci.MenuItem.Name,
                ci.MenuItem.Price,
                ci.MenuItem.Status,
                ci.Qty))
            .ToListAsync();

        return (new MenuComboDetailDto(combo.Id, combo.Name, combo.Price, items), null);
    }
}

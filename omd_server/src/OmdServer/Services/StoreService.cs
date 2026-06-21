using Microsoft.EntityFrameworkCore;
using OmdServer.Common;
using OmdServer.Data;
using OmdServer.Data.Entities;
using OmdServer.Dtos;

namespace OmdServer.Services;

public class StoreService
{
    private readonly AppDbContext _db;

    public StoreService(AppDbContext db) => _db = db;

    public async Task<List<StoreDto>> ListStoresAsync(long userId)
    {
        var stores = await _db.Stores
            .Where(s => s.OwnerUserId == userId)
            .OrderByDescending(s => s.Id)
            .ToListAsync();
        return stores.Select(MapStore).ToList();
    }

    public async Task<List<CustomerStoreDto>> ListCustomerStoresAsync()
    {
        var stores = await _db.Stores
            .OrderByDescending(s => s.Id)
            .ToListAsync();
        return stores.Select(MapCustomerStore).ToList();
    }

    private static CustomerStoreDto MapCustomerStore(Store s) => new(
        s.Id,
        s.Name,
        s.Status,
        s.Address,
        s.Phone);

    public async Task<StoreDto?> GetStoreAsync(long userId, long storeId)
    {
        var store = await _db.Stores
            .FirstOrDefaultAsync(s => s.Id == storeId && s.OwnerUserId == userId);
        return store is null ? null : MapStore(store);
    }

    public async Task<(StoreDto? Result, ApiResponse<StoreDto>? Fail)> SaveStoreAsync(
        long userId,
        SaveStoreRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Name) || string.IsNullOrWhiteSpace(request.Address)
            || string.IsNullOrWhiteSpace(request.Phone) || string.IsNullOrWhiteSpace(request.ContactName))
            return (null, ApiResponse<StoreDto>.Fail(ApiCodes.InvalidParams, "参数不完整"));

        var hoursError = ValidateBusinessHours(request.BusinessHours);
        if (hoursError is not null)
            return (null, ApiResponse<StoreDto>.Fail(ApiCodes.InvalidParams, hoursError));

        if (request.Id is null or <= 0)
            return await CreateStoreAsync(userId, request);

        var store = await _db.Stores
            .FirstOrDefaultAsync(s => s.Id == request.Id && s.OwnerUserId == userId);
        if (store is null)
            return (null, ApiResponse<StoreDto>.Fail(ApiCodes.NoStorePermission, "无门店权限"));

        ApplyBasicFields(store, request);
        ApplyBusinessHours(store, request.BusinessHours);
        ApplyClosedWeekdays(store, request.ClosedWeekdays);

        try
        {
            await _db.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            return (null, ApiResponse<StoreDto>.Fail(ApiCodes.InvalidParams, "保存失败，请检查输入内容后重试"));
        }
        return (MapStore(store), null);
    }

    public async Task<(bool Ok, ApiResponse<object?>? Fail)> DeleteStoreAsync(long userId, long storeId)
    {
        var store = await _db.Stores
            .FirstOrDefaultAsync(s => s.Id == storeId && s.OwnerUserId == userId);
        if (store is null)
            return (false, ApiResponse<object?>.Fail(ApiCodes.NoStorePermission, "无门店权限"));

        var orderIds = await _db.CustomerOrders
            .Where(o => o.StoreId == storeId)
            .Select(o => o.Id)
            .ToListAsync();
        if (orderIds.Count > 0)
        {
            var orderLines = await _db.CustomerOrderLines
                .Where(l => orderIds.Contains(l.OrderId))
                .ToListAsync();
            _db.CustomerOrderLines.RemoveRange(orderLines);
            var orders = await _db.CustomerOrders.Where(o => o.StoreId == storeId).ToListAsync();
            _db.CustomerOrders.RemoveRange(orders);
        }

        var comboIds = await _db.MenuCombos
            .Where(c => c.StoreId == storeId)
            .Select(c => c.Id)
            .ToListAsync();
        if (comboIds.Count > 0)
        {
            var comboItems = await _db.MenuComboItems
                .Where(i => comboIds.Contains(i.ComboId))
                .ToListAsync();
            _db.MenuComboItems.RemoveRange(comboItems);
            var combos = await _db.MenuCombos.Where(c => c.StoreId == storeId).ToListAsync();
            _db.MenuCombos.RemoveRange(combos);
        }

        var items = await _db.MenuItems.Where(i => i.StoreId == storeId).ToListAsync();
        _db.MenuItems.RemoveRange(items);

        var categories = await _db.MenuCategories.Where(c => c.StoreId == storeId).ToListAsync();
        _db.MenuCategories.RemoveRange(categories);

        _db.Stores.Remove(store);
        await _db.SaveChangesAsync();
        return (true, null);
    }

    private async Task<(StoreDto? Result, ApiResponse<StoreDto>? Fail)> CreateStoreAsync(
        long userId,
        SaveStoreRequest request)
    {
        var store = new Store
        {
            OwnerUserId = userId,
            Name = request.Name.Trim(),
            Status = "rest",
            Address = request.Address.Trim(),
            Phone = request.Phone.Trim(),
            ContactName = request.ContactName.Trim(),
            ServiceExpireAt = DateTimeHelper.UtcNow.AddYears(1),
            VipLevel = request.VipLevel,
            ReferrerId = request.ReferrerId,
            AdditionalPeriod = 0,
            CreatedAt = DateTimeHelper.UtcNow
        };
        ApplyBusinessHours(store, request.BusinessHours);
        ApplyClosedWeekdays(store, request.ClosedWeekdays);

        _db.Stores.Add(store);
        try
        {
            await _db.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            return (null, ApiResponse<StoreDto>.Fail(ApiCodes.InvalidParams, "保存失败，请检查输入内容后重试"));
        }
        return (MapStore(store), null);
    }

    private static void ApplyBasicFields(Store store, SaveStoreRequest request)
    {
        store.Name = request.Name.Trim();
        store.Address = request.Address.Trim();
        store.Phone = request.Phone.Trim();
        store.ContactName = request.ContactName.Trim();
        store.VipLevel = request.VipLevel;
        store.ReferrerId = request.ReferrerId;
        if (!string.IsNullOrWhiteSpace(request.Status))
            store.Status = request.Status.Trim();
    }

    private static void ApplyBusinessHours(Store store, BusinessHoursDto? hours)
    {
        if (hours is null) return;

        store.IsOpen24Hours = hours.IsOpen24Hours;
        if (hours.IsOpen24Hours) return;

        if (TimeOfDayMsHelper.TryParse(hours.OpenTime, out var open))
            store.BusinessOpenTime = open;
        if (TimeOfDayMsHelper.TryParse(hours.CloseTime, out var close))
            store.BusinessCloseTime = close;
    }

    private static void ApplyClosedWeekdays(Store store, List<int>? weekdays)
    {
        if (weekdays is null) return;
        store.ClosedWeekdays = weekdays
            .Where(d => d is >= 1 and <= 7)
            .Distinct()
            .OrderBy(d => d)
            .ToList();
    }

    private static string? ValidateBusinessHours(BusinessHoursDto? hours)
    {
        if (hours is null || hours.IsOpen24Hours) return null;

        if (!TimeOfDayMsHelper.TryParse(hours.OpenTime, out var open)
            || !TimeOfDayMsHelper.TryParse(hours.CloseTime, out var close))
            return "请设置正确的营业时间";

        if (open >= close)
            return "营业结束时间需晚于开始时间";

        return null;
    }

    public static StoreDto MapStore(Store s) => new(
        s.Id,
        s.OwnerUserId,
        s.Name,
        s.Status,
        s.Address,
        s.Phone,
        s.ContactName,
        new BusinessHoursDto(
            s.IsOpen24Hours,
            s.IsOpen24Hours ? null : s.BusinessOpenTime,
            s.IsOpen24Hours ? null : s.BusinessCloseTime),
        s.ClosedWeekdays.ToList(),
        new ServiceInfoDto(
            DateTimeHelper.FormatDateTime(s.ServiceExpireAt),
            s.VipLevel,
            s.ReferrerId,
            s.AdditionalPeriod));
}

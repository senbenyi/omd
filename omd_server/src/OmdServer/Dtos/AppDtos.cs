using System.Text.Json.Serialization;
using OmdServer.Common;

namespace OmdServer.Dtos;

public record AppConfigDto(
    string CustomerServicePhone,
    string ImageDomain,
    string OfficialWebsite,
    string CustomerServiceEmail,
    string TechnicalSupportPhone);

public record LoginRequest(string Phone, string Password);

public record RegisterRequest(string Phone, string Password, string? Username);

public record LoginResponse(string Token, string UserId, string Username, string Phone);

public record ServiceInfoDto(
    string ServiceExpireAt,
    int VipLevel,
    string? ReferrerId,
    int AdditionalPeriod);

public record BusinessHoursDto(
    bool IsOpen24Hours,
    [property: JsonConverter(typeof(FlexibleMsJsonConverter))] long? OpenTime,
    [property: JsonConverter(typeof(FlexibleMsJsonConverter))] long? CloseTime);

public record StoreDto(
    long Id,
    string Name,
    string Status,
    string Address,
    string Phone,
    string ContactName,
    BusinessHoursDto BusinessHours,
    List<int> ClosedWeekdays,
    ServiceInfoDto ServiceInfo);

public record SaveStoreRequest(
    long? Id,
    string Name,
    string Address,
    string Phone,
    string ContactName,
    int VipLevel,
    string? ReferrerId,
    string? Status,
    BusinessHoursDto? BusinessHours,
    List<int>? ClosedWeekdays);

public record MenuCategoryDto(long Id, string Name, int Sort, int ItemCount);

public record SaveMenuCategoryRequest(long? Id, string Name, int? Sort);

public record RemoveMenuCategoryRequest(long CategoryId);

public record MenuItemListDto(
    long Id,
    long CategoryId,
    string CategoryName,
    string Name,
    int Price,
    string Status,
    bool SoldOut,
    List<string> Tags,
    string CreatedAt);

public record MenuItemDetailDto(
    long Id,
    long CategoryId,
    string CategoryName,
    string Name,
    string? Description,
    int Price,
    int? OriginalPrice,
    string Unit,
    string? ImageUrl,
    List<string> Tags,
    int DurationMinutes,
    int MinQty,
    string? Remark,
    Dictionary<string, List<string>> RemarkTags,
    int SpicyLevel,
    int Stock,
    bool SoldOut,
    string Status,
    int Sort,
    string CreatedAt,
    string? UpdatedAt);

public record PagedListDto<T>(List<T> List, PageMetaDto Meta);

public record PageMetaDto(int Page, int PageSize, int Total);

public record SaveMenuItemRequest(
    long? Id,
    long? CategoryId,
    string? Name,
    string? Description,
    int? Price,
    int? OriginalPrice,
    string? Unit,
    string? ImageUrl,
    List<string>? Tags,
    int? DurationMinutes,
    int? MinQty,
    string? Remark,
    Dictionary<string, List<string>>? RemarkTags,
    int? SpicyLevel,
    int? Stock,
    bool? SoldOut,
    string? Status,
    int? Sort);

public record RemoveMenuItemRequest(long ItemId);

public record UpdateMenuItemStatusRequest(long ItemId, string Status);

public record UpdateMenuItemSoldOutRequest(long ItemId, bool SoldOut);

public record BatchSortMenuItemsRequest(List<long> ItemIds);

public record MenuComboDto(long Id, string Name, int Sort, int Price, int ItemCount);

/// <summary>套餐内一条菜品及份数。</summary>
public record SaveMenuComboItemEntry(long ItemId, int Qty = 1);

public record SaveMenuComboRequest(
    long? Id,
    string Name,
    int Price,
    List<long>? ItemIds,
    List<SaveMenuComboItemEntry>? Items);

public record MenuComboItemDto(
    long Id,
    long CategoryId,
    string CategoryName,
    string Name,
    int Price,
    string Status,
    int Qty);

public record MenuComboDetailDto(long Id, string Name, int Price, List<MenuComboItemDto> Items);

public record SaveMenuComboContentRequest(int Price, List<long>? ItemIds, List<SaveMenuComboItemEntry>? Items);

public record RemoveMenuComboRequest(long ComboId);

public record MenuTagOptionDto(long Id, string Value);

public record MenuTagGroupDto(long Id, string Name, List<MenuTagOptionDto> Tastes);

public record SaveMenuTagGroupRequest(string Name);

public record SaveMenuTagOptionRequest(long GroupId, string Value);

public record UploadFileResponse(string Url);

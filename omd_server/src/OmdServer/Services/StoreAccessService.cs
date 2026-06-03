using Microsoft.EntityFrameworkCore;
using OmdServer.Data;

namespace OmdServer.Services;

public class StoreAccessService
{
    private readonly AppDbContext _db;

    public StoreAccessService(AppDbContext db) => _db = db;

    public async Task<bool> UserOwnsStoreAsync(long userId, long storeId, CancellationToken ct = default)
    {
        return await _db.Stores.AnyAsync(s => s.Id == storeId && s.OwnerUserId == userId, ct);
    }
}

using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Extensions.Logging;

namespace OmdServer.Data;

/// <summary>
/// 从 <c>mock/</c> 目录加载 JSON 演示数据（优先 ContentRoot/mock，便于开发时即时生效）。
/// </summary>
public static class MockDataLoader
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        ReadCommentHandling = JsonCommentHandling.Skip,
        AllowTrailingCommas = true
    };

    private static string? _contentRootPath;

    public static void Configure(string? contentRootPath) => _contentRootPath = contentRootPath;

    public static string ResolveMockDirectory()
    {
        if (!string.IsNullOrWhiteSpace(_contentRootPath))
        {
            var source = Path.Combine(_contentRootPath, "mock");
            if (Directory.Exists(source))
                return source;
        }

        return Path.Combine(AppContext.BaseDirectory, "mock");
    }

    public static string GetFilePath(string fileName) => Path.Combine(ResolveMockDirectory(), fileName);

    public static async Task<T?> LoadAsync<T>(string fileName, CancellationToken cancellationToken = default)
    {
        var path = GetFilePath(fileName);
        if (!File.Exists(path))
            return default;

        await using var stream = File.OpenRead(path);
        return await JsonSerializer.DeserializeAsync<T>(stream, JsonOptions, cancellationToken);
    }

    public static void LogScanSummary(ILogger logger)
    {
        var dir = ResolveMockDirectory();
        if (!Directory.Exists(dir))
        {
            logger.LogWarning("Mock 目录不存在: {MockDir}", dir);
            return;
        }

        var files = Directory.GetFiles(dir, "*.json")
            .Select(f => Path.GetFileName(f))
            .OrderBy(f => f, StringComparer.Ordinal)
            .ToList();

        logger.LogInformation("扫描 Mock 数据目录: {MockDir}（{Count} 个文件）", dir, files.Count);
        foreach (var file in files)
            logger.LogInformation("  - {File}", file);
    }
}

/// <summary>mock/users.json</summary>
public sealed class MockUserDefinition
{
    public long UserId { get; set; }
    public string Phone { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
}

/// <summary>mock/stores.json</summary>
public sealed class MockStoresDocument
{
    public List<MockStoreDefinition> Stores { get; set; } = [];
}

public sealed class MockStoreDefinition
{
    public long UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Status { get; set; } = "open";
    public string Address { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string ContactName { get; set; } = string.Empty;
    public bool IsOpen24Hours { get; set; }
    public long BusinessOpenTime { get; set; }
    public long BusinessCloseTime { get; set; }
    public List<int> ClosedWeekdays { get; set; } = [];
    public int VipLevel { get; set; } = 1;
    public string? ReferrerId { get; set; }
    public int AdditionalPeriod { get; set; }
    public MockMenuDefinition Menu { get; set; } = new();
}

public sealed class MockMenuDefinition
{
    public List<MockCategoryDefinition> Categories { get; set; } = [];
    public List<MockItemDefinition> Items { get; set; } = [];
    public List<MockComboDefinition> Combos { get; set; } = [];
}

public sealed class MockCategoryDefinition
{
    public string Name { get; set; } = string.Empty;
    public int Sort { get; set; }
}

public sealed class MockItemDefinition
{
    public string CategoryName { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public int Price { get; set; }
    public int Sort { get; set; }
    public string Status { get; set; } = "on_sale";
    public string? Description { get; set; }
    public int? OriginalPrice { get; set; }
    public string Unit { get; set; } = "份";
    public int MinQty { get; set; } = 1;
    public int SpicyLevel { get; set; }
    public int Stock { get; set; } = -1;
    public bool SoldOut { get; set; }
    public int DurationMinutes { get; set; }
    public List<string> Tags { get; set; } = [];
}

public sealed class MockComboDefinition
{
    public string Name { get; set; } = string.Empty;
    public int Price { get; set; }
    public int Sort { get; set; }
    public List<MockComboLineDefinition> Lines { get; set; } = [];
}

public sealed class MockComboLineDefinition
{
    public string ItemName { get; set; } = string.Empty;
    public int Qty { get; set; } = 1;
}

/// <summary>mock/taste.json</summary>
public sealed class MockTasteEntry
{
    public string Name { get; set; } = string.Empty;
    public int Id { get; set; }

    [JsonPropertyName("tastes")]
    public List<string> Tastes { get; set; } = [];
}

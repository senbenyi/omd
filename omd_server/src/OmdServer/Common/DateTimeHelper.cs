namespace OmdServer.Common;

public static class DateTimeHelper
{
    private const string Format = "yyyy-MM-dd HH:mm:ss";

    public static string FormatDateTime(DateTime dt)
    {
        var local = dt.Kind == DateTimeKind.Utc ? dt.ToLocalTime() : dt;
        return local.ToString(Format);
    }

    public static DateTime UtcNow => DateTime.UtcNow;
}

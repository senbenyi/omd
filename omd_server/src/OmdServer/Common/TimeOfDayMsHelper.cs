namespace OmdServer.Common;

/// <summary>
/// 当日时间戳：距本地 00:00 的毫秒数（0–86399999）。
/// </summary>
public static class TimeOfDayMsHelper
{
    public const long DefaultOpenMs = 9 * 3600L * 1000L;
    public const long DefaultCloseMs = 22 * 3600L * 1000L;

    public static long FromHourMinute(int hour, int minute, int second = 0)
        => (hour * 3600L + minute * 60L + second) * 1000L;

    public static bool IsValid(long? value)
        => value is >= 0 and < 86_400_000;

    public static bool TryParse(long? value, out long ms)
    {
        ms = 0;
        if (value is null || !IsValid(value))
            return false;
        ms = value.Value;
        return true;
    }
}

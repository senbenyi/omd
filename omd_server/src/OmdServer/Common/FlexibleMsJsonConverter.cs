using System.Globalization;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace OmdServer.Common;

/// <summary>
/// 兼容毫秒时间戳（int/long）与 "HH:mm" 字符串。
/// </summary>
public sealed class FlexibleMsJsonConverter : JsonConverter<long?>
{
    public override long? Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        switch (reader.TokenType)
        {
            case JsonTokenType.Null:
                return null;
            case JsonTokenType.Number:
                return reader.TryGetInt64(out var ms) ? ms : null;
            case JsonTokenType.String:
                var text = reader.GetString();
                if (string.IsNullOrWhiteSpace(text)) return null;
                if (long.TryParse(text, NumberStyles.Integer, CultureInfo.InvariantCulture, out var parsed))
                    return parsed;
                if (TryParseHHmm(text, out var fromText))
                    return fromText;
                throw new JsonException($"Invalid time value: {text}");
            default:
                throw new JsonException($"Unexpected token {reader.TokenType} for time value.");
        }
    }

    public override void Write(Utf8JsonWriter writer, long? value, JsonSerializerOptions options)
    {
        if (value is null)
            writer.WriteNullValue();
        else
            writer.WriteNumberValue(value.Value);
    }

    internal static bool TryParseHHmm(string text, out long ms)
    {
        ms = 0;
        var parts = text.Split(':');
        if (parts.Length < 2) return false;
        if (!int.TryParse(parts[0], out var hour) || !int.TryParse(parts[1], out var minute))
            return false;
        if (hour is < 0 or > 23 || minute is < 0 or > 59) return false;
        ms = TimeOfDayMsHelper.FromHourMinute(hour, minute);
        return TimeOfDayMsHelper.IsValid(ms);
    }
}

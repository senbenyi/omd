namespace OmdServer.Common;

public sealed class ApiResponse<T>
{
    public string Code { get; init; } = ApiCodes.Success;
    public string Message { get; init; } = "ok";
    public T? Data { get; init; }

    public static ApiResponse<T> Ok(T? data) => new() { Data = data };
    public static ApiResponse<T> Fail(string code, string message) => new() { Code = code, Message = message };
}

public static class ApiResponse
{
    public static ApiResponse<object?> Ok() => ApiResponse<object?>.Ok(null);
    public static ApiResponse<object?> Fail(string code, string message) => ApiResponse<object?>.Fail(code, message);
}

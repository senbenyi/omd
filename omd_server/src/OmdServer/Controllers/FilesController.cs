using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OmdServer.Common;
using OmdServer.Dtos;

namespace OmdServer.Controllers;

[Route("restaurant/v1/files")]
[Authorize]
public class FilesController : ApiControllerBase
{
    private readonly IWebHostEnvironment _env;

    public FilesController(IWebHostEnvironment env) => _env = env;

    [HttpPost("upload")]
    [RequestSizeLimit(10 * 1024 * 1024)]
    public async Task<ActionResult<ApiResponse<UploadFileResponse>>> Upload(IFormFile? file)
    {
        if (CurrentUserId is null)
            return Ok(ApiResponse<UploadFileResponse>.Fail(ApiCodes.TokenInvalid, "Token 失效"));
        if (file is null || file.Length == 0)
            return Ok(ApiResponse<UploadFileResponse>.Fail(ApiCodes.InvalidParams, "请选择图片"));

        var ext = Path.GetExtension(file.FileName);
        if (string.IsNullOrWhiteSpace(ext))
            ext = ".jpg";

        var allowed = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".jpg", ".jpeg", ".png", ".webp", ".gif"
        };
        if (!allowed.Contains(ext))
            return Ok(ApiResponse<UploadFileResponse>.Fail(ApiCodes.InvalidParams, "不支持的图片格式"));

        var webRoot = _env.WebRootPath;
        if (string.IsNullOrWhiteSpace(webRoot))
            webRoot = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");

        var uploadDir = Path.Combine(webRoot, "uploads");
        Directory.CreateDirectory(uploadDir);

        var fileName = $"{Guid.NewGuid():N}{ext.ToLowerInvariant()}";
        var savePath = Path.Combine(uploadDir, fileName);
        await using (var stream = System.IO.File.Create(savePath))
        {
            await file.CopyToAsync(stream);
        }

        return Ok(ApiResponse<UploadFileResponse>.Ok(new UploadFileResponse($"/uploads/{fileName}")));
    }
}

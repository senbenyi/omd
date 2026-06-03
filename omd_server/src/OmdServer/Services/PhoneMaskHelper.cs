namespace OmdServer.Services;

public static class PhoneMaskHelper
{
    public static string Mask(string phone)
    {
        if (phone.Length < 7) return phone;
        return phone[..3] + "****" + phone[^4..];
    }
}

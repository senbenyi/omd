import 'dart:math';

class HttpTool {
  static String generateRandomSubdomain({int length = 8}) {
    const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    final rand = Random.secure();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }
}

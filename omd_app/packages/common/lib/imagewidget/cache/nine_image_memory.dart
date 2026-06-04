import 'nine_image_cache_model.dart';

class NineImageMemory {
  List<NineImageCacheModel> imageModels = [];
  Map<String, NineImageCacheModel> adImageModels = {};

  NineImageCacheModel? getCache(String url, {bool isAd = false}) {
    NineImageCacheModel? result;
    if (isAd) {
      result = adImageModels[url];
      return result;
    }
    for (var i = imageModels.length - 1; i >= 0; i--) {
      NineImageCacheModel model = imageModels[i];
      if (model.url == url) {
        result = model;
        break;
      }
    }
    return result;
  }

  void saveModel(String url, NineImageCacheModel model) {
    if (model.isAd) {
      adImageModels[url] = model;
    }
    if (imageModels.length > 100) {
      imageModels.removeAt(0);
    }
    imageModels.add(model);
  }

  /// [imageModels] + [adImageModels] 中条目的字节合计（优先 [NineImageCacheModel.data]，否则 [NineImageCacheModel.size]），单位为 **KB**（四舍五入）。
  int totalCachedImageKb() {
    int sumBytes = 0;
    for (final NineImageCacheModel m in imageModels) {
      final int len = m.data?.length ?? m.size;
      if (len > 0) sumBytes += len;
    }
    for (final NineImageCacheModel m in adImageModels.values) {
      final int len = m.data?.length ?? m.size;
      if (len > 0) sumBytes += len;
    }
    if (sumBytes == 0) return 0;
    return (sumBytes / 1024).round();
  }
}

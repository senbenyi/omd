import 'package:base/log/nine_log.dart';
import 'package:common/http/go_domian_config.dart';
import 'package:common/http/go_http.dart';
import 'package:dio/dio.dart';
import 'package:network/base/base_response.dart';
import 'package:store/module/login/store_auth_models.dart';
import 'package:store/module/menu/menu_models.dart';

/// 菜单接口，与 [omd_api.openapi.yaml] 对齐。
class MenuApi {
  MenuApi._();

  static String categoriesApi(int storeId) =>
      '/stores/$storeId/menu/categories';

  static String saveCategoryApi(int storeId) =>
      '/stores/$storeId/menu/categories/save';

  static String combosApi(int storeId) => '/stores/$storeId/menu/combos';

  static String saveComboApi(int storeId) => '/stores/$storeId/menu/combos/save';

  static String comboDetailApi(int storeId, int comboId) =>
      '/stores/$storeId/menu/combos/$comboId';

  static String saveComboContentApi(int storeId, int comboId) =>
      '/stores/$storeId/menu/combos/$comboId/save-content';

  static String itemsApi(int storeId) => '/stores/$storeId/menu/items';

  static String itemDetailApi(int storeId, int itemId) =>
      '/stores/$storeId/menu/items/$itemId';

  static String saveItemApi(int storeId) => '/stores/$storeId/menu/items/save';

  static String updateItemStatusApi(int storeId) =>
      '/stores/$storeId/menu/items/status';

  static String updateItemSoldOutApi(int storeId) =>
      '/stores/$storeId/menu/items/sold-out';

  static const tagLibraryApi = '/menu/tag-library';

  static const saveTagGroupApi = '/menu/tag-library/groups/save';

  static const saveTagOptionApi = '/menu/tag-library/options/save';

  static const uploadFileApi = '/files/upload';

  static Future<StoreApiResponse<List<MenuCategoryModel>>> listCategories(
    int storeId,
  ) async {
    final response = await GoHttp.instance.get(
      url: categoriesApi(storeId),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseList(response, MenuCategoryModel.fromJson);
  }

  static Future<StoreApiResponse<MenuCategoryModel>> saveCategory(
    int storeId,
    SaveMenuCategoryRequest request,
  ) async {
    final response = await GoHttp.instance.post(
      url: saveCategoryApi(storeId),
      params: request.toJson(),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseObject(response, MenuCategoryModel.fromJson);
  }

  static Future<StoreApiResponse<List<MenuComboModel>>> listCombos(
    int storeId,
  ) async {
    final response = await GoHttp.instance.get(
      url: combosApi(storeId),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseList(response, MenuComboModel.fromJson);
  }

  static Future<StoreApiResponse<MenuComboDetailModel>> saveCombo(
    int storeId,
    SaveMenuComboRequest request,
  ) async {
    final response = await GoHttp.instance.post(
      url: saveComboApi(storeId),
      params: request.toJson(),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseObject(response, MenuComboDetailModel.fromJson);
  }

  static Future<StoreApiResponse<MenuComboDetailModel>> getComboDetail(
    int storeId,
    int comboId,
  ) async {
    final response = await GoHttp.instance.get(
      url: comboDetailApi(storeId, comboId),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseObject(response, MenuComboDetailModel.fromJson);
  }

  static Future<StoreApiResponse<MenuComboDetailModel>> saveComboContent(
    int storeId,
    int comboId,
    SaveMenuComboContentRequest request,
  ) async {
    final response = await GoHttp.instance.post(
      url: saveComboContentApi(storeId, comboId),
      params: request.toJson(),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseObject(response, MenuComboDetailModel.fromJson);
  }

  static Future<StoreApiResponse<MenuPagedList<MenuItemListModel>>> listItems({
    required int storeId,
    int? categoryId,
    String? status,
    bool? soldOut,
    int page = 1,
    int pageSize = 100,
  }) async {
    final response = await GoHttp.instance.get(
      url: itemsApi(storeId),
      queryParameters: {
        if (categoryId != null) 'categoryId': categoryId,
        if (status != null && status.isNotEmpty) 'status': status,
        if (soldOut != null) 'soldOut': soldOut,
        'page': page,
        'pageSize': pageSize,
      },
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parsePagedList(response, MenuItemListModel.fromJson);
  }

  static Future<StoreApiResponse<MenuItemDetailModel>> getItemDetail({
    required int storeId,
    required int itemId,
  }) async {
    final response = await GoHttp.instance.get(
      url: itemDetailApi(storeId, itemId),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseObject(response, MenuItemDetailModel.fromJson);
  }

  static Future<StoreApiResponse<Map<String, dynamic>>> saveItem(
    int storeId,
    SaveMenuItemRequest request,
  ) async {
    final response = await GoHttp.instance.post(
      url: saveItemApi(storeId),
      params: request.toJson(),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseObject(response, (json) => json);
  }

  static Future<StoreApiResponse<Map<String, dynamic>>> updateItemStatus(
    int storeId,
    UpdateMenuItemStatusRequest request,
  ) async {
    final response = await GoHttp.instance.post(
      url: updateItemStatusApi(storeId),
      params: request.toJson(),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseObject(response, (json) => json);
  }

  static Future<StoreApiResponse<Map<String, dynamic>>> updateItemSoldOut(
    int storeId,
    UpdateMenuItemSoldOutRequest request,
  ) async {
    final response = await GoHttp.instance.post(
      url: updateItemSoldOutApi(storeId),
      params: request.toJson(),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseObject(response, (json) => json);
  }

  static Future<StoreApiResponse<List<MenuTagGroupModel>>> listTagLibrary() async {
    final response = await GoHttp.instance.get(
      url: tagLibraryApi,
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseList(response, MenuTagGroupModel.fromJson);
  }

  static Future<StoreApiResponse<MenuTagGroupModel>> saveTagGroup(String name) async {
    final response = await GoHttp.instance.post(
      url: saveTagGroupApi,
      params: {'name': name},
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseObject(response, MenuTagGroupModel.fromJson);
  }

  static Future<StoreApiResponse<MenuTagOptionModel>> saveTagOption({
    required int groupId,
    required String value,
  }) async {
    final response = await GoHttp.instance.post(
      url: saveTagOptionApi,
      params: {'groupId': groupId, 'value': value},
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseObject(response, MenuTagOptionModel.fromJson);
  }

  static Future<StoreApiResponse<String>> uploadImage(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await GoHttp.instance.uploadFile(
      url: uploadFileApi,
      formData: formData,
      needToast: false,
    );
    if (!_isBusinessSuccess(response)) {
      return StoreApiResponse.failure(
        code: response.code.toString(),
        message: response.message.isNotEmpty ? response.message : '上传失败',
      );
    }
    final raw = response.data;
    if (raw is! Map) {
      return StoreApiResponse.failure(code: '1001', message: '上传响应格式错误');
    }
    final map = Map<String, dynamic>.from(raw);
    final url = map['url']?.toString() ?? '';
    if (url.isEmpty) {
      return StoreApiResponse.failure(code: '1001', message: '上传响应缺少 url');
    }
    return StoreApiResponse.success(_resolveUploadUrl(url), message: response.message);
  }

  static String _resolveUploadUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    final base = GoDomianConfig.instance.currentBaseUrl.replaceFirst(RegExp(r'/$'), '');
    final path = url.startsWith('/') ? url : '/$url';
    return '$base$path';
  }

  static bool _isBusinessSuccess(NineBaseResponse response) {
    if (response.error != null) return false;
    if (response.statusCode >= 400) return false;
    final code = response.code.toString();
    return code == '0' || code == '200';
  }

  static String _failureMessage(NineBaseResponse response) {
    if (response.message.isNotEmpty) return response.message;
    if (response.statusMessage.isNotEmpty) return response.statusMessage;
    return '请求失败';
  }

  static StoreApiResponse<T> _parseObject<T>(
    NineBaseResponse response,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (!_isBusinessSuccess(response)) {
      return StoreApiResponse.failure(
        code: response.code.toString(),
        message: _failureMessage(response),
      );
    }

    final raw = response.data;
    if (raw is! Map) {
      return StoreApiResponse.failure(code: '1001', message: '响应数据格式错误');
    }

    try {
      return StoreApiResponse.success(
        parser(Map<String, dynamic>.from(raw)),
        message: response.message.isNotEmpty ? response.message : 'ok',
      );
    } catch (e, stack) {
      NLog.e('MenuApi 解析对象失败: $e\n$stack');
      return StoreApiResponse.failure(code: '1001', message: '数据解析失败');
    }
  }

  static StoreApiResponse<List<T>> _parseList<T>(
    NineBaseResponse response,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (!_isBusinessSuccess(response)) {
      return StoreApiResponse.failure(
        code: response.code.toString(),
        message: _failureMessage(response),
      );
    }

    final raw = response.data;
    final List<dynamic> items;
    if (raw is List) {
      items = raw;
    } else if (raw is Map && raw['list'] is List) {
      items = raw['list'] as List<dynamic>;
    } else {
      NLog.e('MenuApi 列表格式异常 raw=$raw type=${raw.runtimeType}');
      return StoreApiResponse.failure(code: '1001', message: '响应数据格式错误');
    }

    final list = <T>[];
    for (final item in items) {
      if (item is! Map) continue;
      try {
        list.add(parser(Map<String, dynamic>.from(item)));
      } catch (e, stack) {
        NLog.e('MenuApi 解析列表项失败: $e item=$item\n$stack');
      }
    }

    return StoreApiResponse.success(
      list,
      message: response.message.isNotEmpty ? response.message : 'ok',
    );
  }

  static StoreApiResponse<MenuPagedList<T>> _parsePagedList<T>(
    NineBaseResponse response,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (!_isBusinessSuccess(response)) {
      return StoreApiResponse.failure(
        code: response.code.toString(),
        message: response.message.isNotEmpty ? response.message : '请求失败',
      );
    }

    final raw = response.data;
    if (raw is! Map) {
      return StoreApiResponse.failure(code: '1001', message: '响应数据格式错误');
    }

    final map = Map<String, dynamic>.from(raw);
    final listRaw = map['list'];
    final metaRaw = map['meta'];
    final items = listRaw is List ? listRaw : <dynamic>[];

    final list = <T>[];
    for (final item in items) {
      if (item is! Map) continue;
      try {
        list.add(parser(Map<String, dynamic>.from(item)));
      } catch (e, stack) {
        NLog.e('MenuApi 解析分页项失败: $e item=$item\n$stack');
      }
    }

    final meta = metaRaw is Map ? Map<String, dynamic>.from(metaRaw) : <String, dynamic>{};
    return StoreApiResponse.success(
      MenuPagedList<T>(
        list: list,
        page: _parseInt(meta['page'], def: 1),
        pageSize: _parseInt(meta['pageSize']),
        total: _parseInt(meta['total']),
      ),
      message: response.message.isNotEmpty ? response.message : 'ok',
    );
  }

  static int _parseInt(dynamic value, {int def = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? def;
    return def;
  }
}

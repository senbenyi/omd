import 'package:common/http/go_http.dart';
import 'package:customer/module/api/customer_api_parser.dart';
import 'package:customer/module/api/customer_api_response.dart';
import 'package:customer/module/store/customer_store_models.dart';

class CustomerStoreApi {
  CustomerStoreApi._();

  static const String storesApi = '/customer/stores';

  static Future<CustomerApiResponse<List<CustomerStoreModel>>> listStores() async {
    final response = await GoHttp.instance.get(
      url: storesApi,
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return CustomerApiParser.parseList(response, CustomerStoreModel.fromJson);
  }
}

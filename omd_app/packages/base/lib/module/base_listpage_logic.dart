import 'package:get/get.dart';

class BaseListpageLogic extends GetxController {
  var currentPage = 1.obs;
  var paginationToken = "".obs;
  var isLoading = false.obs;
  var totalPages = 1.obs;
  var showEmptyData = false.obs;
}

import 'base_response.dart';

class PageListData {
  List<dynamic> items;
  int pageIndex;
  int pageSize;
  int pageCount;
  int recordCount;
  int total;
  bool isSuccess;
  String paginationToken;

  PageListData({
    this.items = const [],
    this.pageIndex = 0,
    this.pageSize = 0,
    this.pageCount = 0,
    this.recordCount = 0,
    this.isSuccess = false,
    this.paginationToken = "",
    this.total = 0,
  });

  factory PageListData.fromResponse(
    NineBaseResponse response, {
    String listKey = "items",
  }) {
    if (response.isSuccess == false) {
      return PageListData();
    }
    int pageIndex = 0;
    int pageSize = 0;
    int pageCount = 0;
    int recordCount = 0;
    List<dynamic> items = [];
    if (response.data is List) {
      items = response.data;
    } else if (response.data is Map) {
      items = response.data[listKey] ?? [];
      pageIndex = int.parse(response.data["pageIndex"] ?? "0");
      pageSize = int.parse(response.data["pageSize"] ?? "0");
      pageCount = int.parse(response.data["pageCount"] ?? "0");
      recordCount = int.parse(response.data["recordCount"] ?? "0");
    }
    return PageListData(
      items: items,
      pageIndex: pageIndex,
      pageSize: pageSize,
      pageCount: pageCount,
      recordCount: recordCount,
      isSuccess: response.isSuccess,
    );
  }

  factory PageListData.fromResponseTwo(
    NineBaseResponse response, {
    String listKey = "data",
  }) {
    if (response.isSuccess == false) {
      return PageListData();
    }
    int pageIndex = 0;
    int pageSize = 0;
    int pageCount = 0;
    int total = 0;
    String paginationToken = "";
    List<dynamic> items = [];
    if (response.data is List) {
      items = response.data;
    } else if (response.data is Map) {
      items = response.data[listKey] ?? [];
      pageIndex = int.parse(response.data["page"] ?? "0");
      pageSize = int.parse(response.data["size"] ?? "0");
      pageCount = int.parse(response.data["pages"] ?? "0");
      total = int.parse(response.data["total"] ?? "0");
      paginationToken = response.data["paginationToken"] ?? "";
    }
    return PageListData(
      items: items,
      pageIndex: pageIndex,
      pageSize: pageSize,
      pageCount: pageCount,
      paginationToken: paginationToken,
      isSuccess: response.isSuccess,
      total: total,
    );
  }
}

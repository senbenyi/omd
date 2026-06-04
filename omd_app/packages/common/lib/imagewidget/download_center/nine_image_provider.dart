import 'package:base/theme/app_theme.dart';
import 'package:base/utils/app_channel.dart';
import 'package:event_bus/event_bus.dart';
import 'package:base/log/nine_log.dart';
import 'package:base/nine_globalkey.dart';
import 'package:flutter/foundation.dart';

import '../cache/image_db_manage.dart';
import '../widget/download_progress_tip.dart';
import '../nine_img_tool.dart';
import '../cache/nine_image_cache_model.dart';
import '../cache/nine_image_disk.dart';
import 'nine_image_down_loader.dart';
import 'nine_image_listener.dart';
import '../cache/nine_image_memory.dart';

EventBus downEventBus = EventBus();

class DownloadProgressModel {
  int all;
  int finish;
  int waitCount;
  int processing;
  DownloadProgressModel({
    required this.all,
    required this.finish,
    required this.waitCount,
    required this.processing,
  });
}

class NineImageProvider {
  static final _instanceSingle = NineImageProvider._internal();
  factory NineImageProvider() => _instanceSingle;
  static NineImageProvider get instance => NineImageProvider();
  NineImageProvider._internal() : super();

  late NineImageDownLoader downLoader;
  NineImageMemory imageMemory = NineImageMemory();
  // queues
  final List<NineImageCacheModel> _waitingQueue = [];
  final List<NineImageCacheModel> _processingQueue = [];
  List<NineImageSubscription> consumers = [];

  int addCount = 0;
  int finishCount = 0;
  int get maxCount => appChannel.channleType == ChannelType.tv ? 8 : 4;

  bool showImgeDebug = false;

  Future init() async {
    try {
      imgeLogD("图片线程开始创建");
      await NineImageDisk.createFolderAndSaveFile();
      await ImageDbManage.instance.initDataBase();
      downLoader = NineImageDownLoader();
      await downLoader.initIsolate();
      downLoader.onSuccess = (url, data) {
        finish(url, data);
      };
      downLoader.onFail = (url, err) {
        fail(url, err);
      };

      imgeLogD("图片线程创建成功");
      Future.delayed(Duration(seconds: 5), () {
        if (showImgeDebug && kDebugMode) {
          OverlayToast.show(globalKey.currentContext!, "测试测试");
        }
        ImageDbManage.instance.deleteExpiredData();
      });
    } catch (e) {
      NLog.e("图片Provider出事异常：$e");
    }
  }

  void cancelDownLoad(String url) {
    for (var i = 0; i < _waitingQueue.length; i++) {
      NineImageCacheModel model = _waitingQueue[i];
      if (model.url == url) {
        _waitingQueue.removeAt(i);
        imgeLogD("移出下载队列$url");
        break;
      }
    }
  }

  //去下载
  Future<Uint8List?> requestImageData(
    String url, {
    int priority = 1,
    bool isAd = false,
    bool needDecrypt = true,
    bool compressImage = true,
    int? cacheWidth,
    String title = "",
  }) async {
    if (url.isEmpty) {
      return null;
    }
    NineImageCacheModel? model = imageMemory.getCache(url, isAd: isAd);
    Uint8List modeData = model?.data ?? Uint8List(0);
    if (modeData.isNotEmpty && model != null) {
      model.changTime();
      // imageLog("从缓存读取到数据：$url");
      return model.data!;
    }
    Uint8List data = await NineImageDisk.readImage(url);
    if (data.isNotEmpty) {
      NineImageCacheModel diskModel = NineImageCacheModel(url: url, isAd: isAd);
      diskModel.data = data;
      diskModel.changTime();
      diskModel.size = data.length;
      imageMemory.saveModel(url, diskModel);
      ImageDbManage.instance.updateTime(url: diskModel.url);
      // imageLog("从磁盘读取到数据：$url----${data.length}");
      return data;
    }
    model = check(url);
    if (model == null) {
      model = NineImageCacheModel(
        url: url,
        isAd: isAd,
        needDecrypt: needDecrypt,
        compressImage: compressImage,
        compressCacheWidth: cacheWidth,
        title: title,
      );
      model.priority = priority;
      addCount += 1;
      if (_processingQueue.length < maxCount) {
        _processingQueue.add(model);
        downLoader.startFetchImg(
          url,
          needDecrypt: needDecrypt,
          compressImage: compressImage,
          compressCacheWidthPx: cacheWidth ?? 0,
          title: title,
        );
        imgeLogD("加入下载》〉》$url");
      } else {
        _waitingQueue.insert(0, model);
        imgeLogD("加入等待〉》$url");
      }
      //测试用
      if (showImgeDebug) {
        downEventBus.fire(
          DownloadProgressModel(
            all: addCount,
            finish: finishCount,
            waitCount: _waitingQueue.length,
            processing: _processingQueue.length,
          ),
        );
      }
    }

    Uint8List? dataList = await model.completer?.future;
    model.data = dataList;
    model.size = dataList != null ? dataList.length : 0;
    model.changTime();

    //测试用
    downEventBus.fire(
      DownloadProgressModel(
        all: addCount,
        finish: finishCount,
        waitCount: _waitingQueue.length,
        processing: _processingQueue.length,
      ),
    );
    return dataList;
  }

  //检查model是否存在
  NineImageCacheModel? check(String url) {
    NineImageCacheModel? cur;
    for (var i = _processingQueue.length - 1; i >= 0; i--) {
      NineImageCacheModel model = _processingQueue[i];
      if (model.url == url) {
        cur = model;
        break;
      }
    }
    if (cur != null) {
      return cur;
    }
    for (var i = _waitingQueue.length - 1; i >= 0; i--) {
      NineImageCacheModel model = _waitingQueue[i];
      if (model.url == url) {
        cur = model;
        break;
      }
    }
    return cur;
  }

  // 下载完成逻辑
  void finish(String url, Uint8List data) {
    for (var i = _processingQueue.length - 1; i >= 0; i--) {
      NineImageCacheModel model = _processingQueue[i];
      if (model.url == url) {
        model.data = data;
        if (model.completer != null && model.completer?.isCompleted == false) {
          model.completer?.complete(data);
          finishCount += 1;
          imgeLogD("下载完成哈哈哈>>>${data.length}-----$url");
        }
        imageMemory.saveModel(url, model);
        if (model.data != null && !model.url.contains(".gif")) {
          NineImageDisk.saveImage(url, model.data!);
          ImageDbManage.instance.insertOrUpdate(model: model);
        }
        _processingQueue.removeAt(i);
        break;
      }
    }
    next();
  }

  // 下载失败逻辑（不在此处触发二次下载，由上层自行决定是否再调 [requestImageData]）。
  void fail(String url, dynamic err) {
    imgeLogE("下载失败: $url, 错误: $err");
    for (var i = _processingQueue.length - 1; i >= 0; i--) {
      NineImageCacheModel model = _processingQueue[i];
      if (model.url == url) {
        // 完成 completer，传递 null 表示失败
        if (model.completer != null && model.completer?.isCompleted == false) {
          model.completer?.complete(null);
        }
        _processingQueue.removeAt(i);
        break;
      }
    }
    // 下载失败后，继续处理下一个任务
    next();
  }

  //下一个任务
  void next() {
    if (_waitingQueue.isEmpty) {
      return;
    }
    _waitingQueue.sort((a, b) {
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      return a.lastUpdateTime.compareTo(b.lastUpdateTime);
    });
    NineImageCacheModel model = _waitingQueue.removeAt(0);
    downLoader.startFetchImg(
      model.url,
      needDecrypt: model.needDecrypt,
      compressImage: model.compressImage,
      compressCacheWidthPx: model.compressCacheWidth ?? 0,
      title: model.title,
    );
    _processingQueue.add(model);
  }

  //改变优先级
  void changePriority(String url, int priority) {
    for (var i = 0; i < _waitingQueue.length; i++) {
      NineImageCacheModel model = _waitingQueue[i];
      if (model.url == url) {
        model.priority = priority;
      }
    }
  }

  void cancel(String url) {
    for (var i = 0; i < _waitingQueue.length; i++) {
      NineImageCacheModel model = _waitingQueue[i];
      if (model.url == url) {
        _waitingQueue.removeAt(i);
        break;
      }
    }
  }

  // 通知订阅者
  void notifi(String url, Uint8List data) {
    for (var i = consumers.length - 1; i >= 0; i--) {
      var e = consumers[i];
      if (e.imageUrl == url) {
        e.listenDataChange(data);
      }
    }
  }

  //添加监听
  void addSubScription(NineImageSubscription subscriptor) {
    if (subscriptor.imageUrl.isEmpty) {
      return;
    }
    //去重
    for (var i = consumers.length - 1; i >= 0; i--) {
      var e = consumers[i];
      if (e.uniqueKey == subscriptor.uniqueKey) {
        consumers.removeAt(i);
      }
    }
    consumers.add(subscriptor);
  }

  // 移除监听
  void removeSub(NineImageSubscription subscriptor) {
    if (subscriptor.imageUrl.isEmpty) {
      return;
    }
    //去重
    for (var i = consumers.length - 1; i >= 0; i--) {
      var e = consumers[i];
      if (e.uniqueKey == subscriptor.uniqueKey) {
        consumers.removeAt(i);
      }
    }
  }
}

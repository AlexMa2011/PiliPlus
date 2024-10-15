import 'package:PiliPalaX/grpc/app/main/community/reply/v1/reply.pb.dart';
import 'package:PiliPalaX/http/loading_state.dart';
import 'package:PiliPalaX/pages/common/common_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/http/reply.dart';
import 'package:PiliPalaX/models/common/reply_type.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class VideoReplyReplyController extends CommonController
    with GetTickerProviderStateMixin {
  VideoReplyReplyController(
    this.hasRoot,
    this.id,
    this.aid,
    this.rpid,
    this.replyType,
  );
  final itemScrollCtr = ItemScrollController();
  bool hasRoot = false;
  int? id;
  // 视频aid 请求时使用的oid
  int? aid;
  // rpid 请求楼中楼回复
  String? rpid;
  ReplyType replyType; // = ReplyType.video;
  // 当前页
  RxString noMore = ''.obs;
  // 当前回复的回复
  ReplyInfo? currentReplyItem;

  CursorReply? cursor;
  Rx<Mode> mode = Mode.MAIN_LIST_TIME.obs;
  RxInt count = (-1).obs;
  int? upMid;

  int? index;
  AnimationController? controller;
  Animation<Color?>? colorAnimation;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  // @override
  // bool customHandleResponse(Success response) {
  //   if (response.response.root != null) root = response.response.root;
  //   List<ReplyItemModel> replies = response.response.replies;
  //   if (replies.isNotEmpty) {
  //     noMore.value = '加载中...';
  //     if (replies.length == response.response.page.count) {
  //       noMore.value = '没有更多了';
  //     }
  //   } else {
  //     // 未登录状态replies可能返回null
  //     noMore.value = currentPage == 1 ? '还没有评论' : '没有更多了';
  //   }
  //   if (currentPage != 1) {
  //     List<ReplyItemModel> list = loadingState.value is Success
  //         ? (loadingState.value as Success).response
  //         : <ReplyItemModel>[];
  //     // 每次回复之后，翻页请求有且只有相同的一条回复数据
  //     if (replies.length == 1 && replies.last.rpid == list.last.rpid) {
  //       return true;
  //     } else {
  //       replies.insertAll(0, list);
  //     }
  //   }
  //   loadingState.value = LoadingState.success(replies);
  //   return true;
  // }

  @override
  Future queryData([bool isRefresh = true]) {
    if (['没有更多了', '还没有评论'].contains(noMore.value)) return Future.value();
    return super.queryData(isRefresh);
  }

  // @override
  // Future<LoadingState> customGetData() => ReplyHttp.replyReplyList(
  //       oid: aid!,
  //       root: rpid!,
  //       pageNum: currentPage,
  //       type: replyType.index,
  //     );

  @override
  Future onRefresh() {
    cursor = null;
    return super.onRefresh();
  }

  @override
  bool customHandleResponse(Success response) {
    DetailListReply replies = response.response;
    if (cursor == null) {
      count.value = replies.root.count.toInt();
      if (id != null) {
        index = replies.root.replies
            .map((item) => item.id.toInt())
            .toList()
            .indexOf(id!);
        if (index != -1) {
          controller = AnimationController(
            duration: const Duration(milliseconds: 300),
            vsync: this,
          );
          colorAnimation = ColorTween(
            begin: Theme.of(Get.context!).colorScheme.onInverseSurface,
            end: Theme.of(Get.context!).colorScheme.surface,
          ).animate(controller!);
          () async {
            await Future.delayed(const Duration(milliseconds: 200));
            itemScrollCtr.jumpTo(
              index: hasRoot ? index! + 3 : index! + 1, alignment: 0.25,
              // duration: const Duration(milliseconds: 200),
            );
            await Future.delayed(const Duration(milliseconds: 800));
            await controller?.forward();
            index = null;
          }();
        }
        id = null;
      }
    }
    upMid ??= replies.subjectControl.upMid.toInt();
    cursor = replies.cursor;
    if (replies.root.replies.isNotEmpty) {
      noMore.value = '加载中...';
      if (replies.cursor.isEnd) {
        noMore.value = '没有更多了';
      }
    } else {
      // 未登录状态replies可能返回null
      noMore.value = currentPage == 1 ? '还没有评论' : '没有更多了';
    }
    if (currentPage != 1) {
      List<ReplyInfo> list = loadingState.value is Success
          ? (loadingState.value as Success).response
          : <ReplyInfo>[];
      replies.root.replies.insertAll(0, list);
    }
    loadingState.value = LoadingState.success(replies.root.replies);
    return true;
  }

  @override
  Future<LoadingState> customGetData() => ReplyHttp.replyReplyListGrpc(
        type: replyType.index,
        oid: aid!,
        root: int.parse(rpid!),
        rpid: id ?? 0,
        cursor: CursorReq(
          next: cursor?.next,
          mode: mode.value,
        ),
      );

  queryBySort() {
    noMore.value = '';
    mode.value = mode.value == Mode.MAIN_LIST_HOT
        ? Mode.MAIN_LIST_TIME
        : Mode.MAIN_LIST_HOT;
    loadingState.value = LoadingState.loading();
    onRefresh();
  }
}

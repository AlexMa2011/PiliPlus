import 'package:PiliPalaX/grpc/app/dynamic/v2/dynamic.pb.dart';
import 'package:PiliPalaX/http/loading_state.dart';
import 'package:PiliPalaX/http/member.dart';
import 'package:PiliPalaX/pages/common/common_controller.dart';

class MemberDynamicCtr extends CommonController {
  MemberDynamicCtr({
    required this.mid,
  });
  int mid;
  bool isEnd = false;

  @override
  void onInit() {
    super.onInit();
    // queryData();
  }

  @override
  Future onRefresh() {
    isEnd = false;
    return super.onRefresh();
  }

  @override
  Future queryData([bool isRefresh = true]) {
    if (isEnd) return Future.value();
    return super.queryData(isRefresh);
  }

  @override
  bool customHandleResponse(Success response) {
    DynSpaceRsp res = response.response;
    isEnd = !res.hasMore;
    if (currentPage != 1) {
      res.list.insertAll(
          0, (loadingState.value as Success?)?.response ?? <DynamicItem>[]);
    }
    loadingState.value = LoadingState.success(res.list);
    return true;
  }

  @override
  Future<LoadingState> customGetData() => MemberHttp.spaceDynamic(
        mid: mid,
        page: currentPage,
      );
}

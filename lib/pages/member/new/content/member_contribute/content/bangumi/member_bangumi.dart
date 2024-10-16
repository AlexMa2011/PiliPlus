import 'package:PiliPalaX/common/constants.dart';
import 'package:PiliPalaX/common/widgets/http_error.dart';
import 'package:PiliPalaX/http/loading_state.dart';
import 'package:PiliPalaX/pages/bangumi/widgets/bangumi_card_v_member_home.dart';
import 'package:PiliPalaX/pages/member/new/content/member_contribute/content/bangumi/member_bangumi_ctr.dart';
import 'package:PiliPalaX/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberBangumi extends StatefulWidget {
  const MemberBangumi({
    super.key,
    required this.heroTag,
    required this.mid,
  });

  final String? heroTag;
  final int mid;

  @override
  State<MemberBangumi> createState() => _MemberBangumiState();
}

class _MemberBangumiState extends State<MemberBangumi>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final _controller = Get.put(
    MemberBangumiCtr(
      heroTag: widget.heroTag,
      mid: widget.mid,
    ),
    tag: widget.heroTag,
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() => _buildBody(_controller.loadingState.value));
  }

  _buildBody(LoadingState loadingState) {
    return loadingState is Success
        ? RefreshIndicator(
            onRefresh: () async {
              await _controller.onRefresh();
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: StyleString.safeSpace,
                    right: StyleString.safeSpace,
                    top: StyleString.safeSpace,
                    bottom: StyleString.safeSpace +
                        MediaQuery.of(context).padding.bottom,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithExtentAndRatio(
                      mainAxisSpacing: StyleString.cardSpace - 2,
                      crossAxisSpacing: StyleString.cardSpace,
                      maxCrossAxisExtent: Grid.maxRowWidth / 3 * 2,
                      childAspectRatio: 0.65,
                      mainAxisExtent:
                          MediaQuery.textScalerOf(context).scale(60),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == loadingState.response.length - 1) {
                          _controller.onLoadMore();
                        }
                        return BangumiCardVMemberHome(
                          bangumiItem: loadingState.response[index],
                        );
                      },
                      childCount: loadingState.response.length,
                    ),
                  ),
                ),
              ],
            ),
          )
        : loadingState is Error
            ? Center(
                child: CustomScrollView(
                  shrinkWrap: true,
                  slivers: [
                    HttpError(
                      errMsg: loadingState.errMsg,
                      fn: _controller.onReload,
                    ),
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              );
  }
}

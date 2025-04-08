import 'dart:async';

import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/pages/common/common_page.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/widgets/http_error.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../../common/skeleton/dynamic_card.dart';
import '../../../utils/grid.dart';

import '../index.dart';
import '../widgets/dynamic_panel.dart';
import 'controller.dart';

class DynamicsTabPage extends CommonPage {
  const DynamicsTabPage({super.key, required this.dynamicsType});

  final String dynamicsType;

  @override
  State<DynamicsTabPage> createState() => _DynamicsTabPageState();
}

class _DynamicsTabPageState
    extends CommonPageState<DynamicsTabPage, DynamicsTabController>
    with AutomaticKeepAliveClientMixin {
  late bool dynamicsWaterfallFlow;
  StreamSubscription? _listener;

  DynamicsController dynamicsController = Get.put(DynamicsController());
  @override
  late DynamicsTabController controller = Get.put(
    DynamicsTabController(dynamicsType: widget.dynamicsType)
      ..mid = dynamicsController.mid.value,
    tag: widget.dynamicsType,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.dynamicsType == 'up') {
      _listener = dynamicsController.mid.listen((mid) {
        controller.mid = mid;
        controller.scrollController.jumpTo(0);
        controller.onReload();
      });
    }
    dynamicsWaterfallFlow = GStorage.setting
        .get(SettingBoxKey.dynamicsWaterfallFlow, defaultValue: true);
  }

  @override
  void dispose() {
    _listener?.cancel();
    dynamicsController.mid.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // debugPrint(widget.dynamicsType + widget.mid.value.toString());
    return refreshIndicator(
      // key:
      //     ValueKey<String>(widget.dynamicsType + widget.mid.value.toString()),
      onRefresh: () async {
        dynamicsWaterfallFlow = GStorage.setting
            .get(SettingBoxKey.dynamicsWaterfallFlow, defaultValue: true);
        await Future.wait([
          controller.onRefresh(),
          dynamicsController.queryFollowUp(),
        ]);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: controller.scrollController,
        slivers: [
          Obx(() => _buildBody(controller.loadingState.value)),
        ],
      ),
    );
  }

  Widget skeleton() {
    if (!dynamicsWaterfallFlow) {
      return SliverCrossAxisGroup(
        slivers: [
          const SliverFillRemaining(),
          SliverConstrainedCrossAxis(
            maxExtent: Grid.smallCardWidth * 2,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return const DynamicCardSkeleton();
                },
                childCount: 10,
              ),
            ),
          ),
          const SliverFillRemaining()
        ],
      );
    }
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithExtentAndRatio(
        crossAxisSpacing: StyleString.cardSpace / 2,
        mainAxisSpacing: StyleString.cardSpace / 2,
        maxCrossAxisExtent: Grid.smallCardWidth * 2,
        childAspectRatio: StyleString.aspectRatio,
        mainAxisExtent: 50,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return const DynamicCardSkeleton();
        },
        childCount: 10,
      ),
    );
  }

  Widget _buildBody(LoadingState loadingState) {
    return switch (loadingState) {
      Loading() => skeleton(),
      Success() => (loadingState.response as List?)?.isNotEmpty == true
          ? dynamicsWaterfallFlow
              ? SliverWaterfallFlow.extent(
                  maxCrossAxisExtent: Grid.smallCardWidth * 2,
                  //cacheExtent: 0.0,
                  crossAxisSpacing: StyleString.cardSpace / 2,
                  // mainAxisSpacing: StyleString.cardSpace / 2,

                  lastChildLayoutTypeBuilder: (index) {
                    if (index == loadingState.response.length - 1) {
                      controller.onLoadMore();
                    }
                    return index == loadingState.response.length
                        ? LastChildLayoutType.foot
                        : LastChildLayoutType.none;
                  },
                  children: [
                    if (dynamicsController.tabController.index == 4 &&
                        dynamicsController.mid.value != -1) ...[
                      for (var i in loadingState.response)
                        DynamicPanel(
                          item: i,
                          onRemove: controller.onRemove,
                        ),
                    ] else ...[
                      for (var i in loadingState.response)
                        if (!dynamicsController.tempBannedList
                            .contains(i.modules?.moduleAuthor?.mid))
                          DynamicPanel(
                            item: i,
                            onRemove: controller.onRemove,
                          ),
                    ]
                  ],
                )
              : SliverCrossAxisGroup(
                  slivers: [
                    const SliverFillRemaining(),
                    SliverConstrainedCrossAxis(
                      maxExtent: Grid.smallCardWidth * 2,
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == loadingState.response.length - 1) {
                              controller.onLoadMore();
                            }
                            if ((dynamicsController.tabController.index == 4 &&
                                    dynamicsController.mid.value != -1) ||
                                !dynamicsController.tempBannedList.contains(
                                    loadingState.response[index].modules
                                        ?.moduleAuthor?.mid)) {
                              return DynamicPanel(
                                item: loadingState.response[index],
                                onRemove: controller.onRemove,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          childCount: loadingState.response.length,
                        ),
                      ),
                    ),
                    const SliverFillRemaining(),
                  ],
                )
          : HttpError(
              callback: controller.onReload,
            ),
      Error() => HttpError(
          errMsg: loadingState.errMsg,
          callback: controller.onReload,
        ),
      LoadingState() => throw UnimplementedError(),
    };
  }
}

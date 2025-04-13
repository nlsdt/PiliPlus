import 'package:PiliPlus/common/widgets/image_save.dart';
import 'package:PiliPlus/common/widgets/loading_widget.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:flutter/material.dart';
import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/network_img_layer.dart';
import 'package:PiliPlus/utils/utils.dart';

import '../../../utils/grid.dart';

Widget searchBangumiPanel(
    context, ctr, LoadingState<List<dynamic>?> loadingState) {
  late TextStyle style = TextStyle(fontSize: 13);
  return switch (loadingState) {
    Loading() => loadingWidget,
    Success() => loadingState.response?.isNotEmpty == true
        ? CustomScrollView(
            controller: ctr.scrollController,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 80,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: Grid.smallCardWidth * 2,
                    mainAxisExtent: 160,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      if (index == loadingState.response!.length - 1) {
                        ctr.onLoadMore();
                      }
                      var i = loadingState.response![index];
                      return InkWell(
                        onTap: () {
                          Utils.viewBangumi(seasonId: i.seasonId);
                        },
                        onLongPress: () => imageSaveDialog(
                          context: context,
                          title: (i.title as List?)
                                  ?.map((item) => item['text'])
                                  .join() ??
                              '',
                          cover: i.cover,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: StyleString.safeSpace,
                            vertical: StyleString.cardSpace,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  NetworkImgLayer(
                                    width: 111,
                                    height: 148,
                                    src: i.cover,
                                  ),
                                  PBadge(
                                    text: i.seasonTypeName,
                                    top: 6.0,
                                    right: 4.0,
                                    bottom: null,
                                    left: null,
                                  )
                                ],
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text.rich(
                                      // maxLines: 1,
                                      // overflow: TextOverflow.ellipsis,
                                      TextSpan(
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                        children: [
                                          for (var i in i.title) ...[
                                            TextSpan(
                                              text: i['text'],
                                              style: TextStyle(
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .fontSize!,
                                                fontWeight: FontWeight.bold,
                                                color: i['type'] == 'em'
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                        '评分:${i.mediaScore['score'].toString()}',
                                        style: style),
                                    Row(
                                      children: [
                                        Text(i.areas, style: style),
                                        const SizedBox(width: 3),
                                        const Text('·'),
                                        const SizedBox(width: 3),
                                        Text(
                                            Utils.dateFormat(i.pubtime)
                                                .toString(),
                                            style: style),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(i.styles, style: style),
                                        const SizedBox(width: 3),
                                        const Text('·'),
                                        const SizedBox(width: 3),
                                        Text(i.indexShow, style: style),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: loadingState.response!.length,
                  ),
                ),
              ),
            ],
          )
        : errorWidget(
            callback: ctr.onReload,
          ),
    Error() => errorWidget(
        errMsg: loadingState.errMsg,
        callback: ctr.onReload,
      ),
    LoadingState() => throw UnimplementedError(),
  };
}

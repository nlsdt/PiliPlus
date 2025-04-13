import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/icon_button.dart';
import 'package:PiliPlus/common/widgets/network_img_layer.dart';
import 'package:PiliPlus/models/bangumi/list.dart';
import 'package:PiliPlus/pages/common/multi_select_controller.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';

class FavPgcItem extends StatelessWidget {
  const FavPgcItem({
    super.key,
    required this.item,
    required this.ctr,
    required this.onSelect,
    required this.onUpdateStatus,
  });

  final BangumiListItemModel item;
  final MultiSelectController ctr;
  final VoidCallback onSelect;
  final VoidCallback onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: () {
              if (ctr.enableMultiSelect.value) {
                onSelect();
                return;
              }
              Utils.viewBangumi(seasonId: item.seasonId);
            },
            onLongPress: () {
              if (!ctr.enableMultiSelect.value) {
                ctr.enableMultiSelect.value = true;
                onSelect();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: StyleString.safeSpace,
                vertical: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: LayoutBuilder(
                      builder: (BuildContext context,
                          BoxConstraints boxConstraints) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            NetworkImgLayer(
                              radius: 4,
                              src: item.cover,
                              width: boxConstraints.maxWidth,
                              height: boxConstraints.maxHeight,
                            ),
                            PBadge(
                              right: 4,
                              top: 4,
                              text: item.badge,
                              fs: 10,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 1,
                              ),
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: LayoutBuilder(
                                  builder: (context, constraints) =>
                                      AnimatedOpacity(
                                    opacity: item.checked == true ? 1 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: constraints.maxHeight,
                                      width: constraints.maxHeight *
                                          StyleString.aspectRatio,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.black.withOpacity(0.6),
                                      ),
                                      child: SizedBox(
                                        width: 34,
                                        height: 34,
                                        child: AnimatedScale(
                                          scale: item.checked == true ? 1 : 0,
                                          duration:
                                              const Duration(milliseconds: 250),
                                          curve: Curves.easeInOut,
                                          child: IconButton(
                                            tooltip: '取消选择',
                                            style: ButtonStyle(
                                              padding: WidgetStateProperty.all(
                                                  EdgeInsets.zero),
                                              backgroundColor:
                                                  WidgetStateProperty
                                                      .resolveWith(
                                                (states) {
                                                  return Theme.of(context)
                                                      .colorScheme
                                                      .surface
                                                      .withOpacity(0.8);
                                                },
                                              ),
                                            ),
                                            onPressed: null,
                                            icon: Icon(
                                              Icons.done_all_outlined,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title!),
                        if (item.newEp?['index_show'] != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${item.newEp?['index_show']}${item.isFinish == 0 && item.renewalTime?.isNotEmpty == true ? '，${item.renewalTime}' : ''}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (item.progress != null) ...[
                          SizedBox(
                              height:
                                  item.newEp?['index_show'] != null ? 2 : 6),
                          Text(
                            item.progress!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 0,
            child: iconButton(
              iconSize: 20,
              context: context,
              onPressed: onUpdateStatus,
              icon: Icons.more_vert,
              iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
              bgColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

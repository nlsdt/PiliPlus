import 'dart:async';

import 'package:PiliPlus/pages/video/detail/introduction/controller.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/models/video_detail_res.dart';
import 'package:PiliPlus/pages/video/detail/index.dart';

class SeasonPanel extends StatefulWidget {
  const SeasonPanel({
    super.key,
    required this.changeFuc,
    required this.heroTag,
    required this.showEpisodes,
    this.onTap,
    required this.videoIntroController,
  });
  final Function changeFuc;
  final String heroTag;
  final Function showEpisodes;
  final bool? onTap;
  final VideoIntroController videoIntroController;

  @override
  State<SeasonPanel> createState() => _SeasonPanelState();
}

class _SeasonPanelState extends State<SeasonPanel> {
  RxInt currentIndex = 0.obs;
  late VideoDetailController _videoDetailController;
  StreamSubscription? _listener;
  List<EpisodeItem> episodes = <EpisodeItem>[];

  VideoIntroController get videoIntroController => widget.videoIntroController;
  VideoDetailData get videoDetail =>
      widget.videoIntroController.videoDetail.value;

  @override
  void initState() {
    super.initState();
    _videoDetailController =
        Get.find<VideoDetailController>(tag: widget.heroTag);

    _videoDetailController.seasonCid =
        videoIntroController.lastPlayCid.value != 0
            ? (videoDetail.pages?.isNotEmpty == true
                ? videoDetail.isPageReversed
                    ? videoDetail.pages!.last.cid
                    : videoDetail.pages!.first.cid
                : videoIntroController.lastPlayCid.value)
            : videoDetail.isPageReversed
                ? videoDetail.pages!.last.cid
                : videoDetail.pages!.first.cid;

    /// 根据 cid 找到对应集，找到对应 episodes
    /// 有多个episodes时，只显示其中一个
    _findEpisode();
    if (episodes.isEmpty) {
      return;
    }

    /// 取对应 season_id 的 episodes
    // episodes = widget.ugcSeason.sections!
    //     .firstWhere((e) => e.seasonId == widget.ugcSeason.id)
    //     .episodes;
    currentIndex.value = episodes.indexWhere(
        (EpisodeItem e) => e.cid == _videoDetailController.seasonCid);
    _listener = _videoDetailController.cid.listen((int cid) {
      if (_videoDetailController.seasonCid != cid) {
        bool isPart =
            videoDetail.pages?.indexWhere((item) => item.cid == cid) != -1;
        if (isPart.not) {
          _videoDetailController.seasonCid = cid;
        }
      }
      _findEpisode();
      currentIndex.value = episodes.indexWhere(
          (EpisodeItem e) => e.cid == _videoDetailController.seasonCid);
    });
  }

  @override
  void dispose() {
    _listener?.cancel();
    super.dispose();
  }

  // void changeFucCall(item, int i) async {
  //   await widget.changeFuc!(
  //     IdUtils.av2bv(item.aid),
  //     item.cid,
  //     item.aid,
  //   );
  //   currentIndex = i;
  //   Get.back();
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    if (episodes.isEmpty) {
      return const SizedBox();
    }
    return Builder(builder: (BuildContext context) {
      return Container(
        margin: const EdgeInsets.only(
          top: 8,
          left: 2,
          right: 2,
        ),
        child: Material(
          color: Theme.of(context).colorScheme.onInverseSurface,
          borderRadius: BorderRadius.circular(6),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: widget.onTap == false
                ? null
                : () => widget.showEpisodes(
                      _videoDetailController.seasonIndex.value,
                      videoDetail.ugcSeason,
                      null,
                      _videoDetailController.bvid,
                      null,
                      _videoDetailController.seasonCid,
                    ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '合集：${videoDetail.ugcSeason!.title!}',
                      style: Theme.of(context).textTheme.labelMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Image.asset(
                    'assets/images/live.png',
                    color: Theme.of(context).colorScheme.primary,
                    height: 12,
                    semanticLabel: "正在播放：",
                  ),
                  const SizedBox(width: 10),
                  Obx(
                    () => Text(
                      '${currentIndex.value + 1}/${episodes.length}',
                      style: Theme.of(context).textTheme.labelMedium,
                      semanticsLabel:
                          '第${currentIndex.value + 1}集，共${episodes.length}集',
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 13,
                    semanticLabel: '查看',
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _findEpisode() {
    final List<SectionItem> sections = videoDetail.ugcSeason!.sections!;
    for (int i = 0; i < sections.length; i++) {
      final List<EpisodeItem> episodesList = sections[i].episodes!;
      for (int j = 0; j < episodesList.length; j++) {
        if (episodesList[j].cid == _videoDetailController.seasonCid) {
          if (_videoDetailController.seasonIndex.value != i) {
            _videoDetailController.seasonIndex.value = i;
          }
          episodes = episodesList;
          break;
        }
      }
    }
  }
}

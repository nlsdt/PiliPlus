import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:PiliPlus/pages/live_room/send_dm_panel.dart';
import 'package:PiliPlus/pages/live_room/widgets/chat.dart';
import 'package:PiliPlus/pages/live_room/widgets/header_control.dart';
import 'package:PiliPlus/services/service_locator.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/common/widgets/network_img_layer.dart';
import 'package:PiliPlus/plugin/pl_player/index.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../../utils/storage.dart';
import 'controller.dart';
import 'widgets/bottom_control.dart';

class LiveRoomPage extends StatefulWidget {
  const LiveRoomPage({super.key});

  @override
  State<LiveRoomPage> createState() => _LiveRoomPageState();
}

class _LiveRoomPageState extends State<LiveRoomPage>
    with WidgetsBindingObserver {
  late final int _roomId;
  late final LiveRoomController _liveRoomController;
  late final PlPlayerController plPlayerController;
  late Future? _futureBuilder;
  late Future? _futureBuilderFuture;
  bool get isFullScreen => plPlayerController.isFullScreen.value;

  bool isShowCover = true;
  bool isPlay = true;
  Floating? floating;

  StreamSubscription? _listener;

  int latestAddedPosition = -1;
  bool? _isFullScreen;
  bool? _isPipMode;

  void playCallBack() {
    plPlayerController.play();
  }

  late final String heroTag;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _roomId = int.parse(Get.parameters['roomid'] ?? '-1');
    heroTag = Utils.makeHeroTag(_roomId);
    _liveRoomController = Get.put(
      LiveRoomController(heroTag),
      tag: heroTag,
    );
    PlPlayerController.setPlayCallBack(playCallBack);
    if (Platform.isAndroid) {
      floating = Floating();
    }
    videoSourceInit();
    _futureBuilderFuture = _liveRoomController.queryLiveInfo();
    plPlayerController.autoEnterFullscreen();
    plPlayerController.addStatusLister(playerListener);
    _listener = plPlayerController.isFullScreen.listen((isFullScreen) {
      if (isFullScreen != _isFullScreen) {
        _isFullScreen = isFullScreen;
        _updateFontSize();
      }
    });
  }

  void playerListener(PlayerStatus? status) {
    if (status != PlayerStatus.playing) {
      plPlayerController.danmakuController?.pause();
      _liveRoomController.msgStream?.close();
    } else {
      plPlayerController.danmakuController?.resume();
      _liveRoomController.liveMsg();
    }
  }

  void _updateFontSize() async {
    if (Platform.isAndroid) {
      _isPipMode =
          await const MethodChannel("floating").invokeMethod('inPipAlready');
    }
    if (_liveRoomController.controller != null) {
      _liveRoomController.controller!.updateOption(
        _liveRoomController.controller!.option.copyWith(
          fontSize: _getFontSize(isFullScreen),
        ),
      );
    }
  }

  double _getFontSize(isFullScreen) {
    return isFullScreen == false || _isPipMode == true
        ? 15 * plPlayerController.fontSize
        : 15 * plPlayerController.fontSizeFS;
  }

  void videoSourceInit() {
    _futureBuilder = _liveRoomController.queryLiveInfoH5();
    plPlayerController = _liveRoomController.plPlayerController;
  }

  @override
  void dispose() {
    videoPlayerServiceHandler.onVideoDetailDispose(heroTag);
    _listener?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    ScreenBrightness().resetApplicationScreenBrightness();
    PlPlayerController.setPlayCallBack(null);
    _liveRoomController.msgStream?.close();
    // floating?.dispose();
    plPlayerController.removeStatusLister(playerListener);
    plPlayerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _liveRoomController.showDanmaku = true;
    } else if (state == AppLifecycleState.paused) {
      _liveRoomController.showDanmaku = false;
      plPlayerController.danmakuController?.clear();
    }
  }

  final GlobalKey videoPlayerKey = GlobalKey();
  final GlobalKey playerKey = GlobalKey();
  double? padding;

  Widget videoPlayerPanel({Color? fill, Alignment? alignment}) {
    return PopScope(
      canPop: !isFullScreen,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (isFullScreen) {
          plPlayerController.triggerFullScreen(status: false);
        }
      },
      child: FutureBuilder(
        key: videoPlayerKey,
        future: _futureBuilderFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data['status']) {
            return PLVideoPlayer(
              key: playerKey,
              fill: fill,
              alignment: alignment,
              plPlayerController: plPlayerController,
              headerControl: LiveHeaderControl(
                plPlayerController: plPlayerController,
                floating: floating,
                onSendDanmaku: onSendDanmaku,
              ),
              bottomControl: BottomControl(
                plPlayerController: plPlayerController,
                liveRoomCtr: _liveRoomController,
                onRefresh: () {
                  _futureBuilderFuture = _liveRoomController.queryLiveInfo();
                },
              ),
              danmuWidget: Obx(
                () => AnimatedOpacity(
                  opacity: plPlayerController.isOpenDanmu.value ? 1 : 0,
                  duration: const Duration(milliseconds: 100),
                  child: DanmakuScreen(
                    createdController: (DanmakuController e) {
                      plPlayerController.danmakuController =
                          _liveRoomController.controller = e;
                    },
                    option: DanmakuOption(
                      fontSize: _getFontSize(isFullScreen),
                      fontWeight: plPlayerController.fontWeight,
                      area: plPlayerController.showArea,
                      opacity: plPlayerController.opacity,
                      hideTop: plPlayerController.blockTypes.contains(5),
                      hideScroll: plPlayerController.blockTypes.contains(2),
                      hideBottom: plPlayerController.blockTypes.contains(4),
                      duration: plPlayerController.danmakuDuration /
                          plPlayerController.playbackSpeed,
                      staticDuration: plPlayerController.danmakuStaticDuration /
                          plPlayerController.playbackSpeed,
                      strokeWidth: plPlayerController.strokeWidth,
                      lineHeight: plPlayerController.danmakuLineHeight,
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget childWhenDisabled(bool isPortrait) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          Obx(
            () => isFullScreen
                ? const SizedBox.shrink()
                : Positioned.fill(
                    child: Opacity(
                      opacity: 0.6,
                      child: _liveRoomController.roomInfoH5.value.roomInfo
                                  ?.appBackground?.isNotEmpty ==
                              true
                          ? CachedNetworkImage(
                              fit: BoxFit.cover,
                              width: Get.width,
                              height: Get.height,
                              imageUrl: _liveRoomController.roomInfoH5.value
                                  .roomInfo!.appBackground!.http2https,
                            )
                          : Image.asset(
                              'assets/images/live/default_bg.webp',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
          ),
          isPortrait
              ? Obx(
                  () {
                    if (_liveRoomController.isPortrait.value) {
                      if (padding == null) {
                        final padding = MediaQuery.paddingOf(context);
                        this.padding = padding.bottom + padding.top;
                      }
                      return _buildPP;
                    }
                    return _buildPH;
                  },
                )
              : Column(
                  children: [
                    Obx(() => _buildAppBar),
                    _buildBodyH,
                  ],
                ),
        ],
      ),
    );
  }

  Widget get _buildPH => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar,
        backgroundColor: Colors.transparent,
        body: Column(
          children: _buildBodyP,
        ),
      );

  Widget get _buildPP => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            _buildAppBar,
            Column(
              children: [
                Obx(
                  () => Container(
                    color: Colors.black,
                    width: Get.width,
                    margin: isFullScreen
                        ? null
                        : EdgeInsets.only(
                            top: 56 + MediaQuery.paddingOf(context).top,
                          ),
                    height: isFullScreen
                        ? Get.height -
                            (context.orientation == Orientation.landscape
                                ? 0
                                : MediaQuery.paddingOf(context).top)
                        : Get.height - 56 - 85 - padding!,
                    child: videoPlayerPanel(
                      alignment: isFullScreen ? null : Alignment.topCenter,
                    ),
                  ),
                ),
              ],
            ),
            Obx(
              () => isFullScreen
                  ? const SizedBox.shrink()
                  : Positioned(
                      left: 0,
                      right: 0,
                      bottom: 125 + MediaQuery.paddingOf(context).bottom,
                      child: SizedBox(
                        height: 125,
                        child: _buildChatWidget(true),
                      ),
                    ),
            ),
            Obx(
              () => isFullScreen
                  ? const SizedBox.shrink()
                  : Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 0),
                        child: _buildInputWidget,
                      ),
                    ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFontSize();
    });
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        if (Platform.isAndroid) {
          return PiPSwitcher(
            getChildWhenDisabled: () =>
                childWhenDisabled(orientation == Orientation.portrait),
            getChildWhenEnabled: () => videoPlayerPanel(),
            floating: floating,
          );
        } else {
          return childWhenDisabled(orientation == Orientation.portrait);
        }
      },
    );
  }

  final Color _color = Color(0xFFEEEEEE);

  PreferredSizeWidget get _buildAppBar => AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        toolbarHeight: isFullScreen ? 0 : null,
        titleTextStyle: TextStyle(color: Colors.white),
        title: FutureBuilder(
          future: _futureBuilder,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return const SizedBox();
            }
            Map data = snapshot.data as Map;
            if (data['status']) {
              return Obx(
                () => Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        dynamic uid =
                            _liveRoomController.roomInfoH5.value.roomInfo?.uid;
                        Get.toNamed(
                          '/member?mid=$uid',
                          arguments: {
                            'heroTag': Utils.makeHeroTag(uid),
                          },
                        );
                      },
                      child: NetworkImgLayer(
                        width: 34,
                        height: 34,
                        type: 'avatar',
                        src: _liveRoomController
                            .roomInfoH5.value.anchorInfo!.baseInfo!.face,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _liveRoomController
                              .roomInfoH5.value.anchorInfo!.baseInfo!.uname!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 1),
                        if (_liveRoomController.roomInfoH5.value.watchedShow !=
                            null)
                          Text(
                            _liveRoomController.roomInfoH5.value
                                    .watchedShow!['text_large'] ??
                                '',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Obx(
                      () => IconButton(
                        onPressed: plPlayerController.setOnlyPlayAudio,
                        icon: Icon(
                          plPlayerController.onlyPlayAudio.value
                              ? MdiIcons.musicCircle
                              : MdiIcons.musicCircleOutline,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    //刷新
                    IconButton(
                      tooltip: '刷新',
                      onPressed: () {
                        _futureBuilderFuture =
                            _liveRoomController.queryLiveInfo();
                        // videoSourceInit();
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                    //内置浏览器打开
                    IconButton(
                        tooltip: '浏览器打开',
                        onPressed: () {
                          Utils.inAppWebview(
                            'https://live.bilibili.com/h5/${_liveRoomController.roomId}',
                            off: true,
                          );
                        },
                        icon: const Icon(Icons.open_in_browser)),
                  ],
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      );

  Widget get _buildBodyH {
    double videoWidth =
        clampDouble(context.height / context.width * 1.08, 0.58, 0.75) *
            context.width;
    return Expanded(
      child: Row(
        children: [
          Obx(
            () => Container(
              color: isFullScreen ? Colors.black : null,
              width: isFullScreen ? Get.size.width : videoWidth,
              height: isFullScreen ? Get.size.height : Get.size.width * 9 / 16,
              child: MediaQuery.removePadding(
                removeRight: true,
                context: context,
                child: videoPlayerPanel(fill: Colors.transparent),
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              left: false,
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildBottomWidget,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> get _buildBodyP => [
        Obx(
          () => Container(
            color: Colors.black,
            width: Get.size.width,
            height: isFullScreen ? Get.size.height : Get.size.width * 9 / 16,
            child: videoPlayerPanel(),
          ),
        ),
        ..._buildBottomWidget,
      ];

  final GlobalKey chatKey = GlobalKey();

  List<Widget> get _buildBottomWidget => [
        Expanded(child: _buildChatWidget()),
        _buildInputWidget,
      ];

  Widget _buildChatWidget([bool? isPP]) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: LiveRoomChat(
          key: chatKey,
          isPP: isPP,
          roomId: _roomId,
          liveRoomController: _liveRoomController,
        ),
      );

  Widget get _buildInputWidget => Container(
        padding: EdgeInsets.only(
          left: 10,
          top: 10,
          right: 10,
          bottom: 25 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border(
            top: BorderSide(color: Color(0x1AFFFFFF)),
          ),
          color: Color(0x1AFFFFFF),
        ),
        child: Row(
          children: [
            Obx(
              () => IconButton(
                onPressed: () {
                  plPlayerController.isOpenDanmu.value =
                      !plPlayerController.isOpenDanmu.value;
                  GStorage.setting.put(SettingBoxKey.enableShowDanmaku,
                      plPlayerController.isOpenDanmu.value);
                },
                icon: Icon(
                  plPlayerController.isOpenDanmu.value
                      ? Icons.subtitles_outlined
                      : Icons.subtitles_off_outlined,
                  color: _color,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: onSendDanmaku,
                child: Text(
                  '发送弹幕',
                  style: TextStyle(color: _color),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                onSendDanmaku(true);
              },
              icon: Icon(Icons.emoji_emotions_outlined, color: _color),
            ),
          ],
        ),
      );

  void onSendDanmaku([bool fromEmote = false]) {
    Get.generalDialog(
      barrierLabel: '',
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return LiveSendDmPanel(
          fromEmote: fromEmote,
          liveRoomController: _liveRoomController,
          initialValue: _liveRoomController.savedDanmaku,
          onSave: (msg) => _liveRoomController.savedDanmaku = msg,
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(begin: Offset(0.0, 1.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.linear));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

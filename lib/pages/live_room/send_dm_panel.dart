import 'dart:async';

import 'package:PiliPlus/http/live.dart';
import 'package:PiliPlus/pages/common/common_publish_page.dart';
import 'package:PiliPlus/pages/live_emote/controller.dart';
import 'package:PiliPlus/pages/live_emote/view.dart';
import 'package:PiliPlus/pages/live_room/controller.dart';
import 'package:PiliPlus/pages/video/detail/reply_new/toolbar_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart' hide MultipartFile;

class LiveSendDmPanel extends CommonPublishPage {
  final bool fromEmote;
  final LiveRoomController liveRoomController;

  const LiveSendDmPanel({
    super.key,
    super.initialValue,
    super.onSave,
    this.fromEmote = false,
    required this.liveRoomController,
  });

  @override
  State<LiveSendDmPanel> createState() => _ReplyPageState();
}

class _ReplyPageState extends CommonPublishPageState<LiveSendDmPanel> {
  LiveRoomController get liveRoomController => widget.liveRoomController;

  @override
  void initState() {
    super.initState();
    if (widget.fromEmote) {
      selectKeyboard.value = false;
      updatePanelType(PanelType.emoji);
    }
  }

  @override
  void dispose() {
    Get.delete<LiveEmotePanelController>(
        tag: liveRoomController.roomId.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: GestureDetector(
        onTap: Get.back,
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isH = constraints.maxWidth > constraints.maxHeight;
            late double padding = constraints.maxWidth * 0.12;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: isH ? padding : 0),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: GestureDetector(
                  onTap: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      buildInputView(),
                      buildPanelContainer(
                          Theme.of(context).colorScheme.surface),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget? customPanel(double height) => SizedBox(
        height: height,
        child: LiveEmotePanel(
          onChoose: onChooseEmote,
          roomId: liveRoomController.roomId,
          onSendEmoticonUnique: (emote) {
            onCustomPublish(
              message: emote.emoticonUnique!,
              dmType: 1,
              emoticonOptions: '[object Object]',
              emoticonUnique: emote.emoji,
            );
          },
        ),
      );

  Widget buildInputView() {
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
                const EdgeInsets.only(top: 12, right: 15, left: 15, bottom: 10),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Listener(
                onPointerUp: (event) {
                  if (readOnly.value) {
                    updatePanelType(PanelType.keyboard);
                    selectKeyboard.value = true;
                  }
                },
                child: Obx(
                  () => TextField(
                    controller: editController,
                    minLines: 1,
                    maxLines: 2,
                    autofocus: false,
                    readOnly: readOnly.value,
                    onChanged: (value) {
                      bool isEmpty = value.trim().isEmpty;
                      if (!isEmpty && !enablePublish.value) {
                        enablePublish.value = true;
                      } else if (isEmpty && enablePublish.value) {
                        enablePublish.value = false;
                      }
                      liveRoomController.savedDanmaku = value;
                    },
                    focusNode: focusNode,
                    decoration: InputDecoration(
                        hintText: "输入弹幕内容",
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 14)),
                    style: Theme.of(context).textTheme.bodyLarge,
                    inputFormatters: [LengthLimitingTextInputFormatter(20)],
                  ),
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
          Container(
            height: 52,
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => ToolbarIconButton(
                    tooltip: '输入',
                    onPressed: () {
                      if (!selectKeyboard.value) {
                        selectKeyboard.value = true;
                        updatePanelType(PanelType.keyboard);
                      }
                    },
                    icon: const Icon(Icons.keyboard, size: 22),
                    selected: selectKeyboard.value,
                  ),
                ),
                const SizedBox(width: 10),
                Obx(
                  () => ToolbarIconButton(
                    tooltip: '表情',
                    onPressed: () {
                      if (selectKeyboard.value) {
                        selectKeyboard.value = false;
                        updatePanelType(PanelType.emoji);
                      }
                    },
                    icon: const Icon(Icons.emoji_emotions, size: 22),
                    selected: !selectKeyboard.value,
                  ),
                ),
                const Spacer(),
                Obx(
                  () => FilledButton.tonal(
                    onPressed: enablePublish.value ? onPublish : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      visualDensity: const VisualDensity(
                        horizontal: -2,
                        vertical: -2,
                      ),
                    ),
                    child: const Text('发送'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future onCustomPublish({
    required String message,
    List? pictures,
    int? dmType,
    emoticonOptions,
    emoticonUnique,
  }) async {
    final res = await LiveHttp.sendLiveMsg(
      roomId: liveRoomController.roomId,
      msg: message,
      dmType: dmType,
      emoticonOptions: emoticonOptions,
    );
    if (res['status']) {
      Get.back();
      liveRoomController.savedDanmaku = null;
      SmartDialog.showToast('发送成功');
      // liveRoomController.plPlayerController.danmakuController?.addDanmaku(
      //   DanmakuContentItem(
      //     emoticonUnique ?? message,
      //     type: DanmakuItemType.scroll,
      //     selfSend: true,
      //   ),
      // );
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }
}

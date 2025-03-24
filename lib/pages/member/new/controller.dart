import 'dart:math';

import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/space/data.dart';
import 'package:PiliPlus/models/space/item.dart';
import 'package:PiliPlus/models/space/tab2.dart';
import 'package:PiliPlus/pages/common/common_controller.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum MemberTabType { none, home, dynamic, contribute, favorite, bangumi }

extension MemberTabTypeExt on MemberTabType {
  String get title => ['默认', '首页', '动态', '投稿', '收藏', '番剧'][index];
}

class MemberControllerNew extends CommonController
    with GetTickerProviderStateMixin {
  MemberControllerNew({required this.mid});
  int mid;
  RxBool showUname = false.obs;
  String? username;
  int? ownerMid;
  RxBool isFollow = false.obs;
  RxInt relation = 1.obs;
  TabController? tabController;
  late List<Tab> tabs;
  List<Tab2>? tab2;
  RxInt contributeInitialIndex = 0.obs;
  double? top;
  bool? hasSeasonOrSeries;

  @override
  void onInit() {
    super.onInit();
    ownerMid = GStorage.userInfo.get('userInfoCache')?.mid;
    queryData();
  }

  dynamic live;

  int? silence;
  String? endTime;

  late final implTabs = const [
    'home',
    'dynamic',
    'contribute',
    'favorite',
    'bangumi',
  ];

  @override
  bool customHandleResponse(Success response) {
    Data data = response.response;
    username = data.card?.name ?? '';
    isFollow.value = data.card?.relation?.isFollow == 1;
    relation.value = data.relSpecial == 1 ? 2 : data.relation ?? 1;
    tab2 = data.tab2;
    live = data.live;
    silence = data.card?.silence;
    if ((data.ugcSeason?.count != null && data.ugcSeason?.count != 0) ||
        data.series?.item?.isNotEmpty == true) {
      hasSeasonOrSeries = true;
    }
    if (data.card?.endTime != null) {
      if (data.card!.endTime == 0) {
        endTime = ': 永久封禁';
      } else if (data.card!.endTime! >
          DateTime.now().millisecondsSinceEpoch ~/ 1000) {
        endTime =
            '：至 ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(data.card!.endTime! * 1000))}';
      }
    }
    tab2?.retainWhere((item) => implTabs.contains(item.param));
    if (tab2?.isNotEmpty == true) {
      if (!data.tab!.toJson().values.contains(true) &&
          tab2!.first.param == 'home') {
        // remove empty home tab
        tab2!.removeAt(0);
      }
      if (tab2!.isNotEmpty) {
        int initialIndex = -1;
        MemberTabType memberTab = GStorage.memberTab;
        if (memberTab != MemberTabType.none) {
          initialIndex = tab2!.indexWhere((item) {
            return item.param == memberTab.name;
          });
        }
        if (initialIndex == -1) {
          if (data.defaultTab == 'video') {
            data.defaultTab = 'dynamic';
          }
          initialIndex = tab2!.indexWhere((item) {
            return item.param == data.defaultTab;
          });
        }
        tabs = tab2!.map((item) => Tab(text: item.title ?? '')).toList();
        tabController = TabController(
          vsync: this,
          length: tabs.length,
          initialIndex: max(0, initialIndex),
        );
      }
    }
    loadingState.value = response;
    return true;
  }

  @override
  bool handleError(String? errMsg) {
    tab2 = [
      Tab2(title: '动态', param: 'dynamic'),
      Tab2(
        title: '投稿',
        param: 'contribute',
        items: [Item(title: '视频', param: 'video')],
      ),
      Tab2(title: '收藏', param: 'favorite'),
      Tab2(title: '追番', param: 'bangumi'),
    ];
    tabs = tab2!.map((item) => Tab(text: item.title)).toList();
    tabController = TabController(
      vsync: this,
      length: tabs.length,
    );
    showUname.value = true;
    username = errMsg;
    loadingState.value = LoadingState.success(null);
    return true;
  }

  @override
  Future<LoadingState> customGetData() => MemberHttp.space(mid: mid);

  Future blockUser(BuildContext context) async {
    if (ownerMid == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text(relation.value != -1 ? '确定拉黑UP主?' : '从黑名单移除UP主'),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text(
                '点错了',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                _onBlock();
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }

  void shareUser() {
    Utils.shareText('https://space.bilibili.com/$mid');
  }

  void _onBlock() async {
    dynamic res = await VideoHttp.relationMod(
      mid: mid,
      act: relation.value != -1 ? 5 : 6,
      reSrc: 11,
    );
    if (res['status']) {
      relation.value = relation.value != -1 ? -1 : 1;
      isFollow.value = false;
    }
  }

  void onFollow(BuildContext context) async {
    if (mid == ownerMid) {
      Get.toNamed('/editProfile');
    } else if (relation.value == -1) {
      _onBlock();
    } else {
      if (ownerMid == null) {
        SmartDialog.showToast('账号未登录');
        return;
      }
      Utils.actionRelationMod(
        context: context,
        mid: mid,
        isFollow: isFollow.value,
        callback: (attribute) {
          relation.value = attribute;
          isFollow.value = attribute != 0;
        },
      );
    }
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }
}

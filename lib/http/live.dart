import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/danmu_info.dart';
import 'package:PiliPlus/models/live/follow.dart';
import 'package:PiliPlus/models/live/live_emoticons/data.dart';
import 'package:PiliPlus/models/live/live_emoticons/datum.dart';
import 'package:PiliPlus/utils/wbi_sign.dart';
import 'package:dio/dio.dart';
import '../models/live/item.dart';
import '../models/live/room_info.dart';
import '../models/live/room_info_h5.dart';
import 'api.dart';
import 'init.dart';

class LiveHttp {
  static Future<LoadingState<List<LiveItemModel>?>> liveList(
      {int? vmid, int? pn, int? ps, String? orderType}) async {
    var res = await Request().get(
      Api.liveList,
      queryParameters: await WbiSign.makSign({
        'page': pn,
        'page_size': 30,
        'platform': 'web',
        'web_location': 0.0,
      }),
      options: Options(
        headers: {
          'origin': 'https://live.bilibili.com',
          'referer': 'https://live.bilibili.com/',
          'user-agent': Request.headerUa(type: 'pc'),
        },
      ),
    );
    if (res.data['code'] == 0) {
      List<LiveItemModel>? list = (res.data['data']?['list'] as List?)
          ?.map<LiveItemModel>((e) => LiveItemModel.fromJson(e))
          .toList();
      return LoadingState.success(list);
    } else {
      return LoadingState.error(res.data['message']);
    }
  }

  static Future sendLiveMsg({roomId, msg, dmType, emoticonOptions}) async {
    dynamic csrf = await Request.getCsrf();
    var res = await Request().post(
      Api.sendLiveMsg,
      data: FormData.fromMap({
        'bubble': 0,
        'msg': msg,
        'color': 16777215,
        'mode': 1,
        if (dmType != null) 'dm_type': dmType,
        if (emoticonOptions != null)
          'emoticonOptions': emoticonOptions
        else ...{
          'room_type': 0,
          'jumpfrom': 0,
          'reply_mid': 0,
          'reply_attr': 0,
          'replay_dmid': '',
          'statistics': Constants.statistics,
          'reply_type': 0,
          'reply_uname': '',
        },
        'fontsize': 25,
        'rnd': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'roomid': roomId,
        'csrf': csrf,
        'csrf_token': csrf,
      }),
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }

  static Future liveRoomInfo({roomId, qn}) async {
    var res = await Request().get(Api.liveRoomInfo, queryParameters: {
      'room_id': roomId,
      'protocol': '0, 1',
      'format': '0, 1, 2',
      'codec': '0, 1',
      'qn': qn,
      'platform': 'web',
      'ptype': 8,
      'dolby': 5,
      'panorama': 1,
    });
    if (res.data['code'] == 0) {
      return {'status': true, 'data': RoomInfoModel.fromJson(res.data['data'])};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future liveRoomInfoH5({roomId, qn}) async {
    var res = await Request().get(Api.liveRoomInfoH5, queryParameters: {
      'room_id': roomId,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': RoomInfoH5Model.fromJson(res.data['data'])
      };
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future liveRoomDanmaPrefetch({roomId}) async {
    var res = await Request().get(Api.liveRoomDmPrefetch, queryParameters: {
      'roomid': roomId,
    });
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']['room']};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  static Future liveRoomGetDanmakuToken({roomId}) async {
    var res = await Request().get(Api.liveRoomDmToken, queryParameters: {
      'id': roomId,
    });
    if (res.data['code'] == 0) {
      return {'status': true, 'data': LiveDanmakuInfo.fromJson(res.data)};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  // 我的关注 正在直播
  static Future liveFollowing({required int pn, required int ps}) async {
    var res = await Request().get(
      Api.getFollowingLive,
      queryParameters: {
        'page': pn,
        'page_size': ps,
        'platform': 'web',
        'ignoreRecord': 1,
        'hit_ab': true,
      },
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': LiveFollowingModel.fromJson(res.data['data'])
      };
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }

  static Future<LoadingState<List<LiveEmoteDatum>?>> getLiveEmoticons(
      {required int roomId}) async {
    var res = await Request().get(
      Api.getLiveEmoticons,
      queryParameters: {
        'platform': 'pc',
        'room_id': roomId,
      },
    );
    if (res.data['code'] == 0) {
      return LoadingState.success(
          LiveEmoteData.fromJson(res.data['data']).data);
    } else {
      return LoadingState.error(res.data['message']);
    }
  }
}

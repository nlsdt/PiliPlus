import 'dart:io';
import 'dart:math';
import 'package:PiliPalaX/http/constants.dart';
import 'package:PiliPalaX/pages/dynamics/view.dart' show ReplyOption;
import 'package:dio/dio.dart';

import '../models/msg/account.dart';
import '../models/msg/session.dart';
import '../utils/wbi_sign.dart';
import 'api.dart';
import 'init.dart';

class MsgHttp {
  static Future msgFeedReplyMe({int cursor = -1, int cursorTime = -1}) async {
    var res = await Request().get(Api.msgFeedReply, data: {
      'id': cursor == -1 ? null : cursor,
      'reply_time': cursorTime == -1 ? null : cursorTime,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }

  static Future msgFeedAtMe({int cursor = -1, int cursorTime = -1}) async {
    var res = await Request().get(Api.msgFeedAt, data: {
      'id': cursor == -1 ? null : cursor,
      'at_time': cursorTime == -1 ? null : cursorTime,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }

  static Future msgFeedLikeMe({int cursor = -1, int cursorTime = -1}) async {
    var res = await Request().get(Api.msgFeedLike, data: {
      'id': cursor == -1 ? null : cursor,
      'like_time': cursorTime == -1 ? null : cursorTime,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }

  static Future msgFeedSysUserNotify() async {
    String csrf = await Request.getCsrf();
    var res = await Request().get(Api.msgSysUserNotify, data: {
      'csrf': csrf,
      'csrf': csrf,
      'page_size': 20,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }

  static Future msgFeedSysUnifiedNotify() async {
    String csrf = await Request.getCsrf();
    var res = await Request().get(Api.msgSysUnifiedNotify, data: {
      'csrf': csrf,
      'csrf': csrf,
      'page_size': 10,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }

  static Future msgSysUpdateCursor(int cursor) async {
    String csrf = await Request.getCsrf();
    var res = await Request().get(Api.msgSysUpdateCursor, data: {
      'csrf': csrf,
      'csrf': csrf,
      'cursor': cursor,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
      };
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }

  static Future msgFeedUnread() async {
    var res = await Request().get(Api.msgFeedUnread);
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }

  static Future createDynamic({
    dynamic mid,
    dynamic dynIdStr, // repost
    dynamic rawText,
    List? pics,
    int? publishTime,
    ReplyOption replyOption = ReplyOption.allow,
  }) async {
    String csrf = await Request.getCsrf();
    var res = await Request().post(
      Api.createDynamic,
      queryParameters: {
        'platform': 'web',
        'csrf': csrf,
        'x-bili-device-req-json': {"platform": "web", "device": "pc"},
        'x-bili-web-req-json': {"spm_id": "333.999"},
      },
      data: {
        "dyn_req": {
          "content": {
            "contents": [
              {
                "raw_text": rawText,
                "type": 1,
                "biz_id": "",
              }
            ]
          },
          if (dynIdStr == null)
            "option": {
              if (publishTime != null) "timer_pub_time": publishTime,
              if (replyOption == ReplyOption.close) "close_comment": 1,
              if (replyOption == ReplyOption.choose) "up_choose_comment": 1,
            },
          "scene": dynIdStr != null
              ? 4
              : pics != null
                  ? 2
                  : 1,
          if (pics != null) 'pics': pics,
          "attach_card": null,
          "upload_id":
              "${mid}_${DateTime.now().millisecondsSinceEpoch ~/ 1000}_${Random().nextInt(9000) + 1000}",
          "meta": {
            "app_meta": {"from": "create.dynamic.web", "mobi_app": "web"}
          }
        },
        if (dynIdStr != null) "web_repost_src": {"dyn_id_str": dynIdStr}
      },
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }

  static Future uploadBfs(
    dynamic path,
  ) async {
    String csrf = await Request.getCsrf();
    Map<String, dynamic> data = await WbiSign().makSign({
      'file_up': await MultipartFile.fromFile(path),
      'category': 'daily',
      'csrf': csrf,
    });
    var res = await Request().post(
      Api.uploadBfs,
      data: FormData.fromMap(data),
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

  static Future createTextDynamic(
    dynamic content,
  ) async {
    String csrf = await Request.getCsrf();
    Map<String, dynamic> data = await WbiSign().makSign({
      'dynamic_id': 0,
      'type': 4,
      'rid': 0,
      'content': content,
      'csrf_token': csrf,
      'csrf': csrf,
    });
    var res = await Request().post(
      HttpString.tUrl + Api.createTextDynamic,
      data: FormData.fromMap(data),
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }

  static Future removeDynamic(
    dynamic dynamicId,
  ) async {
    String csrf = await Request.getCsrf();
    Map<String, dynamic> data = await WbiSign().makSign({
      'dynamic_id': dynamicId,
      'csrf_token': csrf,
      'csrf': csrf,
    });
    var res = await Request().post(
      HttpString.tUrl + Api.removeDynamic,
      data: FormData.fromMap(data),
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }

  static Future removeMsg(
    dynamic talkerId,
  ) async {
    String csrf = await Request.getCsrf();
    Map<String, dynamic> data = await WbiSign().makSign({
      'talker_id': talkerId,
      'session_type': 1,
      'build': 0,
      'mobi_app': 'web',
      'csrf_token': csrf,
      'csrf': csrf
    });
    var res = await Request()
        .post(HttpString.tUrl + Api.removeMsg, data: FormData.fromMap(data));
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }

  static Future removeSysMsg(
    dynamic id,
  ) async {
    String csrf = await Request.getCsrf();
    var res = await Request().post(
      HttpString.messageBaseUrl + Api.removeSysMsg,
      queryParameters: {
        'mobi_app': 'android',
        'csrf': csrf,
      },
      data: {
        'csrf': csrf,
        'ids': [id],
        'station_ids': [],
        'type': 4,
        'mobi_app': 'android',
      },
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }

  static Future setTop(
    dynamic talkerId,
    int opType,
  ) async {
    String csrf = await Request.getCsrf();
    Map<String, dynamic> data = await WbiSign().makSign({
      'talker_id': talkerId,
      'session_type': 1,
      'op_type': opType,
      'build': 0,
      'mobi_app': 'web',
      'csrf_token': csrf,
      'csrf': csrf
    });
    var res = await Request()
        .post(HttpString.tUrl + Api.setTop, data: FormData.fromMap(data));
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {
        'status': false,
        'msg': res.data['message'],
      };
    }
  }

  // 会话列表
  static Future sessionList({int? endTs}) async {
    Map<String, dynamic> params = {
      'session_type': 1,
      'group_fold': 1,
      'unfollow_fold': 0,
      'sort_rule': 2,
      'build': 0,
      'mobi_app': 'web',
    };
    if (endTs != null) {
      params['end_ts'] = endTs;
    }

    Map signParams = await WbiSign().makSign(params);
    var res = await Request().get(Api.sessionList, data: signParams);
    if (res.data['code'] == 0) {
      try {
        return {
          'status': true,
          'data': SessionDataModel.fromJson(res.data['data']),
        };
      } catch (err) {
        return {
          'status': false,
          'date': [],
          'msg': err.toString(),
        };
      }
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }

  static Future accountList(uids) async {
    var res = await Request().get(Api.sessionAccountList, data: {
      'uids': uids,
      'build': 0,
      'mobi_app': 'web',
    });
    if (res.data['code'] == 0) {
      try {
        return {
          'status': true,
          'data': res.data['data']
              .map<AccountListModel>((e) => AccountListModel.fromJson(e))
              .toList(),
        };
      } catch (err) {
        print('err🔟: $err');
      }
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }

  static Future sessionMsg({
    int? talkerId,
  }) async {
    Map params = await WbiSign().makSign({
      'talker_id': talkerId,
      'session_type': 1,
      'size': 20,
      'sender_device_id': 1,
      'build': 0,
      'mobi_app': 'web',
    });
    var res = await Request().get(Api.sessionMsg, data: params);
    if (res.data['code'] == 0) {
      try {
        return {
          'status': true,
          'data': SessionMsgDataModel.fromJson(res.data['data']),
        };
      } catch (err) {
        print(err);
      }
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }

  // 消息标记已读
  static Future ackSessionMsg({
    int? talkerId,
    int? ackSeqno,
  }) async {
    String csrf = await Request.getCsrf();
    Map params = await WbiSign().makSign({
      'talker_id': talkerId,
      'session_type': 1,
      'ack_seqno': ackSeqno,
      'build': 0,
      'mobi_app': 'web',
      'csrf_token': csrf,
      'csrf': csrf
    });
    var res = await Request().get(Api.ackSessionMsg, data: params);
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': "message: ${res.data['message']},"
            " msg: ${res.data['msg']},"
            " code: ${res.data['code']}",
      };
    }
  }

  // 发送私信
  static Future sendMsg({
    int? senderUid,
    int? receiverId,
    int? receiverType,
    int? msgType,
    dynamic content,
  }) async {
    String csrf = await Request.getCsrf();
    Map<String, dynamic> base = {
      'msg[sender_uid]': senderUid,
      'msg[receiver_id]': receiverId,
      'msg[receiver_type]': receiverType ?? 1,
      'msg[msg_type]': msgType ?? 1,
      'msg[msg_status]': 0,
      'msg[dev_id]': getDevId(),
      'msg[timestamp]': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'msg[new_face_version]': 1,
      'msg[content]': content,
      'from_firework': 0,
      'build': 0,
      'mobi_app': 'web',
      'csrf_token': csrf,
      'csrf': csrf,
    };
    Map<String, dynamic> params = await WbiSign().makSign(base);
    var res = await Request().post(Api.sendMsg,
        queryParameters: <String, dynamic>{
          'w_sender_uid': params['msg[sender_uid]'],
          'w_receiver_id': params['msg[receiver_id]'],
          'w_dev_id': params['msg[dev_id]'],
          'w_rid': params['w_rid'],
          'wts': params['wts'],
        },
        data: FormData.fromMap(base));
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': "message: ${res.data['message']},"
            " msg: ${res.data['msg']},"
            " code: ${res.data['code']}",
      };
    }
  }

  static String getDevId() {
    final List<String> b = [
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'A',
      'B',
      'C',
      'D',
      'E',
      'F'
    ];
    final List<String> s = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".split('');
    for (int i = 0; i < s.length; i++) {
      if ('-' == s[i] || '4' == s[i]) {
        continue;
      }
      final int randomInt = Random().nextInt(16);
      if ('x' == s[i]) {
        s[i] = b[randomInt];
      } else {
        s[i] = b[3 & randomInt | 8];
      }
    }
    return s.join();
  }
}

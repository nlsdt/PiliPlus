import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/bangumi/pgc_timeline/pgc_timeline.dart';
import 'package:PiliPlus/models/bangumi/pgc_timeline/result.dart';

import '../models/bangumi/list.dart';
import '../models/bangumi/pgc_index/condition.dart';
import 'index.dart';

class BangumiHttp {
  static Future<LoadingState> pgcIndexResult({
    required int page,
    required Map<String, dynamic> params,
    seasonType,
    type,
    indexType,
  }) async {
    dynamic res = await Request().get(
      Api.pgcIndexResult,
      queryParameters: {
        ...params,
        if (seasonType != null) 'season_type': seasonType,
        if (type != null) 'type': type,
        if (indexType != null) 'index_type': indexType,
        'page': page,
        'pagesize': 21,
      },
    );
    if (res.data['code'] == 0) {
      return LoadingState.success(res.data['data']);
    } else {
      return LoadingState.error(res.data['message']);
    }
  }

  static Future<LoadingState> pgcIndexCondition({
    seasonType,
    type,
    indexType,
  }) async {
    dynamic res = await Request().get(
      Api.pgcIndexCondition,
      queryParameters: {
        if (seasonType != null) 'season_type': seasonType,
        if (type != null) 'type': type,
        if (indexType != null) 'index_type': indexType,
      },
    );
    if (res.data['code'] == 0) {
      return LoadingState.success(Condition.fromJson(res.data['data']));
    } else {
      return LoadingState.error(res.data['message']);
    }
  }

  static Future<LoadingState<List<BangumiListItemModel>?>> bangumiList({
    int? page,
    int? indexType,
  }) async {
    var res = await Request().get(Api.bangumiList, queryParameters: {
      'page': page,
      if (indexType != null) 'index_type': indexType,
    });
    if (res.data['code'] == 0) {
      BangumiListDataModel data =
          BangumiListDataModel.fromJson(res.data['data']);
      return LoadingState.success(data.list);
    } else {
      return LoadingState.error(res.data['message']);
    }
  }

  static Future<LoadingState<BangumiListDataModel>> bangumiFollowList({
    required dynamic mid,
    required int type,
    required int pn,
    int? followStatus,
  }) async {
    var res = await Request().get(Api.bangumiFollowList, queryParameters: {
      'vmid': mid,
      'type': type,
      if (followStatus != null) 'follow_status': followStatus,
      'pn': pn,
    });
    if (res.data['code'] == 0) {
      return LoadingState.success(
          BangumiListDataModel.fromJson(res.data['data']));
    } else {
      return LoadingState.error(res.data['message']);
    }
  }

  static Future<LoadingState<List<Result>?>> pgcTimeline({
    int types = 1, // 1：`番剧`<br />3：`电影`<br />4：`国创` |
    required int before,
    required int after,
  }) async {
    var res = await Request().get(
      Api.pgcTimeline,
      queryParameters: {
        'types': types,
        'before': before,
        'after': after,
      },
    );
    if (res.data['code'] == 0) {
      return LoadingState.success(PgcTimeline.fromJson(res.data).result);
    } else {
      return LoadingState.error(res.data['message']);
    }
  }
}

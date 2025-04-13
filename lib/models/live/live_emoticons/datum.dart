import 'emoticon.dart';
import 'top_show.dart';
import 'top_show_recent.dart';

class LiveEmoteDatum {
  List<LiveEmoticon>? emoticons;
  int? pkgId;
  String? pkgName;
  int? pkgType;
  String? pkgDescript;
  int? pkgPerm;
  int? unlockIdentity;
  int? unlockNeedGift;
  String? currentCover;
  List<dynamic>? recentlyUsedEmoticons;
  TopShow? topShow;
  TopShowRecent? topShowRecent;

  LiveEmoteDatum({
    this.emoticons,
    this.pkgId,
    this.pkgName,
    this.pkgType,
    this.pkgDescript,
    this.pkgPerm,
    this.unlockIdentity,
    this.unlockNeedGift,
    this.currentCover,
    this.recentlyUsedEmoticons,
    this.topShow,
    this.topShowRecent,
  });

  factory LiveEmoteDatum.fromJson(Map<String, dynamic> json) => LiveEmoteDatum(
        emoticons: (json['emoticons'] as List<dynamic>?)
            ?.map((e) => LiveEmoticon.fromJson(e as Map<String, dynamic>))
            .toList(),
        pkgId: json['pkg_id'] as int?,
        pkgName: json['pkg_name'] as String?,
        pkgType: json['pkg_type'] as int?,
        pkgDescript: json['pkg_descript'] as String?,
        pkgPerm: json['pkg_perm'] as int?,
        unlockIdentity: json['unlock_identity'] as int?,
        unlockNeedGift: json['unlock_need_gift'] as int?,
        currentCover: json['current_cover'] as String?,
        recentlyUsedEmoticons:
            json['recently_used_emoticons'] as List<dynamic>?,
        topShow: json['top_show'] == null
            ? null
            : TopShow.fromJson(json['top_show'] as Map<String, dynamic>),
        topShowRecent: json['top_show_recent'] == null
            ? null
            : TopShowRecent.fromJson(
                json['top_show_recent'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'emoticons': emoticons?.map((e) => e.toJson()).toList(),
        'pkg_id': pkgId,
        'pkg_name': pkgName,
        'pkg_type': pkgType,
        'pkg_descript': pkgDescript,
        'pkg_perm': pkgPerm,
        'unlock_identity': unlockIdentity,
        'unlock_need_gift': unlockNeedGift,
        'current_cover': currentCover,
        'recently_used_emoticons': recentlyUsedEmoticons,
        'top_show': topShow?.toJson(),
        'top_show_recent': topShowRecent?.toJson(),
      };
}

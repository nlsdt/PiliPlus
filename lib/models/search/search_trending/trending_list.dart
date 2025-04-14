class TrendingList {
  int? position;
  String? keyword;
  String? showName;
  int? wordType;
  String? icon;
  int? hotId;
  String? isCommercial;
  int? resourceId;
  bool? showLiveIcon;

  TrendingList({
    this.position,
    this.keyword,
    this.showName,
    this.wordType,
    this.icon,
    this.hotId,
    this.isCommercial,
    this.resourceId,
    this.showLiveIcon,
  });

  factory TrendingList.fromJson(Map<String, dynamic> json) => TrendingList(
        position: json['position'] as int?,
        keyword: json['keyword'] as String?,
        showName: json['show_name'] as String?,
        wordType: json['word_type'] as int?,
        icon: json['icon'] as String?,
        hotId: json['hot_id'] as int?,
        isCommercial: json['is_commercial'] as String?,
        resourceId: json['resource_id'] as int?,
        showLiveIcon: json['show_live_icon'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'position': position,
        'keyword': keyword,
        'show_name': showName,
        'word_type': wordType,
        'icon': icon,
        'hot_id': hotId,
        'is_commercial': isCommercial,
        'resource_id': resourceId,
        'show_live_icon': showLiveIcon,
      };
}

class LiveEmoticon {
  String? emoji;
  String? descript;
  String? url;
  int? isDynamic;
  int? inPlayerArea;
  int? width;
  int? height;
  int? identity;
  int? unlockNeedGift;
  int? perm;
  int? unlockNeedLevel;
  int? emoticonValueType;
  int? bulgeDisplay;
  String? unlockShowText;
  String? unlockShowColor;
  String? emoticonUnique;
  String? unlockShowImage;
  int? emoticonId;

  LiveEmoticon({
    this.emoji,
    this.descript,
    this.url,
    this.isDynamic,
    this.inPlayerArea,
    this.width,
    this.height,
    this.identity,
    this.unlockNeedGift,
    this.perm,
    this.unlockNeedLevel,
    this.emoticonValueType,
    this.bulgeDisplay,
    this.unlockShowText,
    this.unlockShowColor,
    this.emoticonUnique,
    this.unlockShowImage,
    this.emoticonId,
  });

  factory LiveEmoticon.fromJson(Map<String, dynamic> json) => LiveEmoticon(
        emoji: json['emoji'] as String?,
        descript: json['descript'] as String?,
        url: json['url'] as String?,
        isDynamic: json['is_dynamic'] as int?,
        inPlayerArea: json['in_player_area'] as int?,
        width: json['width'] as int? ?? 0,
        height: json['height'] as int? ?? 0,
        identity: json['identity'] as int?,
        unlockNeedGift: json['unlock_need_gift'] as int?,
        perm: json['perm'] as int?,
        unlockNeedLevel: json['unlock_need_level'] as int?,
        emoticonValueType: json['emoticon_value_type'] as int?,
        bulgeDisplay: json['bulge_display'] as int?,
        unlockShowText: json['unlock_show_text'] as String?,
        unlockShowColor: json['unlock_show_color'] as String?,
        emoticonUnique: json['emoticon_unique'] as String?,
        unlockShowImage: json['unlock_show_image'] as String?,
        emoticonId: json['emoticon_id'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'descript': descript,
        'url': url,
        'is_dynamic': isDynamic,
        'in_player_area': inPlayerArea,
        'width': width,
        'height': height,
        'identity': identity,
        'unlock_need_gift': unlockNeedGift,
        'perm': perm,
        'unlock_need_level': unlockNeedLevel,
        'emoticon_value_type': emoticonValueType,
        'bulge_display': bulgeDisplay,
        'unlock_show_text': unlockShowText,
        'unlock_show_color': unlockShowColor,
        'emoticon_unique': emoticonUnique,
        'unlock_show_image': unlockShowImage,
        'emoticon_id': emoticonId,
      };
}

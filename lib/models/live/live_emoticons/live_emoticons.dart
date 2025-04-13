import 'data.dart';

class LiveEmoticons {
  int? code;
  String? message;
  int? ttl;
  LiveEmoteData? data;

  LiveEmoticons({this.code, this.message, this.ttl, this.data});

  factory LiveEmoticons.fromJson(Map<String, dynamic> json) => LiveEmoticons(
        code: json['code'] as int?,
        message: json['message'] as String?,
        ttl: json['ttl'] as int?,
        data: json['data'] == null
            ? null
            : LiveEmoteData.fromJson(json['data'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'ttl': ttl,
        'data': data?.toJson(),
      };
}

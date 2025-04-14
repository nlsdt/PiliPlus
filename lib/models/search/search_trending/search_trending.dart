import 'trending_data.dart';

class SearchTrending {
  int? code;
  String? message;
  int? ttl;
  TrendingData? data;

  SearchTrending({this.code, this.message, this.ttl, this.data});

  factory SearchTrending.fromJson(Map<String, dynamic> json) {
    return SearchTrending(
      code: json['code'] as int?,
      message: json['message'] as String?,
      ttl: json['ttl'] as int?,
      data: json['data'] == null
          ? null
          : TrendingData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'ttl': ttl,
        'data': data?.toJson(),
      };
}

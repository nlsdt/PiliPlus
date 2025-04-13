import 'datum.dart';

class LiveEmoteData {
  int? fansBrand;
  List<LiveEmoteDatum>? data;
  dynamic purchaseUrl;

  LiveEmoteData({this.fansBrand, this.data, this.purchaseUrl});

  factory LiveEmoteData.fromJson(Map<String, dynamic> json) => LiveEmoteData(
        fansBrand: json['fans_brand'] as int?,
        data: (json['data'] as List<dynamic>?)
            ?.map((e) => LiveEmoteDatum.fromJson(e as Map<String, dynamic>))
            .toList(),
        purchaseUrl: json['purchase_url'] as dynamic,
      );

  Map<String, dynamic> toJson() => {
        'fans_brand': fansBrand,
        'data': data?.map((e) => e.toJson()).toList(),
        'purchase_url': purchaseUrl,
      };
}

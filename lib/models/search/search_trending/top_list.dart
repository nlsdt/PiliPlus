import 'stat_datas.dart';

class TopList {
	int? hotId;
	String? keyword;
	String? showName;
	int? score;
	int? wordType;
	int? gotoType;
	String? gotoValue;
	String? icon;
	List<dynamic>? liveId;
	int? callReason;
	String? heatLayer;
	int? pos;
	int? id;
	String? status;
	String? nameType;
	int? resourceId;
	int? setGray;
	List<dynamic>? cardValues;
	int? heatScore;
	StatDatas? statDatas;

	TopList({
		this.hotId, 
		this.keyword, 
		this.showName, 
		this.score, 
		this.wordType, 
		this.gotoType, 
		this.gotoValue, 
		this.icon, 
		this.liveId, 
		this.callReason, 
		this.heatLayer, 
		this.pos, 
		this.id, 
		this.status, 
		this.nameType, 
		this.resourceId, 
		this.setGray, 
		this.cardValues, 
		this.heatScore, 
		this.statDatas, 
	});

	factory TopList.fromJson(Map<String, dynamic> json) => TopList(
				hotId: json['hot_id'] as int?,
				keyword: json['keyword'] as String?,
				showName: json['show_name'] as String?,
				score: json['score'] as int?,
				wordType: json['word_type'] as int?,
				gotoType: json['goto_type'] as int?,
				gotoValue: json['goto_value'] as String?,
				icon: json['icon'] as String?,
				liveId: json['live_id'] as List<dynamic>?,
				callReason: json['call_reason'] as int?,
				heatLayer: json['heat_layer'] as String?,
				pos: json['pos'] as int?,
				id: json['id'] as int?,
				status: json['status'] as String?,
				nameType: json['name_type'] as String?,
				resourceId: json['resource_id'] as int?,
				setGray: json['set_gray'] as int?,
				cardValues: json['card_values'] as List<dynamic>?,
				heatScore: json['heat_score'] as int?,
				statDatas: json['stat_datas'] == null
						? null
						: StatDatas.fromJson(json['stat_datas'] as Map<String, dynamic>),
			);

	Map<String, dynamic> toJson() => {
				'hot_id': hotId,
				'keyword': keyword,
				'show_name': showName,
				'score': score,
				'word_type': wordType,
				'goto_type': gotoType,
				'goto_value': gotoValue,
				'icon': icon,
				'live_id': liveId,
				'call_reason': callReason,
				'heat_layer': heatLayer,
				'pos': pos,
				'id': id,
				'status': status,
				'name_type': nameType,
				'resource_id': resourceId,
				'set_gray': setGray,
				'card_values': cardValues,
				'heat_score': heatScore,
				'stat_datas': statDatas?.toJson(),
			};
}

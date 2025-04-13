import 'top_left.dart';
import 'top_right.dart';

class TopShowRecent {
	TopLeft? topLeft;
	TopRight? topRight;

	TopShowRecent({this.topLeft, this.topRight});

	factory TopShowRecent.fromJson(Map<String, dynamic> json) => TopShowRecent(
				topLeft: json['top_left'] == null
						? null
						: TopLeft.fromJson(json['top_left'] as Map<String, dynamic>),
				topRight: json['top_right'] == null
						? null
						: TopRight.fromJson(json['top_right'] as Map<String, dynamic>),
			);

	Map<String, dynamic> toJson() => {
				'top_left': topLeft?.toJson(),
				'top_right': topRight?.toJson(),
			};
}

import 'top_left.dart';
import 'top_right.dart';

class TopShow {
	TopLeft? topLeft;
	TopRight? topRight;

	TopShow({this.topLeft, this.topRight});

	factory TopShow.fromJson(Map<String, dynamic> json) => TopShow(
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

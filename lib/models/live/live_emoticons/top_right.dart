class TopRight {
	String? image;
	String? text;

	TopRight({this.image, this.text});

	factory TopRight.fromJson(Map<String, dynamic> json) => TopRight(
				image: json['image'] as String?,
				text: json['text'] as String?,
			);

	Map<String, dynamic> toJson() => {
				'image': image,
				'text': text,
			};
}

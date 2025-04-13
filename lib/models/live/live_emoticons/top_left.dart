class TopLeft {
	String? image;
	String? text;

	TopLeft({this.image, this.text});

	factory TopLeft.fromJson(Map<String, dynamic> json) => TopLeft(
				image: json['image'] as String?,
				text: json['text'] as String?,
			);

	Map<String, dynamic> toJson() => {
				'image': image,
				'text': text,
			};
}

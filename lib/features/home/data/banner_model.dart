class HomeBanner {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final String cta;
  final String image;
  final String linkUrl;
  final int tabIndex;

  HomeBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.cta,
    required this.image,
    required this.linkUrl,
    required this.tabIndex,
  });

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      subtitle: json['subtitle'] ?? json['description'] ?? '',
      tag: json['tag'] ?? 'FEATURED',
      cta: json['cta'] ?? json['buttonText'] ?? 'Explore',
      image: json['image'] ?? json['imageUrl'] ?? json['banner'] ?? '',
      linkUrl: json['linkUrl'] ?? json['link'] ?? '',
      tabIndex: json['tabIndex'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'tag': tag,
      'cta': cta,
      'image': image,
      'linkUrl': linkUrl,
      'tabIndex': tabIndex,
    };
  }
}

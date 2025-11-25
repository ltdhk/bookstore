class Advertisement {
  final int id;
  final String title;
  final String imageUrl;
  final String targetType; // 'book', 'url', 'none'
  final int? targetId; // Book ID if targetType is 'book'
  final String? targetUrl; // URL if targetType is 'url'
  final String? position; // 'home_banner', 'home_popup', etc.
  final int? sortOrder;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  Advertisement({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.targetType,
    this.targetId,
    this.targetUrl,
    this.position,
    this.sortOrder,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'] as int,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      targetType: json['targetType'] as String,
      targetId: json['targetId'] as int?,
      targetUrl: json['targetUrl'] as String?,
      position: json['position'] as String?,
      sortOrder: json['sortOrder'] as int?,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'targetType': targetType,
      'targetId': targetId,
      'targetUrl': targetUrl,
      'position': position,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

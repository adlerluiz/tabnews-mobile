class Content {
  String? id;
  String? ownerId;
  String? parentId;
  String? slug;
  String? title;
  String? body;
  String? status;
  String? sourceUrl;
  String? createdAt;
  String? updatedAt;
  String? publishedAt;
  String? deletedAt;
  String? ownerUsername;
  int? tabcoins;
  List<dynamic>? children;
  int? childrenDeepCount;

  Content({
    this.id,
    this.ownerId,
    this.parentId,
    this.slug,
    this.title,
    this.body,
    this.status,
    this.sourceUrl,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
    this.deletedAt,
    this.ownerUsername,
    this.tabcoins,
    this.children,
    this.childrenDeepCount,
  });

  Content.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        ownerId = json['owner_id'],
        parentId = json['parent_id'],
        slug = json['slug'],
        title = json['title'],
        body = json['body'],
        status = json['status'],
        sourceUrl = json['source_url'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        publishedAt = json['published_at'],
        deletedAt = json['deleted_at'],
        ownerUsername = json['owner_username'],
        tabcoins = json['tabcoins'],
        children = json['children'],
        childrenDeepCount = json['children_deep_count'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner_id': ownerId,
        'parent_id': parentId,
        'slug': slug,
        'title': title,
        'body': body,
        'status': status,
        'source_url': sourceUrl,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'published_at': publishedAt,
        'deleted_at': deletedAt,
        'owner_username': ownerUsername,
        'tabcoins': tabcoins,
        'children': children,
        'children_deep_count': childrenDeepCount,
      };

  bool matchFilter(String filter) {
    if (title != null && title!.toLowerCase().contains(filter.toLowerCase())) {
      return true;
    }

    return false;
  }
}

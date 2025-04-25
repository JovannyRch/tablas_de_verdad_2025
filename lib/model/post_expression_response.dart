class PostExpressionResponse {
  String? expression;
  String? type;
  String? video_link;
  String? origin;
  int? count;
  String? updatedAt;
  String? createdAt;
  int? id;

  PostExpressionResponse({
    this.expression,
    this.type,
    this.video_link,
    this.origin,
    this.count,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  PostExpressionResponse.fromJson(Map<String, dynamic> json) {
    expression = json['expression'];
    type = json['type'];
    video_link = json['video_link'];
    origin = json['origin'];
    count = json['count'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['expression'] = this.expression;
    data['type'] = this.type;
    data['video_link'] = this.video_link;
    data['origin'] = this.origin;
    data['count'] = this.count;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }

  //to string
  @override
  String toString() {
    return 'PostExpressionResponse{expression: $expression, type: $type, youtubeUrl: $video_link, origin: $origin, count: $count, updatedAt: $updatedAt, createdAt: $createdAt, id: $id}';
  }
}

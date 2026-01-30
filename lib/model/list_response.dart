class ListResponse {
  int? currentPage;
  List<Expression>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  ListResponse({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  ListResponse.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'] ?? 1;
    if (json['data'] != null) {
      data = <Expression>[];
      json['data'].forEach((v) {
        data!.add(Expression.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'] ?? data?.length ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url'] = prevPageUrl;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class Expression {
  int? id;
  String? expression;
  String? type;
  String? youtubeUrl;
  int? count;
  String? origin;

  Expression({
    this.id,
    this.expression,
    this.type,
    this.youtubeUrl,
    this.count,
    this.origin,
  });

  Expression.fromJson(Map<String, dynamic> json) {
    // El nuevo formato no tiene id, así que lo generamos si es necesario
    id = json['id'];
    expression = json['expression']?.toString();
    type = json['type']?.toString();
    // video_link puede ser string vacío o URL válida
    var videoLink = json['video_link'];
    youtubeUrl =
        (videoLink != null && videoLink.toString().isNotEmpty)
            ? videoLink.toString()
            : null;
    // counter viene como int en el JSON
    count =
        json['counter'] is int
            ? json['counter']
            : int.tryParse(json['counter']?.toString() ?? '0');
    origin = json['origin']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['expression'] = expression;
    data['type'] = type;
    data['video_link'] = youtubeUrl;
    data['counter'] = count;

    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['label'] = label;
    data['active'] = active;
    return data;
  }
}

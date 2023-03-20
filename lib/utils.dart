class UserFields {
  static const String url = "url";
}

class UrlModel {
  String? url;

  UrlModel({
    required this.url,
  });

  UrlModel.fromJson(Map<String, dynamic> json) {
    url = json[UserFields.url];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[UserFields.url] = url;
    return data;
  }
}

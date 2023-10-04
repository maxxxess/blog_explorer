import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AutoGenerate {
  AutoGenerate({
    required this.blogs,
  });
  late final List<Blogs> blogs;

  AutoGenerate.fromJson(Map<String, dynamic> json) {
    blogs = List.from(json['blogs']).map((e) => Blogs.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['blogs'] = blogs.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Blogs {
  Blogs(
      {required this.id,
      required this.imageUrl,
      required this.title,
    });
  late final String id;
  late final String imageUrl;
  late final String title;
  

  Blogs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imageUrl = json['image_url'];
    title = json['title'];
  
  }

  set isFavorite(bool isFavorite) {}

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['image_url'] = imageUrl;
    _data['title'] = title;
    return _data;
  }
}

Future<void> storeDataInSharedPreferences(Blogs data) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonData = json.encode(data.toJson());
  prefs.setString('data_key', jsonData);
}

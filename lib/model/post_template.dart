import 'package:flutter/material.dart';

class PostTemplate {
  IconData icon;
  Color iconColor;
  String title;
  String titlePrefix;
  String description;
  String commentHint;

  PostTemplate({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titlePrefix,
    required this.description,
    required this.commentHint,
  });

  PostTemplate.fromJson(Map<String, dynamic> json)
      : icon = json['icon'],
        iconColor = json['icon_color'],
        title = json['title'],
        titlePrefix = json['title_prefix'],
        commentHint = json['comment_hint'],
        description = json['description'];

  Map<String, dynamic> toJson() => {
        'icon': icon,
        'icon_color': iconColor,
        'title': title,
        'title_prefix': titlePrefix,
        'description': description,
        'comment_hint': commentHint,
      };
}

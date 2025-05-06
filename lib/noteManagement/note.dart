import 'dart:convert';

class Note {
  final int? id;
  final String title;
  final String content;
  final int priority;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<String>? tags;
  final String? color;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
    required this.modifiedAt,
    this.tags,
    this.color,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      priority: map['priority'],
      createdAt: DateTime.parse(map['createdAt']),
      modifiedAt: DateTime.parse(map['modifiedAt']),
      tags: map['tags'] != null && map['tags'].isNotEmpty
          ? List<String>.from(json.decode(map['tags']))
          : [],
      color: map['color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'tags': json.encode(tags ?? []),
      'color': color,
    };
  }
}

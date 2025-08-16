import 'package:equatable/equatable.dart';

/// Search result entity representing a search result
class SearchResult extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String type; // 'task', 'note', etc.
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const SearchResult({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.createdAt,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    createdAt,
    metadata,
  ];
}

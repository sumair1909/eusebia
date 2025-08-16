import 'package:equatable/equatable.dart';
import '../../domain/entities/search_result.dart';

/// Search result model for data layer
class SearchResultModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String type;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const SearchResultModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.createdAt,
    this.metadata = const {},
  });

  /// Convert SearchResultModel to SearchResult entity
  SearchResult toEntity() {
    return SearchResult(
      id: id,
      title: title,
      description: description,
      type: type,
      createdAt: createdAt,
      metadata: metadata,
    );
  }

  /// Create SearchResultModel from SearchResult entity
  factory SearchResultModel.fromEntity(SearchResult result) {
    return SearchResultModel(
      id: result.id,
      title: result.title,
      description: result.description,
      type: result.type,
      createdAt: result.createdAt,
      metadata: result.metadata,
    );
  }

  /// Convert SearchResultModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create SearchResultModel from JSON
  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

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

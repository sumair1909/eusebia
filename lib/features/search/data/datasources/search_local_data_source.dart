import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for search functionality
abstract class SearchLocalDataSource {
  /// Get recent searches
  Future<List<String>> getRecentSearches();

  /// Save search query to recent searches
  Future<void> saveSearchQuery(String query);

  /// Clear recent searches
  Future<void> clearRecentSearches();

  /// Get search suggestions from local cache
  Future<List<String>> getSearchSuggestions(String query);
}

class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  const SearchLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<String>> getRecentSearches() async {
    final searchesJson =
        sharedPreferences.getStringList(_recentSearchesKey) ?? [];
    return searchesJson.reversed.toList(); // Most recent first
  }

  @override
  Future<void> saveSearchQuery(String query) async {
    if (query.trim().isEmpty) return;

    final searches = await getRecentSearches();

    // Remove if already exists
    searches.remove(query);

    // Add to beginning
    searches.insert(0, query);

    // Keep only the most recent searches
    if (searches.length > _maxRecentSearches) {
      searches.removeRange(_maxRecentSearches, searches.length);
    }

    await sharedPreferences.setStringList(_recentSearchesKey, searches);
  }

  @override
  Future<void> clearRecentSearches() async {
    await sharedPreferences.remove(_recentSearchesKey);
  }

  @override
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    final recentSearches = await getRecentSearches();
    final suggestions = recentSearches
        .where((search) => search.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return suggestions.take(5).toList(); // Limit to 5 suggestions
  }
}

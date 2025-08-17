import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/usecases/search_content.dart';
import '../providers/search_provider.dart';
import '../../../tasks/domain/entities/task.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Filter states
  final List<TaskPriority> _selectedPriorities = [];
  final List<TaskStatus> _selectedStatuses = [];
  DateTime? _dueDateFrom;
  DateTime? _dueDateTo;
  bool _showOverdueOnly = false;
  bool _showDueTodayOnly = false;
  final List<String> _selectedTags = [];
  final List<String> _selectedLabels = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _performSearch();
    } else {
      ref.read(searchProvider.notifier).clearSearch();
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Check if any filters are applied
    final hasFilters =
        _selectedPriorities.isNotEmpty ||
        _selectedStatuses.isNotEmpty ||
        _dueDateFrom != null ||
        _dueDateTo != null ||
        _showOverdueOnly ||
        _showDueTodayOnly ||
        _selectedTags.isNotEmpty ||
        _selectedLabels.isNotEmpty;

    if (hasFilters) {
      final params = TaskSearchParams(
        query: query,
        priorities: _selectedPriorities.isNotEmpty ? _selectedPriorities : null,
        statuses: _selectedStatuses.isNotEmpty ? _selectedStatuses : null,
        dueDateFrom: _dueDateFrom,
        dueDateTo: _dueDateTo,
        tags: _selectedTags.isNotEmpty ? _selectedTags : null,
        labels: _selectedLabels.isNotEmpty ? _selectedLabels : null,
        isOverdue: _showOverdueOnly ? true : null,
        isDueToday: _showDueTodayOnly ? true : null,
      );
      ref.read(searchProvider.notifier).searchTasksWithFilters(params);
    } else {
      ref.read(searchProvider.notifier).searchTasksByQuery(query);
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedPriorities.clear();
      _selectedStatuses.clear();
      _dueDateFrom = null;
      _dueDateTo = null;
      _showOverdueOnly = false;
      _showDueTodayOnly = false;
      _selectedTags.clear();
      _selectedLabels.clear();
    });
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_hasActiveFilters()) _buildActiveFiltersChip(),
          Expanded(child: _buildSearchResults(searchState)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.horizontalPadding),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search tasks by title or description...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchProvider.notifier).clearSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onSubmitted: (_) => _performSearch(),
      ),
    );
  }

  Widget _buildActiveFiltersChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.horizontalPadding,
      ),
      child: Row(
        children: [
          const Text(
            'Filters: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                if (_selectedPriorities.isNotEmpty)
                  Chip(
                    label: Text(
                      'Priority: ${_selectedPriorities.map((p) => p.name).join(', ')}',
                    ),
                    onDeleted: () {
                      setState(() {
                        _selectedPriorities.clear();
                      });
                      _performSearch();
                    },
                  ),
                if (_selectedStatuses.isNotEmpty)
                  Chip(
                    label: Text(
                      'Status: ${_selectedStatuses.map((s) => s.name).join(', ')}',
                    ),
                    onDeleted: () {
                      setState(() {
                        _selectedStatuses.clear();
                      });
                      _performSearch();
                    },
                  ),
                if (_showOverdueOnly)
                  Chip(
                    label: const Text('Overdue'),
                    onDeleted: () {
                      setState(() {
                        _showOverdueOnly = false;
                      });
                      _performSearch();
                    },
                  ),
                if (_showDueTodayOnly)
                  Chip(
                    label: const Text('Due Today'),
                    onDeleted: () {
                      setState(() {
                        _showDueTodayOnly = false;
                      });
                      _performSearch();
                    },
                  ),
              ],
            ),
          ),
          TextButton(onPressed: _clearFilters, child: const Text('Clear All')),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchState searchState) {
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              searchState.error!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (searchState.results.isEmpty) {
      if (searchState.query.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No tasks found for "${searchState.query}"',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.horizontalPadding),
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final result = searchState.results[index];
        return _buildSearchResultCard(result);
      },
    );
  }

  Widget _buildSearchResultCard(SearchResult result) {
    final isTask = result.type == 'task';
    final metadata = result.metadata;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          result.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.description != null && result.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  result.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (isTask && metadata.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildTaskMetadata(metadata),
            ],
          ],
        ),
        trailing: isTask ? _buildTaskStatusIcon(metadata) : null,
        onTap: () {
          // Navigate to task detail or handle tap
          if (isTask) {
            // Navigate to task detail page
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening task: ${result.title}')),
            );
          }
        },
      ),
    );
  }

  Widget _buildTaskMetadata(Map<String, dynamic> metadata) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (metadata['priority'] != null)
          Chip(
            label: Text(
              metadata['priority'].toString().toUpperCase(),
              style: const TextStyle(fontSize: 10),
            ),
            backgroundColor: _getPriorityColor(
              metadata['priority'],
            ).withValues(alpha: 0.2),
            labelStyle: TextStyle(
              color: _getPriorityColor(metadata['priority']),
              fontWeight: FontWeight.bold,
            ),
          ),
        if (metadata['status'] != null)
          Chip(
            label: Text(
              metadata['status'].toString().toUpperCase(),
              style: const TextStyle(fontSize: 10),
            ),
            backgroundColor: _getStatusColor(
              metadata['status'],
            ).withValues(alpha: 0.2),
            labelStyle: TextStyle(
              color: _getStatusColor(metadata['status']),
              fontWeight: FontWeight.bold,
            ),
          ),
        if (metadata['isOverdue'] == true)
          const Chip(
            label: Text(
              'OVERDUE',
              style: TextStyle(fontSize: 10, color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        if (metadata['isDueToday'] == true)
          const Chip(
            label: Text(
              'DUE TODAY',
              style: TextStyle(fontSize: 10, color: Colors.white),
            ),
            backgroundColor: Colors.orange,
          ),
      ],
    );
  }

  Widget _buildTaskStatusIcon(Map<String, dynamic> metadata) {
    if (metadata['isOverdue'] == true) {
      return const Icon(Icons.warning, color: Colors.red);
    }
    if (metadata['isDueToday'] == true) {
      return const Icon(Icons.today, color: Colors.orange);
    }
    return const Icon(Icons.task, color: Colors.grey);
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,

      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Search Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPriorityFilter(),
              const SizedBox(height: AppConstants.mediumPadding),
              _buildStatusFilter(),
              // const SizedBox(height: AppConstants.mediumPadding),
              // _buildDateFilter(),
              // const SizedBox(height: AppConstants.mediumPadding),
              // _buildQuickFilters(),
              const SizedBox(height: AppConstants.largePadding),
              _buildFilterActions(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: AppConstants.smallPadding,
          children: TaskPriority.values.map((priority) {
            final isSelected = _selectedPriorities.contains(priority);
            return FilterChip(
              label: Text(priority.name.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedPriorities.add(priority);
                  } else {
                    _selectedPriorities.remove(priority);
                  }
                });
                // Trigger search immediately when filter changes
                _performSearch();
              },
              backgroundColor: _getPriorityColor(
                priority.name,
              ).withValues(alpha: 0.1),
              selectedColor: _getPriorityColor(
                priority.name,
              ).withValues(alpha: 0.3),
              labelStyle: TextStyle(
                color: _getPriorityColor(priority.name),
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: AppConstants.smallPadding,
          children: TaskStatus.values.map((status) {
            final isSelected = _selectedStatuses.contains(status);
            return FilterChip(
              label: Text(status.name.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedStatuses.add(status);
                  } else {
                    _selectedStatuses.remove(status);
                  }
                });
                // Trigger search immediately when filter changes
                _performSearch();
              },
              backgroundColor: _getStatusColor(
                status.name,
              ).withValues(alpha: 0.1),
              selectedColor: _getStatusColor(
                status.name,
              ).withValues(alpha: 0.3),
              labelStyle: TextStyle(
                color: _getStatusColor(status.name),
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Widget _buildDateFilter() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Due Date Range',
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //       ),
  //       const SizedBox(height: 8),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: TextButton.icon(
  //               icon: const Icon(Icons.calendar_today),
  //               label: Text(
  //                 _dueDateFrom == null
  //                     ? 'From Date'
  //                     : '${_dueDateFrom!.day}/${_dueDateFrom!.month}/${_dueDateFrom!.year}',
  //               ),
  //               onPressed: () async {
  //                 final date = await showDatePicker(
  //                   context: context,
  //                   initialDate: _dueDateFrom ?? DateTime.now(),
  //                   firstDate: DateTime(2020),
  //                   lastDate: DateTime(2030),
  //                 );
  //                 if (date != null) {
  //                   setState(() {
  //                     _dueDateFrom = date;
  //                   });
  //                 }
  //               },
  //             ),
  //           ),
  //           const Text('to'),
  //           Expanded(
  //             child: TextButton.icon(
  //               icon: const Icon(Icons.calendar_today),
  //               label: Text(
  //                 _dueDateTo == null
  //                     ? 'To Date'
  //                     : '${_dueDateTo!.day}/${_dueDateTo!.month}/${_dueDateTo!.year}',
  //               ),
  //               onPressed: () async {
  //                 final date = await showDatePicker(
  //                   context: context,
  //                   initialDate: _dueDateTo ?? DateTime.now(),
  //                   firstDate: DateTime(2020),
  //                   lastDate: DateTime(2030),
  //                 );
  //                 if (date != null) {
  //                   setState(() {
  //                     _dueDateTo = date;
  //                   });
  //                 }
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildQuickFilters() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Quick Filters',
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //       ),
  //       const SizedBox(height: 8),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: CheckboxListTile(
  //               title: const Text('Overdue Only'),
  //               value: _showOverdueOnly,
  //               onChanged: (value) {
  //                 setState(() {
  //                   _showOverdueOnly = value ?? false;
  //                   if (_showOverdueOnly) {
  //                     _showDueTodayOnly = false;
  //                   }
  //                 });
  //               },
  //             ),
  //           ),
  //           Expanded(
  //             child: CheckboxListTile(
  //               title: const Text('Due Today'),
  //               value: _showDueTodayOnly,
  //               onChanged: (value) {
  //                 setState(() {
  //                   _showDueTodayOnly = value ?? false;
  //                   if (_showDueTodayOnly) {
  //                     _showOverdueOnly = false;
  //                   }
  //                 });
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildFilterActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearFilters,
            child: const Text('Clear Filters'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  bool _hasActiveFilters() {
    return _selectedPriorities.isNotEmpty ||
        _selectedStatuses.isNotEmpty ||
        _dueDateFrom != null ||
        _dueDateTo != null ||
        _showOverdueOnly ||
        _showDueTodayOnly ||
        _selectedTags.isNotEmpty ||
        _selectedLabels.isNotEmpty;
  }
}

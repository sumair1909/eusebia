# Search Feature

The search feature provides comprehensive search functionality for tasks with advanced filtering capabilities.

## Features

### Basic Search
- Search tasks by title and description
- Real-time search as you type
- Search history tracking

### Advanced Task Filtering
- **Priority Filter**: Filter by task priority (Low, Medium, High, Urgent)
- **Status Filter**: Filter by task status (Pending, In Progress, Completed, Cancelled)
- **Due Date Range**: Filter tasks by due date range
- **Quick Filters**: 
  - Overdue tasks only
  - Tasks due today
- **Tags & Labels**: Filter by task tags and labels
- **Created Date Range**: Filter by task creation date

## Architecture

### Domain Layer
- `SearchResult`: Entity representing search results
- `SearchContentParams`: Parameters for general search
- `TaskSearchParams`: Parameters for task-specific search with filters
- `SearchContent`: Use case for general search
- `SearchTasks`: Use case for task search with filters
- `SearchRepository`: Repository interface

### Data Layer
- `SearchRepositoryImpl`: Repository implementation
- `TaskLocalDataSource`: Enhanced with advanced search capabilities
- SQLite-based local search with complex filtering

### Presentation Layer
- `SearchPage`: Main search interface with filters
- `SearchProvider`: State management for search functionality
- `SearchState`: Search state management

## Usage

### Basic Search
```dart
// Search tasks by query
final searchNotifier = ref.read(searchProvider.notifier);
await searchNotifier.searchTasksByQuery('meeting');
```

### Advanced Search with Filters
```dart
// Search with multiple filters
final params = TaskSearchParams(
  query: 'project',
  priorities: [TaskPriority.high, TaskPriority.urgent],
  statuses: [TaskStatus.pending],
  isOverdue: true,
  dueDateFrom: DateTime(2024, 1, 1),
  dueDateTo: DateTime(2024, 12, 31),
);

await searchNotifier.searchTasksWithFilters(params);
```

### Quick Filter Methods
```dart
// Search overdue tasks
await searchNotifier.searchOverdueTasks('urgent');

// Search tasks due today
await searchNotifier.searchTasksDueToday('meeting');

// Search by priority
await searchNotifier.searchTasksByPriority('project', [TaskPriority.high]);

// Search by status
await searchNotifier.searchTasksByStatus('task', [TaskStatus.pending]);

// Search by due date range
await searchNotifier.searchTasksByDueDateRange(
  'deadline',
  DateTime(2024, 1, 1),
  DateTime(2024, 12, 31),
);
```

## UI Components

### Search Bar
- Real-time search input
- Clear button
- Search suggestions

### Filter Bottom Sheet
- Priority selection with color-coded chips
- Status selection with color-coded chips
- Date range picker
- Quick filter checkboxes
- Apply/Clear filter actions

### Search Results
- Task cards with metadata
- Priority and status indicators
- Overdue and due today badges
- Tap to navigate to task details

### Active Filters Display
- Visual chips showing active filters
- Individual filter removal
- Clear all filters option

## Database Queries

The search functionality uses optimized SQLite queries with:
- Full-text search on title and description
- Indexed columns for performance
- Complex WHERE clauses for filtering
- Proper parameter binding for security

## Performance Considerations

- Search queries are debounced to avoid excessive database calls
- Results are cached in the provider state
- Database indexes on frequently searched columns
- Efficient SQL queries with proper joins

## Testing

The search functionality includes comprehensive unit tests covering:
- Use case creation and execution
- Parameter validation
- Filter logic
- Repository interactions

Run tests with:
```bash
flutter test test/unit/features/search/
```

## Future Enhancements

- Search suggestions based on user history
- Fuzzy search for typos
- Search result ranking
- Export search results
- Search analytics
- Voice search integration

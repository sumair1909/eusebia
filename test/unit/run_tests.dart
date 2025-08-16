import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'core/error/failures_test.dart' as failures_test;
import 'core/usecases/usecase_test.dart' as usecase_test;
import 'features/tasks/domain/entities/task_test.dart' as task_entity_test;
import 'features/tasks/domain/usecases/get_all_tasks_test.dart'
    as get_all_tasks_test;
import 'features/tasks/domain/usecases/create_task_test.dart'
    as create_task_test;
import 'features/tasks/domain/usecases/delete_task_test.dart'
    as delete_task_test;
import 'features/tasks/data/repositories/task_repository_impl_test.dart'
    as task_repository_test;
import 'features/search/domain/usecases/search_content_test.dart'
    as search_content_test;

void main() {
  group('Unit Tests', () {
    group('Core', () {
      failures_test.main();
      usecase_test.main();
    });

    group('Tasks Feature', () {
      group('Domain', () {
        group('Entities', () {
          task_entity_test.main();
        });

        group('Use Cases', () {
          get_all_tasks_test.main();
          create_task_test.main();
          delete_task_test.main();
        });
      });

      group('Data', () {
        group('Repositories', () {
          task_repository_test.main();
        });
      });
    });

    group('Search Feature', () {
      group('Domain', () {
        group('Use Cases', () {
          search_content_test.main();
        });
      });
    });
  });
}

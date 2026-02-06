import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_model.dart';
import '../services/projects_service.dart';
import '../services/tasks_service.dart';

// Projects Provider
final projectsServiceProvider = Provider<ProjectsService>((ref) {
  return ProjectsService();
});

final projectsProvider = FutureProvider<ProjectsResponse>((ref) async {
  final service = ref.read(projectsServiceProvider);
  return await service.fetchProjects();
});

// Tasks Provider
final tasksServiceProvider = Provider<TasksService>((ref) {
  return TasksService();
});

final tasksProvider = FutureProvider<TasksResponse>((ref) async {
  final service = ref.read(tasksServiceProvider);
  return await service.fetchTasks();
});

// Task Status Update Provider
final taskStatusUpdateProvider =
    StateNotifierProvider<
      TaskStatusUpdateNotifier,
      AsyncValue<TaskStatusUpdateResponse?>
    >((ref) {
      return TaskStatusUpdateNotifier(ref.read(tasksServiceProvider));
    });

class TaskStatusUpdateNotifier
    extends StateNotifier<AsyncValue<TaskStatusUpdateResponse?>> {
  final TasksService _tasksService;

  TaskStatusUpdateNotifier(this._tasksService)
    : super(const AsyncValue.data(null));

  Future<void> updateTaskStatus(int taskId, String status) async {
    state = const AsyncValue.loading();
    try {
      final response = await _tasksService.updateTaskStatus(taskId, status);
      state = AsyncValue.data(response);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

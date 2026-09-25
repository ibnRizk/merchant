import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../domain/entities/day_schedule.dart';
import '../models/day_schedule_model.dart';

/// Talks to `GET` and `PUT /vendor/working-hours`. Throws `AppException`s;
/// the repository turns them into failures.
abstract class WorkingHoursRemoteDataSource {
  Future<List<DaySchedule>> getWorkingHours();

  Future<List<DaySchedule>> saveWorkingHours(List<DaySchedule> days);
}

class WorkingHoursRemoteDataSourceImpl implements WorkingHoursRemoteDataSource {
  final DioConsumer _client;

  const WorkingHoursRemoteDataSourceImpl({required DioConsumer client})
    : _client = client;

  @override
  Future<List<DaySchedule>> getWorkingHours() async {
    final dynamic response = await _client.get(ApiEndpoints.workingHours);
    return DayScheduleModel.listFromResponse(response);
  }

  /// The PUT answers with the saved week, in the same shape as the GET.
  @override
  Future<List<DaySchedule>> saveWorkingHours(List<DaySchedule> days) async {
    final dynamic response = await _client.put(
      ApiEndpoints.workingHours,
      body: DayScheduleModel.requestBody(days),
    );
    return DayScheduleModel.listFromResponse(response);
  }
}

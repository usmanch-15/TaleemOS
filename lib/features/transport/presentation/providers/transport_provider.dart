import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/transport_remote_datasource.dart';
import '../../data/repositories/transport_repository_impl.dart';
import '../../domain/entities/transport_entity.dart';
import '../../domain/repositories/transport_repository.dart';

final transportRemoteDatasourceProvider = Provider<TransportRemoteDatasource>((ref) {
  return TransportRemoteDatasource(ref.watch(supabaseClientProvider));
});

final transportRepositoryProvider = Provider<TransportRepository>((ref) {
  return TransportRepositoryImpl(ref.watch(transportRemoteDatasourceProvider));
});

final vehiclesListProvider = FutureProvider.autoDispose<List<VehicleEntity>>((ref) async {
  final schoolId = ref.watch(authControllerProvider).user?.schoolId;
  if (schoolId == null) return [];
  return ref.watch(transportRepositoryProvider).getVehicles(schoolId);
});

final driversListProvider = FutureProvider.autoDispose<List<DriverEntity>>((ref) async {
  final schoolId = ref.watch(authControllerProvider).user?.schoolId;
  if (schoolId == null) return [];
  return ref.watch(transportRepositoryProvider).getDrivers(schoolId);
});

final routesListProvider = FutureProvider.autoDispose<List<TransportRouteEntity>>((ref) async {
  final schoolId = ref.watch(authControllerProvider).user?.schoolId;
  if (schoolId == null) return [];
  return ref.watch(transportRepositoryProvider).getRoutes(schoolId);
});

final routeDetailProvider = FutureProvider.autoDispose.family<TransportRouteEntity, String>((ref, routeId) async {
  return ref.watch(transportRepositoryProvider).getRouteById(routeId);
});

final routeOccupancyProvider = FutureProvider.autoDispose.family<RouteOccupancy, String>((ref, routeId) async {
  return ref.watch(transportRepositoryProvider).getRouteOccupancy(routeId);
});

final routeStudentsProvider =
FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, routeId) async {
  return ref.watch(transportRepositoryProvider).getRouteStudents(routeId);
});

final studentTransportInfoProvider =
FutureProvider.autoDispose.family<Map<String, dynamic>?, String>((ref, studentId) async {
  return ref.watch(transportRepositoryProvider).getStudentTransportInfo(studentId);
});

final selectedTransportDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final routeLogsForDateProvider = FutureProvider.autoDispose
    .family<List<TransportLogEntity>, ({String routeId, DateTime date})>((ref, params) async {
  return ref.watch(transportRepositoryProvider).getRouteLogsForDate(routeId: params.routeId, date: params.date);
});

final studentTransportHistoryProvider = FutureProvider.autoDispose
    .family<List<TransportLogEntity>, ({String studentId, DateTime month})>((ref, params) async {
  return ref.watch(transportRepositoryProvider).getStudentTransportHistory(studentId: params.studentId, month: params.month);
});

// ---- Controllers ----
class VehicleController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  VehicleController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> create(VehicleEntity vehicle) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(transportRepositoryProvider).createVehicle(vehicle);
      ref.invalidate(vehiclesListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> delete(String id) async {
    await ref.read(transportRepositoryProvider).deleteVehicle(id);
    ref.invalidate(vehiclesListProvider);
  }
}

final vehicleControllerProvider = StateNotifierProvider<VehicleController, AsyncValue<void>>((ref) => VehicleController(ref));

class DriverController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  DriverController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> create(DriverEntity driver) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(transportRepositoryProvider).createDriver(driver);
      ref.invalidate(driversListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> delete(String id) async {
    await ref.read(transportRepositoryProvider).deleteDriver(id);
    ref.invalidate(driversListProvider);
  }
}

final driverControllerProvider = StateNotifierProvider<DriverController, AsyncValue<void>>((ref) => DriverController(ref));

class RouteController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  RouteController(this.ref) : super(const AsyncValue.data(null));

  Future<String?> create(TransportRouteEntity route) async {
    state = const AsyncValue.loading();
    try {
      final created = await ref.read(transportRepositoryProvider).createRoute(route);
      ref.invalidate(routesListProvider);
      state = const AsyncValue.data(null);
      return created.id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> addStop({required String routeId, required String stopName, required int stopOrder, String? pickupTime, String? dropTime}) async {
    try {
      await ref.read(transportRepositoryProvider).addStop(
        routeId: routeId,
        stopName: stopName,
        stopOrder: stopOrder,
        pickupTime: pickupTime,
        dropTime: dropTime,
      );
      ref.invalidate(routeDetailProvider(routeId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> removeStop(String stopId, String routeId) async {
    await ref.read(transportRepositoryProvider).removeStop(stopId);
    ref.invalidate(routeDetailProvider(routeId));
  }

  Future<void> deleteRoute(String routeId) async {
    await ref.read(transportRepositoryProvider).deleteRoute(routeId);
    ref.invalidate(routesListProvider);
  }

  Future<bool> assignStudent({required String studentId, required String routeId, String? stopId}) async {
    final schoolId = ref.read(authControllerProvider).user?.schoolId;
    if (schoolId == null) return false;
    try {
      await ref.read(transportRepositoryProvider).assignStudentToRoute(
        schoolId: schoolId,
        studentId: studentId,
        routeId: routeId,
        stopId: stopId,
      );
      ref.invalidate(routeStudentsProvider(routeId));
      ref.invalidate(routeOccupancyProvider(routeId));
      ref.invalidate(studentTransportInfoProvider(studentId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> unassignStudent(String studentId, String routeId) async {
    await ref.read(transportRepositoryProvider).unassignStudent(studentId);
    ref.invalidate(routeStudentsProvider(routeId));
    ref.invalidate(routeOccupancyProvider(routeId));
    ref.invalidate(studentTransportInfoProvider(studentId));
  }
}

final routeControllerProvider = StateNotifierProvider<RouteController, AsyncValue<void>>((ref) => RouteController(ref));

class TransportLogController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  TransportLogController(this.ref) : super(const AsyncValue.data(null));

  Future<int?> generateTodayLogs(String routeId, DateTime date) async {
    state = const AsyncValue.loading();
    try {
      final count = await ref.read(transportRepositoryProvider).createDailyLogs(routeId: routeId, date: date);
      ref.invalidate(routeLogsForDateProvider((routeId: routeId, date: date)));
      state = const AsyncValue.data(null);
      return count;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> markPickup(String logId, String status, String routeId, DateTime date) async {
    await ref.read(transportRepositoryProvider).updatePickupStatus(logId: logId, status: status);
    ref.invalidate(routeLogsForDateProvider((routeId: routeId, date: date)));
  }

  Future<void> markDrop(String logId, String status, String routeId, DateTime date) async {
    await ref.read(transportRepositoryProvider).updateDropStatus(logId: logId, status: status);
    ref.invalidate(routeLogsForDateProvider((routeId: routeId, date: date)));
  }
}

final transportLogControllerProvider =
StateNotifierProvider<TransportLogController, AsyncValue<void>>((ref) => TransportLogController(ref));
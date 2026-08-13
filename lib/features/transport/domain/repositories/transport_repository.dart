import '../entities/transport_entity.dart';

abstract class TransportRepository {
  Future<List<VehicleEntity>> getVehicles(String schoolId);
  Future<VehicleEntity> createVehicle(VehicleEntity vehicle);
  Future<void> updateVehicleStatus(String id, String status);
  Future<void> deleteVehicle(String id);

  Future<List<DriverEntity>> getDrivers(String schoolId);
  Future<DriverEntity> createDriver(DriverEntity driver);
  Future<void> deleteDriver(String id);

  Future<List<TransportRouteEntity>> getRoutes(String schoolId);
  Future<TransportRouteEntity> getRouteById(String routeId);
  Future<TransportRouteEntity> createRoute(TransportRouteEntity route);
  Future<void> addStop({required String routeId, required String stopName, required int stopOrder, String? pickupTime, String? dropTime});
  Future<void> removeStop(String stopId);
  Future<void> deleteRoute(String routeId);
  Future<RouteOccupancy> getRouteOccupancy(String routeId);

  Future<void> assignStudentToRoute({required String schoolId, required String studentId, required String routeId, String? stopId});
  Future<void> unassignStudent(String studentId);
  Future<List<Map<String, dynamic>>> getRouteStudents(String routeId);
  Future<Map<String, dynamic>?> getStudentTransportInfo(String studentId);

  Future<int> createDailyLogs({required String routeId, required DateTime date});
  Future<List<TransportLogEntity>> getRouteLogsForDate({required String routeId, required DateTime date});
  Future<void> updatePickupStatus({required String logId, required String status});
  Future<void> updateDropStatus({required String logId, required String status});
  Future<List<TransportLogEntity>> getStudentTransportHistory({required String studentId, required DateTime month});
}
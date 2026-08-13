
import '../../domain/entities/transport_entity.dart';
import '../../domain/repositories/transport_repository.dart';
import '../datasources/transport_remote_datasource.dart';
import '../models/transport_models.dart';

class TransportRepositoryImpl implements TransportRepository {
  final TransportRemoteDatasource remote;
  TransportRepositoryImpl(this.remote);

  @override
  Future<List<VehicleEntity>> getVehicles(String schoolId) => remote.getVehicles(schoolId);

  @override
  Future<VehicleEntity> createVehicle(VehicleEntity vehicle) {
    final model = VehicleModel(
      id: vehicle.id,
      schoolId: vehicle.schoolId,
      vehicleNumber: vehicle.vehicleNumber,
      vehicleType: vehicle.vehicleType,
      capacity: vehicle.capacity,
      status: vehicle.status,
    );
    return remote.createVehicle(model);
  }

  @override
  Future<void> updateVehicleStatus(String id, String status) => remote.updateVehicleStatus(id, status);

  @override
  Future<void> deleteVehicle(String id) => remote.deleteVehicle(id);

  @override
  Future<List<DriverEntity>> getDrivers(String schoolId) => remote.getDrivers(schoolId);

  @override
  Future<DriverEntity> createDriver(DriverEntity driver) {
    final model = DriverModel(
      id: driver.id,
      schoolId: driver.schoolId,
      fullName: driver.fullName,
      phone: driver.phone,
      licenseNumber: driver.licenseNumber,
      status: driver.status,
    );
    return remote.createDriver(model);
  }

  @override
  Future<void> deleteDriver(String id) => remote.deleteDriver(id);

  @override
  Future<List<TransportRouteEntity>> getRoutes(String schoolId) => remote.getRoutes(schoolId);

  @override
  Future<TransportRouteEntity> getRouteById(String routeId) => remote.getRouteById(routeId);

  @override
  Future<TransportRouteEntity> createRoute(TransportRouteEntity route) {
    final model = TransportRouteModel(
      id: route.id,
      schoolId: route.schoolId,
      vehicleId: route.vehicleId,
      driverId: route.driverId,
      routeName: route.routeName,
      startPoint: route.startPoint,
      endPoint: route.endPoint,
      monthlyFee: route.monthlyFee,
      status: route.status,
    );
    return remote.createRoute(model);
  }

  @override
  Future<void> addStop({required String routeId, required String stopName, required int stopOrder, String? pickupTime, String? dropTime}) {
    return remote.addStop(routeId: routeId, stopName: stopName, stopOrder: stopOrder, pickupTime: pickupTime, dropTime: dropTime);
  }

  @override
  Future<void> removeStop(String stopId) => remote.removeStop(stopId);

  @override
  Future<void> deleteRoute(String routeId) => remote.deleteRoute(routeId);

  @override
  Future<RouteOccupancy> getRouteOccupancy(String routeId) => remote.getRouteOccupancy(routeId);

  @override
  Future<void> assignStudentToRoute({required String schoolId, required String studentId, required String routeId, String? stopId}) {
    return remote.assignStudentToRoute(schoolId: schoolId, studentId: studentId, routeId: routeId, stopId: stopId);
  }

  @override
  Future<void> unassignStudent(String studentId) => remote.unassignStudent(studentId);

  @override
  Future<List<Map<String, dynamic>>> getRouteStudents(String routeId) => remote.getRouteStudents(routeId);

  @override
  Future<Map<String, dynamic>?> getStudentTransportInfo(String studentId) => remote.getStudentTransportInfo(studentId);

  @override
  Future<int> createDailyLogs({required String routeId, required DateTime date}) =>
      remote.createDailyLogs(routeId: routeId, date: date);

  @override
  Future<List<TransportLogEntity>> getRouteLogsForDate({required String routeId, required DateTime date}) {
    return remote.getRouteLogsForDate(routeId: routeId, date: date);
  }

  @override
  Future<void> updatePickupStatus({required String logId, required String status}) =>
      remote.updatePickupStatus(logId: logId, status: status);

  @override
  Future<void> updateDropStatus({required String logId, required String status}) =>
      remote.updateDropStatus(logId: logId, status: status);

  @override
  Future<List<TransportLogEntity>> getStudentTransportHistory({required String studentId, required DateTime month}) {
    return remote.getStudentTransportHistory(studentId: studentId, month: month);
  }
}
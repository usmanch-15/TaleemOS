import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transport_models.dart';

class TransportRemoteDatasource {
  final SupabaseClient client;
  TransportRemoteDatasource(this.client);

  // ---- Vehicles ----
  Future<List<VehicleModel>> getVehicles(String schoolId) async {
    final data = await client.from('vehicles').select().eq('school_id', schoolId).order('vehicle_number');
    return (data as List).map((e) => VehicleModel.fromMap(e)).toList();
  }

  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    final data = await client.from('vehicles').insert(vehicle.toInsertMap()).select().single();
    return VehicleModel.fromMap(data);
  }

  Future<void> updateVehicleStatus(String id, String status) async {
    await client.from('vehicles').update({'status': status}).eq('id', id);
  }

  Future<void> deleteVehicle(String id) async {
    await client.from('vehicles').delete().eq('id', id);
  }

  // ---- Drivers ----
  Future<List<DriverModel>> getDrivers(String schoolId) async {
    final data = await client.from('drivers').select().eq('school_id', schoolId).order('full_name');
    return (data as List).map((e) => DriverModel.fromMap(e)).toList();
  }

  Future<DriverModel> createDriver(DriverModel driver) async {
    final data = await client.from('drivers').insert(driver.toInsertMap()).select().single();
    return DriverModel.fromMap(data);
  }

  Future<void> deleteDriver(String id) async {
    await client.from('drivers').delete().eq('id', id);
  }

  // ---- Routes ----
  Future<List<TransportRouteModel>> getRoutes(String schoolId) async {
    final data = await client
        .from('transport_routes')
        .select('*, vehicles(vehicle_number), drivers(full_name), route_stops(*)')
        .eq('school_id', schoolId)
        .order('route_name');
    return (data as List).map((e) => TransportRouteModel.fromMap(e)).toList();
  }

  Future<TransportRouteModel> getRouteById(String routeId) async {
    final data = await client
        .from('transport_routes')
        .select('*, vehicles(vehicle_number), drivers(full_name), route_stops(*)')
        .eq('id', routeId)
        .single();
    return TransportRouteModel.fromMap(data);
  }

  Future<TransportRouteModel> createRoute(TransportRouteModel route) async {
    final data = await client
        .from('transport_routes')
        .insert(route.toInsertMap())
        .select('*, vehicles(vehicle_number), drivers(full_name), route_stops(*)')
        .single();
    return TransportRouteModel.fromMap(data);
  }

  Future<void> addStop({
    required String routeId,
    required String stopName,
    required int stopOrder,
    String? pickupTime,
    String? dropTime,
  }) async {
    await client.from('route_stops').insert({
      'route_id': routeId,
      'stop_name': stopName,
      'stop_order': stopOrder,
      'pickup_time': pickupTime,
      'drop_time': dropTime,
    });
  }

  Future<void> removeStop(String stopId) async {
    await client.from('route_stops').delete().eq('id', stopId);
  }

  Future<void> deleteRoute(String routeId) async {
    await client.from('transport_routes').delete().eq('id', routeId);
  }

  Future<RouteOccupancyModel> getRouteOccupancy(String routeId) async {
    final result = await client.rpc('get_route_occupancy', params: {'p_route_id': routeId});
    final row = (result as List).first as Map<String, dynamic>;
    return RouteOccupancyModel.fromMap(row);
  }

  // ---- Student Assignment ----
  Future<void> assignStudentToRoute({
    required String schoolId,
    required String studentId,
    required String routeId,
    String? stopId,
  }) async {
    await client.from('student_transport').upsert({
      'school_id': schoolId,
      'student_id': studentId,
      'route_id': routeId,
      'stop_id': stopId,
      'status': 'active',
    }, onConflict: 'student_id');
  }

  Future<void> unassignStudent(String studentId) async {
    await client.from('student_transport').delete().eq('student_id', studentId);
  }

  Future<List<Map<String, dynamic>>> getRouteStudents(String routeId) async {
    final data = await client
        .from('student_transport')
        .select('id, student_id, students(full_name, student_code), route_stops(stop_name)')
        .eq('route_id', routeId)
        .eq('status', 'active');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> getStudentTransportInfo(String studentId) async {
    final data = await client
        .from('student_transport')
        .select('*, transport_routes(route_name, vehicles(vehicle_number), drivers(full_name, phone)), route_stops(stop_name, pickup_time, drop_time)')
        .eq('student_id', studentId)
        .maybeSingle();
    return data;
  }

  // ---- Daily Logs ----
  Future<int> createDailyLogs({required String routeId, required DateTime date}) async {
    final result = await client.rpc('create_daily_transport_logs', params: {
      'p_route_id': routeId,
      'p_date': date.toIso8601String().split('T')[0],
    });
    return result as int;
  }

  Future<List<TransportLogModel>> getRouteLogsForDate({required String routeId, required DateTime date}) async {
    final data = await client
        .from('transport_logs')
        .select('*, students(full_name)')
        .eq('route_id', routeId)
        .eq('date', date.toIso8601String().split('T')[0])
        .order('created_at');
    return (data as List).map((e) => TransportLogModel.fromMap(e)).toList();
  }

  Future<void> updatePickupStatus({required String logId, required String status}) async {
    await client.from('transport_logs').update({
      'pickup_status': status,
      'pickup_time': status == 'picked_up' ? DateTime.now().toIso8601String() : null,
    }).eq('id', logId);
  }

  Future<void> updateDropStatus({required String logId, required String status}) async {
    await client.from('transport_logs').update({
      'drop_status': status,
      'drop_time': status == 'dropped' ? DateTime.now().toIso8601String() : null,
    }).eq('id', logId);
  }

  Future<List<TransportLogModel>> getStudentTransportHistory({
    required String studentId,
    required DateTime month,
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    final data = await client
        .from('transport_logs')
        .select('*, students(full_name)')
        .eq('student_id', studentId)
        .gte('date', start.toIso8601String().split('T')[0])
        .lte('date', end.toIso8601String().split('T')[0])
        .order('date', ascending: false);
    return (data as List).map((e) => TransportLogModel.fromMap(e)).toList();
  }
}
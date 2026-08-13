import '../../domain/entities/transport_entity.dart';

class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    required super.schoolId,
    required super.vehicleNumber,
    required super.vehicleType,
    required super.capacity,
    required super.status,
  });

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      vehicleNumber: map['vehicle_number'] as String,
      vehicleType: map['vehicle_type'] as String,
      capacity: map['capacity'] as int,
      status: VehicleStatusX.fromString(map['status'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'school_id': schoolId,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'capacity': capacity,
      'status': status.toDbString(),
    };
  }
}

class DriverModel extends DriverEntity {
  const DriverModel({
    required super.id,
    required super.schoolId,
    required super.fullName,
    required super.phone,
    super.licenseNumber,
    super.photoUrl,
    required super.status,
  });

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    return DriverModel(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String,
      licenseNumber: map['license_number'] as String?,
      photoUrl: map['photo_url'] as String?,
      status: map['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'school_id': schoolId,
      'full_name': fullName,
      'phone': phone,
      'license_number': licenseNumber,
      'photo_url': photoUrl,
      'status': status,
    };
  }
}

class RouteStopModel extends RouteStopEntity {
  const RouteStopModel({
    required super.id,
    required super.routeId,
    required super.stopName,
    required super.stopOrder,
    super.pickupTime,
    super.dropTime,
  });

  factory RouteStopModel.fromMap(Map<String, dynamic> map) {
    return RouteStopModel(
      id: map['id'] as String,
      routeId: map['route_id'] as String,
      stopName: map['stop_name'] as String,
      stopOrder: map['stop_order'] as int? ?? 0,
      pickupTime: map['pickup_time'] as String?,
      dropTime: map['drop_time'] as String?,
    );
  }
}

class TransportRouteModel extends TransportRouteEntity {
  const TransportRouteModel({
    required super.id,
    required super.schoolId,
    super.vehicleId,
    super.vehicleNumber,
    super.driverId,
    super.driverName,
    required super.routeName,
    super.startPoint,
    super.endPoint,
    required super.monthlyFee,
    required super.status,
    super.stops,
  });

  factory TransportRouteModel.fromMap(Map<String, dynamic> map) {
    final vehicle = map['vehicles'] as Map<String, dynamic>?;
    final driver = map['drivers'] as Map<String, dynamic>?;
    final stopsList = (map['route_stops'] as List<dynamic>?)
        ?.map((e) => RouteStopModel.fromMap(e as Map<String, dynamic>))
        .toList() ??
        [];
    stopsList.sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

    return TransportRouteModel(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      vehicleId: map['vehicle_id'] as String?,
      vehicleNumber: vehicle?['vehicle_number'] as String?,
      driverId: map['driver_id'] as String?,
      driverName: driver?['full_name'] as String?,
      routeName: map['route_name'] as String,
      startPoint: map['start_point'] as String?,
      endPoint: map['end_point'] as String?,
      monthlyFee: (map['monthly_fee'] as num?)?.toDouble() ?? 0,
      status: map['status'] as String? ?? 'active',
      stops: stopsList,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'school_id': schoolId,
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'route_name': routeName,
      'start_point': startPoint,
      'end_point': endPoint,
      'monthly_fee': monthlyFee,
      'status': status,
    };
  }
}

class TransportLogModel extends TransportLogEntity {
  const TransportLogModel({
    required super.id,
    required super.studentId,
    required super.studentName,
    required super.routeId,
    required super.date,
    required super.pickupStatus,
    super.pickupTime,
    required super.dropStatus,
    super.dropTime,
  });

  factory TransportLogModel.fromMap(Map<String, dynamic> map) {
    final student = map['students'] as Map<String, dynamic>?;
    return TransportLogModel(
      id: map['id'] as String,
      studentId: map['student_id'] as String,
      studentName: student?['full_name'] as String? ?? '',
      routeId: map['route_id'] as String,
      date: DateTime.parse(map['date'] as String),
      pickupStatus: PickupDropStatusX.fromPickupString(map['pickup_status'] as String?),
      pickupTime: map['pickup_time'] != null ? DateTime.parse(map['pickup_time'] as String) : null,
      dropStatus: PickupDropStatusX.fromDropString(map['drop_status'] as String?),
      dropTime: map['drop_time'] != null ? DateTime.parse(map['drop_time'] as String) : null,
    );
  }
}

class RouteOccupancyModel extends RouteOccupancy {
  const RouteOccupancyModel({required super.assignedCount, required super.capacity});

  factory RouteOccupancyModel.fromMap(Map<String, dynamic> map) {
    return RouteOccupancyModel(
      assignedCount: (map['assigned_count'] as num?)?.toInt() ?? 0,
      capacity: (map['capacity'] as num?)?.toInt() ?? 0,
    );
  }
}
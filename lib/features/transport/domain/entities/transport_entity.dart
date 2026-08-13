import 'package:equatable/equatable.dart';

enum VehicleStatus { active, maintenance, inactive }

extension VehicleStatusX on VehicleStatus {
  String toDbString() => name;
  static VehicleStatus fromString(String value) =>
      VehicleStatus.values.firstWhere((e) => e.name == value, orElse: () => VehicleStatus.active);
  String get label {
    switch (this) {
      case VehicleStatus.active:
        return 'Active';
      case VehicleStatus.maintenance:
        return 'Maintenance';
      case VehicleStatus.inactive:
        return 'Inactive';
    }
  }
}

class VehicleEntity extends Equatable {
  final String id;
  final String schoolId;
  final String vehicleNumber;
  final String vehicleType;
  final int capacity;
  final VehicleStatus status;

  const VehicleEntity({
    required this.id,
    required this.schoolId,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.capacity,
    required this.status,
  });

  @override
  List<Object?> get props => [id, schoolId, vehicleNumber, vehicleType, capacity, status];
}

class DriverEntity extends Equatable {
  final String id;
  final String schoolId;
  final String fullName;
  final String phone;
  final String? licenseNumber;
  final String? photoUrl;
  final String status;

  const DriverEntity({
    required this.id,
    required this.schoolId,
    required this.fullName,
    required this.phone,
    this.licenseNumber,
    this.photoUrl,
    required this.status,
  });

  @override
  List<Object?> get props => [id, schoolId, fullName, phone, status];
}

class RouteStopEntity extends Equatable {
  final String id;
  final String routeId;
  final String stopName;
  final int stopOrder;
  final String? pickupTime;
  final String? dropTime;

  const RouteStopEntity({
    required this.id,
    required this.routeId,
    required this.stopName,
    required this.stopOrder,
    this.pickupTime,
    this.dropTime,
  });

  @override
  List<Object?> get props => [id, routeId, stopName, stopOrder];
}

class TransportRouteEntity extends Equatable {
  final String id;
  final String schoolId;
  final String? vehicleId;
  final String? vehicleNumber;
  final String? driverId;
  final String? driverName;
  final String routeName;
  final String? startPoint;
  final String? endPoint;
  final double monthlyFee;
  final String status;
  final List<RouteStopEntity> stops;

  const TransportRouteEntity({
    required this.id,
    required this.schoolId,
    this.vehicleId,
    this.vehicleNumber,
    this.driverId,
    this.driverName,
    required this.routeName,
    this.startPoint,
    this.endPoint,
    required this.monthlyFee,
    required this.status,
    this.stops = const [],
  });

  @override
  List<Object?> get props => [id, schoolId, vehicleId, driverId, routeName, monthlyFee, status];
}

enum PickupDropStatus { pending, done, absent }

extension PickupDropStatusX on PickupDropStatus {
  static PickupDropStatus fromPickupString(String? value) {
    switch (value) {
      case 'picked_up':
        return PickupDropStatus.done;
      case 'absent':
        return PickupDropStatus.absent;
      default:
        return PickupDropStatus.pending;
    }
  }

  static PickupDropStatus fromDropString(String? value) {
    switch (value) {
      case 'dropped':
        return PickupDropStatus.done;
      case 'absent':
        return PickupDropStatus.absent;
      default:
        return PickupDropStatus.pending;
    }
  }
}

class TransportLogEntity extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String routeId;
  final DateTime date;
  final PickupDropStatus pickupStatus;
  final DateTime? pickupTime;
  final PickupDropStatus dropStatus;
  final DateTime? dropTime;

  const TransportLogEntity({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.routeId,
    required this.date,
    required this.pickupStatus,
    this.pickupTime,
    required this.dropStatus,
    this.dropTime,
  });

  @override
  List<Object?> get props => [id, studentId, routeId, date, pickupStatus, dropStatus];
}

class RouteOccupancy extends Equatable {
  final int assignedCount;
  final int capacity;

  const RouteOccupancy({required this.assignedCount, required this.capacity});

  double get occupancyPercentage => capacity == 0 ? 0 : (assignedCount / capacity) * 100;
  bool get isFull => assignedCount >= capacity;

  @override
  List<Object?> get props => [assignedCount, capacity];
}
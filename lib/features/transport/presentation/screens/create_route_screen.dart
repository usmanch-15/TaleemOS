import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/transport_entity.dart';
import '../providers/transport_provider.dart';

class CreateRouteScreen extends ConsumerStatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  ConsumerState<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends ConsumerState<CreateRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _routeNameController = TextEditingController();
  final _startPointController = TextEditingController();
  final _endPointController = TextEditingController();
  final _feeController = TextEditingController();
  String? _selectedVehicleId;
  String? _selectedDriverId;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final schoolId = ref.read(authControllerProvider).user?.schoolId;
    if (schoolId == null) return;

    final route = TransportRouteEntity(
      id: '',
      schoolId: schoolId,
      vehicleId: _selectedVehicleId,
      driverId: _selectedDriverId,
      routeName: _routeNameController.text.trim(),
      startPoint: _startPointController.text.trim(),
      endPoint: _endPointController.text.trim(),
      monthlyFee: double.tryParse(_feeController.text.trim()) ?? 0,
      status: 'active',
    );

    final routeId = await ref.read(routeControllerProvider.notifier).create(route);
    if (routeId != null && mounted) {
      context.pushReplacement('/transport/routes/$routeId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesListProvider);
    final driversAsync = ref.watch(driversListProvider);
    final state = ref.watch(routeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Route')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(controller: _routeNameController, label: 'Route Name (e.g. Route A - North)', validator: Validators.name),
            const SizedBox(height: 12),
            AppTextField(controller: _startPointController, label: 'Start Point'),
            const SizedBox(height: 12),
            AppTextField(controller: _endPointController, label: 'End Point (School)'),
            const SizedBox(height: 12),
            AppTextField(controller: _feeController, label: 'Monthly Fee', keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            vehiclesAsync.when(
              data: (vehicles) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Assign Vehicle (optional)'),
                items: vehicles.map((v) => DropdownMenuItem(value: v.id, child: Text(v.vehicleNumber))).toList(),
                onChanged: (value) => setState(() => _selectedVehicleId = value),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading vehicles'),
            ),
            const SizedBox(height: 12),
            driversAsync.when(
              data: (drivers) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Assign Driver (optional)'),
                items: drivers.map((d) => DropdownMenuItem(value: d.id, child: Text(d.fullName))).toList(),
                onChanged: (value) => setState(() => _selectedDriverId = value),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading drivers'),
            ),
            const SizedBox(height: 24),
            AppButton(label: 'Create Route', onPressed: _submit, isLoading: state.isLoading),
          ],
        ),
      ),
    );
  }
}
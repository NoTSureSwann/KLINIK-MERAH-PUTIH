import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/widgets/app_app_bar.dart';
import '../../../../../shared/widgets/app_container.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../domain/entities/doctor_service.dart';
import '../../../../providers/doctor_service_provider.dart';

class ServiceFormScreen extends ConsumerStatefulWidget {
  final DoctorService? existingService;
  const ServiceFormScreen({super.key, this.existingService});

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existingService?.name ?? '');
    _descCtrl = TextEditingController(text: widget.existingService?.description ?? '');
    _priceCtrl = TextEditingController(text: widget.existingService?.price.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final service = DoctorService(
      id: widget.existingService?.id ?? '0',
      name: _nameCtrl.text,
      description: _descCtrl.text,
      price: double.tryParse(_priceCtrl.text) ?? 0,
    );

    if (widget.existingService == null) {
      await ref.read(doctorServiceProvider.notifier).addService(service);
    } else {
      await ref.read(doctorServiceProvider.notifier).updateService(service);
    }

    if (mounted) {
      final serviceState = ref.read(doctorServiceProvider);
      if (serviceState.hasError) {
        final errorMsg = serviceState.error.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMsg'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppAppBar(
            title: widget.existingService == null ? 'Add Service' : 'Edit Service',
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: AppContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                child: Column(
                  children: [
                    AppTextField(controller: _nameCtrl, hintText: 'Service Name', prefixIcon: Icons.medical_services),
                    const SizedBox(height: 16),
                    AppTextField(controller: _descCtrl, hintText: 'Description', prefixIcon: Icons.description),
                    const SizedBox(height: 16),
                    AppTextField(controller: _priceCtrl, hintText: 'Price', prefixIcon: Icons.attach_money, keyboardType: TextInputType.number),
                    const SizedBox(height: 32),
                    AppButton(text: 'Save', onPressed: _save),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

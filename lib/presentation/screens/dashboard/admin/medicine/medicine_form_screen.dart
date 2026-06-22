import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/widgets/app_app_bar.dart';
import '../../../../../shared/widgets/app_container.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../domain/entities/medicine.dart';
import '../../../../providers/medicine_provider.dart';

class MedicineFormScreen extends ConsumerStatefulWidget {
  final Medicine? existingMedicine;
  const MedicineFormScreen({super.key, this.existingMedicine});

  @override
  ConsumerState<MedicineFormScreen> createState() => _MedicineFormScreenState();
}

class _MedicineFormScreenState extends ConsumerState<MedicineFormScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existingMedicine?.name ?? '');
    _descCtrl = TextEditingController(text: widget.existingMedicine?.description ?? '');
    _priceCtrl = TextEditingController(text: widget.existingMedicine?.price.toStringAsFixed(0) ?? '');
    _stockCtrl = TextEditingController(text: widget.existingMedicine?.stock.toString() ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final medicine = Medicine(
      id: widget.existingMedicine?.id ?? '0',
      name: _nameCtrl.text,
      description: _descCtrl.text,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      stock: int.tryParse(_stockCtrl.text) ?? 0,
    );

    if (widget.existingMedicine == null) {
      await ref.read(medicineProvider.notifier).addMedicine(medicine);
    } else {
      await ref.read(medicineProvider.notifier).updateMedicine(medicine);
    }

    if (mounted) {
      final medicineState = ref.read(medicineProvider);
      if (medicineState.hasError) {
        final errorMsg = medicineState.error.toString().replaceAll('Exception: ', '');
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
            title: widget.existingMedicine == null ? 'Add Medicine' : 'Edit Medicine',
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
                    AppTextField(controller: _nameCtrl, hintText: 'Medicine Name', prefixIcon: Icons.medication),
                    const SizedBox(height: 16),
                    AppTextField(controller: _descCtrl, hintText: 'Description', prefixIcon: Icons.description),
                    const SizedBox(height: 16),
                    AppTextField(controller: _priceCtrl, hintText: 'Price', prefixIcon: Icons.attach_money, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    AppTextField(controller: _stockCtrl, hintText: 'Stock', prefixIcon: Icons.inventory, keyboardType: TextInputType.number),
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

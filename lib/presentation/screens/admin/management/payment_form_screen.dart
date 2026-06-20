import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/payment.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../shared/widgets/glass_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/patient_provider.dart';
import '../../../providers/doctor_provider.dart';

class PaymentFormScreen extends ConsumerStatefulWidget {
  final Payment? payment;

  const PaymentFormScreen({super.key, this.payment});

  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedPatientId;
  String? _selectedDoctorId;
  final _amountController = TextEditingController();
  final _invoiceController = TextEditingController();
  
  String _paymentMethod = 'Cash';
  String _status = 'Pending';

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      _selectedPatientId = widget.payment!.patientId;
      _selectedDoctorId = widget.payment!.doctorId;
      _amountController.text = widget.payment!.amount.toStringAsFixed(0);
      _invoiceController.text = widget.payment!.invoiceNumber;
      _paymentMethod = widget.payment!.paymentMethod;
      _status = widget.payment!.status;
    } else {
      _invoiceController.text = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    }
    
    Future.microtask(() {
      ref.read(patientProvider.notifier).loadPatients();
      ref.read(doctorProvider.notifier).loadDoctors();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _invoiceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null || _selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Patient and Doctor')),
      );
      return;
    }

    final payment = Payment(
      id: widget.payment?.id ?? '',
      patientId: _selectedPatientId!,
      doctorId: _selectedDoctorId!,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      paymentMethod: _paymentMethod,
      invoiceNumber: _invoiceController.text,
      status: _status,
    );

    if (widget.payment == null) {
      ref.read(paymentProvider.notifier).createPayment(payment);
    } else {
      ref.read(paymentProvider.notifier).updatePayment(payment);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final patientState = ref.watch(patientProvider);
    final doctorState = ref.watch(doctorProvider);

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [AppColors.darkBackgroundTop, AppColors.darkBackgroundMiddle, AppColors.darkBackgroundBottom]
                : [AppColors.backgroundTop, AppColors.backgroundMiddle, AppColors.backgroundBottom],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GlassAppBar(
                title: widget.payment == null ? 'Create Payment' : 'Edit Payment',
                showBackButton: true,
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: GlassContainer(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 24,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Patient', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        _buildDropdown<String>(
                          value: _selectedPatientId,
                          hint: 'Select Patient',
                          items: patientState.patients.map((p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          )).toList(),
                          onChanged: (val) => setState(() => _selectedPatientId = val),
                        ),
                        const SizedBox(height: 16),
                        
                        Text('Doctor', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        _buildDropdown<String>(
                          value: _selectedDoctorId,
                          hint: 'Select Doctor',
                          items: doctorState.doctors.map((d) => DropdownMenuItem(
                            value: d.id,
                            child: Text('Dr. ${d.name}'),
                          )).toList(),
                          onChanged: (val) => setState(() => _selectedDoctorId = val),
                        ),
                        const SizedBox(height: 20),

                        GlassTextField(
                          controller: _invoiceController,
                          hintText: 'Invoice Number',
                          prefixIcon: Icons.receipt,
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        GlassTextField(
                          controller: _amountController,
                          hintText: 'Amount (Rp)',
                          prefixIcon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Method', style: Theme.of(context).textTheme.titleSmall),
                                  const SizedBox(height: 8),
                                  _buildDropdown<String>(
                                    value: _paymentMethod,
                                    hint: 'Method',
                                    items: const [
                                      DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                                      DropdownMenuItem(value: 'Transfer', child: Text('Transfer')),
                                      DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
                                      DropdownMenuItem(value: 'BPJS', child: Text('BPJS')),
                                    ],
                                    onChanged: (val) => setState(() => _paymentMethod = val!),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Status', style: Theme.of(context).textTheme.titleSmall),
                                  const SizedBox(height: 8),
                                  _buildDropdown<String>(
                                    value: _status,
                                    hint: 'Status',
                                    items: const [
                                      DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                                      DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                                      DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                                    ],
                                    onChanged: (val) => setState(() => _status = val!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        GlassButton(
                          text: 'Save Payment',
                          onPressed: _save,
                          isLoading: ref.watch(paymentProvider).isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400)),
          isExpanded: true,
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

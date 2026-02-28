import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_bloc.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_event.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_state.dart';

class CreateServiceRequestScreen extends StatefulWidget {
  final String categoryId;

  const CreateServiceRequestScreen({super.key, required this.categoryId});

  @override
  State<CreateServiceRequestScreen> createState() =>
      _CreateServiceRequestScreenState();
}

class _CreateServiceRequestScreenState
    extends State<CreateServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceRangeController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceRangeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && mounted) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      context.read<ServiceRequestBloc>().add(
        CreateServiceRequestEvent(
          categoryId: widget.categoryId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          date: _selectedDate!,
          priceRange: _priceRangeController.text.trim(),
          address: _addressController.text.trim(),
        ),
      );
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Request')),
      body: BlocConsumer<ServiceRequestBloc, ServiceRequestState>(
        listener: (context, state) {
          if (state is ServiceRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ServiceRequestSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Request Created Successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // Go back to Home
          }
        },
        builder: (context, state) {
          if (state is ServiceRequestLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Category ID: ${widget.categoryId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Job Title',
                      hintText: 'e.g. Need a deep house cleaning',
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a title'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe what needs to be done...',
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a description'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceRangeController,
                    decoration: const InputDecoration(
                      labelText: 'Expected Price Range',
                      hintText: 'e.g. \$50 - \$100',
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a price range'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // 💡 Direct payment info banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4FD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF90CAF9)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF1565C0),
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '💡 Payment is handled directly with the provider (Cash or Transfer) upon completion. No payments are taken through the app.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1565C0),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Service Address',
                      hintText: 'e.g. 123 Main St, Warsaw, Poland',
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter the service address'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'No Date & Time Chosen!'
                              : 'Selected: ${_selectedDate!.toLocal().toString().substring(0, 16)}',
                        ),
                      ),
                      TextButton(
                        onPressed: _presentDatePicker,
                        child: const Text(
                          'Choose Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed:
                        _submitRequest, // Changed _submitData to _submitRequest
                    child: const Text('SUBMIT REQUEST'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

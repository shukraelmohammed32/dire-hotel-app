import 'package:flutter/material.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/services/customer_session.dart';
import 'package:mobile/core/theme/app_theme.dart';
import '../../delivery/domain/delivery_order.dart';
import '../../delivery/domain/delivery_order_request.dart';
import 'delivery_order_confirmation_dialog.dart';

class DeliveryOrderFlowSheet extends StatefulWidget {
  const DeliveryOrderFlowSheet({
    this.initialItems = const [],
    this.initialDeliveryTime,
    this.apiClient,
    this.onOrderSuccess,
    super.key,
  });

  final List<DeliveryOrderItemRequest> initialItems;
  final DateTime? initialDeliveryTime;
  final ApiClient? apiClient;
  final void Function(DeliveryOrder order)? onOrderSuccess;

  @override
  State<DeliveryOrderFlowSheet> createState() => _DeliveryOrderFlowSheetState();
}

class _DeliveryOrderFlowSheetState extends State<DeliveryOrderFlowSheet> {
  late final ApiClient _apiClient;
  final _formKey = GlobalKey<FormState>();

  late List<DeliveryOrderItemRequest> _items;
  DateTime? _deliveryTime;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;
  String? _submissionError;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? ApiClient();
    _items = List.from(widget.initialItems);
    _deliveryTime = widget.initialDeliveryTime;

    // Pre-fill from active customer session if available
    final session = CustomerSession.instance;
    if (session.phone != null) _phoneController.text = session.phone!;
    if (session.name != null) _nameController.text = session.name!;
    if (session.email != null) _emailController.text = session.email!;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateItemQuantity(String itemId, int newQuantity) {
    setState(() {
      _items = _items.map((item) {
        if (item.id == itemId) {
          return DeliveryOrderItemRequest(
            id: item.id,
            name: item.name,
            price: item.price,
            quantity: newQuantity.clamp(1, 99),
            category: item.category,
            notes: item.notes,
          );
        }
        return item;
      }).toList();
    });
  }

  void _removeItem(String itemId) {
    setState(() {
      _items.removeWhere((item) => item.id == itemId);
    });
  }

  double get _subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.price * item.quantity);
  }

  Future<void> _pickDeliveryTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
      initialDate: _deliveryTime ?? now.add(const Duration(hours: 1)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_deliveryTime ?? now.add(const Duration(hours: 1))),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          );
        },
      );
      if (time != null && mounted) {
        setState(() {
          _deliveryTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item to your order.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    try {
      final request = DeliveryOrderRequest(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        address: _addressController.text.trim(),
        items: _items,
        deliveryTime: _deliveryTime,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      final order = await _apiClient.createDeliveryOrder(request);

      // Save customer identity for session management
      CustomerSession.instance.setCustomer(
        phone: request.phone,
        name: request.name,
        email: request.email,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close bottom sheet

        widget.onOrderSuccess?.call(order);

        showDialog<void>(
          context: context,
          builder: (_) => DeliveryOrderConfirmationDialog(
            order: order,
            onViewOrders: () {
              // onOrderSuccess already navigated
            },
          ),
        );
      }
    } on NetworkException catch (e) {
      if (mounted) {
        setState(() {
          _submissionError = e.message;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submissionError = e.toString().replaceFirst('ApiException: ', '');
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            shrinkWrap: true,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Order',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                        const Text(
                          'Ras Restaurant & Bar',
                          style: TextStyle(color: AppColors.muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Section 1: Order Items
              _buildOrderItemsSection(),
              const SizedBox(height: 20),
              // Section 2: Delivery Details
              _buildDeliveryDetailsSection(),
              const SizedBox(height: 20),
              // Section 3: Contact Information
              _buildContactSection(),
              if (_submissionError != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Colors.red.shade800, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _submissionError!,
                          style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSubmitting ? null : _submitOrder,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: AppColors.burgundy,
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Text('Placing Order…'),
                        ],
                      )
                    : Text(
                        _items.isNotEmpty
                            ? 'Place Order (${_formatPrice(_subtotal)} ETB)'
                            : 'Add Items to Order',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '1. Your Order',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink),
            ),
            if (_items.isNotEmpty)
              Text(
                '${_items.length} item${_items.length == 1 ? '' : 's'} • ${_formatPrice(_subtotal)} ETB',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.burgundy),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (_items.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(Icons.shopping_bag_outlined, size: 48, color: AppColors.muted),
                const SizedBox(height: 12),
                const Text(
                  'No items in your order',
                  style: TextStyle(fontSize: 15, color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select items from the menu to add them here.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              ..._items.map((item) => _buildOrderItemCard(item)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _priceRow('Subtotal', _formatPrice(_subtotal)),
                    _priceRow('Delivery Fee', '50.00'),
                    const Divider(height: 16),
                    _priceRow('Total', _formatPrice(_subtotal + 50), isTotal: true),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildOrderItemCard(DeliveryOrderItemRequest item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          if (item.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.fastfood_outlined, color: Colors.grey.shade400),
                ),
              ),
            )
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.fastfood_outlined, color: Colors.grey.shade400),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.category != null)
                  Text(
                    item.category!,
                    style: const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                if (item.notes != null && item.notes!.isNotEmpty)
                  Text(
                    item.notes!,
                    style: const TextStyle(fontSize: 11, color: AppColors.muted, fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${_formatPrice(item.price)} ETB',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.burgundy),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _quantityButton(
                    icon: Icons.remove,
                    onPressed: item.quantity > 1 ? () => _updateItemQuantity(item.id, item.quantity - 1) : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  _quantityButton(
                    icon: Icons.add,
                    onPressed: item.quantity < 99 ? () => _updateItemQuantity(item.id, item.quantity + 1) : null,
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
            onPressed: () => _removeItem(item.id),
            tooltip: 'Remove item',
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 18),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size(32, 32),
        padding: EdgeInsets.zero,
        backgroundColor: onPressed != null ? AppColors.burgundy.withOpacity(0.1) : Colors.grey.shade100,
        foregroundColor: onPressed != null ? AppColors.burgundy : Colors.grey.shade400,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDeliveryDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Delivery Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickDeliveryTime,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_outlined, size: 18, color: AppColors.burgundy),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Delivery Time', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                      Text(
                        _deliveryTime != null
                            ? '${_deliveryTime!.day}/${_deliveryTime!.month} at ${_formatTime(_deliveryTime!)}'
                            : 'ASAP',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. Contact & Address',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            hintText: 'e.g. Abebe Bikila',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: (v) => v == null || v.trim().isEmpty ? 'Full name is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number *',
            hintText: '+251 91 123 4567',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: (v) => v == null || v.trim().isEmpty ? 'Phone number is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address (optional)',
            hintText: 'customer@example.com',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Delivery Address *',
            hintText: 'Full address including building, floor, room number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on_outlined),
            alignLabelWithHint: true,
          ),
          validator: (v) => v == null || v.trim().isEmpty ? 'Delivery address is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Special Instructions (optional)',
            hintText: 'e.g. Call on arrival, leave at reception, dietary notes',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? AppColors.ink : AppColors.muted,
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: FontWeight.bold,
              color: isTotal ? AppColors.burgundy : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(2);
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
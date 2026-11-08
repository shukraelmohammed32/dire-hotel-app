import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/core/services/customer_session.dart';
import 'package:mobile/core/theme/app_theme.dart';
import '../domain/delivery_order.dart';
import 'controllers/delivery_orders_controller.dart';

class DeliveryOrdersScreen extends StatefulWidget {
  const DeliveryOrdersScreen({
    super.key,
    this.controller,
  });

  final DeliveryOrdersController? controller;

  @override
  State<DeliveryOrdersScreen> createState() => _DeliveryOrdersScreenState();
}

class _DeliveryOrdersScreenState extends State<DeliveryOrdersScreen> {
  late final DeliveryOrdersController _controller;
  final _phoneInputController = TextEditingController();
  int _selectedTabIndex = 0; // 0 = Pending, 1 = Active, 2 = Past

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? DeliveryOrdersController();

    final sessionPhone = CustomerSession.instance.phone;
    if (sessionPhone != null && sessionPhone.isNotEmpty) {
      _phoneInputController.text = sessionPhone;
      _controller.loadOrders(phone: sessionPhone);
    }
    _controller.startPolling(intervalSeconds: 30);
  }

  @override
  void dispose() {
    _controller.stopPolling();
    _phoneInputController.dispose();
    super.dispose();
  }

  void _searchOrders() {
    final phone = _phoneInputController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number to find your delivery orders.')),
      );
      return;
    }
    CustomerSession.instance.setCustomer(phone: phone);
    _controller.loadOrders(phone: phone);
  }

  List<DeliveryOrder> _getCurrentTabOrders() {
    switch (_selectedTabIndex) {
      case 0:
        return _controller.pendingOrders;
      case 1:
        return _controller.confirmedOrders;
      case 2:
        return _controller.pastOrders;
      default:
        return _controller.pendingOrders;
    }
  }

  String _getTabLabel(int index) {
    switch (index) {
      case 0:
        return 'Pending (${_controller.pendingOrders.length})';
      case 1:
        return 'Active (${_controller.confirmedOrders.length})';
      case 2:
        return 'Past (${_controller.pastOrders.length})';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final currentOrders = _getCurrentTabOrders();
        final isLoading = _controller.isLoading;
        final error = _controller.errorMessage;
        final hasPhone = CustomerSession.instance.hasIdentity;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Delivery Orders',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontFamily: 'serif',
                            fontSize: 32,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Track your food delivery orders from Ras Restaurant & Bar.',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    _buildPhoneLookupHeader(hasPhone),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (hasPhone) _buildFilterTabs(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (CustomerSession.instance.phone != null) {
                      await _controller.loadOrders();
                    }
                  },
                  color: AppColors.burgundy,
                  child: _buildBody(isLoading, error, currentOrders, hasPhone),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhoneLookupHeader(bool hasPhone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.delivery_dining_outlined, color: AppColors.burgundy, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _phoneInputController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Enter phone number (+251...)',
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _searchOrders(),
            ),
          ),
          FilledButton.tonal(
            onPressed: _searchOrders,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text('Find'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabButton(0, _getTabLabel(0)),
          _tabButton(1, _getTabLabel(1)),
          _tabButton(2, _getTabLabel(2)),
        ],
      ),
    );
  }

  Widget _tabButton(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.burgundy : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isLoading, String? error, List<DeliveryOrder> orders, bool hasPhone) {
    if (!hasPhone) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(Icons.lock_outline_rounded, size: 48, color: AppColors.muted),
                SizedBox(height: 12),
                Text(
                  'Customer Verification Required',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
                SizedBox(height: 6),
                Text(
                  'Enter your phone number above to access your delivery orders.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.burgundy),
            SizedBox(height: 12),
            Text('Loading orders...', style: TextStyle(color: AppColors.muted)),
          ],
        ),
      );
    }

    if (error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(Icons.error_outline_rounded, size: 44, color: Colors.red.shade700),
                const SizedBox(height: 12),
                Text(
                  'Error loading orders',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                ),
                const SizedBox(height: 6),
                Text(error, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _controller.loadOrders(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (orders.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                const Icon(Icons.delivery_dining_outlined, size: 48, color: AppColors.muted),
                const SizedBox(height: 12),
                Text(
                  _selectedTabIndex == 0
                      ? 'No pending orders'
                      : _selectedTabIndex == 1
                          ? 'No active orders'
                          : 'No past orders',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your delivery orders will appear here.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(DeliveryOrder order) {
    Color badgeColor;
    Color badgeTextColor;
    IconData statusIcon;
    switch (order.status) {
      case 'PENDING':
        badgeColor = const Color(0xFFFFF3E0);
        badgeTextColor = const Color(0xFFE65100);
        statusIcon = Icons.schedule_outlined;
        break;
      case 'CONFIRMED':
      case 'PREPARING':
        badgeColor = const Color(0xFFE3F2FD);
        badgeTextColor = const Color(0xFF1565C0);
        statusIcon = Icons.restaurant_outlined;
        break;
      case 'OUT_FOR_DELIVERY':
        badgeColor = const Color(0xFFF3E5F5);
        badgeTextColor = const Color(0xFF7B1FA2);
        statusIcon = Icons.local_shipping_outlined;
        break;
      case 'DELIVERED':
        badgeColor = const Color(0xFFE8F5E9);
        badgeTextColor = const Color(0xFF2E7D32);
        statusIcon = Icons.check_circle_outlined;
        break;
      case 'CANCELLED':
        badgeColor = const Color(0xFFFFEBEE);
        badgeTextColor = const Color(0xFFC62828);
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        badgeColor = const Color(0xFFF5F5F5);
        badgeTextColor = const Color(0xFF757575);
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Reference & Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    order.confirmationNo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.burgundy,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.muted),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: order.confirmationNo));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reference copied!'), duration: Duration(seconds: 1)),
                      );
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(statusIcon, size: 14, color: badgeTextColor),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 18),
          // Order items preview
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.burgundy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: order.items.isNotEmpty && order.items.first.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          order.items.first.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.delivery_dining_outlined, color: AppColors.burgundy, size: 28),
                        ),
                      )
                    : const Icon(Icons.delivery_dining_outlined, color: AppColors.burgundy, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.items.isNotEmpty ? order.items.first.name : 'Order',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    if (order.items.length > 1) ...[
                      const SizedBox(height: 2),
                      Text(
                        '+${order.items.length - 1} more item${order.items.length > 2 ? 's' : ''}',
                        style: const TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      order.address.length > 40
                          ? '${order.address.substring(0, 40)}...'
                          : order.address,
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Total & Delivery time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Total', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                  Text(
                    '${order.total.toStringAsFixed(2)} ETB',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.burgundy,
                    ),
                  ),
                ],
              ),
              if (order.deliveryTime != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Delivery by', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    Text(
                      '${order.deliveryTime!.day}/${order.deliveryTime!.month} at ${_formatTime(order.deliveryTime!)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
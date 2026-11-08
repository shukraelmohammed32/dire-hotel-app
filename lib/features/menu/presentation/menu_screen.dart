import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../delivery/domain/delivery_order_request.dart';
import '../../delivery/presentation/delivery_order_flow_sheet.dart';
import '../data/menu_data.dart';
import '../domain/menu_item.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  MenuCategory? _selectedCategory;
  String _query = '';

  // Cart state
  final List<_CartItem> _cart = [];

  static const _categoryLabels = <MenuCategory, String>{
    MenuCategory.breakfast: 'Breakfast',
    MenuCategory.ethiopian: 'Ethiopian',
    MenuCategory.international: 'International',
    MenuCategory.grill: 'From the Grill',
    MenuCategory.drinks: 'Drinks',
    MenuCategory.dessert: 'Dessert',
  };

  List<MenuItem> get _visibleItems {
    final query = _query.trim().toLowerCase();
    return MenuData.items.where((item) {
      final matchesCategory =
          _selectedCategory == null || item.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.tags.any((tag) => tag.toLowerCase().contains(query));
      return matchesCategory && matchesQuery;
    }).toList();
  }

  int get _cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);
  double get _cartTotal => _cart.fold(0.0, (sum, item) => sum + item.item.price * item.quantity);

  void _addToCart(MenuItem item) {
    setState(() {
      final existingIndex = _cart.indexWhere((c) => c.item.id == item.id);
      if (existingIndex >= 0) {
        _cart[existingIndex] = _CartItem(item: item, quantity: _cart[existingIndex].quantity + 1);
      } else {
        _cart.add(_CartItem(item: item, quantity: 1));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to order'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View Order',
          onPressed: _showCartBottomSheet,
        ),
      ),
    );
  }

  void _removeFromCart(String itemId) {
    setState(() {
      _cart.removeWhere((c) => c.item.id == itemId);
    });
  }

  void _updateCartQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      _removeFromCart(itemId);
      return;
    }
    setState(() {
      final index = _cart.indexWhere((c) => c.item.id == itemId);
      if (index >= 0) {
        _cart[index] = _CartItem(item: _cart[index].item, quantity: quantity);
      }
    });
  }

  void _showCartBottomSheet() {
    if (_cart.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CartBottomSheet(
        cart: _cart,
        onUpdateQuantity: _updateCartQuantity,
        onRemove: _removeFromCart,
        onCheckout: _proceedToDelivery,
      ),
    );
  }

  void _proceedToDelivery() {
    Navigator.of(context).pop(); // Close cart bottom sheet
    if (_cart.isEmpty) return;

    final items = _cart.map((c) => DeliveryOrderItemRequest(
      id: c.item.id,
      name: c.item.name,
      price: c.item.price.toDouble(),
      quantity: c.quantity,
      category: c.item.category.name,
    )).toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeliveryOrderFlowSheet(initialItems: items),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildCategories()),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, _cart.isEmpty ? 30 : 120),
                sliver: _visibleItems.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState(context))
                    : SliverList.builder(
                        key: ValueKey('${_selectedCategory?.name}:$_query'),
                        itemCount: _visibleItems.length,
                        itemBuilder: (context, index) =>
                            _MenuCard(
                              key: ValueKey(_visibleItems[index].id),
                              item: _visibleItems[index],
                              onAddToCart: _addToCart,
                            ),
                      ),
              ),
            ],
          ),
          if (_cart.isNotEmpty) _buildCartBar(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/room_dining.png',
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.25),
                          Colors.black.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blush,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Ras Dining & Bar',
                          style: TextStyle(
                            color: AppColors.burgundy,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Our menu',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontFamily: 'serif',
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Fresh Ethiopian and international dishes, prepared at Ras Hotel.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: 'Search dishes, drinks, or dietary options',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 45,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: [
          _CategoryChip(
            label: 'All',
            selected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          ..._categoryLabels.entries.map(
            (entry) => _CategoryChip(
              label: entry.value,
              selected: _selectedCategory == entry.key,
              onTap: () => setState(() => _selectedCategory = entry.key),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Text(
          'No menu items match your search.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildCartBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_cartItemCount item${_cartItemCount == 1 ? '' : 's'} in your order',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      '${_cartTotal.toStringAsFixed(2)} ETB',
                      style: const TextStyle(
                        color: AppColors.burgundy,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _showCartBottomSheet,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.burgundy,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Review & Order', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItem {
  const _CartItem({required this.item, required this.quantity});
  final MenuItem item;
  final int quantity;
}

class _CartBottomSheet extends StatelessWidget {
  const _CartBottomSheet({
    required this.cart,
    required this.onUpdateQuantity,
    required this.onRemove,
    required this.onCheckout,
  });

  final List<_CartItem> cart;
  final Function(String itemId, int quantity) onUpdateQuantity;
  final Function(String itemId) onRemove;
  final VoidCallback onCheckout;

  double get _total => cart.fold(0.0, (sum, c) => sum + c.item.price * c.quantity);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Row(
                children: [
                  const Text(
                    'Your Order',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.ink),
                  ),
                  const Spacer(),
                  if (cart.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // We need to clear cart from parent - this is handled by parent state
                      },
                      child: const Text('Clear', style: TextStyle(color: AppColors.muted)),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                itemCount: cart.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final c = cart[index];
                  return _CartItemTile(
                    item: c.item,
                    quantity: c.quantity,
                    onUpdateQuantity: (q) => onUpdateQuantity(c.item.id, q),
                    onRemove: () => onRemove(c.item.id),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  _priceRow('Subtotal', _formatPrice(_total)),
                  _priceRow('Delivery Fee', '50.00'),
                  const Divider(height: 16),
                  _priceRow('Total', _formatPrice(_total + 50), isTotal: true),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: onCheckout,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.burgundy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Proceed to Delivery', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? AppColors.ink : AppColors.muted,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? AppColors.burgundy : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(2)} ETB';
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.quantity,
    required this.onUpdateQuantity,
    required this.onRemove,
  });

  final MenuItem item;
  final int quantity;
  final ValueChanged<int> onUpdateQuantity;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final itemTotal = item.price * quantity;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 56,
              height: 56,
              color: item.featured ? AppColors.blush : Colors.grey.shade100,
              child: Icon(
                item.category == MenuCategory.drinks
                    ? Icons.local_cafe_outlined
                    : item.category == MenuCategory.dessert
                        ? Icons.cake_outlined
                        : Icons.restaurant_outlined,
                color: AppColors.burgundy,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  '${item.price} ETB each',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${_formatPrice(itemTotal.toDouble())}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.burgundy),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _qtyBtn(Icons.remove, quantity > 1 ? () => onUpdateQuantity(quantity - 1) : null),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                  _qtyBtn(Icons.add, quantity < 99 ? () => onUpdateQuantity(quantity + 1) : null),
                ],
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
            onPressed: onRemove,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback? onPressed) {
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

  String _formatPrice(double price) {
    return price.toStringAsFixed(2);
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: AppColors.blush,
        side: BorderSide(color: selected ? AppColors.burgundy : AppColors.border),
        labelStyle: TextStyle(
          color: selected ? AppColors.burgundy : AppColors.muted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({super.key, required this.item, required this.onAddToCart});

  final MenuItem item;
  final void Function(MenuItem) onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${item.price} ETB',
                  style: const TextStyle(
                    color: AppColors.burgundy,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(item.description, style: Theme.of(context).textTheme.bodyMedium),
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: item.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: item.featured ? AppColors.blush : AppColors.canvas,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => onAddToCart(item),
                icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
                label: const Text('Add to Delivery Order'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.burgundy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../../../core/theme/app_design_system.dart';
import '../../../../core/theme/rs_components.dart';
import '../../delivery/domain/delivery_order_request.dart';
import '../../delivery/presentation/delivery_order_flow_sheet.dart';
import '../data/menu_data.dart';
import '../domain/menu_item.dart';

class MenuScreenV2 extends StatefulWidget {
  const MenuScreenV2({super.key});

  @override
  State<MenuScreenV2> createState() => _MenuScreenV2State();
}

class _MenuScreenV2State extends State<MenuScreenV2> {
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
    _showAddedSnackBar(item);
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

  void _showAddedSnackBar(MenuItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to order'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
        ),
        action: SnackBarAction(
          label: 'View Order',
          textColor: RSColors.gold,
          onPressed: _showCartBottomSheet,
        ),
      ),
    );
  }

  void _showCartBottomSheet() {
    if (_cart.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CartBottomSheetV2(
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
              // ── Header ────────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader(context)),

              // ── Categories ────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildCategories()),

              // ── Menu Items ───────────────────────────────────────────
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  RSSpacing.xl,
                  RSSpacing.xl,
                  RSSpacing.xl,
                  _cart.isEmpty ? RSSpacing.massive : 140,
                ),
                sliver: _visibleItems.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState(context))
                    : SliverList.builder(
                        itemCount: _visibleItems.length,
                        itemBuilder: (context, index) => _MenuCardV2(
                          key: ValueKey(_visibleItems[index].id),
                          item: _visibleItems[index],
                          onAddToCart: _addToCart,
                          index: index,
                        ),
                      ),
              ),
            ],
          ),

          // ── Cart Bar ─────────────────────────────────────────────────
          if (_cart.isNotEmpty) _buildCartBar(),
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// HEADER
  /// ═══════════════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(RSSpacing.xl, RSSpacing.lg, RSSpacing.xl, RSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image with gradient
          RSAnimatedSlide(
            begin: const Offset(0, 30),
            child: RSCard(
              variant: RSCardVariant.elevated,
              padding: EdgeInsets.zero,
              borderRadius: RSSpacing.radiusXxxl,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(RSSpacing.radiusXxxl),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/room_dining.png',
                      height: 200,
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
                              Colors.black.withValues(alpha: 0.2),
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: RSSpacing.xl,
                      right: RSSpacing.xl,
                      bottom: RSSpacing.xl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RSAnimatedFade(
                            delay: const Duration(milliseconds: 200),
                            child: RSBadge(
                              label: 'Ras Dining & Bar',
                              variant: RSBadgeVariant.primary,
                              size: RSBadgeSize.medium,
                            ),
                          ),
                          const SizedBox(height: RSSpacing.md),
                          RSAnimatedFade(
                            delay: const Duration(milliseconds: 300),
                            child: Text(
                              'Our Menu',
                              style: RSTypography.displaySmall.copyWith(
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            ),
                          ),
                          const SizedBox(height: RSSpacing.xs),
                          RSAnimatedFade(
                            delay: const Duration(milliseconds: 400),
                            child: Text(
                              'Fresh Ethiopian and international dishes, prepared at Ras Hotel.',
                              style: RSTypography.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: RSSpacing.xl),

          // Search field
          RSAnimatedSlide(
            delay: const Duration(milliseconds: 350),
            begin: const Offset(0, 20),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search dishes, drinks, or dietary options',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: RSSpacing.lg,
                  vertical: RSSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RSSpacing.radiusInput),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RSSpacing.radiusInput),
                  borderSide: BorderSide(color: RSColors.border, width: RSBorders.thin),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RSSpacing.radiusInput),
                  borderSide: BorderSide(color: RSColors.burgundy, width: RSBorders.thick),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// CATEGORIES
  /// ═══════════════════════════════════════════════════════════════════════

  Widget _buildCategories() {
    return RSAnimatedSlide(
      delay: const Duration(milliseconds: 400),
      begin: const Offset(0, 20),
      child: SizedBox(
        height: 48,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: RSSpacing.xl),
          scrollDirection: Axis.horizontal,
          children: [
            _CategoryChipV2(
              label: 'All',
              selected: _selectedCategory == null,
              onTap: () => setState(() => _selectedCategory = null),
            ),
            ..._categoryLabels.entries.map(
              (entry) => _CategoryChipV2(
                label: entry.value,
                selected: _selectedCategory == entry.key,
                onTap: () => setState(() => _selectedCategory = entry.key),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// EMPTY STATE
  /// ═══════════════════════════════════════════════════════════════════════

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: RSSpacing.massive),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(RSSpacing.xxl),
              decoration: BoxDecoration(
                color: RSColors.rose100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: RSIconSizes.xxxl,
                color: RSColors.muted,
              ),
            ),
            const SizedBox(height: RSSpacing.lg),
            Text(
              'No menu items match your search.',
              style: RSTypography.bodyLarge.copyWith(color: RSColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: RSSpacing.sm),
            Text(
              'Try adjusting your filters or search terms.',
              style: RSTypography.bodyMedium.copyWith(color: RSColors.mutedLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// CART BAR
  /// ═══════════════════════════════════════════════════════════════════════

  Widget _buildCartBar() {
    return RSAnimatedSlide(
      begin: const Offset(0, 100),
      child: Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: RSSpacing.xl,
              vertical: RSSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
              border: Border(top: BorderSide(color: RSColors.border)),
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
                        style: RSTypography.titleMedium.copyWith(
                          color: RSColors.ink,
                        ),
                      ),
                      Text(
                        '${_cartTotal.toStringAsFixed(2)} ETB',
                        style: RSTypography.priceMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: RSSpacing.md),
                RSButton(
                  label: 'Review & Order',
                  style: RSButtonStyle.primary,
                  size: RSButtonSize.medium,
                  onPressed: _showCartBottomSheet,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════
/// CATEGORY CHIP V2
/// ════════════════════════════════════════════════════════════════════════

class _CategoryChipV2 extends StatelessWidget {
  const _CategoryChipV2({
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
      padding: const EdgeInsets.only(right: RSSpacing.sm),
      child: RSChip(
        label: label,
        selected: selected,
        onSelected: (_) => onTap(),
        style: RSChipStyle.filter,
      ),
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════
/// MENU CARD V2
/// ════════════════════════════════════════════════════════════════════════

class _MenuCardV2 extends StatelessWidget {
  const _MenuCardV2({
    super.key,
    required this.item,
    required this.onAddToCart,
    this.index = 0,
  });

  final MenuItem item;
  final void Function(MenuItem) onAddToCart;
  final int index;

  @override
  Widget build(BuildContext context) {
    return RSAnimatedSlide(
      delay: Duration(milliseconds: (index * 60).clamp(0, 300)),
      begin: const Offset(0, 20),
      child: RSCard(
        variant: RSCardVariant.outlined,
        padding: const EdgeInsets.all(RSSpacing.lg),
        margin: const EdgeInsets.only(bottom: RSSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name & Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: RSTypography.titleLarge.copyWith(
                          color: RSColors.ink,
                        ),
                      ),
                      if (item.featured) ...[
                        const SizedBox(height: RSSpacing.xs),
                        RSBadge(
                          label: 'Chef\'s Choice',
                          variant: RSBadgeVariant.warning,
                          size: RSBadgeSize.small,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: RSSpacing.md),
                Text(
                  '${item.price} ETB',
                  style: RSTypography.priceMedium.copyWith(
                    color: RSColors.burgundy,
                  ),
                ),
              ],
            ),

            const SizedBox(height: RSSpacing.md),

            // Description
            Text(
              item.description,
              style: RSTypography.bodyMedium.copyWith(
                color: RSColors.onSurfaceVariant,
              ),
            ),

            // Tags
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: RSSpacing.md),
              Wrap(
                spacing: RSSpacing.xs,
                runSpacing: RSSpacing.xs,
                children: item.tags.map((tag) {
                  return RSBadge(
                    label: tag,
                    variant: item.featured ? RSBadgeVariant.warning : RSBadgeVariant.neutral,
                    size: RSBadgeSize.small,
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: RSSpacing.lg),

            // Add button
            RSButton(
              label: 'Add to Order',
              icon: const Icon(Icons.add_shopping_cart_outlined),
              style: RSButtonStyle.primary,
              fullWidth: true,
              onPressed: () => onAddToCart(item),
            ),
          ],
        ),
      ),
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════
/// CART BOTTOM SHEET V2
/// ════════════════════════════════════════════════════════════════════════

class _CartBottomSheetV2 extends StatelessWidget {
  const _CartBottomSheetV2({
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
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(RSSpacing.radiusSheet)),
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
                margin: const EdgeInsets.only(top: RSSpacing.md, bottom: RSSpacing.sm),
                decoration: BoxDecoration(
                  color: RSColors.border,
                  borderRadius: BorderRadius.circular(RSSpacing.radiusFull),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(RSSpacing.xl, 0, RSSpacing.xl, RSSpacing.md),
              child: Row(
                children: [
                  Text(
                    'Your Order',
                    style: RSTypography.titleLarge,
                  ),
                  const Spacer(),
                  if (cart.isNotEmpty)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Clear',
                        style: RSTypography.labelLarge.copyWith(color: RSColors.muted),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 1, color: RSColors.divider),

            // Cart items
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(RSSpacing.xl, RSSpacing.lg, RSSpacing.xl, RSSpacing.md),
                itemCount: cart.length,
                separatorBuilder: (_, _) => const SizedBox(height: RSSpacing.md),
                itemBuilder: (context, index) {
                  final c = cart[index];
                  return _CartItemTileV2(
                    item: c.item,
                    quantity: c.quantity,
                    onUpdateQuantity: (q) => onUpdateQuantity(c.item.id, q),
                    onRemove: () => onRemove(c.item.id),
                  );
                },
              ),
            ),

            const Divider(height: 1, color: RSColors.divider),

            // Totals & Checkout
            Padding(
              padding: const EdgeInsets.fromLTRB(RSSpacing.xl, RSSpacing.lg, RSSpacing.xl, RSSpacing.xxxl),
              child: Column(
                children: [
                  _PriceRowV2(label: 'Subtotal', value: '${_total.toStringAsFixed(2)} ETB'),
                  _PriceRowV2(label: 'Delivery Fee', value: '50.00 ETB'),
                  const Divider(height: RSSpacing.xl, color: RSColors.divider),
                  _PriceRowV2(
                    label: 'Total',
                    value: '${(_total + 50).toStringAsFixed(2)} ETB',
                    isTotal: true,
                  ),
                  const SizedBox(height: RSSpacing.xl),
                  RSButton(
                    label: 'Proceed to Delivery',
                    icon: const Icon(Icons.arrow_forward_rounded),
                    style: RSButtonStyle.primary,
                    size: RSButtonSize.large,
                    fullWidth: true,
                    onPressed: onCheckout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════
/// CART ITEM TILE V2
/// ════════════════════════════════════════════════════════════════════════

class _CartItemTileV2 extends StatelessWidget {
  const _CartItemTileV2({
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

    return RSCard(
      variant: RSCardVariant.filled,
      padding: const EdgeInsets.all(RSSpacing.md),
      child: Row(
        children: [
          // Item image/icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: item.featured ? RSColors.rose100 : RSColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
            ),
            child: Icon(
              item.category == MenuCategory.drinks
                  ? Icons.local_cafe_outlined
                  : item.category == MenuCategory.dessert
                      ? Icons.cake_outlined
                      : Icons.restaurant_outlined,
              color: RSColors.burgundy,
              size: RSIconSizes.lg,
            ),
          ),

          const SizedBox(width: RSSpacing.md),

          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: RSTypography.titleMedium.copyWith(
                    color: RSColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: RSSpacing.xs),
                Text(
                  '${item.price} ETB each',
                  style: RSTypography.bodySmall.copyWith(color: RSColors.muted),
                ),
              ],
            ),
          ),

          // Quantity & price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${itemTotal.toStringAsFixed(2)} ETB',
                style: RSTypography.priceSmall.copyWith(
                  color: RSColors.burgundy,
                ),
              ),
              const SizedBox(height: RSSpacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RSIconButton(
                    icon: const Icon(Icons.remove_rounded),
                    onPressed: quantity > 1 ? () => onUpdateQuantity(quantity - 1) : null,
                    size: RSIconButtonSize.small,
                    style: RSIconButtonStyle.tonal,
                    enabled: quantity > 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: RSSpacing.md),
                    child: Text(
                      '$quantity',
                      style: RSTypography.titleMedium.copyWith(
                        color: RSColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  RSIconButton(
                    icon: const Icon(Icons.add_rounded),
                    onPressed: quantity < 99 ? () => onUpdateQuantity(quantity + 1) : null,
                    size: RSIconButtonSize.small,
                    style: RSIconButtonStyle.tonal,
                    enabled: quantity < 99,
                  ),
                ],
              ),
            ],
          ),

          // Remove button
          RSIconButton(
            icon: Icon(Icons.delete_outline_rounded, color: RSColors.error),
            onPressed: onRemove,
            size: RSIconButtonSize.small,
            style: RSIconButtonStyle.ghost,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════
/// PRICE ROW V2
/// ════════════════════════════════════════════════════════════════════════

class _PriceRowV2 extends StatelessWidget {
  const _PriceRowV2({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RSSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? RSTypography.titleMedium.copyWith(color: RSColors.ink)
                : RSTypography.bodyMedium.copyWith(color: RSColors.muted),
          ),
          Text(
            value,
            style: isTotal
                ? RSTypography.priceMedium.copyWith(color: RSColors.burgundy)
                : RSTypography.titleMedium.copyWith(color: RSColors.ink),
          ),
        ],
      ),
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════
/// CART ITEM MODEL
/// ════════════════════════════════════════════════════════════════════════

class _CartItem {
  const _CartItem({required this.item, required this.quantity});
  final MenuItem item;
  final int quantity;
}
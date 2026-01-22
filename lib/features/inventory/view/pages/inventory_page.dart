// ignore_for_file: use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:divine_manager/core/services/util_service.dart';
import 'package:divine_manager/core/theme/app_theme.dart';
import 'package:divine_manager/core/widgets/custom_form_widgets.dart';
import 'package:divine_manager/features/analytics/providers/analytics_providers.dart';
import 'package:divine_manager/features/inventory/model/inventory_item.dart';
import 'package:divine_manager/features/inventory/services/inventory_service.dart';
import 'package:divine_manager/features/inventory/view/widgets/inventory_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;
  late final TextEditingController _maxStockController;
  late final TextEditingController _priceController;

  List<InventoryItem> inventoryItems = [];
  final InventoryService _inventoryService = InventoryService();

  InventoryCategory? selectedCategory;
  String searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInventoryItems();
    _initVariables();
  }

  void _initVariables() {
    _nameController = TextEditingController();
    _stockController = TextEditingController();
    _minStockController = TextEditingController();
    _maxStockController = TextEditingController();
    _priceController = TextEditingController();
  }

  Future<void> _loadInventoryItems() async {
    try {
      setState(() => _isLoading = true);
      final items = await _inventoryService.getAllInventoryItems();
      setState(() {
        inventoryItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading inventory: $e');
    }
  }

  List<InventoryItem> get filteredItems {
    var items = inventoryItems;

    if (selectedCategory != null) {
      items = items.where((item) => item.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      items = items
          .where(
            (item) =>
                item.name.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    return items;
  }

  void _showAddItemDialog(bool isDarkMode) {
    InventoryCategory selectedCat = InventoryCategory.foodIngredients;
    InventoryUnit selectedUnit = InventoryUnit.pieces;
    DateTime? selectedExpiryDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTheme.primaryColor),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_box_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Add New Item',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Item Name',
                    hintText: 'e.g. Coffee Beans',
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  CustomDropdown<InventoryCategory>(
                    value: selectedCat,
                    items: InventoryCategory.values,
                    labelText: 'Category',
                    isRequired: true,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCat = value!;
                      });
                    },
                    itemBuilder: (category) {
                      String label;
                      IconData icon;
                      Color color;

                      switch (category) {
                        case InventoryCategory.beverageIngredients:
                          label = 'Beverage Ingredients';
                          icon = Icons.local_cafe_rounded;
                          color = AppTheme.primaryBrown;
                          break;
                        case InventoryCategory.foodIngredients:
                          label = 'Food Ingredients';
                          icon = Icons.restaurant_rounded;
                          color = AppTheme.primaryGreen;
                          break;
                        case InventoryCategory.packaging:
                          label = 'Packaging';
                          icon = Icons.inventory_rounded;
                          color = AppTheme.primaryOrange;
                          break;
                        case InventoryCategory.equipment:
                          label = 'Equipment';
                          icon = Icons.build_rounded;
                          color = AppTheme.primaryBlue;
                          break;
                        case InventoryCategory.cleaning:
                          label = 'Cleaning Supplies';
                          icon = Icons.cleaning_services_rounded;
                          color = AppTheme.primaryPurple;
                          break;
                        case InventoryCategory.none:
                          label = 'Other';
                          icon = Icons.category_rounded;
                          color = AppTheme.primaryGrey;
                          break;
                      }

                      return Row(
                        children: [
                          CustomIconContainer(
                            icon: icon,
                            iconColor: color,
                            size: 24,
                            iconSize: 14,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomTextField(
                          controller: _stockController,
                          labelText: 'Current Stock',
                          hintText: '10',
                          keyboardType: TextInputType.number,
                          isRequired: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: CustomDropdown<InventoryUnit>(
                          value: selectedUnit,
                          items: InventoryUnit.values,
                          labelText: 'Unit',
                          isRequired: true,
                          onChanged: (value) {
                            setDialogState(() {
                              selectedUnit = value!;
                            });
                          },
                          itemBuilder: (unit) => Text(unit.name),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _minStockController,
                          labelText: 'Min Stock',
                          hintText: '5',
                          keyboardType: TextInputType.number,
                          isRequired: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _maxStockController,
                          labelText: 'Max Stock',
                          hintText: '50',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _priceController,
                    labelText: 'Price per Unit',
                    hintText: '25.00',
                    keyboardType: TextInputType.number,
                    prefixText: '₹ ',
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  CustomDatePicker(
                    selectedDate: selectedExpiryDate,
                    onDateSelected: (date) {
                      setDialogState(() {
                        selectedExpiryDate = date;
                      });
                    },
                    labelText: 'Expires',
                    hintText: 'Select Expiry Date (Optional)',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isEmpty ||
                    _stockController.text.isEmpty ||
                    _minStockController.text.isEmpty ||
                    _priceController.text.isEmpty) {
                  UtilService.showErrorSnackBar(
                    context,
                    'Please fill all required fields',
                  );
                  return;
                }

                final stock = double.tryParse(_stockController.text);
                final minStock = double.tryParse(_minStockController.text);
                final maxStock = double.tryParse(_maxStockController.text);
                final price = double.tryParse(_priceController.text);

                if (stock == null || minStock == null || price == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter valid numbers'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                  return;
                }

                try {
                  final newItem = InventoryItem(
                    name: _nameController.text.trim(),
                    category: selectedCat,
                    currentStock: stock,
                    minStockLevel: minStock,
                    maxStockLevel: maxStock ?? (minStock * 5),
                    unit: selectedUnit,
                    pricePerUnit: price,
                    expiryDate: selectedExpiryDate,
                    lastUpdated: DateTime.now(),
                    assetPath: 'assets/images/inventory.png',
                  );

                  await _inventoryService.addInventoryItem(newItem);
                  
                  ref.read(analyticsRefreshProvider.notifier).state++;
                  
                  await _loadInventoryItems();

                  Navigator.pop(context);

                  UtilService.showSuccessSnackBar(
                    context,
                    'Item added successfully!',
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error adding item: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.cardColor,
              ),
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStockDialog(InventoryItem item, int index, bool isDarkMode) {
    final TextEditingController controller = TextEditingController(
      text: item.currentStock.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode
            ? AppTheme.darkBackgroundColor
            : AppTheme.lightBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.primaryColor),
        ),
        title: Row(
          children: [
            Icon(Icons.edit_rounded, color: AppTheme.primaryColor, size: 24),
            const SizedBox(width: 8),
            Text(
              'Update Stock',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Current: ${item.currentStock} ${item.unit.name}\nMinimum Level: ${item.minStockLevel} ${item.unit.name}',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller,
              labelText: 'New Stock Quantity',
              keyboardType: TextInputType.number,
              isRequired: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newStock = double.tryParse(controller.text);
              if (newStock != null) {
                try {
                  final updatedItem = item.copyWith(
                    currentStock: newStock,
                    lastUpdated: DateTime.now(),
                  );

                  await _inventoryService.updateInventoryItem(
                    index,
                    updatedItem,
                  );
                  
                  ref.read(analyticsRefreshProvider.notifier).state++;
                  
                  await _loadInventoryItems();

                  Navigator.pop(context);

                  UtilService.showSuccessSnackBar(
                    context,
                    'Stock updated successfully!',
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating stock: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.cardColor,
            ),
            child: const Text(
              'Update',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(
    InventoryItem item,
    int index,
    bool isDarkMode,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode
            ? AppTheme.darkBackgroundColor
            : AppTheme.lightBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.errorColor),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.warningColor, size: 24),
            const SizedBox(width: 8),
            Text(
              'Delete Item',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _inventoryService.deleteInventoryItem(index);
                await _loadInventoryItems();

                Navigator.pop(context);

                UtilService.showSuccessSnackBar(
                  context,
                  'Item deleted successfully!',
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting item: $e'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: AppTheme.cardColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lowStockCount = inventoryItems
        .where((item) => item.currentStock <= item.minStockLevel)
        .length;

    final outOfStockCount = inventoryItems
        .where((item) => item.currentStock <= 0)
        .length;

    bool isDarkMode = (Theme.brightnessOf(context) == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Inventory',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(right: 16),
        child: ElevatedButton.icon(
          onPressed: () {
            _showAddItemDialog(isDarkMode);
          },
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Add Item'),
          style: ElevatedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            backgroundColor: isDarkMode
                ? AppTheme.darkBackgroundColor
                : AppTheme.lightBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppTheme.primaryColor),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  if (lowStockCount > 0)
                    Expanded(
                      child: FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        child: CustomStatusContainer(
                          text: '$lowStockCount Low Stock',
                          color: AppTheme.primaryOrange,
                          icon: Icons.warning_rounded,
                        ),
                      ),
                    ),
                  if (lowStockCount > 0 && outOfStockCount > 0)
                    const SizedBox(width: 8),
                  if (outOfStockCount > 0)
                    Expanded(
                      child: FadeInRight(
                        duration: const Duration(milliseconds: 600),
                        child: CustomStatusContainer(
                          text: '$outOfStockCount Out of Stock',
                          color: AppTheme.errorColor,
                          icon: Icons.error_rounded,
                        ),
                      ),
                    ),
                ],
              ),
              if (lowStockCount > 0 || outOfStockCount > 0)
                const SizedBox(height: 16),
        
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CustomSearchField(
                        onChanged: (value) => setState(() => searchQuery = value),
                        hintText: 'Search inventory...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<InventoryCategory?>(
                        value: selectedCategory,
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.filter_list_rounded,
                                color: AppTheme.primaryColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text('Filter', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppTheme.primaryColor,
                            size: 16,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        items: [
                          DropdownMenuItem<InventoryCategory?>(
                            value: null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'All Categories',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          ...InventoryCategory.values.map((category) {
                            String label;
                            switch (category) {
                              case InventoryCategory.beverageIngredients:
                                label = 'Beverages';
                                break;
                              case InventoryCategory.foodIngredients:
                                label = 'Food';
                                break;
                              case InventoryCategory.packaging:
                                label = 'Packaging';
                                break;
                              case InventoryCategory.equipment:
                                label = 'Equipment';
                                break;
                              case InventoryCategory.cleaning:
                                label = 'Cleaning';
                                break;
                              case InventoryCategory.none:
                                label = 'Other';
                                break;
                            }
                            return DropdownMenuItem<InventoryCategory?>(
                              value: category,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) =>
                            setState(() => selectedCategory = value),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
        
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      )
                    : filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isNotEmpty
                                  ? 'No items found'
                                  : 'No items yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              searchQuery.isNotEmpty
                                  ? 'Try searching for something else'
                                  : 'Tap "Add Item" to get started',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredItems.length + 1,
                        itemBuilder: (context, index) {
                          if (index == filteredItems.length) {
                            return SizedBox(height: 50);
                          }
                          final item = filteredItems[index];
                          final actualIndex = inventoryItems.indexOf(item);
        
                          return FadeInUp(
                            duration: const Duration(milliseconds: 300),
                            delay: Duration(milliseconds: index * 50),
                            child: InventoryItemCard(
                              item: item,
                              showUpdateStockDialog: () => _showUpdateStockDialog(
                                item,
                                actualIndex,
                                isDarkMode,
                              ),
                              showDeleteConfirmDialog: () =>
                                  _showDeleteConfirmDialog(
                                    item,
                                    actualIndex,
                                    isDarkMode,
                                  ),
                              isDarkMode: isDarkMode,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

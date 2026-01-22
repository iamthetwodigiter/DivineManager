// ignore_for_file: use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:divine_manager/core/services/util_service.dart';
import 'package:divine_manager/core/theme/app_theme.dart';
import 'package:divine_manager/core/widgets/custom_form_widgets.dart';
import 'package:divine_manager/features/order/model/menu_items.dart';
import 'package:divine_manager/features/order/services/menu_service.dart';
import 'package:divine_manager/features/order/constants/constants.dart';
import 'package:divine_manager/features/order/view/widgets/menu_filter_chip.dart';
import 'package:divine_manager/features/order/view/widgets/menu_item_card.dart';
import 'package:flutter/material.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key});

  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage> {
  List<MenuItems> menuItems = [];
  final MenuService _menuService = MenuService();
  bool _isLoading = true;
  String searchQuery = '';
  MenuItemsType? selectedType;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    try {
      setState(() => _isLoading = true);
      final items = await _menuService.getAllMenuItems();
      setState(() {
        menuItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading menu items: $e');
    }
  }

  List<MenuItems> get filteredItems {
    var items = menuItems;

    if (selectedType != null) {
      items = items.where((item) => item.type == selectedType).toList();
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
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    MenuItemsType selectedItemType = MenuItemsType.tea;
    bool isNonVeg = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconContainer(
                icon: Icons.add_box_rounded,
                size: 40,
                iconSize: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Add New Menu Item',
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
                    controller: nameController,
                    labelText: 'Item Name',
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: priceController,
                    labelText: 'Price',
                    keyboardType: TextInputType.number,
                    prefixText: '₹ ',
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  CustomDropdown<MenuItemsType>(
                    value: selectedItemType,
                    items: MenuItemsType.values,
                    labelText: 'Type',
                    isRequired: true,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedItemType = value);
                      }
                    },
                    itemBuilder: (type) => Row(
                      children: [
                        Image.asset(_getDefaultAssetPath(type), height: 24),
                        SizedBox(width: 10),
                        Text(_getTypeDisplayName(type)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Non-Vegetarian Item',
                          style: TextStyle(fontSize: 16),
                        ),
                        Switch(
                          value: isNonVeg,
                          onChanged: (value) {
                            setDialogState(() => isNonVeg = value);
                          },
                          activeThumbColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
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
                style: TextStyle(color: AppTheme.primaryRed),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: AppTheme.primaryRed,
                    ),
                  );
                  return;
                }

                final price = double.tryParse(priceController.text);
                if (price == null || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid price'),
                      backgroundColor: AppTheme.primaryRed,
                    ),
                  );
                  return;
                }

                try {
                  final newItem = MenuItems(
                    name: nameController.text.trim(),
                    price: price,
                    type: selectedItemType,
                    isNonVeg: isNonVeg,
                    assetPath: _getDefaultAssetPath(selectedItemType),
                  );

                  await _menuService.addMenuItem(newItem);
                  await _loadMenuItems();

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text('Menu item added successfully!'),
                        ],
                      ),
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error adding item: $e'),
                      backgroundColor: AppTheme.primaryRed,
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

  void _showEditItemDialog(MenuItems item, int index, bool isDarkMode) {
    final TextEditingController nameController = TextEditingController(
      text: item.name,
    );
    final TextEditingController priceController = TextEditingController(
      text: item.price.toString(),
    );
    MenuItemsType selectedItemType = item.type ?? MenuItemsType.tea;
    bool isNonVeg = item.isNonVeg;

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
              CustomIconContainer(
                icon: Icons.edit_rounded,
                iconColor: AppTheme.primaryOrange,
                size: 40,
                iconSize: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Edit Menu Item',
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
                    controller: nameController,
                    labelText: 'Item Name',
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: priceController,
                    labelText: 'Price',
                    keyboardType: TextInputType.number,
                    prefixText: '₹ ',
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),
                  CustomDropdown<MenuItemsType>(
                    value: selectedItemType,
                    items: MenuItemsType.values,
                    labelText: 'Type',
                    isRequired: true,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedItemType = value);
                      }
                    },
                    itemBuilder: (type) => Row(
                      children: [
                        Image.asset(_getDefaultAssetPath(type), height: 24),
                        SizedBox(width: 10),
                        Text(_getTypeDisplayName(type)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Non-Vegetarian Item',
                          style: TextStyle(fontSize: 16),
                        ),
                        Switch(
                          value: isNonVeg,
                          onChanged: (value) {
                            setDialogState(() => isNonVeg = value);
                          },
                          activeThumbColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
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
                style: TextStyle(color: AppTheme.primaryRed),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: AppTheme.primaryRed,
                    ),
                  );
                  return;
                }

                final price = double.tryParse(priceController.text);
                if (price == null || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid price'),
                      backgroundColor: AppTheme.primaryRed,
                    ),
                  );
                  return;
                }

                try {
                  final updatedItem = MenuItems(
                    name: nameController.text.trim(),
                    price: price,
                    type: selectedItemType,
                    isNonVeg: isNonVeg,
                    assetPath: item.assetPath,
                  );

                  await _menuService.updateMenuItem(index, updatedItem);
                  await _loadMenuItems();

                  Navigator.pop(context);

                  UtilService.showSuccessSnackBar(
                    context,
                    'Menu item updated successfully!',
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating item: $e'),
                      backgroundColor: AppTheme.primaryRed,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.cardColor,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(MenuItems item, int index, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode
            ? AppTheme.darkBackgroundColor
            : AppTheme.lightBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.primaryRed),
        ),
        title: Row(
          children: [
            Icon(Icons.delete_rounded, color: AppTheme.primaryRed, size: 24),
            const SizedBox(width: 8),
            Text(
              'Delete Menu Item',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.primaryRed)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _menuService.deleteMenuItem(index);
                await _loadMenuItems();

                Navigator.pop(context);

                UtilService.showSuccessSnackBar(
                  context,
                  'Menu item deleted successfully!',
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting item: $e'),
                    backgroundColor: AppTheme.primaryRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: AppTheme.cardColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getTypeDisplayName(MenuItemsType type) {
    switch (type) {
      case MenuItemsType.tea:
        return 'Tea';
      case MenuItemsType.coffee:
        return 'Coffee';
      case MenuItemsType.mocktails:
        return 'Mocktails';
      case MenuItemsType.momo:
        return 'Momo';
      case MenuItemsType.breadToast:
        return 'Bread Toast';
      case MenuItemsType.friesAndBites:
        return 'Fries & Bites';
    }
  }

  String _getDefaultAssetPath(MenuItemsType type) {
    final sampleItem = MenuConstants.menuItems.firstWhere(
      (item) => item.type == type,
      orElse: () => MenuItems(
        name: 'Default',
        price: 0.0,
        assetPath: 'assets/images/food-package.png',
        isNonVeg: false,
        type: type,
      ),
    );
    return sampleItem.assetPath;
  }

  Color _getTypeColor(MenuItemsType type) {
    switch (type) {
      case MenuItemsType.tea:
        return AppTheme.primaryGreen;
      case MenuItemsType.coffee:
        return AppTheme.primaryBrown;
      case MenuItemsType.mocktails:
        return AppTheme.primaryPurple;
      case MenuItemsType.momo:
        return AppTheme.primaryOrange;
      case MenuItemsType.breadToast:
        return AppTheme.primaryTeal;
      case MenuItemsType.friesAndBites:
        return AppTheme.primaryRed;
    }
  }

  IconData _getTypeIcon(MenuItemsType type) {
    switch (type) {
      case MenuItemsType.tea:
        return Icons.emoji_food_beverage_rounded;
      case MenuItemsType.coffee:
        return Icons.local_cafe_rounded;
      case MenuItemsType.mocktails:
        return Icons.local_bar_rounded;
      case MenuItemsType.momo:
        return Icons.restaurant_rounded;
      case MenuItemsType.breadToast:
        return Icons.breakfast_dining_rounded;
      case MenuItemsType.friesAndBites:
        return Icons.fastfood_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.brightnessOf(context) == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menu Management',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddItemDialog(isDarkMode),
            icon: Icon(Icons.add_rounded, color: AppTheme.primaryColor),
            tooltip: 'Add New Item',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CustomSearchField(
                          onChanged: (value) =>
                              setState(() => searchQuery = value),
                          hintText: 'Search menu items...',
                        ),
                        const SizedBox(height: 12),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              MenuFilterChip(
                                label: 'All',
                                isSelected: selectedType == null,
                                onSelected: (selected) {
                                  setState(() => selectedType = null);
                                },
                                selectedColor: AppTheme.primaryBlue,
                              ),

                              const SizedBox(width: 8),
                              ...MenuItemsType.values.map((type) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: MenuFilterChip(
                                    label: _getTypeDisplayName(type),
                                    isSelected: selectedType == type,
                                    onSelected: (selected) {
                                      setState(() {
                                        selectedType = selected ? type : null;
                                      });
                                    },
                                    selectedColor: _getTypeColor(type),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: filteredItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant_menu_rounded,
                                  size: 64,
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  searchQuery.isNotEmpty || selectedType != null
                                      ? 'No items found'
                                      : 'No menu items yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                if (searchQuery.isEmpty &&
                                    selectedType == null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap the + button to add your first menu item',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondaryColor
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final originalIndex = menuItems.indexOf(item);

                              return FadeInUp(
                                duration: Duration(
                                  milliseconds: 300 + (index * 100),
                                ),
                                child: MenuItemCard(
                                  item: item,
                                  typeColor: _getTypeColor(item.type!),
                                  typeIcon: _getTypeIcon(item.type!),
                                  typeName: _getTypeDisplayName(item.type!),
                                  showEditItemDialog: () => _showEditItemDialog(
                                    item,
                                    originalIndex,
                                    isDarkMode,
                                  ),
                                  showDeleteConfirmDialog: () =>
                                      _showDeleteConfirmDialog(
                                        item,
                                        originalIndex,
                                        isDarkMode,
                                      ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:divine_manager/features/inventory/model/inventory_item.dart';
import 'package:divine_manager/features/inventory/services/inventory_service.dart';
import 'package:divine_manager/features/inventory/viewmodel/inventory_viewmodel.dart';
import 'package:flutter_riverpod/legacy.dart';

final inventoryServiceProvider = Provider<InventoryService>((ref) {
  return InventoryService();
});

final inventoryViewModelProvider = Provider<InventoryViewModel>((ref) {
  return InventoryViewModel(ref.read(inventoryServiceProvider));
});

final inventoryItemsProvider = StateNotifierProvider<InventoryNotifier, AsyncValue<List<InventoryItem>>>((ref) {
  return InventoryNotifier(ref.read(inventoryViewModelProvider));
});

final filteredInventoryProvider = Provider<List<InventoryItem>>((ref) {
  final inventoryAsync = ref.watch(inventoryItemsProvider);
  final searchQuery = ref.watch(inventorySearchProvider);
  final selectedCategory = ref.watch(inventoryFilterProvider);

  return inventoryAsync.when(
    data: (items) {
      var filteredItems = items;

      if (selectedCategory != null) {
        filteredItems = filteredItems.where((item) => item.category == selectedCategory).toList();
      }

      if (searchQuery.isNotEmpty) {
        filteredItems = filteredItems
            .where((item) => item.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }

      return filteredItems;
    },
    loading: () => [],
    error: (_, _) => [],
  );
});

final inventorySearchProvider = StateProvider<String>((ref) => '');

final inventoryFilterProvider = StateProvider<InventoryCategory?>((ref) => null);

final lowStockItemsProvider = Provider<List<InventoryItem>>((ref) {
  final inventoryAsync = ref.watch(inventoryItemsProvider);
  return inventoryAsync.when(
    data: (items) => items.where((item) => item.isLowStock).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

final outOfStockItemsProvider = Provider<List<InventoryItem>>((ref) {
  final inventoryAsync = ref.watch(inventoryItemsProvider);
  return inventoryAsync.when(
    data: (items) => items.where((item) => item.isOutOfStock).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

final expiringItemsProvider = Provider<List<InventoryItem>>((ref) {
  final inventoryAsync = ref.watch(inventoryItemsProvider);
  return inventoryAsync.when(
    data: (items) => items.where((item) => item.isExpiring).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

class InventoryNotifier extends StateNotifier<AsyncValue<List<InventoryItem>>> {
  final InventoryViewModel _viewModel;

  InventoryNotifier(this._viewModel) : super(const AsyncValue.loading()) {
    loadInventoryItems();
  }

  Future<void> loadInventoryItems() async {
    try {
      state = const AsyncValue.loading();
      final items = await _viewModel.loadAllInventoryItems();
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addInventoryItem(InventoryItem item) async {
    try {
      await _viewModel.addNewInventoryItem(item);
      await loadInventoryItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateInventoryItem(int index, InventoryItem updatedItem) async {
    try {
      await _viewModel.updateExistingInventoryItem(index, updatedItem);
      await loadInventoryItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteInventoryItem(int index) async {
    try {
      await _viewModel.removeInventoryItem(index);
      await loadInventoryItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateStock(String itemName, double newStock) async {
    try {
      await _viewModel.updateItemStock(itemName, newStock);
      await loadInventoryItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
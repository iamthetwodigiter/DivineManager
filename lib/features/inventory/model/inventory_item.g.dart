// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryItemAdapter extends TypeAdapter<InventoryItem> {
  @override
  final int typeId = 2;

  @override
  InventoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryItem(
      name: fields[0] as String,
      category: fields[1] as InventoryCategory,
      currentStock: fields[2] as double,
      minStockLevel: fields[3] as double,
      maxStockLevel: fields[4] as double,
      unit: fields[5] as InventoryUnit,
      pricePerUnit: fields[6] as double,
      expiryDate: fields[7] as DateTime?,
      lastUpdated: fields[8] as DateTime,
      assetPath: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.currentStock)
      ..writeByte(3)
      ..write(obj.minStockLevel)
      ..writeByte(4)
      ..write(obj.maxStockLevel)
      ..writeByte(5)
      ..write(obj.unit)
      ..writeByte(6)
      ..write(obj.pricePerUnit)
      ..writeByte(7)
      ..write(obj.expiryDate)
      ..writeByte(8)
      ..write(obj.lastUpdated)
      ..writeByte(9)
      ..write(obj.assetPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InventoryCategoryAdapter extends TypeAdapter<InventoryCategory> {
  @override
  final int typeId = 0;

  @override
  InventoryCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InventoryCategory.beverageIngredients;
      case 1:
        return InventoryCategory.foodIngredients;
      case 2:
        return InventoryCategory.packaging;
      case 3:
        return InventoryCategory.equipment;
      case 4:
        return InventoryCategory.cleaning;
      case 5:
        return InventoryCategory.none;
      default:
        return InventoryCategory.beverageIngredients;
    }
  }

  @override
  void write(BinaryWriter writer, InventoryCategory obj) {
    switch (obj) {
      case InventoryCategory.beverageIngredients:
        writer.writeByte(0);
        break;
      case InventoryCategory.foodIngredients:
        writer.writeByte(1);
        break;
      case InventoryCategory.packaging:
        writer.writeByte(2);
        break;
      case InventoryCategory.equipment:
        writer.writeByte(3);
        break;
      case InventoryCategory.cleaning:
        writer.writeByte(4);
        break;
      case InventoryCategory.none:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InventoryUnitAdapter extends TypeAdapter<InventoryUnit> {
  @override
  final int typeId = 1;

  @override
  InventoryUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InventoryUnit.kg;
      case 1:
        return InventoryUnit.grams;
      case 2:
        return InventoryUnit.liters;
      case 3:
        return InventoryUnit.ml;
      case 4:
        return InventoryUnit.pieces;
      case 5:
        return InventoryUnit.packets;
      case 6:
        return InventoryUnit.bottles;
      default:
        return InventoryUnit.kg;
    }
  }

  @override
  void write(BinaryWriter writer, InventoryUnit obj) {
    switch (obj) {
      case InventoryUnit.kg:
        writer.writeByte(0);
        break;
      case InventoryUnit.grams:
        writer.writeByte(1);
        break;
      case InventoryUnit.liters:
        writer.writeByte(2);
        break;
      case InventoryUnit.ml:
        writer.writeByte(3);
        break;
      case InventoryUnit.pieces:
        writer.writeByte(4);
        break;
      case InventoryUnit.packets:
        writer.writeByte(5);
        break;
      case InventoryUnit.bottles:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

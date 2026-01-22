// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_items.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MenuItemsAdapter extends TypeAdapter<MenuItems> {
  @override
  final int typeId = 3;

  @override
  MenuItems read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MenuItems(
      name: fields[0] as String,
      price: fields[1] as double,
      assetPath: fields[2] as String,
      isNonVeg: fields[3] as bool,
      type: fields[4] as MenuItemsType?,
    );
  }

  @override
  void write(BinaryWriter writer, MenuItems obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.price)
      ..writeByte(2)
      ..write(obj.assetPath)
      ..writeByte(3)
      ..write(obj.isNonVeg)
      ..writeByte(4)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItemsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MenuItemsTypeAdapter extends TypeAdapter<MenuItemsType> {
  @override
  final int typeId = 9;

  @override
  MenuItemsType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MenuItemsType.tea;
      case 1:
        return MenuItemsType.coffee;
      case 2:
        return MenuItemsType.mocktails;
      case 3:
        return MenuItemsType.momo;
      case 4:
        return MenuItemsType.breadToast;
      case 5:
        return MenuItemsType.friesAndBites;
      default:
        return MenuItemsType.tea;
    }
  }

  @override
  void write(BinaryWriter writer, MenuItemsType obj) {
    switch (obj) {
      case MenuItemsType.tea:
        writer.writeByte(0);
        break;
      case MenuItemsType.coffee:
        writer.writeByte(1);
        break;
      case MenuItemsType.mocktails:
        writer.writeByte(2);
        break;
      case MenuItemsType.momo:
        writer.writeByte(3);
        break;
      case MenuItemsType.breadToast:
        writer.writeByte(4);
        break;
      case MenuItemsType.friesAndBites:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItemsTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

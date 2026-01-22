// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailySalesRecordAdapter extends TypeAdapter<DailySalesRecord> {
  @override
  final int typeId = 8;

  @override
  DailySalesRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailySalesRecord(
      date: fields[0] as DateTime,
      revenue: fields[1] as double,
      orderCount: fields[2] as int,
      itemsSold: fields[3] as int,
      itemsSoldBreakdown: (fields[4] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, DailySalesRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.revenue)
      ..writeByte(2)
      ..write(obj.orderCount)
      ..writeByte(3)
      ..write(obj.itemsSold)
      ..writeByte(4)
      ..write(obj.itemsSoldBreakdown);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySalesRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnalyticsPeriodAdapter extends TypeAdapter<AnalyticsPeriod> {
  @override
  final int typeId = 6;

  @override
  AnalyticsPeriod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AnalyticsPeriod.daily;
      case 1:
        return AnalyticsPeriod.weekly;
      case 2:
        return AnalyticsPeriod.monthly;
      case 3:
        return AnalyticsPeriod.yearly;
      case 4:
        return AnalyticsPeriod.custom;
      default:
        return AnalyticsPeriod.daily;
    }
  }

  @override
  void write(BinaryWriter writer, AnalyticsPeriod obj) {
    switch (obj) {
      case AnalyticsPeriod.daily:
        writer.writeByte(0);
        break;
      case AnalyticsPeriod.weekly:
        writer.writeByte(1);
        break;
      case AnalyticsPeriod.monthly:
        writer.writeByte(2);
        break;
      case AnalyticsPeriod.yearly:
        writer.writeByte(3);
        break;
      case AnalyticsPeriod.custom:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsPeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnalyticsTypeAdapter extends TypeAdapter<AnalyticsType> {
  @override
  final int typeId = 7;

  @override
  AnalyticsType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AnalyticsType.orders;
      case 1:
        return AnalyticsType.inventory;
      case 2:
        return AnalyticsType.revenue;
      default:
        return AnalyticsType.orders;
    }
  }

  @override
  void write(BinaryWriter writer, AnalyticsType obj) {
    switch (obj) {
      case AnalyticsType.orders:
        writer.writeByte(0);
        break;
      case AnalyticsType.inventory:
        writer.writeByte(1);
        break;
      case AnalyticsType.revenue:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

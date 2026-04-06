import 'package:hive/hive.dart';

class Transaction extends HiveObject {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String note;
  final bool isIncome;
  final DateTime createdAt;
  final String? cardId;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
    required this.isIncome,
    DateTime? createdAt,
    this.cardId,
  }) : createdAt = createdAt ?? DateTime.now();

  Transaction copyWith({
    String? id,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    bool? isIncome,
    String? cardId,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      isIncome: isIncome ?? this.isIncome,
      createdAt: createdAt,
      cardId: cardId ?? this.cardId,
    );
  }
}

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 0;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      amount: fields[1] as double,
      category: fields[2] as String,
      date: fields[3] as DateTime,
      note: fields[4] as String? ?? '',
      isIncome: fields[5] as bool,
      createdAt: fields[6] as DateTime?,
      cardId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.isIncome)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.cardId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

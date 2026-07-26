import 'package:hive/hive.dart';
import 'nutrition.dart';

class MealTypeAdapter extends TypeAdapter<MealType> {
  @override
  final int typeId = 17;

  @override
  MealType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0: return MealType.breakfast;
      case 1: return MealType.lunch;
      case 2: return MealType.dinner;
      case 3: return MealType.snack;
      case 4: return MealType.secondBreakfast;
      case 5: return MealType.afternoonSnack;
      case 6: return MealType.eveningSnack;
      default: return MealType.breakfast;
    }
  }

  @override
  void write(BinaryWriter writer, MealType obj) {
    switch (obj) {
      case MealType.breakfast: writer.writeByte(0); break;
      case MealType.lunch: writer.writeByte(1); break;
      case MealType.dinner: writer.writeByte(2); break;
      case MealType.snack: writer.writeByte(3); break;
      case MealType.secondBreakfast: writer.writeByte(4); break;
      case MealType.afternoonSnack: writer.writeByte(5); break;
      case MealType.eveningSnack: writer.writeByte(6); break;
    }
  }
}

class FoodItemAdapter extends TypeAdapter<FoodItem> {
  @override
  final int typeId = 18;

  @override
  FoodItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return FoodItem(
      name: fields[0] as String,
      barcode: fields[1] as String?,
      calories: fields[2] as double,
      protein: fields[3] as double,
      fat: fields[4] as double,
      carbs: fields[5] as double,
      brand: fields[6] as String?,
      imageUrl: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FoodItem obj) {
    writer.writeByte(8);
    writer.writeByte(0); writer.write(obj.name);
    writer.writeByte(1); writer.write(obj.barcode);
    writer.writeByte(2); writer.write(obj.calories);
    writer.writeByte(3); writer.write(obj.protein);
    writer.writeByte(4); writer.write(obj.fat);
    writer.writeByte(5); writer.write(obj.carbs);
    writer.writeByte(6); writer.write(obj.brand);
    writer.writeByte(7); writer.write(obj.imageUrl);
  }
}

class MealEntryAdapter extends TypeAdapter<MealEntry> {
  @override
  final int typeId = 19;

  @override
  MealEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return MealEntry(
      id: fields[0] as String,
      foodName: fields[1] as String,
      mealType: fields[2] as MealType,
      grams: fields[3] as double,
      calories: fields[4] as double,
      protein: fields[5] as double,
      fat: fields[6] as double,
      carbs: fields[7] as double,
      date: fields[8] as DateTime,
      barcode: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MealEntry obj) {
    writer.writeByte(10);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.foodName);
    writer.writeByte(2); writer.write(obj.mealType);
    writer.writeByte(3); writer.write(obj.grams);
    writer.writeByte(4); writer.write(obj.calories);
    writer.writeByte(5); writer.write(obj.protein);
    writer.writeByte(6); writer.write(obj.fat);
    writer.writeByte(7); writer.write(obj.carbs);
    writer.writeByte(8); writer.write(obj.date);
    writer.writeByte(9); writer.write(obj.barcode);
  }
}

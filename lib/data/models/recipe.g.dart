import 'package:hive/hive.dart';
import 'recipe.dart';

class RecipeIngredientAdapter extends TypeAdapter<RecipeIngredient> {
  @override
  final int typeId = 21;

  @override
  RecipeIngredient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return RecipeIngredient(
      foodName: fields[0] as String,
      grams: fields[1] as double,
      calories: fields[2] as double,
      protein: fields[3] as double,
      fat: fields[4] as double,
      carbs: fields[5] as double,
      barcode: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeIngredient obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.foodName);
    writer.writeByte(1);
    writer.write(obj.grams);
    writer.writeByte(2);
    writer.write(obj.calories);
    writer.writeByte(3);
    writer.write(obj.protein);
    writer.writeByte(4);
    writer.write(obj.fat);
    writer.writeByte(5);
    writer.write(obj.carbs);
    writer.writeByte(6);
    writer.write(obj.barcode);
  }
}

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 20;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Recipe(
      id: fields[0] as String,
      name: fields[1] as String,
      ingredients: (fields[2] as List).cast<RecipeIngredient>(),
      targetCalories: fields[3] as double,
      targetProtein: fields[4] as double,
      targetFat: fields[5] as double,
      targetCarbs: fields[6] as double,
      totalGrams: fields[7] as double,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer.writeByte(9);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.ingredients);
    writer.writeByte(3);
    writer.write(obj.targetCalories);
    writer.writeByte(4);
    writer.write(obj.targetProtein);
    writer.writeByte(5);
    writer.write(obj.targetFat);
    writer.writeByte(6);
    writer.write(obj.targetCarbs);
    writer.writeByte(7);
    writer.write(obj.totalGrams);
    writer.writeByte(8);
    writer.write(obj.createdAt);
  }
}

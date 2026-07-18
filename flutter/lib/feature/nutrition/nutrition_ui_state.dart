import '../../core/model/nutrition_models.dart';
import '../../data/local/database.dart';

class EditableNutritionDraft {
  final String nameVi;
  final String caloriesText;
  final String proteinText;
  final String carbsText;
  final String fatText;
  final String fiberText;
  final bool saveAsTemplate;
  final Map<String, String> errors;

  EditableNutritionDraft({
    this.nameVi = "",
    this.caloriesText = "",
    this.proteinText = "",
    this.carbsText = "",
    this.fatText = "",
    this.fiberText = "",
    this.saveAsTemplate = false,
    this.errors = const {},
  });

  EditableNutritionDraft copyWith({
    String? nameVi,
    String? caloriesText,
    String? proteinText,
    String? carbsText,
    String? fatText,
    String? fiberText,
    bool? saveAsTemplate,
    Map<String, String>? errors,
  }) {
    return EditableNutritionDraft(
      nameVi: nameVi ?? this.nameVi,
      caloriesText: caloriesText ?? this.caloriesText,
      proteinText: proteinText ?? this.proteinText,
      carbsText: carbsText ?? this.carbsText,
      fatText: fatText ?? this.fatText,
      fiberText: fiberText ?? this.fiberText,
      saveAsTemplate: saveAsTemplate ?? this.saveAsTemplate,
      errors: errors ?? this.errors,
    );
  }
}

class CartItem {
  final FoodCatalogItem food;
  final double grams;
  final String mealTime; // BREAKFAST, LUNCH, DINNER, SNACK

  CartItem({
    required this.food,
    required this.grams,
    this.mealTime = "BREAKFAST",
  });

  CartItem copyWith({
    FoodCatalogItem? food,
    double? grams,
    String? mealTime,
  }) {
    return CartItem(
      food: food ?? this.food,
      grams: grams ?? this.grams,
      mealTime: mealTime ?? this.mealTime,
    );
  }
}

class TemplateNameEdit {
  final int id;
  final String nameVi;
  final String? error;

  TemplateNameEdit({
    required this.id,
    required this.nameVi,
    this.error,
  });

  TemplateNameEdit copyWith({
    int? id,
    String? nameVi,
    String? error,
  }) {
    return TemplateNameEdit(
      id: id ?? this.id,
      nameVi: nameVi ?? this.nameVi,
      error: error,
    );
  }
}

sealed class NutritionUiState {}

class NutritionLoading extends NutritionUiState {}

class NutritionContent extends NutritionUiState {
  final int calorieLimit;
  final int caloriesEaten;
  final int nutritionScore;
  final String nutritionScoreLabel;
  final String nutritionScoreEmoji;
  final int proteinEaten;
  final int proteinLimit;
  final int carbsEaten;
  final int carbsLimit;
  final int fatEaten;
  final int fatLimit;
  final int fiberEaten;
  final int fiberLimit;
  final bool sweatActive;
  final String? sweatExerciseName;
  final int sweatExtraSets;
  final int waterIntakeMl;
  final ScanResult? scanResult;
  final bool scanning;
  final String? scanError;
  final List<NutritionDay> history;
  final EditableNutritionDraft? draft;
  final List<MealTemplate> mealTemplates;
  final bool savingDraft;
  final int? pendingDeleteTemplateId;
  final TemplateNameEdit? templateNameEdit;
  final int foodCatalogCount;
  final List<FoodCatalogItem> foodCatalogItems;
  final String searchQuery;
  final bool? importSuccess;
  final String? importErrorMessage;
  final List<String> importWarnings;
  final List<CartItem> cart;
  final List<LoggedFoodData> loggedFoods;
  final List<FoodCatalogItem> favorites;
  final List<FoodCatalogItem> recentFoods;

  NutritionContent({
    required this.calorieLimit,
    required this.caloriesEaten,
    this.nutritionScore = 0,
    this.nutritionScoreLabel = "",
    this.nutritionScoreEmoji = "",
    required this.proteinEaten,
    required this.proteinLimit,
    required this.carbsEaten,
    required this.carbsLimit,
    required this.fatEaten,
    required this.fatLimit,
    this.fiberEaten = 0,
    this.fiberLimit = 30,
    required this.sweatActive,
    this.sweatExerciseName,
    required this.sweatExtraSets,
    required this.waterIntakeMl,
    this.scanResult,
    required this.scanning,
    this.scanError,
    this.history = const [],
    this.draft,
    this.mealTemplates = const [],
    this.savingDraft = false,
    this.pendingDeleteTemplateId,
    this.templateNameEdit,
    this.foodCatalogCount = 0,
    this.foodCatalogItems = const [],
    this.searchQuery = "",
    this.importSuccess,
    this.importErrorMessage,
    this.importWarnings = const [],
    this.cart = const [],
    this.loggedFoods = const [],
    this.favorites = const [],
    this.recentFoods = const [],
  });
}

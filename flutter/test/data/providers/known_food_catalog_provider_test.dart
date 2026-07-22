import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/model/food_photo_analysis_models.dart';
import 'package:gym_app/data/providers/remote_providers.dart';
import 'package:gym_app/data/remote/food_analysis_client.dart';

void main() {
  test('known food provider exposes the client capability catalog', () async {
    final food = KnownFoodOption.listFromJson({
      'foods': [
        {
          'foodId': 'white-rice',
          'nameVi': 'Cơm trắng',
          'supportsGrams': true,
          'portionOptions': [
            {
              'unit': 'BOWL',
              'sizes': ['SMALL', 'MEDIUM', 'LARGE']
            }
          ]
        }
      ]
    });
    final client = _FakeClient(food);
    final container = ProviderContainer(overrides: [
      foodAnalysisClientProvider.overrideWithValue(client),
    ]);
    addTearDown(container.dispose);

    final result = await container.read(knownFoodCatalogProvider.future);
    expect(result.single.foodId, 'white-rice');
    expect(result.single.portionOptions.single.unit, HouseholdPortionUnit.bowl);
    await Future<void>.delayed(Duration.zero);
    final cachedAgain = await container.read(knownFoodCatalogProvider.future);
    expect(cachedAgain.single.foodId, 'white-rice');
    expect(client.calls, 1);
  });
}

class _FakeClient implements FoodAnalysisClient {
  final List<KnownFoodOption> foods;
  _FakeClient(this.foods);
  int calls = 0;

  @override
  Future<List<KnownFoodOption>> listKnownFoods() async {
    calls++;
    return foods;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

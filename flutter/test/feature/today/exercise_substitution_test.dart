import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/model/catalog_models.dart';
import 'package:gym_app/feature/today/widgets/exercise_substitution_dialog.dart';
import 'package:gym_app/feature/today/today_ui_state.dart';

void main() {
  testWidgets('ExerciseSubstitutionDialog dismiss button calls onDismiss callback',
      (WidgetTester tester) async {
    bool dismissCalled = false;

    final dummyState = ExerciseSubstitutionUi(
      currentNameVi: 'Plank',
      candidates: [
        ExerciseSubstitutionCandidateUi(
          exerciseId: 'dead_bug',
          nameVi: 'Dead bug',
          equipment: [Equipment.bodyweight],
          instructionsVi: ['Instruction 1'],
          restoresOriginal: false,
        ),
      ],
      orderIndex: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ExerciseSubstitutionDialog(
                      state: dummyState,
                      onApply: (_) {},
                      onDismiss: () {
                        dismissCalled = true;
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog title and close button are present
    expect(find.text('Thay Plank'), findsOneWidget);
    expect(find.text('Đóng'), findsOneWidget);

    // Tap dismiss button
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();

    // Verify callback was triggered and dialog closed
    expect(dismissCalled, isTrue);
    expect(find.text('Thay Plank'), findsNothing);
  });
}

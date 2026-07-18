import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/model/goal_models.dart';
import '../../core/model/catalog_models.dart';
import '../../core/program/program_selector.dart';
import '../../data/providers/data_providers.dart';
import 'onboarding_ui_state.dart';

class OnboardingNotifier extends Notifier<OnboardingUiState> {
  late List<ProgramTemplate> _programs;

  @override
  OnboardingUiState build() {
    final catalogRepo = ref.watch(assetCatalogRepositoryProvider);
    _programs = catalogRepo.programs;
    return _editing(OnboardingStep.personalInfo, const OnboardingDraft());
  }

  void selectGender(Gender value) => _updateDraft((d) => d.copyWith(gender: value));
  void selectBodyType(BodyType value) => _updateDraft((d) => d.copyWith(bodyType: value));

  void toggleGoal(FitnessGoal value) => _updateDraft((draft) {
        final goals = draft.goals.contains(value)
            ? draft.goals.where((g) => g != value).toList()
            : (draft.goals.length < 3 ? [...draft.goals, value] : draft.goals);
        return draft.copyWith(
          goals: goals,
          goal: goals.isNotEmpty ? goals.first : null,
          level: null,
          equipment: null,
          sessionsPerWeek: null,
          durationWeeks: null,
          restDayMode: null,
          trainingDays: const {},
          sessionDurationMinutes: 45,
        );
      });

  void selectLevel(ExperienceLevel value) => _updateDraft((d) => d.copyWith(
        level: value,
        equipment: null,
        sessionsPerWeek: null,
        durationWeeks: null,
        restDayMode: null,
        trainingDays: const {},
        sessionDurationMinutes: 45,
      ));

  void selectEquipment(EquipmentProfile value) => _updateDraft((draft) {
        final matching = _programs.where((p) =>
            p.goal == draft.goal && p.level == draft.level && p.equipmentProfile == value);
        final durationWeeks = matching.isNotEmpty ? matching.first.durationWeeks : null;
        return draft.copyWith(
          equipment: value,
          sessionsPerWeek: null,
          durationWeeks: durationWeeks,
          restDayMode: null,
          trainingDays: const {},
          sessionDurationMinutes: 45,
        );
      });

  void toggleTrainingDay(WeekDay day) => _updateDraft((draft) {
        final days = draft.trainingDays.contains(day)
            ? draft.trainingDays.where((d) => d != day).toSet()
            : (draft.trainingDays.length < 6 ? {...draft.trainingDays, day} : draft.trainingDays);
        return draft.copyWith(
          trainingDays: days,
          sessionsPerWeek: days.isNotEmpty ? days.length : null,
        );
      });

  void selectSessionDuration(int minutes) => _updateDraft((draft) {
        if (minutes == 30 || minutes == 45 || minutes == 60 || minutes == 75 || minutes == 90) {
          return draft.copyWith(sessionDurationMinutes: minutes);
        }
        return draft;
      });

  void selectRestDayMode(RestDayMode value) => _updateDraft((d) => d.copyWith(restDayMode: value));

  void next() {
    state.mapOrNull(
      editing: (editingState) {
        if (editingState.isSaving) return;
        if (_canAdvance(editingState)) {
          final nextStepIndex = editingState.step.index + 1;
          if (nextStepIndex < OnboardingStep.values.length) {
            state = _editing(OnboardingStep.values[nextStepIndex], editingState.draft);
          }
        }
      },
    );
  }

  void back(VoidCallback? onCancel) {
    state.mapOrNull(
      editing: (editingState) {
        if (editingState.isSaving) return;
        if (editingState.step == OnboardingStep.personalInfo) {
          onCancel?.call();
        } else {
          final prevStepIndex = editingState.step.index - 1;
          state = _editing(OnboardingStep.values[prevStepIndex], editingState.draft);
        }
      },
      unsupported: (unsupportedState) {
        state = _editing(OnboardingStep.review, unsupportedState.draft);
      },
    );
  }

  Future<void> createGoal() async {
    final currentState = state;
    final isEditing = currentState.mapOrNull(editing: (_) => true) == true;
    if (!isEditing || (currentState as dynamic).isSaving == true) return;

    final dynamic editingState = currentState;
    final draft = editingState.draft;
    final matchingPrograms = _programs.where((p) =>
        p.goal == draft.goal && p.level == draft.level && p.equipmentProfile == draft.equipment).toList();

    if (matchingPrograms.length != 1) {
      state = OnboardingUiState.unsupported(
        draft: draft,
        explanation: "Chưa có chương trình phù hợp với mục tiêu, trình độ và dụng cụ đã chọn.",
        alternatives: _programs.map(_programLabel).toSet().toList(),
      );
      return;
    }

    final baseProgram = matchingPrograms.single;
    final config = GoalConfig(
      goal: draft.goal!,
      goals: draft.goals.isNotEmpty ? draft.goals : [draft.goal!],
      gender: draft.gender ?? Gender.male,
      bodyType: draft.bodyType ?? BodyType.mesomorph,
      level: draft.level!,
      equipmentProfile: draft.equipment!,
      sessionsPerWeek: draft.trainingDays.length,
      durationWeeks: baseProgram.durationWeeks,
      restDayMode: draft.restDayMode!,
      trainingDays: draft.trainingDays,
      sessionDurationMinutes: draft.sessionDurationMinutes ?? 45,
    );

    final selection = ProgramSelector.select(config, [baseProgram]);
    if (selection is ProgramSelectionUnsupported) {
      state = OnboardingUiState.unsupported(
        draft: draft,
        explanation: "Chưa có chương trình phù hợp với lựa chọn này. Hãy thay đổi mục tiêu, trình độ hoặc dụng cụ.",
        alternatives: _programs.map(_programLabel).toSet().toList(),
      );
    } else if (selection is ProgramSelectionFound) {
      state = editingState.copyWith(isSaving: true, saveError: null);
      try {
        final workoutRepo = ref.read(workoutRepositoryProvider);
        final epochDay = currentLocalEpochDay();
        await workoutRepo.createGoal(config, selection.program, epochDay);
        state = const OnboardingUiState.created();
      } catch (e) {
        state = _editing(editingState.step, draft, saveError: "Không thể lưu mục tiêu. Vui lòng thử lại.");
      }
    }
  }

  void _updateDraft(OnboardingDraft Function(OnboardingDraft) transform) {
    state.mapOrNull(
      editing: (editingState) {
        if (editingState.isSaving) return;
        state = _editing(editingState.step, transform(editingState.draft));
      },
    );
  }

  OnboardingUiState _editing(OnboardingStep step, OnboardingDraft draft, {String? saveError}) {
    return OnboardingUiState.editing(
      step: step,
      draft: draft,
      saveError: saveError,
      options: OnboardingOptions(
        goals: _programs.map((p) => p.goal).toSet(),
        levels: _programs.where((p) => draft.goal == null || p.goal == draft.goal).map((p) => p.level).toSet(),
        equipment: _programs.where((p) =>
            (draft.goal == null || p.goal == draft.goal) &&
            (draft.level == null || p.level == draft.level)
        ).map((p) => p.equipmentProfile).toSet(),
        commitments: const {},
        restDayModes: RestDayMode.values.toSet(),
      ),
    );
  }

  bool _canAdvance(OnboardingUiState editingState) {
    final isEditing = editingState.mapOrNull(editing: (_) => true) == true;
    if (!isEditing) return false;
    final dynamic editing = editingState;
    final draft = editing.draft;
    switch (editing.step as OnboardingStep) {
      case OnboardingStep.personalInfo:
        return draft.gender != null && draft.bodyType != null;
      case OnboardingStep.goal:
        return draft.goals.isNotEmpty;
      case OnboardingStep.level:
        return draft.level != null;
      case OnboardingStep.equipment:
        return draft.equipment != null;
      case OnboardingStep.trainingDays:
        return draft.trainingDays.length >= 1 && draft.trainingDays.length <= 6;
      case OnboardingStep.sessionDuration:
        return draft.sessionDurationMinutes != null;
      case OnboardingStep.restBehavior:
        return draft.restDayMode != null;
      case OnboardingStep.review:
        return true;
    }
  }

  String _programLabel(ProgramTemplate program) {
    return [
      program.goal.labelVi(),
      program.level.labelVi(),
      program.equipmentProfile.labelVi(),
      "Chương trình ${program.durationWeeks} tuần",
    ].join(" · ");
  }
}

extension FitnessGoalVi on FitnessGoal {
  String labelVi() {
    switch (this) {
      case FitnessGoal.muscleGain:
        return "Tăng cơ";
      case FitnessGoal.fatLossConditioning:
        return "Giảm mỡ & thể lực";
      case FitnessGoal.endurance:
        return "Sức bền";
      case FitnessGoal.generalFitness:
        return "Thể lực tổng quát";
    }
  }
}

extension ExperienceLevelVi on ExperienceLevel {
  String labelVi() => this == ExperienceLevel.beginner ? "Người mới" : "Trung cấp";
}

extension EquipmentProfileVi on EquipmentProfile {
  String labelVi() {
    switch (this) {
      case EquipmentProfile.bodyweightOnly:
        return "Không dụng cụ";
      case EquipmentProfile.dumbbells:
        return "Tạ đơn";
      case EquipmentProfile.resistanceBands:
        return "Dây kháng lực";
      case EquipmentProfile.fullGym:
        return "Phòng gym đầy đủ";
    }
  }
}

extension RestDayModeVi on RestDayMode {
  String labelVi() => this == RestDayMode.fullRest ? "Nghỉ hoàn toàn" : "Phục hồi nhẹ";
}

extension GenderVi on Gender {
  String labelVi() => this == Gender.male ? "Nam" : "Nữ";
}

extension BodyTypeVi on BodyType {
  String labelVi() {
    switch (this) {
      case BodyType.ectomorph:
        return "Ectomorph";
      case BodyType.mesomorph:
        return "Mesomorph";
      case BodyType.endomorph:
        return "Endomorph";
    }
  }
}

extension WeekDayVi on WeekDay {
  String labelVi() {
    switch (this) {
      case WeekDay.monday:
        return "Thứ Hai";
      case WeekDay.tuesday:
        return "Thứ Ba";
      case WeekDay.wednesday:
        return "Thứ Tư";
      case WeekDay.thursday:
        return "Thứ Năm";
      case WeekDay.friday:
        return "Thứ Sáu";
      case WeekDay.saturday:
        return "Thứ Bảy";
      case WeekDay.sunday:
        return "Chủ Nhật";
    }
  }

  String shortLabelVi() {
    switch (this) {
      case WeekDay.monday:
        return "T2";
      case WeekDay.tuesday:
        return "T3";
      case WeekDay.wednesday:
        return "T4";
      case WeekDay.thursday:
        return "T5";
      case WeekDay.friday:
        return "T6";
      case WeekDay.saturday:
        return "T7";
      case WeekDay.sunday:
        return "CN";
    }
  }
}

final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingUiState>(OnboardingNotifier.new);

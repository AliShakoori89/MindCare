import 'package:mind_care/Features/Conditions/Domain/Entities/condition.dart';

sealed class ConditionState {
  const ConditionState();
}

final class ConditionInitial extends ConditionState {
  const ConditionInitial();
}

final class ConditionLoading extends ConditionState {
  const ConditionLoading();
}

final class ConditionCreated extends ConditionState {
  const ConditionCreated();
}

final class ConditionLoaded extends ConditionState {
  final Condition condition;

  const ConditionLoaded(this.condition);
}

final class ConditionsLoaded extends ConditionState {
  final List<Condition> conditions;

  const ConditionsLoaded(this.conditions);
}

final class ConditionUpdated extends ConditionState {
  const ConditionUpdated();
}

final class ConditionDeleted extends ConditionState {
  const ConditionDeleted();
}

final class ConditionError extends ConditionState {
  final String message;

  const ConditionError(this.message);
}
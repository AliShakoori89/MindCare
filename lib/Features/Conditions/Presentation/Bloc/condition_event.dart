import 'package:mind_care/Features/Conditions/Domain/Entities/condition.dart';

sealed class ConditionEvent {
  const ConditionEvent();
}

final class CreateConditionEvent extends ConditionEvent {
  final Condition condition;

  const CreateConditionEvent(this.condition);
}

final class GetConditionByIdEvent extends ConditionEvent {
  final String id;

  const GetConditionByIdEvent(this.id);
}

final class GetConditionsByUserIdEvent extends ConditionEvent {
  final String userId;

  const GetConditionsByUserIdEvent(this.userId);
}

final class UpdateConditionEvent extends ConditionEvent {
  final Condition condition;

  const UpdateConditionEvent(this.condition);
}

final class DeleteConditionEvent extends ConditionEvent {
  final String id;

  const DeleteConditionEvent(this.id);
}
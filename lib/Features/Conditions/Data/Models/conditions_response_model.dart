import 'condition_model.dart';

class ConditionsResponseModel {
  final List<ConditionModel> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const ConditionsResponseModel({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory ConditionsResponseModel.fromJson(Map<String, dynamic> json) {
    return ConditionsResponseModel(
      items: (json['items'] as List<dynamic>)
          .map((item) => ConditionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

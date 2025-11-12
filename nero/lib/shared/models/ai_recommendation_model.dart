import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_recommendation_model.freezed.dart';
part 'ai_recommendation_model.g.dart';

/// Modelo de recomendação da IA
@freezed
class AIRecommendationModel with _$AIRecommendationModel {
  const factory AIRecommendationModel({
    required String id,
    required String userId,
    required String message,
    required String type, // task, finance, routine, meeting
    @Default('sent') String status, // sent, read, accepted, dismissed
    String? actionUrl,
    Map<String, dynamic>? context,
    DateTime? sentAt,
    DateTime? readAt,
    DateTime? actionedAt,
    DateTime? createdAt,
  }) = _AIRecommendationModel;

  factory AIRecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$AIRecommendationModelFromJson(json);
}

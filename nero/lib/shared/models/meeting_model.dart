import 'package:freezed_annotation/freezed_annotation.dart';

part 'meeting_model.freezed.dart';
part 'meeting_model.g.dart';

@freezed
class MeetingModel with _$MeetingModel {
  const factory MeetingModel({
    required String id,
    required String userId,
    required String companyId,
    required String title,
    String? description,
    String? location,
    required DateTime startAt,
    required DateTime endAt,
    @Default([]) List<String> participants,
    String? agenda,
    String? notes,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MeetingModel;

  factory MeetingModel.fromJson(Map<String, dynamic> json) =>
      _$MeetingModelFromJson(json);
}

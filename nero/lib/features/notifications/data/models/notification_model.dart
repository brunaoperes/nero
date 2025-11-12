import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/notification_entity.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// Model que representa uma notificação vinda do backend/Supabase
@freezed
class NotificationModel with _$NotificationModel {
  const NotificationModel._();

  const factory NotificationModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    required String body,
    required String type,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'is_read') required bool isRead,
    String? payload,
    @JsonKey(name: 'action_url') String? actionUrl,
    @JsonKey(name: 'scheduled_for') String? scheduledFor,
  }) = _NotificationModel;

  /// Cria um NotificationModel a partir de JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  /// Converte para Entity
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: NotificationTypeExtension.fromJson(type),
      createdAt: DateTime.parse(createdAt),
      isRead: isRead,
      payload: payload,
      actionUrl: actionUrl,
      scheduledFor: scheduledFor != null ? DateTime.parse(scheduledFor!) : null,
    );
  }

  /// Converte Entity para Model
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      body: entity.body,
      type: entity.type.toJson(),
      createdAt: entity.createdAt.toIso8601String(),
      isRead: entity.isRead,
      payload: entity.payload,
      actionUrl: entity.actionUrl,
      scheduledFor: entity.scheduledFor?.toIso8601String(),
    );
  }
}

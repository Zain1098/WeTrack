import 'package:flutter/material.dart';

class InAppNotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String icon;
  final Color iconColor;
  final Color iconBg;
  final bool isRead;
  final String? actionLabel;
  final String? actionType; // 'open_positive_test', 'open_appointment', 'open_kicks', 'open_symptoms', 'open_settings'

  const InAppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.icon,
    this.iconColor = const Color(0xFFC2185B),
    this.iconBg = const Color(0xFFFCE4EC),
    this.isRead = false,
    this.actionLabel,
    this.actionType,
  });

  InAppNotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    String? icon,
    Color? iconColor,
    Color? iconBg,
    bool? isRead,
    String? actionLabel,
    String? actionType,
  }) {
    return InAppNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBg: iconBg ?? this.iconBg,
      isRead: isRead ?? this.isRead,
      actionLabel: actionLabel ?? this.actionLabel,
      actionType: actionType ?? this.actionType,
    );
  }
}

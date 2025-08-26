// ignore_for_file: public_member_api_docs

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class TimeAgo extends StatelessWidget {
  const TimeAgo({required this.createdAt, this.short = false, super.key});

  final bool short;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    return Text(
      short ? createdAt.timeAgoShort(context) : createdAt.timeAgo(context),
      overflow: TextOverflow.visible,
      style: context.bodyMedium?.copyWith(color: AppColors.grey),
    );
  }
}

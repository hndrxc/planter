import 'package:flutter/material.dart';

import '../models/due_status.dart';

Color dueColor(DueStatus status, ColorScheme scheme) => switch (status) {
  DueStatus.overdue => scheme.error,
  DueStatus.dueToday => Colors.orange.shade800,
  DueStatus.ok => scheme.primary,
};

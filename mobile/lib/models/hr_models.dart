import 'package:flutter/material.dart';

class HrSettings {
  int campusTargetPercent;
  int monthlyCo2TargetKg;

  HrSettings({
    required this.campusTargetPercent,
    required this.monthlyCo2TargetKg,
  });
}

class Co2Entry {
  final String id;
  final String weekLabel;
  final int kgSaved;
  final String dateRange;
  final String primaryMode;

  Co2Entry({
    required this.id,
    required this.weekLabel,
    required this.kgSaved,
    required this.dateRange,
    required this.primaryMode,
  });
}

class ParkingGroup {
  final String id;
  final String groupName;
  final String route;
  final int commuters;
  String status; // 'Arrived', 'En-route', 'Reserved'
  String spotCode; // 'B-12', 'B-13'

  ParkingGroup({
    required this.id,
    required this.groupName,
    required this.route,
    required this.commuters,
    required this.status,
    required this.spotCode,
  });
}

class TopRoute {
  final String id;
  final String name;
  final int riders;
  final String tag;
  final Color tagColor;
  bool isPinned;

  TopRoute({
    required this.id,
    required this.name,
    required this.riders,
    required this.tag,
    required this.tagColor,
    this.isPinned = true,
  });
}

class MonthlyReportItem {
  final String id;
  final String title;
  final String publishDate;
  final double fileSizeMb;
  final int co2SavedKg;
  final double evSharePercent;
  final String auditScope;

  MonthlyReportItem({
    required this.id,
    required this.title,
    required this.publishDate,
    required this.fileSizeMb,
    required this.co2SavedKg,
    required this.evSharePercent,
    required this.auditScope,
  });
}

class IncentiveItem {
  final String id;
  String title;
  String description;
  int budgetLkr;
  int disbursedLkr;
  bool isActive;

  IncentiveItem({
    required this.id,
    required this.title,
    required this.description,
    required this.budgetLkr,
    required this.disbursedLkr,
    this.isActive = true,
  });
}

class CommuteSplit {
  final String name;
  final double percentage;
  final Color color;

  CommuteSplit({
    required this.name,
    required this.percentage,
    required this.color,
  });
}

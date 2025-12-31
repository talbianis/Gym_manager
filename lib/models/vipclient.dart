import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

class VipClient {
  final int? id;
  final String name;
  final int age;
  final String? photo;
  final String phone;

  /// Weight history
  final List<WeightEntry> weights;

  /// Height in centimeters
  final int height;

  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  VipClient({
    this.id,
    required this.name,
    required this.age,
    this.photo,
    required this.phone,
    required this.weights,
    required this.height,
    required this.startDate,
    required this.endDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ------------------------------------------------------
  // STATUS
  // ------------------------------------------------------

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  int get daysRemaining {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  // ------------------------------------------------------
  // WEIGHT LOGIC
  // ------------------------------------------------------

  /// Latest weight (most recent entry)
  double? get latestWeight {
    if (weights.isEmpty) return null;
    final sorted = List<WeightEntry>.from(weights)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first.weight;
  }

  /// First recorded weight
  double? get initialWeight {
    if (weights.isEmpty) return null;
    final sorted = List<WeightEntry>.from(weights)
      ..sort((a, b) => a.date.compareTo(b.date));
    return sorted.first.weight;
  }

  /// Weight progress (latest - initial)
  double? get weightProgress {
    if (initialWeight == null || latestWeight == null) return null;
    return latestWeight! - initialWeight!;
  }

  Color bmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  double bmiFromWeight(double weight) {
    final heightMeters = height / 100;
    return weight / (heightMeters * heightMeters);
  }

  List<BmiPoint> get bmiHistory {
    return weights.map((w) {
      return BmiPoint(date: w.date, bmi: bmiFromWeight(w.weight));
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  // ------------------------------------------------------
  // BMI (NEW FEATURE)
  // ------------------------------------------------------

  /// Body Mass Index
  double? get bmi {
    if (latestWeight == null || height <= 0) return null;
    final heightInMeters = height / 100;
    return latestWeight! / (heightInMeters * heightInMeters);
  }

  /// BMI category (optional but useful)
  String get bmiCategory {
    final value = bmi;
    if (value == null) return 'Not available';
    if (value < 18.5) return 'Underweight';
    if (value < 25) return 'Normal';
    if (value < 30) return 'Overweight';
    return 'Obese';
  }

  // ------------------------------------------------------
  // DATABASE MAPPING
  // ------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'photo': photo,
      'phone': phone,
      'weights': _weightsToJson(weights),
      'height': height,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VipClient.fromMap(Map<String, dynamic> map) {
    return VipClient(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      photo: map['photo'],
      phone: map['phone'],
      weights: _weightsFromJson(map['weights']),
      height: map['height'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // ------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------

  static String _weightsToJson(List<WeightEntry> weights) {
    return jsonEncode(weights.map((w) => w.toMap()).toList());
  }

  static List<WeightEntry> _weightsFromJson(String json) {
    final List decoded = jsonDecode(json);
    return decoded.map((e) => WeightEntry.fromMap(e)).toList();
  }

  VipClient copyWith({
    int? id,
    String? name,
    int? age,
    String? photo,
    String? phone,
    List<WeightEntry>? weights,
    int? height,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return VipClient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      photo: photo ?? this.photo,
      phone: phone ?? this.phone,
      weights: weights ?? this.weights,
      height: height ?? this.height,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class BmiPoint {
  final DateTime date;
  final double bmi;

  BmiPoint({required this.date, required this.bmi});
}

// ------------------------------------------------------
// WEIGHT ENTRY MODEL
// ------------------------------------------------------

class WeightEntry {
  final DateTime date;
  final double weight;

  WeightEntry({required this.date, required this.weight});

  Map<String, dynamic> toMap() {
    return {'date': date.toIso8601String(), 'weight': weight};
  }

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      date: DateTime.parse(map['date']),
      weight: (map['weight'] as num).toDouble(),
    );
  }
}

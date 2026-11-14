import 'package:flutter_test/flutter_test.dart';
import 'package:orca/features/competitions/data/competitions_model.dart';
import 'package:orca/features/ecom/data/address_model.dart';
import 'package:orca/features/fitness/domain/exercise_model.dart';

void main() {
  group('Competition Model Tests', () {
    test('Competition.fromJson correctly parses valid JSON', () {
      final json = {
        '_id': 'comp_123',
        'name': 'Summer Marathon 2026',
        'category': ['Running', 'Endurance'],
        'image': ['https://example.com/banner.jpg'],
        'time': '06:00 AM',
        'date': '2026-06-15T06:00:00.000Z',
        'place': 'Central Stadium',
        'state': ['California'],
        'district': 'Orange County',
        'town': 'Irvine',
        'duration': 180,
        'type': ['Solo', 'Team'],
        'cost': 499.0,
        'maxRegistrations': 100,
        'description': 'Annual running competition',
        'status': 'active',
      };

      final comp = Competition.fromJson(json);

      expect(comp.id, equals('comp_123'));
      expect(comp.name, equals('Summer Marathon 2026'));
      expect(comp.category, contains('Running'));
      expect(comp.cost, equals(499.0));
      expect(comp.duration, equals(180));
      expect(comp.status, equals('active'));
    });

    test('Competition.fromJson handles null or missing optional fields gracefully', () {
      final json = <String, dynamic>{
        '_id': 'comp_minimal',
        'name': 'Minimal Comp',
      };

      final comp = Competition.fromJson(json);

      expect(comp.id, equals('comp_minimal'));
      expect(comp.name, equals('Minimal Comp'));
      expect(comp.cost, equals(0.0));
      expect(comp.status, equals('inactive'));
      expect(comp.category, isEmpty);
      expect(comp.image, isEmpty);
    });
  });

  group('Address Model Tests', () {
    test('Address.fromJson correctly parses address JSON', () {
      final json = {
        '_id': 'addr_1',
        'name': 'John Doe',
        'phone': '9876543210',
        'addressLine1': '123 Main St',
        'addressLine2': 'Apt 4B',
        'city': 'Metropolis',
        'state': 'NY',
        'pincode': '10001',
        'isDefault': true,
      };

      final addr = Address.fromJson(json);

      expect(addr.id, equals('addr_1'));
      expect(addr.name, equals('John Doe'));
      expect(addr.isDefault, isTrue);
      expect(addr.city, equals('Metropolis'));
    });
  });

  group('Exercise Model Tests', () {
    test('Exercise.fromJson parses complete exercise data', () {
      final json = {
        '_id': 'ex_bench',
        'name': 'Barbell Bench Press',
        'description': 'Chest exercise',
        'type': 'Strength',
        'category': 'Chest',
        'difficulty': 'Intermediate',
        'duration': 15,
        'sets': 4,
        'reps': 10,
        'restTime': 60,
        'equipment': ['Barbell', 'Bench'],
        'targetMuscles': ['Pectoralis Major', 'Triceps'],
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise.id, equals('ex_bench'));
      expect(exercise.name, equals('Barbell Bench Press'));
      expect(exercise.sets, equals(4));
      expect(exercise.reps, equals(10));
      expect(exercise.equipment, contains('Barbell'));
    });
  });
}


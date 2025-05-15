import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create a UserModel from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'John Doe',
        'email': 'john@example.com',
        'password': 'password123',
        'weight': 75.5,
        'height': 180.0,
        'age': 30,
        'gender': 'male',
      };

      // Act
      final user = UserModel.fromJson(json);

      // Assert
      expect(user.id, 1);
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.password, 'password123');
      expect(user.weight, 75.5);
      expect(user.height, 180.0);
      expect(user.age, 30);
      expect(user.gender, 'male');
    });

    test('should convert UserModel to JSON', () {
      // Arrange
      final user = UserModel(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
        weight: 75.5,
        height: 180.0,
        age: 30,
        gender: 'male',
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['name'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['password'], 'password123');
      expect(json['weight'], 75.5);
      expect(json['height'], 180.0);
      expect(json['age'], 30);
      expect(json['gender'], 'male');
    });
  });
}

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SqlDb {
  static Database? _db;

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    Database? myDb = await db;
    List<Map<String, dynamic>> users = await myDb!.query('users');
    return users;
  }

  // delete all users
  Future<int> deleteAllUsers() async {
    Database? myDb = await db;
    int count = await myDb!.delete('users');
    return count;
  }

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initDb();
      return _db;
    } else {
      return _db;
    }
  }

  Future<Database> initDb() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'my_database.db');
    Database database = await openDatabase(
      path,
      version: 1,
      onCreate: onCreate,
    );
    return database;
  }

  Future<void> onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // Hash password for security
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Sign Up - Create new user account
  Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      Database? myDb = await db;

      // Check if email already exists
      List<Map> existingUser = await myDb!.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );

      if (existingUser.isNotEmpty) {
        return {'success': false, 'message': 'Email already registered'};
      }

      // Insert new user
      int userId = await myDb.insert('users', {
        'fullName': fullName.trim(),
        'email': email.toLowerCase().trim(),
        'password': _hashPassword(password),
        'createdAt': DateTime.now().toIso8601String(),
      });

      return {
        'success': true,
        'message': 'Account created successfully',
        'userId': userId,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Login - Authenticate user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      Database? myDb = await db;

      // Find user by email
      List<Map> users = await myDb!.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.toLowerCase().trim()],
      );

      if (users.isEmpty) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      // Verify password
      Map user = users.first;
      String hashedInputPassword = _hashPassword(password);

      if (user['password'] != hashedInputPassword) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      return {
        'success': true,
        'message': 'Login successful',
        'user': {
          'id': user['id'],
          'fullName': user['fullName'],
          'email': user['email'],
        },
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      Database? myDb = await db;
      List<Map> users = await myDb!.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (users.isNotEmpty) {
        Map user = users.first;
        return {
          'id': user['id'],
          'fullName': user['fullName'],
          'email': user['email'],
          'createdAt': user['createdAt'],
        };
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user: $e');
      }
      return null;
    }
  }

  // Delete user account
  Future<bool> deleteUser(int userId) async {
    try {
      Database? myDb = await db;
      int count = await myDb!.delete(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      return count > 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user: $e');
      }
      return false;
    }
  }

  // Update password
  Future<Map<String, dynamic>> updatePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      Database? myDb = await db;

      // Verify current password
      List<Map> users = await myDb!.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (users.isEmpty) {
        return {'success': false, 'message': 'User not found'};
      }

      if (users.first['password'] != _hashPassword(currentPassword)) {
        return {'success': false, 'message': 'Current password is incorrect'};
      }

      // Update password
      await myDb.update(
        'users',
        {'password': _hashPassword(newPassword)},
        where: 'id = ?',
        whereArgs: [userId],
      );

      return {'success': true, 'message': 'Password updated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gym_manager/database/db_helper.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  // Get database file path
  Future<File> getDatabaseFile() async {
    try {
      final dbFactory = databaseFactoryFfi;
      final dbPath = await dbFactory.getDatabasesPath();
      final fullPath = path.join(dbPath, "gym_manager.db");
      return File(fullPath);
    } catch (e) {
      print('Error getting database path: $e');
      rethrow;
    }
  }

  // ============================
  // CREATE BACKUP (SAFE VERSION)
  // ============================
  Future<bool> createBackup(BuildContext context) async {
    bool wasDatabaseOpen = DBHelper.isDatabaseOpen;

    try {
      print('🔄 Starting backup process...');

      // Close database only if it's open
      if (wasDatabaseOpen) {
        await DBHelper.closeDatabaseForBackup();
        await Future.delayed(Duration(milliseconds: 500));
      }

      final dbFile = await getDatabaseFile();

      // Check if database exists
      if (!await dbFile.exists()) {
        // Try to create a minimal database first
        await _createMinimalDatabase();
        if (!await dbFile.exists()) {
          throw Exception('Database file not found and could not be created');
        }
      }

      // Let user choose where to save backup
      String? selectedPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Backup Location',
      );

      if (selectedPath == null) {
        print('❌ User cancelled backup');
        return false;
      }

      // Create backup file name with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupFileName = 'gym_backup_$timestamp.db';
      final backupFile = File(path.join(selectedPath, backupFileName));

      // Copy database to backup location
      await dbFile.copy(backupFile.path);

      // Update last backup timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'last_manual_backup',
        DateTime.now().toIso8601String(),
      );

      // Show success dialog
      _showBackupSuccessDialog(context, backupFile.path);

      return true;
    } catch (e) {
      print('❌ Backup failed: $e');
      _showErrorDialog(context, 'Backup failed: $e');
      return false;
    } finally {
      // ALWAYS reopen database if we closed it
      if (wasDatabaseOpen) {
        await DBHelper.reopenDatabase();
        print('✅ Database reopened after backup attempt');
      }
    }
  }

  // ============================
  // RESTORE BACKUP (SAFE VERSION)
  // ============================
  Future<bool> restoreBackup(BuildContext context) async {
    bool wasDatabaseOpen = DBHelper.isDatabaseOpen;

    try {
      print('🔄 Starting restore process...');

      // Let user select a backup file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
        dialogTitle: 'Select Backup File to Restore',
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final backupFile = File(result.files.single.path!);
      final dbFile = await getDatabaseFile();

      // Validate backup file
      if (!await backupFile.exists()) {
        throw Exception('Backup file does not exist');
      }

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('⚠️ Important Warning'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('This will replace ALL current data.'),
              SizedBox(height: 10),
              Text('App will close after restore.'),
              SizedBox(height: 10),
              Text('Continue?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Restore'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      );

      if (confirmed != true) return false;

      // Close database if open
      if (wasDatabaseOpen) {
        await DBHelper.closeDatabaseForBackup();
        await Future.delayed(Duration(milliseconds: 500));
      }

      // ========== SAFETY BACKUP ==========
      if (await dbFile.exists()) {
        final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final safetyDir = await getApplicationDocumentsDirectory();
        final safetyPath = path.join(safetyDir.path, 'safety_backups');

        await Directory(safetyPath).create(recursive: true);

        final safetyBackup = File(
          path.join(safetyPath, 'safety_$timestamp.db'),
        );
        await dbFile.copy(safetyBackup.path);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_safety_backup', safetyBackup.path);

        print('🔒 Safety backup created: ${safetyBackup.path}');
      }
      // ===================================

      // Perform restore with retry logic
      bool restoreSuccess = await _performRestoreWithRetry(backupFile, dbFile);

      if (restoreSuccess) {
        // Show success dialog
        _showRestoreSuccessDialog(context);
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Restore failed: $e');
      _showErrorDialog(context, 'Restore failed: $e');
      return false;
    } finally {
      // ALWAYS reopen database if we closed it
      if (wasDatabaseOpen) {
        await DBHelper.reopenDatabase();
        print('✅ Database reopened after restore attempt');
      }
    }
  }

  // ============================
  // HELPER METHODS
  // ============================
  Future<bool> _performRestoreWithRetry(File backupFile, File dbFile) async {
    // Try multiple methods
    final methods = [
      _restoreMethodDirectCopy,
      _restoreMethodDeleteThenCopy,
      _restoreMethodTempRename,
    ];

    for (int i = 0; i < methods.length; i++) {
      try {
        print('🔄 Trying restore method ${i + 1}...');
        await methods[i](backupFile, dbFile);
        print('✅ Restore method ${i + 1} successful');
        return true;
      } catch (e) {
        print('❌ Restore method ${i + 1} failed: $e');
        if (i == methods.length - 1) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: 200));
      }
    }

    return false;
  }

  Future<void> _restoreMethodDirectCopy(File backupFile, File dbFile) async {
    await backupFile.copy(dbFile.path);
  }

  Future<void> _restoreMethodDeleteThenCopy(
    File backupFile,
    File dbFile,
  ) async {
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    await backupFile.copy(dbFile.path);
  }

  Future<void> _restoreMethodTempRename(File backupFile, File dbFile) async {
    final tempFile = File('${dbFile.path}.restore_temp');
    await backupFile.copy(tempFile.path);

    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    await tempFile.rename(dbFile.path);
  }

  Future<void> _createMinimalDatabase() async {
    try {
      // Create a minimal database to ensure file exists
      final db = await DBHelper.database;

      // Check if clients table exists, create if not
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='clients'",
      );

      if (tables.isEmpty) {
        await db.execute("""
          CREATE TABLE IF NOT EXISTS clients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone TEXT,
            start_date TEXT,
            end_date TEXT,
            subscription_type TEXT
          )
        """);
        print('✅ Created minimal database structure');
      }
    } catch (e) {
      print('❌ Error creating minimal database: $e');
      rethrow;
    }
  }

  // ============================
  // DIALOG METHODS
  // ============================
  void _showBackupSuccessDialog(BuildContext context, String backupPath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Backup Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Backup created successfully!'),
            SizedBox(height: 10),
            Text('Location:', style: TextStyle(fontWeight: FontWeight.bold)),
            SelectableText(
              backupPath,
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRestoreSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Restore Complete'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Database restored successfully!'),
            SizedBox(height: 10),
            Text(
              '⚠️ IMPORTANT:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            Text('Please restart the application.'),
            SizedBox(height: 5),
            Text('1. Click "Close App" below'),
            Text('2. Restart Gym Manager'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Close the app
              exit(0);
            },
            child: Text('Close App'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Error'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Get database info for UI
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final dbFile = await getDatabaseFile();
      final exists = await dbFile.exists();

      if (!exists) {
        return {'exists': false, 'path': dbFile.path};
      }

      final stat = await dbFile.stat();

      return {
        'exists': true,
        'path': dbFile.path,
        'size': stat.size,
        'sizeKB': (stat.size / 1024).toStringAsFixed(2),
        'modified': stat.modified,
        'isOpen': DBHelper.isDatabaseOpen,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}

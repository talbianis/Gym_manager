import 'package:flutter/material.dart';
import 'package:gym_manager/services/backup_service.dart';
import 'package:intl/intl.dart';

class BackupPage extends StatefulWidget {
  @override
  _BackupPageState createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final BackupService _backupService = BackupService();
  bool _isProcessing = false;
  String _statusMessage = '';
  Map<String, dynamic> _dbInfo = {};

  @override
  void initState() {
    super.initState();
    _loadDatabaseInfo();
  }

  Future<void> _loadDatabaseInfo() async {
    final info = await _backupService.getDatabaseInfo();
    setState(() {
      _dbInfo = info;
    });
  }

  Future<void> _createBackup() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Creating backup...';
    });

    final success = await _backupService.createBackup(context);

    setState(() {
      _isProcessing = false;
      if (success) {
        _statusMessage = 'Backup created successfully!';
      } else {
        _statusMessage = 'Backup failed or cancelled.';
      }
    });

    // Reload database info
    await _loadDatabaseInfo();
  }

  Future<void> _restoreBackup() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Preparing restore...';
    });

    final success = await _backupService.restoreBackup(context);

    setState(() {
      _isProcessing = false;
      if (!success) {
        _statusMessage = 'Restore cancelled or failed.';
      }
    });

    // Reload database info
    await _loadDatabaseInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Backup & Restore')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Database Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storage, color: Colors.blue),
                        SizedBox(width: 10),
                        Text(
                          'Database Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    if (_dbInfo['error'] != null)
                      Text('Error: ${_dbInfo['error']}'),
                    if (_dbInfo['exists'] == true) ...[
                      Text('Status: ✅ Connected'),
                      Text('Size: ${_dbInfo['sizeKB']} KB'),
                      if (_dbInfo['modified'] != null)
                        Text(
                          'Modified: ${DateFormat('yyyy-MM-dd HH:mm').format(_dbInfo['modified'])}',
                        ),
                      Text('Path: ${_dbInfo['path']}'),
                    ] else if (_dbInfo['exists'] == false) ...[
                      Text('Status: ❌ Not found'),
                      Text('Path: ${_dbInfo['path']}'),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Backup Button
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _createBackup,
              icon: Icon(Icons.backup),
              label: Text('CREATE BACKUP'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
              ),
            ),

            SizedBox(height: 15),

            // Restore Button
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _restoreBackup,
              icon: Icon(Icons.restore),
              label: Text('RESTORE FROM BACKUP'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
              ),
            ),

            SizedBox(height: 30),

            // Status Display
            if (_isProcessing)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(_statusMessage),
                  ],
                ),
              ),

            if (_statusMessage.isNotEmpty && !_isProcessing)
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('successfully')
                      ? Colors.green[50]
                      : Colors.blue[50],
                  border: Border.all(
                    color: _statusMessage.contains('successfully')
                        ? Colors.green
                        : Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_statusMessage),
              ),

            Spacer(),

            // Tips
            Card(
              color: Colors.blueGrey[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Backup Tips:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text('• Create backups regularly (weekly)'),
                    Text('• Store backups in multiple locations'),
                    Text('• Test restore process periodically'),
                    Text('• Always backup before app updates'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

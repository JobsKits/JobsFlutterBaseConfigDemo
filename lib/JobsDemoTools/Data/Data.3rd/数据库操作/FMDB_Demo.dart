import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// dependencies:
//   flutter:
//     sdk: flutter
//   sqflite:
//   path:

void main() =>
    runApp(const JobsMaterialRunner(SqliteDemo(), title: 'SQLite Demo'));

class SqliteDemo extends StatefulWidget {
  const SqliteDemo({super.key});

  @override
  _SqliteDemoState createState() => _SqliteDemoState();
}

class _SqliteDemoState extends State<SqliteDemo> {
  Database? _database;
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    widget;
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    /// 获取数据库存储路径
    final path = join(databasePath, 'demo.db');
    _database = await openDatabase(
      /// 打开数据库并创建 items 表
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE items(id INTEGER PRIMARY KEY, name TEXT)',
        );
      },
    );

    _refreshRecords();
  }

  /// CRUD 操作：
  /// 查
  Future<void> _refreshRecords() async {
    final List<Map<String, dynamic>> records = await _database!.query('items');
    setState(() {
      _records = records;
    });
  }

  /// 增
  Future<void> _addItem(String name) async {
    await _database!.insert('items', {'name': name});
    _refreshRecords();
  }

  /// 改
  Future<void> _updateItem(int id, String newName) async {
    await _database!
        .update('items', {'name': newName}, where: 'id = ?', whereArgs: [id]);
    _refreshRecords();
  }

  /// 删
  Future<void> _deleteItem(int id) async {
    await _database!.delete('items', where: 'id = ?', whereArgs: [id]);
    _refreshRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => _addItem('New Item'),
            child: const Text('Add Item'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return ListTile(
                  title: Text(record['name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _updateItem(record['id'], 'Updated Item'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteItem(record['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }
}

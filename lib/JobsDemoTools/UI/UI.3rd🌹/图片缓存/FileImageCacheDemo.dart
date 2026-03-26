import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:jobs_runners/jobs_runners.dart';

void main() => runApp(JobsGetRunner(const FileImageCacheDemo(),
    title: 'flutter_cache_manager + Image.file 示例'));

class FileImageCacheDemo extends StatelessWidget {
  const FileImageCacheDemo({super.key});

  final String imageUrl = 'https://via.placeholder.com/150'; // ✅ 图片地址

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<File>(
        future: MyCustomCacheManager().getSingleFile(imageUrl), // ✅ 获取缓存文件
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(), // ✅ 加载中
                SizedBox(height: 10),
                Text('正在加载图片...'),
              ],
            );
          } else if (snapshot.hasError) {
            debugPrint('加载失败: ${snapshot.error}');
            return const Icon(Icons.error); // ✅ 加载失败
          } else if (snapshot.hasData) {
            final file = snapshot.data!;
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(file), // ✅ 使用缓存文件显示图片
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else {
            return const Text('无图片可显示');
          }
        },
      ),
    );
  }
}

class MyCustomCacheManager extends CacheManager {
  static const String key = 'myCustomCache';
  static final MyCustomCacheManager _instance =
      MyCustomCacheManager._internal();

  factory MyCustomCacheManager() => _instance;

  MyCustomCacheManager._internal()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 3),
            maxNrOfCacheObjects: 100,
            repo: JsonCacheInfoRepository(databaseName: key),
            fileService: HttpFileService(),
          ),
        );
}

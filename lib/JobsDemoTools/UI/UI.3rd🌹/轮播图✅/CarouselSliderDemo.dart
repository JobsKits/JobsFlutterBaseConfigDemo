import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// 此案例演示了利用carousel_slider实现轮播图效果。
// 图片资源位于项目跟目录下的：
// 'assets/Images/CarouselAssets/slide1.png',
// 'assets/Images/CarouselAssets/slide2.png',
void main() =>
    runApp(const JobsMaterialRunner(CarouselDemo(), title: 'Carousel Demo'));

// 展示轮播图的页面
class CarouselDemo extends StatelessWidget {
  static const List<String> imgList = [
    'assets/Images/CarouselAssets/slide1.png',
    'assets/Images/CarouselAssets/slide2.png',
    'https://imgs.699pic.com/images/500/362/891.jpg!list1x.v2',
    'https://pic.huitu.com/pic/20230531/3248670_20230531151554010203_0.jpg',
  ];
  const CarouselDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carousel Slider Demo'),
      ),
      body: Center(
        child: CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
          ),
          items: imgList
              .map((item) => Center(
                    // child: Image.network(item, fit: BoxFit.cover, width: 1000)
                    child: item.startsWith('assets/')
                        ? Image.asset(item, fit: BoxFit.cover, width: 1000)
                        : Image.network(item, fit: BoxFit.cover, width: 1000),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

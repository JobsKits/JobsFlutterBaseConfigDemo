import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// 此案例演示了利用card_swiper做的轮播图效果，可以自定义样式，可以设置自动播放，可以设置指示器样式等。
// 图片资源位于项目跟目录下的：
// 'assets/Images/CarouselAssets/slide1.png',
// 'assets/Images/CarouselAssets/slide2.png',
void main() =>
    runApp(const JobsMaterialRunner(SwiperDemo(), title: 'Swiper Demo'));

class SwiperDemo extends StatelessWidget {
  static const List<String> imgList = [
    'assets/Images/CarouselAssets/slide1.png',
    'assets/Images/CarouselAssets/slide2.png',
    'https://imgs.699pic.com/images/500/362/891.jpg!list1x.v2',
    'https://pic.huitu.com/pic/20230531/3248670_20230531151554010203_0.jpg',
  ];

  const SwiperDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Swiper(
      itemCount: imgList.length,
      itemBuilder: (BuildContext context, int index) {
        String imgUrl = imgList[index];
        return imgUrl.startsWith('http')
            ? Image.network(
                imgUrl,
                fit: BoxFit.cover,
              )
            : Image.asset(
                imgUrl,
                fit: BoxFit.cover,
              );
      },
      pagination: const SwiperPagination(),
      control: const SwiperControl(),
    );
  }
}

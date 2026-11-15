import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/extra_support.dart';

void main() => runApp(const JobsDemoApp(home: ResizeLayoutLabDemo()));

class ResizeLayoutLabDemo extends StatefulWidget {
  const ResizeLayoutLabDemo({super.key});
  @override
  State<ResizeLayoutLabDemo> createState() => _State();
}

class _State extends State<ResizeLayoutLabDemo> {
  double width = 300, height = 400;
  bool linked = true;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ExtraFrame(
      title: '布局尺寸联动',
      children: [
        Text('${extraTr(context, '宽度')} ${width.round()}'),
        Slider(
          min: 200,
          max: 500,
          value: width,
          onChanged: (v) => setState(() => width = v),
        ),
        Text('${extraTr(context, '高度')} ${height.round()}'),
        Slider(
          min: 200,
          max: 500,
          value: height,
          onChanged: (v) => setState(() => height = v),
        ),
        SwitchListTile(
          title: Text(extraTr(context, '子视图随父级缩放')),
          value: linked,
          onChanged: (v) => setState(() => linked = v),
        ),
        SizedBox(
          height: 360,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: width,
                height: height,
                color: colors.primaryContainer,
                child: Stack(
                  children: [
                    Positioned(
                      left: 20,
                      top: 20,
                      child: Container(
                        width: linked ? width / 2 : 100,
                        height: linked ? height * .3 : 60,
                        color: colors.tertiaryContainer,
                        alignment: Alignment.center,
                        child: const Text('fitHor(20,20,100,60)'),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: linked ? height * .4 : 80,
                      child: Container(
                        width: linked ? width - 50 : 150,
                        height: linked ? height * .3 : 120,
                        color: colors.secondaryContainer,
                        alignment: Alignment.center,
                        child: Text(
                          '${(linked ? width - 50 : 150).round()} × ${(linked ? height * .3 : 120).round()}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

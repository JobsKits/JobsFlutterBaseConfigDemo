import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/lab_support.dart';

void main() => runApp(const JobsDemoApp(home: BarcodeDemo(), title: '二维码条形码'));

class BarcodeDemo extends StatefulWidget {
  const BarcodeDemo({super.key});
  @override
  State<BarcodeDemo> createState() => _State();
}

class _State extends State<BarcodeDemo> {
  final input = TextEditingController(text: 'Jobs Flutter 2026');
  int mode = 0;
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LabFrame(
    title: '二维码条形码',
    children: [
      TextField(
        controller: input,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: labTr(context, '内容')),
      ),
      Wrap(
        spacing: 8,
        children: [
          for (var i = 0; i < 3; i++)
            ChoiceChip(
              label: Text(['QR', 'Code128', 'DataMatrix'][i]),
              selected: mode == i,
              onSelected: (_) => setState(() => mode = i),
            ),
        ],
      ),
      Center(
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: BarcodeWidget(
              barcode: [
                Barcode.qrCode(),
                Barcode.code128(),
                Barcode.dataMatrix(),
              ][mode],
              data: input.text.isEmpty ? 'Jobs' : input.text,
              color: Colors.black,
              width: 240,
              height: mode == 1 ? 100 : 240,
              drawText: false,
              errorBuilder: (_, error) => SizedBox(
                width: 240,
                child: Text(error, style: const TextStyle(color: Colors.black)),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

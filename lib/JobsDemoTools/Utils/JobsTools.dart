

// Future<DecorationImage> svgAssetBy(String asset, {JobsSizeSpec? size}) async {
//     size = size ?? const JobsSizeSpec(w: 24, h: 24);

//     final PictureInfo pictureInfo = await vg.loadPicture(
//       SvgAssetLoader(asset),
//       null,
//     );
//     final ui.Image image = await pictureInfo.picture.toImage(
//       size.w.toInt(),
//       size.h.toInt(),
//     );
//     final ByteData? byteData =
//         await image.toByteData(format: ui.ImageByteFormat.png);

//     return DecorationImage(
//       image: MemoryImage(byteData!.buffer.asUint8List()),
//       fit: BoxFit.contain,
//     );
//   }

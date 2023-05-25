import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

class AGContentPreview extends StatefulWidget {
  const AGContentPreview({
    Key? key,
    required this.content,
    this.touchpointId = 0,
  }) : super(key: key);

  final int? touchpointId;
  final MAGContent content;

  @override
  State<AGContentPreview> createState() => _AGContentPreviewState();
}

class _AGContentPreviewState extends State<AGContentPreview> {
  @override
  Widget build(BuildContext context) {
    print("Label: ${Uri.encodeFull(widget.content.label!)}");
    return _buildFrame(
      context,
      child: _buildIFrameView(context),
    );
  }

  @override
  void initState() {
    super.initState();
    html.window.onMessage.listen((event) {
      print("EventData: ${event.data}");
      if (event.data == "{ type: 'ready' }") _sendContent();
    });
  }

  @override
  void didUpdateWidget(covariant AGContentPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sendContent();
  }

  void _sendContent() {
    html.window.postMessage(
        {"type": "content", "content": "${widget.content.label}"}, '*');
  }

  Widget _buildFrame(BuildContext context, {Widget? child}) {
    return FittedBox(
      child: Container(
        width: 240,
        height: 320,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        clipBehavior: Clip.hardEdge,
        child: child,
      ),
    );
  }

  Widget _buildIFrameView(BuildContext context) {
    final html.IFrameElement _iframeElement = html.IFrameElement()
      ..width = '100%'
      ..height = '100%'
      ..style.border = 'none'
      ..style.overflow = 'hidden'
      ..style.borderRadius = '8px'
      ..src = '/content_preview.html';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'iframe',
      (int viewId) => _iframeElement,
    );

    return const SizedBox(
      width: 240,
      height: 320,
      child: HtmlElementView(
        viewType: 'iframe',
      ),
    );
  }
}
// class AGContentPreview extends StatelessWidget {
//   const AGContentPreview({
//     Key? key,
//     required this.content,
//     this.touchpointId = 0,
//   }) : super(key: key);
//
//   final int? touchpointId;
//   final MAGContent content;
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AgContentPreviewBloc, AgContentPreviewState>(
//       bloc: getIt<AgContentPreviewBloc>(),
//       builder: (context, state) {
//         return _buildFrame(
//           context,
//           child: state is AgContentPreviewLoaded
//               ? _buildCustomPaint(context, assets: state.assets)
//               : _buildLoading(context),
//         );
//       },
//     );
//   }
//
//   Widget _buildFrame(BuildContext context, {Widget? child}) {
//     return FittedBox(
//       child: Container(
//         width: 240,
//         height: 320,
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: Theme.of(context).dividerColor,
//             width: 2.0,
//           ),
//           borderRadius: BorderRadius.circular(8),
//           color: Colors.white,
//         ),
//         clipBehavior: Clip.hardEdge,
//         child: child,
//       ),
//     );
//   }
//
//   Widget _buildLoading(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Center(child: CircularProgressIndicator()),
//           const SizedBox(height: 8),
//           Text(
//             'Loading assets...',
//             style: Theme.of(context).textTheme.bodyText2,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCustomPaint(BuildContext context,
//       {required Map<int, ui.Image> assets}) {
//     return CustomPaint(
//       painter: AGContentPreviewPainter(
//         assets: assets,
//         label: content.label ?? '',
//         touchpointId: touchpointId,
//       ),
//     );
//   }
// }

// class GuiTextChar {
//   final int assetId;
//   final int x;
//   final int y;
//   final int width;
//   final int height;
//
//   GuiTextChar({
//     required this.assetId,
//     required this.x,
//     required this.y,
//     required this.width,
//     required this.height,
//   });
// }
//
// class AGContentPreviewPainter extends CustomPainter {
//   final String label;
//   final int? touchpointId;
//   final Map<int, ui.Image> assets;
//
//   static const int ascii0 = 48;
//   static const int guiColorBlue = 0;
//   static const int guiColorGreen = 1;
//   static const int guiColorWhiteOnBlue = 2;
//   static const int guiColorWhiteOnGreen = 3;
//
//   AGContentPreviewPainter({
//     required this.assets,
//     this.label = 'Preview',
//     this.touchpointId = 0,
//   });
//
//   void lcdWriteArea(Canvas canvas, int x, int y, int w, int h, int color) {
//     final paint = Paint()
//       ..color = Color(color)
//       ..style = PaintingStyle.fill;
//
//     canvas.drawRect(
//         Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble()),
//         paint);
//   }
//
//   void writeAssetToScreen(Canvas canvas, int assetId, int x, int y, int width,
//       int height, int languageId) {
//     final asset = assets[assetId];
//     if (asset != null) {
//       canvas.drawImageRect(
//         asset,
//         Rect.fromLTWH(0, 0, asset.width.toDouble(), asset.height.toDouble()),
//         Rect.fromLTWH(
//             x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble()),
//         Paint(),
//       );
//     }
//   }
//
//   void guiPrintAudioPlayScreen(Canvas canvas) {
//     writeAssetToScreen(canvas, 16, 200, 20, 25, 24, 0); //Fav Icon
//     writeAssetToScreen(canvas, 15, 86, 15, 68, 34, 0); //Number Frame
//     writeAssetToScreen(canvas, 18, 14, 292, 212, 14, 0); //Empty Time Bar
//     writeAssetToScreen(canvas, 47, 157, 272, 9, 4, 0); //Minus Sign in Time
//     writeAssetToScreen(canvas, 46, 42, 269, 4, 13, 0); //dp left
//     writeAssetToScreen(canvas, 46, 194, 269, 4, 13, 0); //dp right
//     writeAssetToScreen(canvas, 25, 18, 297, 3, 5, 0); //Bar Start
//   }
//
//   void guiPrintAudioTrackNumber(Canvas canvas, int number, int color) {
//     int startAudioNbrAssets = 26;
//     switch (color) {
//       case guiColorBlue:
//         lcdWriteArea(canvas, 97, 21, 45, 22, 0xFFFF);
//         startAudioNbrAssets = 26;
//         break;
//       case guiColorGreen:
//         lcdWriteArea(canvas, 97, 21, 45, 22, 0x03D6);
//         startAudioNbrAssets = 26;
//         break;
//       case guiColorWhiteOnBlue:
//         lcdWriteArea(canvas, 97, 21, 45, 22, 0x03D6);
//         startAudioNbrAssets = 184;
//         break;
//       case guiColorWhiteOnGreen:
//         break;
//     }
//
//     final int asciiOffset = ascii0 - startAudioNbrAssets;
//     final String numberStr = number.toString().padLeft(3, '0');
//     final int digit0 = int.parse(numberStr[0]);
//     final int digit1 = int.parse(numberStr[1]);
//     final int digit2 = int.parse(numberStr[2]);
//
//     writeAssetToScreen(
//         canvas,
//         numberStr.codeUnitAt(0) - asciiOffset,
//         100,
//         22,
//         audioPlayNumberInfo[digit0][0],
//         audioPlayNumberInfo[digit0][1],
//         0); //First_Char
//     writeAssetToScreen(
//         canvas,
//         numberStr.codeUnitAt(1) - asciiOffset,
//         114,
//         22,
//         audioPlayNumberInfo[digit1][0],
//         audioPlayNumberInfo[digit1][1],
//         0); //Second_Char
//     writeAssetToScreen(
//         canvas,
//         numberStr.codeUnitAt(2) - asciiOffset,
//         129,
//         22,
//         audioPlayNumberInfo[digit2][0],
//         audioPlayNumberInfo[digit2][1],
//         0); //third_Char
//   }
//
//   List<GuiTextChar?> guiCalcAudioPlayName(String name) {
//     final List<GuiTextChar> textChars = [];
//
//     int turtleX = 15; // String will be leftbound
//     int turtleY = 93; // Start of First Line
//
//     int startIndex = 0;
//     int endIndex = 0;
//
//     bool charsLeft =
//         true; // Flag to indicate if there are chars left to process
//     int length = 0; // Length of the current line
//
//     // While we have characters left to render
//     while (charsLeft) {
//       // Try to figure out the length of the next word segment (marked by a space or -)
//       bool foundSpace = false;
//       while (!foundSpace) {
//         // If we hit the end of the string, we're done
//         if (endIndex >= name.length - 1) {
//           charsLeft = false;
//           break;
//         }
//         foundSpace = name[endIndex] == ' ' || name[endIndex] == '-';
//         if (!foundSpace) {
//           endIndex++;
//           // get the info for the character at ind_end
//           // and add its width to the length
//           bool foundChar = false;
//           for (int i = 0; i < audioTextBlueInfo.length; i++) {
//             if (audioTextBlueInfo[i][0] == name[endIndex]) {
//               length += audioTextBlueInfo[i][1] as int;
//               endIndex++;
//               foundChar = true;
//               break;
//             }
//           }
//           if (!foundChar) endIndex++;
//         }
//       }
//
//       // Skip the space or -
//       endIndex++;
//
//       // If the length is too long, we need to break the line
//       if (turtleX + length > 240) {
//         turtleX = 15;
//         turtleY += 31;
//       }
//
//       // We have finished measuring, so reset the length
//       length = 0;
//
//       // layout current line
//       for (int i = startIndex; i < endIndex; i++) {
//         // if we hit the ends of the string or a period, we're done with this line
//         if (i > name.length - 1 || name[i] == '.') break;
//
//         if (name[i] == ' ') {
//           // Space
//           // Render Space
//           // Space is a 6px gap
//           turtleX += 6;
//         } else if (name[i] == '\r' || name[i] == '\n') {
//           // CR or LF
//           // Render Newline
//           // Line height is 31px
//           turtleY += 31;
//           turtleX = 15;
//         } else {
//           // Render Normal Character
//
//           // Look for details on the character
//           for (int pt = 0; pt < audioTextBlueInfo.length; pt++) {
//             if (audioTextBlueInfo[pt][0] == name[i]) {
//               final charInfo = audioTextBlueInfo[pt];
//               textChars.add(GuiTextChar(
//                 assetId: pt,
//                 x: turtleX,
//                 y: turtleY + (charInfo[3] as int),
//                 // charInfo[3] is the characters y offset
//                 width: charInfo[1] as int,
//                 height: charInfo[2] as int,
//               ));
//
//               turtleX += charInfo[1]
//                   as int; // Move the turtle forward by the width of the character
//               break;
//             }
//           }
//         }
//       }
//
//       startIndex = endIndex;
//     }
//
//     return textChars;
//   }
//
//   void guiPrintAudioPlayName(Canvas canvas, String name, int color) {
//     int assetOffset = 0;
//     switch (color) {
//       case guiColorBlue:
//         assetOffset = 49;
//         break;
//       case guiColorGreen:
//         break;
//       case guiColorWhiteOnBlue:
//         assetOffset = 194;
//         break;
//       case guiColorWhiteOnGreen:
//         break;
//     }
//
//     final textChars = guiCalcAudioPlayName(name);
//
//     for (final char in textChars) {
//       if (char == null) continue;
//       writeAssetToScreen(canvas, char.assetId + assetOffset, char.x, char.y,
//           char.width, char.height, 0);
//     }
//   }
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     guiPrintAudioPlayScreen(canvas);
//     guiPrintAudioTrackNumber(canvas, touchpointId ?? 0, guiColorBlue);
//     guiPrintAudioPlayName(canvas, label, guiColorBlue);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     if (oldDelegate is AGContentPreviewPainter) {
//       return oldDelegate.label != label;
//     }
//     return true;
//   }
// }

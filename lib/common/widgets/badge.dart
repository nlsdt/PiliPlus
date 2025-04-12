import 'package:flutter/material.dart';

class PBadge extends StatelessWidget {
  final String? text;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final String? type;
  final String? size;
  final String? stack;
  final double? fs;
  final String? semanticsLabel;
  final bool bold;
  final double? textScaleFactor;
  final EdgeInsets? padding;

  const PBadge({
    super.key,
    this.text,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.type = 'primary',
    this.size = 'medium',
    this.stack = 'position',
    this.fs = 11,
    this.semanticsLabel,
    this.bold = true,
    this.textScaleFactor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme t = Theme.of(context).colorScheme;
    // 背景色
    Color bgColor = t.primary;
    // 前景色
    Color color = t.onPrimary;
    // 边框色
    Color borderColor = Colors.transparent;
    if (type == 'gray') {
      bgColor = Colors.black54.withOpacity(0.45);
      color = Colors.white;
    } else if (type == 'color') {
      bgColor = t.secondaryContainer.withOpacity(0.5);
      color = t.onSecondaryContainer;
    } else if (type == 'line') {
      bgColor = Colors.transparent;
      color = t.primary;
      borderColor = t.primary;
    } else if (type == 'error') {
      bgColor = t.error;
      color = t.onError;
    }

    late EdgeInsets paddingStyle =
        const EdgeInsets.symmetric(vertical: 2, horizontal: 3);
    double fontSize = 11;
    BorderRadius br = BorderRadius.circular(4);

    if (size == 'small') {
      paddingStyle = const EdgeInsets.symmetric(vertical: 2, horizontal: 3);
      fontSize = 11;
      br = BorderRadius.circular(3);
    }

    Widget content = Container(
      padding: padding ?? paddingStyle,
      decoration: BoxDecoration(
        borderRadius: br,
        color: bgColor,
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text ?? "",
        textScaler: textScaleFactor != null
            ? TextScaler.linear(textScaleFactor!)
            : null,
        style: TextStyle(
          height: 1,
          fontSize: fs ?? fontSize,
          color: color,
          fontWeight: bold ? FontWeight.bold : null,
        ),
        strutStyle: StrutStyle(
          leading: 0,
          height: 1,
          fontSize: fs ?? fontSize,
          fontWeight: bold ? FontWeight.bold : null,
        ),
        semanticsLabel: semanticsLabel,
      ),
    );
    if (stack == 'position') {
      return Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        child: content,
      );
    } else {
      return content;
    }
  }
}

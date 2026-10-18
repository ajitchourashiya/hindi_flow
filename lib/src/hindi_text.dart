import 'package:flutter/material.dart';

import 'hindi_flow_client.dart';

/// A Text-like widget that asynchronously translates [data] into Hindi.
class HindiText extends StatefulWidget {
  const HindiText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.placeholder,
    this.errorBuilder,
    this.semanticsLabel,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final String? placeholder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final String? semanticsLabel;

  @override
  State<HindiText> createState() => _HindiTextState();
}

class _HindiTextState extends State<HindiText> {
  late Future<String> _translation;

  @override
  void initState() {
    super.initState();
    _translation = HindiFlow.translate(widget.data);
  }

  @override
  void didUpdateWidget(covariant HindiText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _translation = HindiFlow.translate(widget.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _translation,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, snapshot.error!);
          }
          return Text(
            widget.data,
            style: widget.style,
            textAlign: widget.textAlign,
            maxLines: widget.maxLines,
            overflow: widget.overflow,
            softWrap: widget.softWrap,
            semanticsLabel: widget.semanticsLabel,
          );
        }

        final value = snapshot.data;
        return Text(
          value ?? widget.placeholder ?? widget.data,
          style: widget.style,
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
          softWrap: widget.softWrap,
          semanticsLabel: widget.semanticsLabel,
        );
      },
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

class ForwardSeekIndicator extends StatefulWidget {
  // final void Function(Duration) onChanged;
  final ValueChanged<Duration> onSubmitted;
  final int duration;

  const ForwardSeekIndicator({
    super.key,
    // required this.onChanged,
    required this.onSubmitted,
    required this.duration,
  });

  @override
  State<ForwardSeekIndicator> createState() => ForwardSeekIndicatorState();
}

class ForwardSeekIndicatorState extends State<ForwardSeekIndicator> {
  late Duration duration;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    duration = Duration(seconds: widget.duration);
    timer = Timer(const Duration(milliseconds: 400), () {
      widget.onSubmitted.call(duration);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void increment() {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 400), () {
      widget.onSubmitted.call(duration);
    });
    // widget.onChanged.call(value);
    // 重复点击 快进秒数累加10
    setState(() {
      duration += Duration(seconds: widget.duration);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: const Color(0x44767676),
      onTap: increment,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0x00767676),
              Color(0x88767676),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.fast_forward,
              size: 24.0,
              color: Colors.white,
            ),
            const SizedBox(height: 8.0),
            Text(
              '快进${duration.inSeconds}秒',
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

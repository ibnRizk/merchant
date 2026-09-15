import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

/// "إعادة إرسال الرمز" link with a countdown; the link only becomes
/// tappable once the countdown reaches zero, then resets it.
class ResendCodeTimer extends StatefulWidget {
  const ResendCodeTimer({
    super.key,
    required this.onResend,
    this.duration = const Duration(seconds: 60),
  });

  final VoidCallback onResend;
  final Duration duration;

  @override
  State<ResendCodeTimer> createState() => _ResendCodeTimerState();
}

class _ResendCodeTimerState extends State<ResendCodeTimer> {
  late int _secondsLeft = widget.duration.inSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = widget.duration.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  bool get _canResend => _secondsLeft == 0;

  String get _formatted {
    final String minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final String seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handleTap() {
    if (!_canResend) return;
    widget.onResend();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: _handleTap,
          child: Text(
            'إعادة إرسال الرمز',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _canResend ? BrandColors.orange : BrandColors.textGray,
            ),
          ),
        ),
        if (!_canResend) ...<Widget>[
          const SizedBox(width: 6),
          Text(
            _formatted,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: BrandColors.textGray,
            ),
          ),
        ],
      ],
    );
  }
}

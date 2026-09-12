import 'dart:async';

import 'package:flutter/material.dart';

class AutoDismissHint extends StatefulWidget {
  final Widget child;

  const AutoDismissHint({super.key, required this.child});

  @override
  State<AutoDismissHint> createState() => AutoDismissHintState();
}

class AutoDismissHintState extends State<AutoDismissHint> {
  static const _duration = Duration(seconds: 3);
  bool _visible = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_duration, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: widget.child,
      ),
    );
  }
}

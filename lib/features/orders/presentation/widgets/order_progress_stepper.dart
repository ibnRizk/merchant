import 'package:flutter/material.dart';

class ProgressStep {
  const ProgressStep({required this.label, required this.color});

  final String label;
  final Color color;
}

/// 3-segment order progress bar (e.g. accepted → preparing → ready), each
/// segment coloured independently with its label underneath. List order
/// flows right-to-left under an RTL [Directionality], matching reading
/// order (first step reads first, at the right).
class OrderProgressStepper extends StatelessWidget {
  const OrderProgressStepper({super.key, required this.steps});

  final List<ProgressStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            for (int i = 0; i < steps.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: steps[i].color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            for (final ProgressStep step in steps)
              Expanded(
                child: Text(
                  step.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: step.color,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

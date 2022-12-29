import 'package:flutter/material.dart';

class TooltipTabCounterWidget extends StatelessWidget {
  final String message;
  final String tabCount;
  final Color color;

  const TooltipTabCounterWidget({required this.message, required this.tabCount, required this.color, super.key});

  @override
  Widget build(BuildContext context) => Tooltip(
        message: message,
        triggerMode: TooltipTriggerMode.tap,
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: color,
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: 3)),
            Text(tabCount)
          ],
        ),
      );
}

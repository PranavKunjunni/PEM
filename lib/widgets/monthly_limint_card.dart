import 'package:flutter/material.dart';

class MonthlyLimitCard extends StatelessWidget {
  final double spentAmount;
  final double totalLimit;
  final bool isLimitExceeded;
  final VoidCallback? onTap;

  const MonthlyLimitCard({
    super.key,
    required this.spentAmount,
    required this.totalLimit,
    required this.isLimitExceeded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (spentAmount / totalLimit).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "MONTHLY LIMIT",
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(.5),
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "₹${spentAmount.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: " / ₹${totalLimit.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(
                isLimitExceeded ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isLimitExceeded
                  ? "Limit Exceeded"
                  : "${((1 - progress) * 100).toStringAsFixed(0)}% Remaining",
              style: TextStyle(
                color:
                    isLimitExceeded ? Colors.white : Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

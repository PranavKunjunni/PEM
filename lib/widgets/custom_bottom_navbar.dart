import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 77.5,
          right: 93,
          bottom: 42,
        ),
        child: Container(
          width: 220,
          height: 64,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withOpacity(.15),
            ),
          ),
          child: Row(
            children: [
              _navItem(
                asset: "assets/images/chart.svg",
                index: 0,
              ),

              const SizedBox(width: 22),

              _navItem(
                asset: "assets/images/retry.svg",
                index: 1,
              ),

              const SizedBox(width: 22),

              _navItem(
                asset: "assets/images/person.svg",
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required String asset,
    required int index,
  }) {
    final bool selected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected
              ? const Color(0xFF312ECB)
              : Colors.transparent,
        ),
        child: Center(
          child: SvgPicture.asset(
            asset,
            width: 28,
            height: 28,
            colorFilter: ColorFilter.mode(
              selected ? Colors.white : Colors.white54,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
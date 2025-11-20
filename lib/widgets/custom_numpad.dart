import 'package:flutter/material.dart';

class CustomNumpad extends StatelessWidget {
  final Function(String) onNumberTap;
  final VoidCallback onDotTap;
  final VoidCallback onDeleteTap;

  const CustomNumpad({
    super.key,
    required this.onNumberTap,
    required this.onDotTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.grey.shade200,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton("1"),
              _buildButton("2"),
              _buildButton("3"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton("4"),
              _buildButton("5"),
              _buildButton("6"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton("7"),
              _buildButton("8"),
              _buildButton("9"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(".", isDot: true),
              _buildButton("0"),
              _buildButton(
                "DEL",
                isIcon: true,
                icon: Icons.backspace_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String text, {
    bool isIcon = false,
    IconData? icon,
    bool isDot = false,
  }) {
    return SizedBox(
      width: 100,
      height: 60,
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          if (isIcon) {
            onDeleteTap();
          } else if (isDot) {
            onDotTap();
          } else {
            onNumberTap(text);
          }
        },
        child: isIcon
            ? Icon(icon, size: 24, color: Colors.black87)
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
      ),
    );
  }
}
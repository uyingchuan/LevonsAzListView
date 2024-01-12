import 'package:flutter/material.dart';

class AzListCursor extends StatelessWidget {
  const AzListCursor({super.key, required this.title, required this.size});

  final String title;
  final double size;
  final double _arrowSize = 30;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildTitle(),
        Positioned(
          top: (size - _arrowSize) * 0.5,
          right: -_arrowSize * 0.5 - 2.5,
          child: _buildArrow(),
        ),
      ],
    );
  }

  Widget _buildArrow() {
    return Icon(
      Icons.arrow_right,
      color: Colors.black54,
      size: _arrowSize,
    );
  }

  Widget _buildTitle() {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 32),
      ),
    );
  }
}

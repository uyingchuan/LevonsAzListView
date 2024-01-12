import 'package:flutter/material.dart';

class AzListItemView extends StatelessWidget {
  const AzListItemView({
    super.key,
    required this.name,
    this.isShowSeparator = true,
  });

  final String name;
  final bool isShowSeparator;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: isShowSeparator
            ? Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 0.5,
                ),
              )
            : null,
      ),
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(left: 16),
      child: Text(
        name,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}

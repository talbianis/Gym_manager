import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CounterRow extends StatelessWidget {
  final String label;
  final int price;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CounterRow({
    Key? key,
    required this.label,
    required this.price,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(label, style: TextStyle(fontSize: 16.sp)),
          ),
          Expanded(
            flex: 3,
            child: Text("${price} DA", textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onDecrement,
                  icon: Icon(Icons.remove_circle_outline),
                ),
                SizedBox(width: 8.w),
                Text(count.toString(), style: TextStyle(fontSize: 16.sp)),
                SizedBox(width: 8.w),
                IconButton(
                  onPressed: onIncrement,
                  icon: Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text("${count * price} DA", textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

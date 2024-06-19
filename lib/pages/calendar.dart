import "package:flutter/material.dart";

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
      ),
      child: Center(
        child: Text(
          'Only premium users have access',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

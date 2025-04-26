import 'package:flutter/material.dart';
import 'package:gymmate/custom_widgets/buttom_navbar.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime today = DateTime.now();
  List<DateTime> selectedDates = [
    DateTime(2025, 4, 7),
    DateTime(2025, 4, 8),
    DateTime(2025, 4, 9),
    DateTime(2025, 4, 24),
  ];

 /* void _onTabTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/workout');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }
*/
  bool _isSelected(DateTime day) {
    return selectedDates.any((d) =>
        d.year == day.year && d.month == day.month && d.day == day.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 36, 34),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: today,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Color.fromARGB(255, 235, 94, 40),
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(color: Colors.white),
            defaultTextStyle: const TextStyle(color: Colors.grey),
            outsideTextStyle: const TextStyle(color: Colors.grey),
            weekendTextStyle: const TextStyle(color: Colors.grey),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: _isSelected,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              today = focusedDay;
            });
          },
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.grey),
            weekendStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavBar(currentIndex: 1)
    );
  }
}

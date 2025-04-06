import 'package:flutter/material.dart';
import 'events.dart'; // Import your EventsPage
import 'calander_page.dart'; // Import your CalendarPage

class TabbedEventsPage extends StatefulWidget {
  @override
  _TabbedEventsPageState createState() => _TabbedEventsPageState();
}

class _TabbedEventsPageState extends State<TabbedEventsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Two tabs
  }

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'אירועים',
          style: TextStyle(color: Colors.black),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          onTap: _changeTab, // Change tabs only via tapping
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.black54,
          tabs: [
            Tab(
              child: Text(
                'רשימת אירועים',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
            ),
            Tab(
              child: Text(
                'לוח שנה',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          EventsPage(), // Tab 1: Events list
          CalendarPage(), // Tab 2: Calendar
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:hanahala3/business_map.dart';
import 'package:hanahala3/businesses.dart';


class BusinessesTabbedPage extends StatefulWidget {
  @override
  _BusinessesTabbedPageState createState() => _BusinessesTabbedPageState();
}

class _BusinessesTabbedPageState extends State<BusinessesTabbedPage>
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
          'עסקים בשכונה',
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
                'רשימת עסקים',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
            ),
            Tab(
              child: Text(
                'מפת עסקים',
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
          BusinessesPage(), // Tab 1: Businesses list
          BusinessMapPage(), // Tab 2: Business map
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

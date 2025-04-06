import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'event_detail.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Map<DateTime, List<Map<String, dynamic>>> _events;
  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _events = {};
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('events').get();
      final eventMap = <DateTime, List<Map<String, dynamic>>>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final dateField = data['date'];

        if (dateField == null) continue;

        DateTime date;
        if (dateField is Timestamp) {
          date = dateField.toDate();
        } else if (dateField is String) {
          date = DateTime.tryParse(dateField) ?? DateTime.now();
        } else {
          continue;
        }

        final eventId = doc.id;
        final dateOnly = DateTime(date.year, date.month, date.day);
        eventMap[dateOnly] ??= [];
        eventMap[dateOnly]!.add({
          'id': eventId,
          'title': data['title'] ?? 'ללא כותרת',
          'date': date,
          'description': data['description'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'location': data['location'] ?? '',
        });
      }

      setState(() {
        _events = eventMap;
      });
    } catch (e) {
      print("Error loading events: $e");
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    return _events[dateOnly] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayEvents = _selectedDate != null ? _getEventsForDay(_selectedDate!) : [];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        body: Column(
          children: [
            TableCalendar(
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: _focusedDate,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              eventLoader: _getEventsForDay,
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: const Color.fromARGB(255, 44, 39, 182),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: const Color.fromARGB(255, 13, 49, 110),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: const Color.fromARGB(255, 113, 115, 233),
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDate = focusedDay;
                });
              },
            ),
            const Divider(),
            Expanded(
              child: selectedDayEvents.isEmpty
                  ? Center(
                      child: Text(
                        'אין אירועים בתאריך שנבחר',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        textAlign: TextAlign.right,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: selectedDayEvents.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final event = selectedDayEvents[index];
                        final eventDate = event['date'] as DateTime? ?? DateTime.now();

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetailPage(eventData: event),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                )
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Title
                                Text(
                                  event['title'] ?? 'ללא כותרת',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 8),
                                // Time Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


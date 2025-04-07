import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'event_detail.dart';

/// This widget displays a calendar and lists all the events for the selected day.
/// The user can tap on any day to view the events for that date.
class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // A map that holds the events grouped by their date (only date, no time)
  late Map<DateTime, List<Map<String, dynamic>>> _events;

  // The currently focused month/week in the calendar view
  DateTime _focusedDate = DateTime.now();

  // The specific date the user has selected (can be null initially)
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _events = {}; // Initialize empty map
    _loadEvents(); // Load events from Firestore
  }

  /// Loads events from Firestore and groups them by date
  Future<void> _loadEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('events').get();
      final eventMap = <DateTime, List<Map<String, dynamic>>>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final dateField = data['date'];

        // Skip events with no valid date
        if (dateField == null) continue;

        // Parse the date field (could be a Timestamp or String)
        DateTime date;
        if (dateField is Timestamp) {
          date = dateField.toDate();
        } else if (dateField is String) {
          date = DateTime.tryParse(dateField) ?? DateTime.now();
        } else {
          continue;
        }

        // Convert the date to a format without time (used as key)
        final dateOnly = DateTime(date.year, date.month, date.day);

        // Add the event to the list for that day
        eventMap[dateOnly] ??= [];
        eventMap[dateOnly]!.add({
          'id': doc.id,
          'title': data['title'] ?? 'ללא כותרת',
          'date': date,
          'description': data['description'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'location': data['location'] ?? '',
        });
      }

      // Update the state with the loaded events
      setState(() {
        _events = eventMap;
      });
    } catch (e) {
      print("Error loading events: $e");
    }
  }

  /// Returns the list of events for a given day
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    return _events[dateOnly] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // Get events for the currently selected day
    final selectedDayEvents = _selectedDate != null ? _getEventsForDay(_selectedDate!) : [];

    return Directionality(
      textDirection: TextDirection.rtl, // Makes everything RTL for Hebrew
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6), // Light gray background
        body: Column(
          children: [
            // The calendar widget
            TableCalendar(
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: _focusedDate,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              eventLoader: _getEventsForDay, // Show markers on dates with events
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
                  _selectedDate = selectedDay; // Update selected day
                  _focusedDate = focusedDay;   // Keep focus in sync
                });
              },
            ),

            const Divider(),

            // Show events of the selected day
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
                            // Navigate to event details page
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
                                // Event title
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

                                // Event time with clock icon
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

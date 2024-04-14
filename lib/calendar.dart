import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarBackend {
  late CalendarController _calendarController;

  CalendarBackend() {
    _calendarController = CalendarController();
    _loadSavedEvents();
  }

  CalendarController get calendarController => _calendarController;

  List<Meeting> getMeetingData() {
   return _dataSource?.appointments?? [];
  }

  late MeetingDataSource _dataSource;

  Future<void> _loadSavedEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEvents = prefs.getString('eventData');
    if (savedEvents!= null) {
      List<dynamic> eventData = jsonDecode(savedEvents) as List<dynamic>;
      List<Meeting> meetings = eventData.map((event) {
        if (event is Meeting) return event; // Only return if it's already a Meeting
        // Handle non-Meeting data here (optional)
        return Meeting(
          event['Name'],
          DateTime(
            int.parse(event['startTime'].split(', ')[0]),
            int.parse(event['startTime'].split(', ')[1]),
            int.parse(event['startTime'].split(', ')[2]),
            int.parse(event['startTime'].split(', ')[3]),
          ),
          DateTime(
            int.parse(event['endTime'].split(', ')[0]),
            int.parse(event['endTime'].split(', ')[1]),
            int.parse(event['endTime'].split(', ')[2]),
            int.parse(event['endTime'].split(', ')[3]),
          ),
          Color(int.parse(event['Color'])),
          event['AllDay'],
        );
      }).toList();

      _dataSource = MeetingDataSource(meetings);
    } else {
      _dataSource = MeetingDataSource(_getDataSource());
    }
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime = DateTime(today.year, today.month, today.day, 9);
    final DateTime endTime = startTime.add(const Duration(hours: 2));

    meetings.add(
      Meeting(
        'Conference',
        startTime,
        endTime,
        const Color(0xFF0F8644),
        false,
      ),
    );

    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }
    return meetingData;
  }
}

class Meeting {
  Meeting(
      this.eventName,
      this.from,
      this.to,
      this.background,
      this.isAllDay,
      );

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
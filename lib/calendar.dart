import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CalendarBackend {
  late CalendarController _calendarController;
  late MeetingDataSource _dataSource;

  CalendarBackend() {
    _calendarController = CalendarController();
    _dataSource = MeetingDataSource(_getDataSource());
    _loadSavedEvents();
  }

  CalendarController get calendarController => _calendarController;

  List<Meeting> getMeetingData() {
    if (_dataSource != null && _dataSource.appointments != null) {
      return _dataSource.appointments!.cast<Meeting>().toList();
    } else {
      return [];
    }
  }


  Future<void> _loadSavedEvents() async {
    String? jsonFilePath = 'http://127.0.0.1:5500/test/callendar.json'; // Ersetzen Sie durch den tatsächlichen Pfad zur JSON-Datei
    if (jsonFilePath != null) {
      List<Meeting> meetings = await _loadMeetingsFromJsonFile(jsonFilePath);
      _dataSource = MeetingDataSource(meetings);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedEvents = prefs.getString('eventData');
      if (savedEvents != null) {
        List<Map<String, dynamic>> eventData = (jsonDecode(savedEvents) as List<dynamic>)
            .map((event) => event as Map<String, dynamic>)
            .toList();
        List<Meeting> meetings = eventData.map((event) {
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
  }

  Future<List<Meeting>> _loadMeetingsFromJsonFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final jsonData = jsonDecode(response.body) as List<dynamic>;
      return jsonData.map((event) {
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
    } catch (e) {
      print('Error loading meetings from JSON file: $e');
      return [];
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

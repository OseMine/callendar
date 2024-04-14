import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarBackend {
  late CalendarController _calendarController;
  late MeetingDataSource _dataSource;

  CalendarBackend() {
    _calendarController = CalendarController();
    //_dataSource = MeetingDataSource(_getDataSource());

    _loadEventsFromLocalStorage();

  }

  Future<void> _loadEventsFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('eventData');
    final List<Meeting> meetings = <Meeting>[];


    if (jsonData != null) {
      Map<String, dynamic> eventData = jsonDecode(jsonData);

      String eventName = eventData['Name'];
      DateTime startTime = DateTime.parse(eventData['startTime']);
      DateTime endTime = DateTime.parse(eventData['endTime']);
      String type = eventData['Type'];
      Color color = Color(int.parse(eventData['Color'], radix: 16));
      bool isAllDay = eventData['AllDay'];
      meetings.add(
          Meeting(
              eventName,
              startTime,
              endTime,
              color,
              isAllDay
          )
      );
      List<Meeting> _getDataSource() {


        meetings.add(
          Meeting(
            eventName,
            startTime,
            endTime,
            const Color(0xFF0F8644),
            false,
          ),
        );
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

      Meeting meeting = Meeting(eventName, startTime, endTime, color, isAllDay);
      _dataSource.appointments?.add(meetings);
      _dataSource.notifyListeners(CalendarDataSourceAction.add, [meetings]);
      _dataSource = MeetingDataSource(_getDataSource());

    }
  }

  Future<void> _printEventData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('eventData');

    if (jsonData != null) {
      print('Gespeicherte Eventdaten:');
      Map<String, dynamic> eventData = jsonDecode(jsonData);

      print('Name: ${eventData['Name']}');
      print('Startzeit: ${eventData['startTime']}');
      print('Endzeit: ${eventData['endTime']}');
      print('Typ: ${eventData['Type']}');
      print('Farbe: ${eventData['Color']}');
      print('Ganztägig: ${eventData['AllDay']}');
    } else {
      print('Keine Eventdaten gefunden.');
    }
  }

  CalendarController get calendarController => _calendarController;


}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  List<Meeting>? get dataSource => appointments?.cast<Meeting>();
  set dataSource(List<Meeting>? source) {
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

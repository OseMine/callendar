import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'calendar.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'AddWidget.dart';

void main() {
  runApp(const CalendarApp());
}

class CalendarApp extends StatelessWidget {
  const CalendarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Calendar',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CalendarBackend _calendarBackend;
  late CalendarBackend _slidercalendarBackend;

  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _calendarBackend = CalendarBackend();
    _slidercalendarBackend = CalendarBackend();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _LoadAddEventWidget() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddEventWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double _initFabHeight = 120.0;
    double _fabHeight = 0;
    double _panelHeightOpen = 1000;
    double _panelHeightClosed = 80;
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Calendar'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SlidingUpPanel(
        maxHeight: _panelHeightOpen,
        minHeight: _panelHeightClosed,
        parallaxEnabled: true,
        parallaxOffset: .5,
        panel: Center(
          child: SfCalendar(
            view: CalendarView.day,
            controller: _slidercalendarBackend.calendarController,
            dataSource: MeetingDataSource(_calendarBackend.getMeetingData()),
          ),
        ),
        body: Center(
          child: SfCalendar(
            view: CalendarView.month,
            controller: _calendarBackend.calendarController,
            dataSource: MeetingDataSource(_calendarBackend.getMeetingData()),
            monthViewSettings: MonthViewSettings(showAgenda: true, agendaViewHeight: 500),
          ),
        ),
        borderRadius: radius,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _LoadAddEventWidget,
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}

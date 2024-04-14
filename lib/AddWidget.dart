import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddEventWidget extends StatefulWidget {
  @override
  _AddEventWidgetState createState() => _AddEventWidgetState();
}

class _AddEventWidgetState extends State<AddEventWidget> {
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);
  String _eventTitle = '';
  bool _isAllDay = false;

  String formatTime(DateTime date, TimeOfDay time) {
    return '${date.year}, ${date.month}, ${date.day}, ${time.hour}';
  }

  Future<void> _saveEventData(String jsonData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('eventData', jsonData);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Event Title',
            ),
            onChanged: (value) {
              setState(() {
                _eventTitle = value;
              });
            },
          ),
          SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                      });
                    }
                  },
                  child: Text('Start Date: ${_startDate.toString().split(' ')[0]}'),
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _startTime,
                    );
                    if (time != null) {
                      setState(() {
                        _startTime = time;
                      });
                    }
                  },
                  child: Text('Start Time: ${_startTime.format(context)}'),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                      });
                    }
                  },
                  child: Text('End Date: ${_endDate.toString().split(' ')[0]}'),
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _endTime,
                    );
                    if (time != null) {
                      setState(() {
                        _endTime = time;
                      });
                    }
                  },
                  child: Text('End Time: ${_endTime.format(context)}'),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            children: [
              Checkbox(
                value: _isAllDay,
                onChanged: (value) {
                  setState(() {
                    _isAllDay = value!;
                  });
                },
              ),
              Text('All Day'),
            ],
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              Map<String, dynamic> eventData = {
                'Name': _eventTitle,
                'startTime': formatTime(_startDate, _startTime),
                'endTime': formatTime(_endDate, _endTime),
                'Type': 'Conference',
                'Color': '0xFF0F8644',
                'AllDay': _isAllDay,
              };
              String jsonData = jsonEncode(eventData);
              await _saveEventData(jsonData); // Speichern der JSON-Daten im lokalen Gerätespeicher
              print(jsonData);
              Navigator.of(context).pop();
            },
            child: Text('Save Event'),
          ),
        ],
      ),
    );
  }
}

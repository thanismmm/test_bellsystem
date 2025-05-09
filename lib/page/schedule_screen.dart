import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:bell_system_test/new_test/datecard.dart';
import 'package:bell_system_test/new_test/schedule_provider.dart';
import 'package:bell_system_test/new_test/settings_dialog.dart';
import 'package:bell_system_test/new_test/time_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final List<String> _scheduleTypes = [
    'Regular',
    'Friday',
    'Exam/Special day',
    'Emergency',
  ];
  String? _selectedScheduleType = 'Regular';

  // Add enabled state lists for each schedule type
  late List<bool> _regularEnabled;
  late List<bool> _fridayEnabled;
  late List<bool> _examEnabled;

  @override
  void initState() {
    super.initState();
    // Initialize enabled lists
    _regularEnabled = List<bool>.filled(15, true);
    _fridayEnabled = List<bool>.filled(11, true);
    _examEnabled = List<bool>.filled(8, true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScheduleProvider>(context, listen: false)
          .fetchScheduleFromFirebase();
    });
  }

  List<bool> get _currentEnabledList {
    switch (_selectedScheduleType) {
      case 'Regular':
        return _regularEnabled;
      case 'Friday':
        return _fridayEnabled;
      case 'Exam/Special day':
        return _examEnabled;
      default:
        return [];
    }
  }

  void _toggleEnabled(int index, bool value) {
    setState(() {
      _currentEnabledList[index] = value;
    });
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    final currentTime = provider.getCurrentTime(_selectedScheduleType!, index);

    final picked = await showTimePicker(
      context: context,
       initialTime: currentTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      provider.updateTime(_selectedScheduleType!, index, picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Bell Schedule'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const SettingsDialog(),
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildScheduleTypeSelector(),
              Expanded(child: _buildScheduleContent()),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleTypeSelector() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<String>(
          value: _selectedScheduleType,
          decoration: const InputDecoration(
            labelText: 'Schedule Type',
            border: OutlineInputBorder(),
          ),
          items: _scheduleTypes
              .map(
                  (type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: (value) => setState(() => _selectedScheduleType = value),
        ),
      ),
    );
  }

  Widget _buildScheduleContent() {
    if (_selectedScheduleType == 'Emergency') {
      return _buildEmergencyContent();
    } else if (_selectedScheduleType == 'Regular') {
      return Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // School Ready Time
                TimeCard(
                  title: 'School Ready Time',
                  time: _regularEnabled[0]
                      ? provider.getCurrentTime(_selectedScheduleType!, 0)
                      : null,
                  enabled: _regularEnabled[0],
                  onTimeTap: () => _selectTime(context, 0),
                  onToggle: (value) {
                    _toggleEnabled(0, value);
                    provider.toggleTimeEnabled(_selectedScheduleType!, 0, value);
                  },
                ),
                // School Start Time
                TimeCard(
                  title: 'School Start Time',
                  time: _regularEnabled[1]
                      ? provider.getCurrentTime(_selectedScheduleType!, 1)
                      : null,
                  enabled: _regularEnabled[1],
                  onTimeTap: () => _selectTime(context, 1),
                  onToggle: (value) {
                    _toggleEnabled(1, value);
                    provider.toggleTimeEnabled(_selectedScheduleType!, 1, value);
                  },
                ),
                // Subjects 1-5
                ...List.generate(
                  5,
                  (index) => TimeCard(
                    title: 'Subject ${index + 1}',
                    time: _regularEnabled[2 + index]
                        ? provider.getCurrentTime(
                            _selectedScheduleType!, 2 + index)
                        : null,
                    enabled: _regularEnabled[2 + index],
                    onTimeTap: () => _selectTime(context, 2 + index),
                    onToggle: (value) {
                      _toggleEnabled(2 + index, value);
                      provider.toggleTimeEnabled(_selectedScheduleType!,2 + index, value);
                    },
                  ),
                ),
                // Interval Start time
                TimeCard(
                  title: 'Interval Start Time',
                  time: _regularEnabled[7]
                      ? provider.getCurrentTime(_selectedScheduleType!, 7)
                      : null,
                  enabled: _regularEnabled[7],
                  onTimeTap: () => _selectTime(context, 7),
                  onToggle: (value) {
                    _toggleEnabled(7, value);
                    provider.toggleTimeEnabled(_selectedScheduleType!, 7, value);
                  },
                ),
                // Interval Close Time
                TimeCard(
                  title: 'Interval Close Time',
                  time: _regularEnabled[8]
                      ? provider.getCurrentTime(_selectedScheduleType!, 8)
                      : null,
                  enabled: _regularEnabled[8],
                  onTimeTap: () => _selectTime(context, 8),
                  onToggle: (value) {
                    _toggleEnabled(8, value);
                    provider.toggleTimeEnabled(_selectedScheduleType!, 8, value);
                  },
                ),
                // Wastage Time
                TimeCard(
                  title: 'Wastage Time',
                  time: _regularEnabled[9]
                      ? provider.getCurrentTime(_selectedScheduleType!, 9)
                      : null,
                  enabled: _regularEnabled[9],
                  onTimeTap: () => _selectTime(context, 9),
                  onToggle: (value) {
                    _toggleEnabled(9, value);
                    provider.toggleTimeEnabled(_selectedScheduleType!, 9, value);
                  },
                ),
                // Subjects 6-9
                ...List.generate(
                  4,
                  (index) => TimeCard(
                    title: 'Subject ${index + 6}',
                    time: _regularEnabled[10 + index]
                        ? provider.getCurrentTime(
                            _selectedScheduleType!, 10 + index)
                        : null,
                    enabled: _regularEnabled[10 + index],
                    onTimeTap: () => _selectTime(context, 10 + index),
                    onToggle: (value) {
                      _toggleEnabled(10 + index, value);
                      provider.toggleTimeEnabled(_selectedScheduleType!,10 + index, value);
                    },
                  ),
                ),
                // School Over Time
                TimeCard(
                  title: 'School Over Time',
                  time: _regularEnabled[14]
                      ? provider.getCurrentTime(_selectedScheduleType!, 14)
                      : null,
                  enabled: _regularEnabled[14],
                  onTimeTap: () => _selectTime(context, 14),
                  onToggle: (value) {
                    _toggleEnabled(14, value);
                    provider.toggleTimeEnabled(_selectedScheduleType!, 14, value);
                  },
                ),
              ],
            ),
          );
        },
      );
    } else if (_selectedScheduleType == 'Friday') {
      return Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                TimeCard(
                  title: 'School Ready Time',
                  time: _fridayEnabled[0]
                      ? provider.getCurrentTime(_selectedScheduleType!, 0)
                      : null,
                  enabled: _fridayEnabled[0],
                  onTimeTap: () => _selectTime(context, 0),
                  onToggle: (value) {
                    _toggleEnabled(0, value);
                    provider.toggleTimeEnabled(_selectedScheduleType!, 0, value);
                  },
                ),
                TimeCard(
                  title: 'School Start Time',
                  time: _fridayEnabled[1]
                      ? provider.getCurrentTime(_selectedScheduleType!, 1)
                      : null,
                  enabled: _fridayEnabled[1],
                  onTimeTap: () => _selectTime(context, 1),
                  onToggle: (value) {
                    _toggleEnabled(1, value);
                    provider.toggleTimeEnabled(_selectedScheduleType!, 1, value);
                  },
                ),
                ...List.generate(
                  5,
                  (index) => TimeCard(
                    title: 'Subject ${index + 1}',
                    time: _fridayEnabled[2 + index]
                        ? provider.getCurrentTime(
                            _selectedScheduleType!, 2 + index)
                        : null,
                    enabled: _fridayEnabled[2 + index],
                    onTimeTap: () => _selectTime(context, 2 + index),
                    onToggle: (value) {
                      _toggleEnabled(2 + index, value);
                      provider.toggleTimeEnabled(_selectedScheduleType!, 2 + index, value);
                    },
                  ),
                ),
                TimeCard(
                  title: 'Interval Start Time',
                  time: _fridayEnabled[7]
                      ? provider.getCurrentTime(_selectedScheduleType!, 7)
                      : null,
                  enabled: _fridayEnabled[7],
                  onTimeTap: () => _selectTime(context, 7),
                  onToggle: (value) {
                    _toggleEnabled(7, value);
                    provider.toggleTimeEnabled(_selectedScheduleType!, 7, value);
                  },
                ),
                TimeCard(
                  title: 'Interval Close Time',
                  time: _fridayEnabled[8]
                      ? provider.getCurrentTime(_selectedScheduleType!, 8)
                      : null,
                  enabled: _fridayEnabled[8],
                  onTimeTap: () => _selectTime(context, 8),
                  onToggle: (value) {
                    _toggleEnabled(8, value);
                    provider.toggleTimeEnabled(_selectedScheduleType!, 8, value);
                  },
                ),
                TimeCard(
                  title: 'Wastage Time',
                  time: _fridayEnabled[9]
                      ? provider.getCurrentTime(_selectedScheduleType!, 9)
                      : null,
                  enabled: _fridayEnabled[9],
                  onTimeTap: () => _selectTime(context, 9),
                  onToggle: (value) {
                    _toggleEnabled(9, value);
                    provider.toggleTimeEnabled(_selectedScheduleType!, 9, value);
                  },
                ),
                TimeCard(
                  title: 'School Over Time',
                  time: _fridayEnabled[10]
                      ? provider.getCurrentTime(_selectedScheduleType!, 10)
                      : null,
                  enabled: _fridayEnabled[10],
                  onTimeTap: () => _selectTime(context, 10),
                  onToggle: (value) {
                    _toggleEnabled(10, value);
                    provider.toggleTimeEnabled(_selectedScheduleType!, 10, value);
                  },
                ),
              ],
            ),
          );
        },
      );
    } else if (_selectedScheduleType == 'Exam/Special day') {
      return Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          while (provider.examDates.length < 5) {
            provider.examDates.add(DateTime.now());
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Week End Schedule",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                ...List.generate(
                  5,
                  (index) => DateCard(
                    title: 'Weekend ${index + 1} Date',
                    date: index < provider.examDates.length
                        ? provider.examDates[index]
                        : DateTime.now(),
                    onDateSelected: (date) {
                      provider.updateExamDate(index, date);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Exam Schedule",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                TimeCard(
                  title: 'Exam Start Time',
                  time: _examEnabled[0]
                      ? provider.getCurrentTime(_selectedScheduleType!, 0)
                      : null,
                  enabled: _examEnabled[0],
                  onTimeTap: () => _selectTime(context, 0),
                  onToggle: (value) {
                    _toggleEnabled(0, value);
                    provider.toggleTimeEnabled(_selectedScheduleType!, 0, value);
                  },
                ),
                TimeCard(
                  title: 'Register mark Time',
                  time: _examEnabled[1]
                      ? provider.getCurrentTime(_selectedScheduleType!, 1)
                      : null,
                  enabled: _examEnabled[1],
                  onTimeTap: () => _selectTime(context, 1),
                  onToggle: (value) {
                    _toggleEnabled(1, value);
                    provider.toggleTimeEnabled(_selectedScheduleType!, 1, value);
                  },
                ),
                ...List.generate(
                  5,
                  (index) => TimeCard(
                    title: 'Exam ${index + 1}',
                    time: _examEnabled[2 + index]
                        ? provider.getCurrentTime(
                            _selectedScheduleType!, 2 + index)
                        : null,
                    enabled: _examEnabled[2 + index],
                    onTimeTap: () => _selectTime(context, 2 + index),
                    onToggle: (value) {
                      _toggleEnabled(2 + index, value);
                      provider.toggleTimeEnabled(_selectedScheduleType!, 2 + index, value);
                    },
                  ),
                ),
                TimeCard(
                  title: 'Exam Over Time',
                  time: _examEnabled[7]
                      ? provider.getCurrentTime(_selectedScheduleType!, 7)
                      : null,
                  enabled: _examEnabled[7],
                  onTimeTap: () => _selectTime(context, 7),
                  onToggle: (value) {
                    _toggleEnabled(7, value);
                    provider.toggleTimeEnabled(_selectedScheduleType!, 7, value);
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      return AlertDialog(
        title: const Text('Invalid Selection'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: [Text('Please Select a Valid Selection')],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Approve'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }
  }

  Widget _buildEmergencyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, size: 64, color: Colors.orange),
          const SizedBox(height: 20),
          Text(
            'Emergency Mode Active',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'All schedules are overridden',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          Consumer<ScheduleProvider>(
            builder: (context, provider, child) {
              return SwitchListTile(
                title: const Text('Emergency Ring'),
                value: provider.emergencyRing,
                onChanged: (value) {
                  provider.toggleEmergencyRing(value);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: provider.isUpdating
                ? null
                : () async {
                    await provider.saveScheduleToFirebase();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Schedule Updated Successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
            child: provider.isUpdating
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'UPDATE SCHEDULE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

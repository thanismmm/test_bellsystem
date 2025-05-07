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
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final List<String> _scheduleTypes = [
    'Regular',
    'Friday',
    'Exam/Special day',
    'Emergency',
  ];
  String? _selectedScheduleType = 'Regular';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScheduleProvider>(
        context,
        listen: false,
      ).fetchScheduleFromFirebase();
    });
  }

  Future _selectTime(BuildContext context, int index) async {
  final provider = Provider.of<ScheduleProvider>(context, listen: false);
  final currentTime = provider.getCurrentTime(_selectedScheduleType!, index);
  final picked = await showTimePicker(
    context: context,
    initialTime: currentTime,
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
            onPressed:
                () => showDialog(
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
          items:
              _scheduleTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
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
                // 1st - Start Time
                TimeCard(
                  title: 'School Start Time',
                  time: provider.getCurrentTime(_selectedScheduleType!, 0),
                  onTimeTap: () => _selectTime(context, 0),
                ),

                // 2nd - Register mark Time
                TimeCard(
                  title: 'Register mark Time',
                  time: provider.getCurrentTime(_selectedScheduleType!, 1),
                  onTimeTap: () => _selectTime(context, 1),
                ),

                // 3rd - Register mark Close Time
                TimeCard(
                  title: 'Register mark Close Time',
                  time: provider.getCurrentTime(_selectedScheduleType!, 2),
                  onTimeTap: () => _selectTime(context, 2),
                ),

                // Subjects 1-5
                ...List.generate(
                  5,
                  (index) => TimeCard(
                    title: 'Subject ${index + 1}',
                    time: provider.getCurrentTime(
                      _selectedScheduleType!,
                      3 + index,
                    ),
                    onTimeTap: () => _selectTime(context, 3 + index),
                  ),
                ),

                // Interval Start time
                TimeCard(
                  title: 'Interval Start Time',
                  time: provider.getCurrentTime(_selectedScheduleType!, 8),
                  onTimeTap: () => _selectTime(context, 8),
                ),

                // Interval Close Time
                TimeCard(
                  title: 'Interval Close Time',
                  time: provider.getCurrentTime(_selectedScheduleType!, 9),
                  onTimeTap: () => _selectTime(context, 9),
                ),

                // Subjects 6-9
                ...List.generate(
                  4,
                  (index) => TimeCard(
                    title: 'Subject ${index + 6}',
                    time: provider.getCurrentTime(
                      _selectedScheduleType!,
                      10 + index,
                    ),
                    onTimeTap: () => _selectTime(context, 10 + index),
                  ),
                ),

                // School Over Time
                TimeCard(
                  title: 'School Over Time',
                  time: provider.getCurrentTime(_selectedScheduleType!, 14),
                  onTimeTap: () => _selectTime(context, 14),
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
                // 1st - Start Time
                TimeCard(
                  title: 'School Start Time',
                  time: provider.getCurrentTime(_selectedScheduleType!, 0),
                  onTimeTap: () => _selectTime(context, 0),
                ),

                // 2nd - Register mark Time
                TimeCard(
                  title: 'Register mark Time',
                  time: provider.getCurrentTime(_selectedScheduleType!, 1),
                  onTimeTap: () => _selectTime(context, 1),
                ),

                // 3rd - Register mark Close Time
                TimeCard(
                  title: 'Register mark Close Time',
                  time: provider.getCurrentTime(_selectedScheduleType!, 2),
                  onTimeTap: () => _selectTime(context, 2),
                ),

                // Subjects 1-5
                ...List.generate(
                  5,
                  (index) => TimeCard(
                    title: 'Subject ${index + 1}',
                    time: provider.getCurrentTime(
                      _selectedScheduleType!,
                      3 + index,
                    ),
                    onTimeTap: () => _selectTime(context, 3 + index),
                  ),
                ),

                // Interval Start time
                TimeCard(
                  title: 'Interval Start Time',
                  time: provider.getCurrentTime(_selectedScheduleType!, 8),
                  onTimeTap: () => _selectTime(context, 8),
                ),

                // Interval Close Time
                TimeCard(
                  title: 'Interval Close Time',
                  time: provider.getCurrentTime(_selectedScheduleType!, 9),
                  onTimeTap: () => _selectTime(context, 9),
                ),

                // School Over Time
                TimeCard(
                  title: 'School Over Time',
                  time: provider.getCurrentTime(_selectedScheduleType!, 10),
                  onTimeTap: () => _selectTime(context, 10),
                ),
              ],
            ),
          );
        },
      );
    } else if (_selectedScheduleType == 'Exam/Special day') {
  return Consumer<ScheduleProvider>(
    builder: (context, provider, child) {
      // Make sure we have at least 5 dates
      while (provider.examDates.length < 5) {
        provider.examDates.add(DateTime.now());
      }
          return SingleChildScrollView(
            child: Column(
              children: [

                Text("Week End Schedule", style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),),

                  
                //SS Day Day Selection and Schedule 
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
            Text("Exam Schedule", style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),),

                  const SizedBox(height: 10),

                // 1st - Start Time
                TimeCard(
                  title: 'Exam Start Time',
                  time: provider.getCurrentTime(_selectedScheduleType!, 0),
                  onTimeTap: () => _selectTime(context, 0),
                ),

                // 2nd - Register mark Time
                TimeCard(
                  title: 'Register mark Time',
                  time: provider.getCurrentTime(_selectedScheduleType!, 1),
                  onTimeTap: () => _selectTime(context, 1),
                ),

                // Exams 1-5
                ...List.generate(
                  5,
                  (index) => TimeCard(
                    title: 'Exam ${index + 1}',
                    time: provider.getCurrentTime(
                      _selectedScheduleType!,
                      2 + index,
                    ),
                    onTimeTap: () => _selectTime(context, 2 + index),
                  ),
                ),

                // School Over Time
                TimeCard(
                  title: 'Exam Over Time',
                  time: provider.getCurrentTime(_selectedScheduleType!, 7),
                  onTimeTap: () => _selectTime(context, 7),
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
            children: <Widget>[
              Text('Please Select an Valid Selection'),
            
            ],
          ),
        ),
        actions: <Widget>[
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
            onPressed:
                provider.isUpdating
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
            child:
                provider.isUpdating
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

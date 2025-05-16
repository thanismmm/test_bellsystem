import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bell_system_test/new_test/datecard.dart';
import 'package:bell_system_test/new_test/schedule_provider.dart';
import 'package:bell_system_test/new_test/settings_dialog.dart';
import 'package:bell_system_test/new_test/time_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _titlesLoaded = false;

  final List<String> _scheduleTypes = [
    'Regular',
    'Friday',
    'Exam/Special day',
    'Emergency',
  ];
  String? _selectedScheduleType = 'Regular';

  late List<bool> _regularEnabled;
  late List<bool> _fridayEnabled;
  late List<bool> _examEnabled;
  late List<String> _regularTitles;
  late List<String> _fridayTitles;
  late List<String> _examTitles;

  List<String> get _currentTitleList {
    switch (_selectedScheduleType) {
      case 'Regular':
        return _regularTitles;
      case 'Friday':
        return _fridayTitles;
      case 'Exam/Special day':
        return _examTitles;
      default:
        return [];
    }
  }

  void _syncEnabledLists(ScheduleProvider provider) {
  for (int i = 0; i < _regularEnabled.length; i++) {
    _regularEnabled[i] = provider.isEnabled('Regular', i);
  }
  for (int i = 0; i < _fridayEnabled.length; i++) {
    _fridayEnabled[i] = provider.isEnabled('Friday', i);
  }
  for (int i = 0; i < _examEnabled.length; i++) {
    _examEnabled[i] = provider.isEnabled('Exam/Special day', i);
  }
}


  @override
  void initState() {
    super.initState();
    _loadTitles();

    // Initialize enabled lists
    _regularEnabled = List<bool>.filled(20, true);
    _fridayEnabled = List<bool>.filled(20, true);
    _examEnabled = List<bool>.filled(8, true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScheduleProvider>(
        context,
        listen: false,
      ).fetchScheduleFromFirebase();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    await provider.fetchScheduleFromFirebase();
    setState(() {
      _syncEnabledLists(provider);
    });
  });
}
  

  Future<void> _loadTitles() async {
    final prefs = await SharedPreferences.getInstance();
    _regularTitles =
        prefs.getStringList('regularTitles') ??
        [
          'School Ready Time',
          'School Start Time',
          'Subject 1',
          'Subject 2',
          'Subject 3',
          'Subject 4',
          'Subject 5',
          'Interval Start Time',
          'Interval Close Time',
          'Wastage Time',
          'Subject 6',
          'Subject 7',
          'Subject 8',
          'Subject 9',
          'Subject 10',
          'Subject 11',
          'Subject 12',
          'Subject 13',
          'Subject 14',
          'School Over Time',
        ];
    _fridayTitles =
        prefs.getStringList('fridayTitles') ??
        [
          'School Ready Time',
          'School Start Time',
          'Subject 1',
          'Subject 2',
          'Subject 3',
          'Subject 4',
          'Subject 5',
          'Interval Start Time',
          'Interval Close Time',
          'Wastage Time',
          'Subject 6',
          'Subject 7',
          'Subject 8',
          'Subject 9',
          'Subject 10',
          'Subject 11',
          'Subject 12',
          'Subject 13',
          'Subject 14',
          'School Over Time',
        ];
    if (_fridayTitles.length < 20) {
      _fridayTitles.addAll(
        List.generate(
          20 - _fridayTitles.length,
          (i) => 'Subject ${_fridayTitles.length + i + 1}',
        ),
      );
    }
    _examTitles =
        prefs.getStringList('examTitles') ??
        [
          'Exam Start Time',
          'Register mark Time',
          'Exam 1',
          'Exam 2',
          'Exam 3',
          'Exam 4',
          'Exam 5',
          'Exam Over Time',
        ];
    setState(() {
      _titlesLoaded = true;
    }); // Refresh UI after loading
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

  Future<void> _saveTitles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('regularTitles', _regularTitles);
    await prefs.setStringList('fridayTitles', _fridayTitles);
    await prefs.setStringList('examTitles', _examTitles);
  }

  Future<void> _showEditTitleDialog(BuildContext context, int index) async {
    final currentList = _currentTitleList;
    final controller = TextEditingController(text: currentList[index]);
    final newTitle = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Title'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(controller.text),
                child: const Text('Save'),
              ),
            ],
          ),
    );
    if (newTitle != null && newTitle.trim().isNotEmpty) {
      setState(() {
        currentList[index] = newTitle.trim();
      });
      await _saveTitles(); // <-- Save to persistent storage
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_titlesLoaded) {
      // Show loading spinner while titles are loading
      return const Center(child: CircularProgressIndicator());
    }
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
                // School Ready Time
                // TimeCard(
                //   title: _currentTitleList[0],
                //   time:
                //       _regularEnabled[0]
                //           ? provider.getCurrentTime(_selectedScheduleType!, 0)
                //           : null,
                //   enabled: _regularEnabled[0],
                //   onTimeTap: () => _selectTime(context, 0),
                //   onToggle: (value) {
                //     _toggleEnabled(0, value);
                //     provider.toggleTimeEnabled(
                //       _selectedScheduleType!,
                //       0,
                //       value,
                //     );
                //   },
                //   onEditTitle: () => _showEditTitleDialog(context, 0),
                // ),
                // // School Start Time
                // TimeCard(
                //   title: _currentTitleList[1],
                //   time:
                //       _regularEnabled[1]
                //           ? provider.getCurrentTime(_selectedScheduleType!, 1)
                //           : null,
                //   enabled: _regularEnabled[1],
                //   onTimeTap: () => _selectTime(context, 1),
                //   onToggle: (value) {
                //     _toggleEnabled(1, value);
                //     provider.toggleTimeEnabled(
                //       _selectedScheduleType!,
                //       1,
                //       value,
                //     );
                //   },
                //   onEditTitle: () => _showEditTitleDialog(context, 1),
                // ),
                // // Subjects 1-5
                // ...List.generate(
                //   5,
                //   (index) => TimeCard(
                //     title: _currentTitleList[2 + index],
                //     time:
                //         _regularEnabled[2 + index]
                //             ? provider.getCurrentTime(
                //               _selectedScheduleType!,
                //               2 + index,
                //             )
                //             : null,
                //     enabled: _regularEnabled[2 + index],
                //     onTimeTap: () => _selectTime(context, 2 + index),
                //     onToggle: (value) {
                //       _toggleEnabled(2 + index, value);
                //       provider.toggleTimeEnabled(
                //         _selectedScheduleType!,
                //         2 + index,
                //         value,
                //       );
                //     },
                //     onEditTitle: () => _showEditTitleDialog(context, 2 + index),
                //   ),
                // ),
                // // Interval Start time
                // TimeCard(
                //   title: _currentTitleList[7],
                //   time:
                //       _regularEnabled[7]
                //           ? provider.getCurrentTime(_selectedScheduleType!, 7)
                //           : null,
                //   enabled: _regularEnabled[7],
                //   onTimeTap: () => _selectTime(context, 7),
                //   onToggle: (value) {
                //     _toggleEnabled(7, value);
                //     provider.toggleTimeEnabled(
                //       _selectedScheduleType!,
                //       7,
                //       value,
                //     );
                //   },
                //   onEditTitle: () => _showEditTitleDialog(context, 7),
                // ),
                // // Interval Close Time
                // TimeCard(
                //   title: _currentTitleList[8],
                //   time:
                //       _regularEnabled[8]
                //           ? provider.getCurrentTime(_selectedScheduleType!, 8)
                //           : null,
                //   enabled: _regularEnabled[8],
                //   onTimeTap: () => _selectTime(context, 8),
                //   onToggle: (value) {
                //     _toggleEnabled(8, value);
                //     provider.toggleTimeEnabled(
                //       _selectedScheduleType!,
                //       8,
                //       value,
                //     );
                //   },
                //   onEditTitle: () => _showEditTitleDialog(context, 8),
                // ),
                // // Wastage Time
                // TimeCard(
                //   title: _currentTitleList[9],
                //   time:
                //       _regularEnabled[9]
                //           ? provider.getCurrentTime(_selectedScheduleType!, 9)
                //           : null,
                //   enabled: _regularEnabled[9],
                //   onTimeTap: () => _selectTime(context, 9),
                //   onToggle: (value) {
                //     _toggleEnabled(9, value);
                //     provider.toggleTimeEnabled(
                //       _selectedScheduleType!,
                //       9,
                //       value,
                //     );
                //   },
                //   onEditTitle: () => _showEditTitleDialog(context, 9),
                // ),
                // // Subjects 6-9
                // ...List.generate(
                //   4,
                //   (index) => TimeCard(
                //     title: _currentTitleList[15 + index],
                //     time:
                //         _regularEnabled[15 + index]
                //             ? provider.getCurrentTime(
                //               _selectedScheduleType!,
                //               15 + index,
                //             )
                //             : null,
                //     enabled: _regularEnabled[15 + index],
                //     onTimeTap: () => _selectTime(context, 15 + index),
                //     onToggle: (value) {
                //       _toggleEnabled(10 + index, value);
                //       provider.toggleTimeEnabled(
                //         _selectedScheduleType!,
                //         15 + index,
                //         value,
                //       );
                //     },
                //     onEditTitle:
                //         () => _showEditTitleDialog(context, 15 + index),
                //   ),
                // ),
                // // School Over Time
                // TimeCard(
                //   title: _currentTitleList[14],
                //   time:
                //       _regularEnabled[14]
                //           ? provider.getCurrentTime(_selectedScheduleType!, 14)
                //           : null,
                //   enabled: _regularEnabled[14],
                //   onTimeTap: () => _selectTime(context, 14),
                //   onToggle: (value) {
                //     _toggleEnabled(14, value);
                //     provider.toggleTimeEnabled(
                //       _selectedScheduleType!,
                //       14,
                //       value,
                //     );
                //   },
                //   onEditTitle: () => _showEditTitleDialog(context, 14),
                // ),
                ...List.generate(
                  _regularTitles.length,
                  (index) => TimeCard(
                    title: _currentTitleList[index],
                    time:
                        _regularEnabled[index]
                            ? provider.getCurrentTime(
                              _selectedScheduleType!,
                              index,
                            )
                            : null,
                    enabled: _regularEnabled[index],
                    onTimeTap: () => _selectTime(context, index),
                    onToggle: (value) {
                      _toggleEnabled(index, value);
                      provider.toggleTimeEnabled(
                        _selectedScheduleType!,
                        index,
                        value,
                      );
                    },
                    onEditTitle: () => _showEditTitleDialog(context, index),
                  ),
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
              children: List.generate(
                _fridayTitles.length,
                (index) => TimeCard(
                  title: _currentTitleList[index],
                  time:
                      _fridayEnabled[index]
                          ? provider.getCurrentTime(
                            _selectedScheduleType!,
                            index,
                          )
                          : null,
                  enabled: _fridayEnabled[index],
                  onTimeTap: () => _selectTime(context, index),
                  onToggle: (value) {
                    _toggleEnabled(index, value);
                    provider.toggleTimeEnabled(
                      _selectedScheduleType!,
                      index,
                      value,
                    );
                  },
                  onEditTitle: () => _showEditTitleDialog(context, index),
                ),
              ),
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
                    date:
                        index < provider.examDates.length
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
                  title: _currentTitleList[0],
                  time:
                      _examEnabled[0]
                          ? provider.getCurrentTime(_selectedScheduleType!, 0)
                          : null,
                  enabled: _examEnabled[0],
                  onTimeTap: () => _selectTime(context, 0),
                  onToggle: (value) {
                    _toggleEnabled(0, value);
                    provider.toggleTimeEnabled(
                      _selectedScheduleType!,
                      0,
                      value,
                    );
                  },
                  onEditTitle: () => _showEditTitleDialog(context, 0),
                ),
                TimeCard(
                  title: _currentTitleList[1],
                  time:
                      _examEnabled[1]
                          ? provider.getCurrentTime(_selectedScheduleType!, 1)
                          : null,
                  enabled: _examEnabled[1],
                  onTimeTap: () => _selectTime(context, 1),
                  onToggle: (value) {
                    _toggleEnabled(1, value);
                    provider.toggleTimeEnabled(
                      _selectedScheduleType!,
                      1,
                      value,
                    );
                  },
                  onEditTitle: () => _showEditTitleDialog(context, 1),
                ),
                ...List.generate(
                  5,
                  (index) => TimeCard(
                    title: _currentTitleList[2 + index],
                    time:
                        _examEnabled[2 + index]
                            ? provider.getCurrentTime(
                              _selectedScheduleType!,
                              2 + index,
                            )
                            : null,
                    enabled: _examEnabled[2 + index],
                    onTimeTap: () => _selectTime(context, 2 + index),
                    onToggle: (value) {
                      _toggleEnabled(2 + index, value);
                      provider.toggleTimeEnabled(
                        _selectedScheduleType!,
                        2 + index,
                        value,
                      );
                    },
                    onEditTitle: () => _showEditTitleDialog(context, 2 + index),
                  ),
                ),
                TimeCard(
                  title: _currentTitleList[7],
                  time:
                      _examEnabled[7]
                          ? provider.getCurrentTime(_selectedScheduleType!, 7)
                          : null,
                  enabled: _examEnabled[7],
                  onTimeTap: () => _selectTime(context, 7),
                  onToggle: (value) {
                    _toggleEnabled(7, value);
                    provider.toggleTimeEnabled(
                      _selectedScheduleType!,
                      7,
                      value,
                    );
                  },
                  onEditTitle: () => _showEditTitleDialog(context, 7),
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
          child: ListBody(children: [Text('Please Select a Valid Selection')]),
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

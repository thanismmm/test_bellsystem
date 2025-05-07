import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ScheduleUpdate extends StatefulWidget {
  const ScheduleUpdate({super.key});

  @override
  ScheduleUpdateState createState() => ScheduleUpdateState();
}

class ScheduleUpdateState extends State<ScheduleUpdate> {
  final List<String> _scheduleTypes = ['Regular', 'Friday', 'Exam', 'Emergency'];
  final List<String> _bellDurations = ['Short term Bell', 'Long term Bell'];
  final List<String> _bellTypes = ['Voice bell', 'Ring Bell'];
  
  String? _selectedScheduleType;
  bool _isUpdating = false;
  bool _showFridaySchedule = false;

  // Default durations
  int _shortTermDuration = 10;
  int _longTermDuration = 20;

  // Time management
  final Map<String, TimeOfDay> _times = {
    'start': TimeOfDay.now(),
    'registerMarkStart': TimeOfDay.now(),
    'registerMarkClose': TimeOfDay.now(),
    'interval': TimeOfDay.now(),
    'intervalClose': TimeOfDay.now(),
    'over': TimeOfDay.now(),
  };

  final List<TimeOfDay> _subjectTimes = List.generate(9, (_) => TimeOfDay.now());

  // Bell settings management
  final Map<String, Map<String, dynamic>> _bellSettings = {
    'start': {'duration': 'Short term Bell', 'type': 'Ring Bell'},
    'registerMarkStart': {'duration': 'Short term Bell', 'type': 'Ring Bell'},
    'registerMarkClose': {'duration': 'Short term Bell', 'type': 'Ring Bell'},
    'interval': {'duration': 'Short term Bell', 'type': 'Ring Bell'},
    'intervalClose': {'duration': 'Short term Bell', 'type': 'Ring Bell'},
    'over': {'duration': 'Short term Bell', 'type': 'Ring Bell'},
  };

  final List<Map<String, dynamic>> _subjectBellSettings = 
    List.generate(9, (_) => {'duration': 'Short term Bell', 'type': 'Ring Bell'});

  @override
  void initState() {
    super.initState();
    _fetchScheduleFromFirebase();
    _loadDurationSettings();
  }

  Future<void> _loadDurationSettings() async {
    // You can load saved duration settings from SharedPreferences or Firestore here
    // For now using defaults
  }

  Future<void> _fetchScheduleFromFirebase() async {
    try {
      final docName = _showFridaySchedule ? 'friday' : 'scheduleUpdate';
      final snapshot = await FirebaseFirestore.instance
          .collection('scheduleUpdate')
          .doc(docName)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          _selectedScheduleType = data['type'];
          _updateTimeFromData(data, 'start', 'startTime');
          _updateTimeFromData(data, 'interval', 'intervalTime');
          _updateTimeFromData(data, 'intervalClose', 'intervalCloseTime'); 
          
          if (!_showFridaySchedule) {
            _updateTimeFromData(data, 'over', 'overTime');
          }
          
          _updateTimeFromData(data, 'registerMarkStart', 'Register_mark_start_time');
          _updateTimeFromData(data, 'registerMarkClose', 'Register_mark_close_time');

          int subjectCount = _showFridaySchedule ? 4 : 9;
          for (int i = 0; i < subjectCount; i++) {
            _subjectTimes[i] = _parseTime(data['subject${i + 1}'] ?? '08:00');
            _subjectBellSettings[i] = {
              'duration': data['subject${i + 1}Duration'] ?? 'Short term Bell',
              'type': data['subject${i + 1}BellType'] ?? 'Ring Bell',
            };
          }

          _updateBellSettingsFromData(data, 'start', 'startTime');
          _updateBellSettingsFromData(data, 'interval', 'intervalTime');
          _updateBellSettingsFromData(data, 'intervalClose', 'intervalCloseTime');
          
          if (!_showFridaySchedule) {
            _updateBellSettingsFromData(data, 'over', 'overTime');
          }
          
          _updateBellSettingsFromData(data, 'registerMarkStart', 'Register_mark_start_time');
          _updateBellSettingsFromData(data, 'registerMarkClose', 'Register_mark_close_time');
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error loading schedule: $e');
    }
  }

  void _updateTimeFromData(Map<String, dynamic> data, String key, String field) {
    _times[key] = _parseTime(data[field] ?? '08:00');
  }

  void _updateBellSettingsFromData(Map<String, dynamic> data, String key, String prefix) {
    _bellSettings[key] = {
      'duration': data['${prefix}Duration'] ?? 'Short term Bell',
      'type': data['${prefix}BellType'] ?? 'Ring Bell',
    };
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _selectTime(BuildContext context, String timeKey) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[timeKey]!,
    );
    if (picked != null) {
      setState(() => _times[timeKey] = picked);
    }
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Confirm ${_showFridaySchedule ? 'Friday' : ''} Schedule Update'),
        content: Text('Are you sure want to save this ${_showFridaySchedule ? 'Friday ' : ''}schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveScheduleToFirebase();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveScheduleToFirebase() async {    
    setState(() => _isUpdating = true);
    
    try {
      final docName = _showFridaySchedule ? 'friday' : 'scheduleUpdate';
      final scheduleData = {
        'type': _selectedScheduleType,
        'lastUpdated': FieldValue.serverTimestamp(),
        ..._createTimeData('start', 'startTime'),
        ..._createTimeData('interval', 'intervalTime'),
        ..._createTimeData('intervalClose', 'intervalCloseTime'),
        ..._createTimeData('registerMarkStart', 'Register_mark_start_time'),
        ..._createTimeData('registerMarkClose', 'Register_mark_close_time'),
      };

      if (!_showFridaySchedule) {
        scheduleData.addAll(_createTimeData('over', 'overTime'));
      }

      int subjectCount = _showFridaySchedule ? 4 : 9;
      for (int i = 0; i < subjectCount; i++) {
        scheduleData.addAll({
          'subject${i + 1}': _formatTime(_subjectTimes[i]),
          'subject${i + 1}Duration': _subjectBellSettings[i]['duration'],
          'subject${i + 1}BellType': _subjectBellSettings[i]['type'],
        });
      }

      await FirebaseFirestore.instance
          .collection('scheduleUpdate')
          .doc(docName)
          .set(scheduleData, SetOptions(merge: true));

      _showSuccessSnackBar('${_showFridaySchedule ? 'Friday ' : ''}Schedule Updated Successfully!');
    } catch (e) {
      _showErrorSnackBar('Error updating schedule: $e');
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Map<String, dynamic> _createTimeData(String key, String fieldPrefix) {
    return {
      fieldPrefix: _formatTime(_times[key]!),
      '${fieldPrefix}Duration': _bellSettings[key]!['duration'],
      '${fieldPrefix}BellType': _bellSettings[key]!['type'],
    };
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  Future<void> _showBellSettingsDialog(Map<String, dynamic> settings, String title) async {
    String duration = settings['duration']!;
    String type = settings['type']!;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('$title Bell Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BellDropdown(
                  value: duration,
                  items: _bellDurations,
                  label: 'Bell Duration',
                  onChanged: (v) => setState(() => duration = v!),
                ),
                const SizedBox(height: 16),
                _BellDropdown(
                  value: type,
                  items: _bellTypes,
                  label: 'Bell Type',
                  onChanged: (v) => setState(() => type = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  settings
                    ..['duration'] = duration
                    ..['type'] = type;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDurationSettingsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Default Bell Durations'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _shortTermDuration.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Short term duration (seconds)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (text) {
                    final seconds = int.tryParse(text) ?? 10;
                    setState(() => _shortTermDuration = seconds.clamp(1, 60));
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _longTermDuration.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Long term duration (seconds)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (text) {
                    final seconds = int.tryParse(text) ?? 20;
                    setState(() => _longTermDuration = seconds.clamp(1, 60));
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTypeCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue[100]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Text(
                  'SCHEDULE TYPE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: _showDurationSettingsDialog,
                  tooltip: 'Bell Duration Settings',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ScheduleTypeDropdown(
              value: _selectedScheduleType,
              items: _scheduleTypes,
              onChanged: (v) {
                setState(() {
                  _selectedScheduleType = v;
                  _showFridaySchedule = v == 'Friday';
                });
                _fetchScheduleFromFirebase();
              },
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard({
    required String title,
    required String timeKey,
    required Map<String, dynamic> bellSettings,
    bool isSubject = false,
    int? subjectIndex,
  }) {
    final duration = bellSettings['duration'] == 'Short term Bell' 
        ? _shortTermDuration 
        : _longTermDuration;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue[100]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showBellSettingsDialog(bellSettings, title),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${bellSettings['duration']} • ${bellSettings['type']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TimeDisplay(time: _times[timeKey]!),
                  const SizedBox(height: 4),
                  Text(
                    '$duration sec',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.access_time, color: Colors.blue[700]),
                onPressed: () => _selectTime(context, timeKey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleContent() {
    if (_showFridaySchedule) {
      return Column(
        children: [
          _buildTimeCard(
            title: 'Start Time',
            timeKey: 'start',
            bellSettings: _bellSettings['start']!,
          ),
          _buildTimeCard(
            title: 'Register Mark Start Time',
            timeKey: 'registerMarkStart',
            bellSettings: _bellSettings['registerMarkStart']!,
          ),
          _buildTimeCard(
            title: 'Register Mark Close Time',
            timeKey: 'registerMarkClose',
            bellSettings: _bellSettings['registerMarkClose']!,
          ),
          for (int i = 0; i < 4; i++)
            _buildTimeCard(
              title: 'Subject ${i + 1} Time',
              timeKey: 'start', // Placeholder
              bellSettings: _subjectBellSettings[i],
              isSubject: true,
              subjectIndex: i,
            ),
          _buildTimeCard(
            title: 'Interval Time',
            timeKey: 'interval',
            bellSettings: _bellSettings['interval']!,
          ),
          _buildTimeCard(
            title: 'Interval Close Time',
            timeKey: 'intervalClose',
            bellSettings: _bellSettings['intervalClose']!,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildTimeCard(
            title: 'Start Time',
            timeKey: 'start',
            bellSettings: _bellSettings['start']!,
          ),
          _buildTimeCard(
            title: 'Register Mark Start Time',
            timeKey: 'registerMarkStart',
            bellSettings: _bellSettings['registerMarkStart']!,
          ),
          _buildTimeCard(
            title: 'Register Mark Close Time',
            timeKey: 'registerMarkClose',
            bellSettings: _bellSettings['registerMarkClose']!,
          ),
          for (int i = 0; i < 9; i++)
            _buildTimeCard(
              title: 'Subject ${i + 1} Time',
              timeKey: 'start', // Placeholder
              bellSettings: _subjectBellSettings[i],
              isSubject: true,
              subjectIndex: i,
            ),
          _buildTimeCard(
            title: 'Interval Time',
            timeKey: 'interval',
            bellSettings: _bellSettings['interval']!,
          ),
          _buildTimeCard(
            title: 'Interval Close Time',
            timeKey: 'intervalClose',
            bellSettings: _bellSettings['intervalClose']!,
          ),
          _buildTimeCard(
            title: 'Over Time',
            timeKey: 'over',
            bellSettings: _bellSettings['over']!,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showFridaySchedule ? 'Friday Schedule' : 'Schedule Management'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showDurationSettingsDialog,
            tooltip: 'Bell Duration Settings',
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
              _buildScheduleTypeCard(),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildScheduleContent(),
                ),
              ),
              _UpdateScheduleButton(
                isLoading: _isUpdating,
                onPressed: _showConfirmationDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BellDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final String label;
  final ValueChanged<String?> onChanged;

  const _BellDropdown({
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[200]!),
        ),
      ),
      items: items.map((value) => DropdownMenuItem(
        value: value,
        child: Text(value),
      )).toList(),
      onChanged: onChanged,
    );
  }
}

class _ScheduleTypeDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final BuildContext context;

  const _ScheduleTypeDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[200]!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      isExpanded: true,
      items: items.map((type) => DropdownMenuItem(
        value: type,
        child: Text(type),
      )).toList(),
      onChanged: onChanged,
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final TimeOfDay time;

  const _TimeDisplay({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        time.format(context),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }
}

class _UpdateScheduleButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _UpdateScheduleButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            shadowColor: Colors.blue.withOpacity(0.3),
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save_alt, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      'UPDATE SCHEDULE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
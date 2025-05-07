import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ScheduleProvider with ChangeNotifier {
  // Time lists
  final List<TimeOfDay> _regularTimes = List.generate(15, (_) => TimeOfDay.now());
  final List<TimeOfDay> _fridayTimes = List.generate(11, (_) => TimeOfDay.now());
  final List<TimeOfDay> _examTimes = List.generate(8, (_) => TimeOfDay.now());
  
  // Exam dates
  final List<DateTime> _examDates = List.generate(5, (_) => DateTime.now());

  // Bell settings
  int _bellType = 1;
  int _shortBellDuration = 5;
  int _longBellDuration = 10;
  bool _emergencyRing = true;
  List _morningBellMode = [0, 15, 4, 0];
  List _intervalBellMode = [0, 15, 3, 0];
  List _closingBellMode = [0, 15, 2, 0];
  bool _isUpdating = false;

  // Audio files
  String _audioList = 'Mor_Str.mp3,Mor_End.mp3,Sub_1.mp3,Sub_2.mp3,Interval.mp3';
  String _audioListF = 'aa.mp3';

  // Getters
  List<TimeOfDay> get regularTimes => _regularTimes;
  List<TimeOfDay> get fridayTimes => _fridayTimes;
  List<TimeOfDay> get examTimes => _examTimes;
  List<DateTime> get examDates => _examDates;
  int get bellType => _bellType;
  int get shortBellDuration => _shortBellDuration;
  int get longBellDuration => _longBellDuration;
  bool get emergencyRing => _emergencyRing;
  List get morningBellMode => _morningBellMode;
  List get intervalBellMode => _intervalBellMode;
  List get closingBellMode => _closingBellMode;
  String get audioList => _audioList;
  String get audioListF => _audioListF;
  bool get isUpdating => _isUpdating;

  TimeOfDay getCurrentTime(String scheduleType, int index) {
    switch (scheduleType) {
      case 'Regular':
        return _regularTimes[index];
      case 'Friday':
        return _fridayTimes[index];
      case 'Exam/Special day':
        return _examTimes[index];
      default:
        return TimeOfDay.now();
    }
  }

  int getTimeCount(String scheduleType) {
    switch (scheduleType) {
      case 'Regular':
        return _regularTimes.length;
      case 'Friday':
        return _fridayTimes.length;
      case 'Exam/Special day':
        return _examTimes.length;
      default:
        return 0;
    }
  }

  Future<void> fetchScheduleFromFirebase() async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref().get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        _updateTimes(data);
        _updateBellSettings(data);
        _updateAudioFiles(data);
        _updateExamDates(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading schedule: $e');
    }
  }

  void updateTime(String scheduleType, int index, TimeOfDay time) {
    switch (scheduleType) {
      case 'Regular':
        _regularTimes[index] = time;
        break;
      case 'Friday':
        _fridayTimes[index] = time;
        break;
      case 'Exam/Special day':
        _examTimes[index] = time;
        break;
    }
    notifyListeners();
  }
  
  void updateExamDate(int index, DateTime date) {
    if (index >= 0 && index < _examDates.length) {
      _examDates[index] = date;
      notifyListeners();
    }
  }

  void updateBellType(int value) {
    _bellType = value;
    notifyListeners();
  }

  void updateShortBellDuration(int value) {
    _shortBellDuration = value;
    notifyListeners();
  }

  void updateLongBellDuration(int value) {
    _longBellDuration = value;
    notifyListeners();
  }

  void toggleEmergencyRing(bool value) {
    _emergencyRing = value;
    notifyListeners();
  }

  void updateMorningBellMode(int index, int value) {
    _morningBellMode[index] = value;
    notifyListeners();
  }

  void updateIntervalBellMode(int index, int value) {
    _intervalBellMode[index] = value;
    notifyListeners();
  }

  void updateClosingBellMode(int index, int value) {
    _closingBellMode[index] = value;
    notifyListeners();
  }

  void updateAudioList(String value) {
    _audioList = value;
    notifyListeners();
  }

  void updateAudioListF(String value) {
    _audioListF = value;
    notifyListeners();
  }

  Future<void> saveScheduleToFirebase() async {
    _isUpdating = true;
    notifyListeners();
    
    try {
      final updates = {
        'R_Time': _regularTimes.map(_formatDatabaseTime).join(','),
        'F_Time': _fridayTimes.map(_formatDatabaseTime).join(','),
        'E_Time': _examTimes.map(_formatDatabaseTime).join(','),
        'SS_Date': _formatDatabaseDates(),
        'Bell_Type': _bellType,
        'S_Bell_Dur': _shortBellDuration,
        'L_Bell_Dur': _longBellDuration,
        'Emergency_Ring': _emergencyRing ? 1 : 0,
        'Mor_Bell_Mode': _morningBellMode.join(','),
        'Int_Bell_Mode': _intervalBellMode.join(','),
        'Clo_Bell_Mode': _closingBellMode.join(','),
        'Audio_List': _audioList,
        'Audio_List_F': _audioListF,
        'Update': 1,
        'Status': {'value': 1},
        'count': 5,
      };
      
      await FirebaseDatabase.instance.ref().update(updates);
    } catch (e) {
      debugPrint('Error saving schedule: $e');
      rethrow;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  void _updateTimes(Map data) {
    _updateTimeList(data['R_Time'], _regularTimes);
    _updateTimeList(data['F_Time'], _fridayTimes);
    _updateTimeList(data['E_Time'], _examTimes);
  }

  void _updateTimeList(String? timeString, List<TimeOfDay> timeList) {
    if (timeString != null) {
      final times = timeString.split(',');
      for (int i = 0; i < times.length && i < timeList.length; i++) {
        timeList[i] = _parseDatabaseTime(times[i]);
      }
    }
  }

  void _updateBellSettings(Map data) {
    _bellType = data['Bell_Type'] ?? 1;
    _shortBellDuration = data['S_Bell_Dur'] ?? 5;
    _longBellDuration = data['L_Bell_Dur'] ?? 15;
    _emergencyRing = data['Emergency_Ring'] == 1;
    _updateBellMode(data['Mor_Bell_Mode'], _morningBellMode);
    _updateBellMode(data['Int_Bell_Mode'], _intervalBellMode);
    _updateBellMode(data['Clo_Bell_Mode'], _closingBellMode);
  }

  void _updateBellMode(String? modeString, List modeList) {
    if (modeString != null) {
      final modes = modeString.split(',').map((e) => int.tryParse(e) ?? 0).toList();
      for (int i = 0; i < modes.length && i < modeList.length; i++) {
        modeList[i] = modes[i];
      }
    }
  }

  void _updateAudioFiles(Map data) {
    _audioList = data['Audio_List'] ?? 'Mor_Str.mp3,Mor_End.mp3,Sub_1.mp3,Sub_2.mp3,Interval.mp3';
    _audioListF = data['Audio_List_F'] ?? 'aa.mp3';
  }
  
  void _updateExamDates(Map data) {
    if (data['SS_Date'] != null) {
      final datesString = data['SS_Date'] as String;
      final dates = _parseDatabaseDates(datesString);
      
      // Update exam dates list
      for (int i = 0; i < dates.length && i < _examDates.length; i++) {
        _examDates[i] = dates[i];
      }
    }
  }
  
  List<DateTime> _parseDatabaseDates(String datesString) {
    final datesList = <DateTime>[];
    final dates = datesString.split(',');
    
    for (final dateStr in dates) {
      if (dateStr.length == 8) {
        try {
          final day = int.parse(dateStr.substring(0, 2));
          final month = int.parse(dateStr.substring(2, 4));
          final year = int.parse(dateStr.substring(4));
          datesList.add(DateTime(year, month, day));
        } catch (e) {
          debugPrint('Error parsing date: $dateStr - $e');
        }
      }
    }
    
    return datesList;
  }
  
  String _formatDatabaseDates() {
    return _examDates.map((date) => 
      '${date.day.toString().padLeft(2, '0')}${date.month.toString().padLeft(2, '0')}${date.year}'
    ).join(',');
  }

  TimeOfDay _parseDatabaseTime(String timeStr) {
    try {
      final padded = timeStr.padLeft(6, '0');
      final hour = int.parse(padded.substring(0, 2));
      final minute = int.parse(padded.substring(2, 4));
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  String _formatDatabaseTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}${time.minute.toString().padLeft(2, '0')}00';
  }
}

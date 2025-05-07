// lib/models/bell_config.dart
class BellConfig {
  final List<String> audioList;
  final String audioListF;
  final String bellType;
  final List<int> cloBellMode;
  final List<String> eTime;
  final int emergencyRing;
  final List<String> fTime;
  final List<int> intBellMode;
  final int lBellDur;
  final List<int> morBellMode;
  final List<String> rTime;
  final String sBellDur;
  final int status;
  final String update;
  final int updatedTime;
  final int count;

  BellConfig({
    required this.audioList,
    required this.audioListF,
    required this.bellType,
    required this.cloBellMode,
    required this.eTime,
    required this.emergencyRing,
    required this.fTime,
    required this.intBellMode,
    required this.lBellDur,
    required this.morBellMode,
    required this.rTime,
    required this.sBellDur,
    required this.status,
    required this.update,
    required this.updatedTime,
    required this.count,
  });

  factory BellConfig.fromMap(Map<String, dynamic> data) {
    return BellConfig(
      audioList: (data['Audio_List'] as String).split(','),
      audioListF: data['Audio_List_F'] as String,
      bellType: data['Bell_Type'] as String,
      cloBellMode: (data['Clo_Bell_Mode'] as String).split(',').map(int.parse).toList(),
      eTime: (data['E_Time'] as String).split(','),
      emergencyRing: data['Emergency_Ring'] as int,
      fTime: (data['F_Time'] as String).split(','),
      intBellMode: (data['Int_Bell_Mode'] as String).split(',').map(int.parse).toList(),
      lBellDur: data['L_Bell_Dur'] as int,
      morBellMode: (data['Mor_Bell_Mode'] as String).split(',').map(int.parse).toList(),
      rTime: (data['R_Time'] as String).split(','),
      sBellDur: data['S_Bell_Dur'] as String,
      status: (data['Status'] as Map)['value'] as int,
      update: data['Update'] as String,
      updatedTime: data['Updated_Time'] as int,
      count: data['count'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Audio_List': audioList.join(','),
      'Audio_List_F': audioListF,
      'Bell_Type': bellType,
      'Clo_Bell_Mode': cloBellMode.join(','),
      'E_Time': eTime.join(','),
      'Emergency_Ring': emergencyRing,
      'F_Time': fTime.join(','),
      'Int_Bell_Mode': intBellMode.join(','),
      'L_Bell_Dur': lBellDur,
      'Mor_Bell_Mode': morBellMode.join(','),
      'R_Time': rTime.join(','),
      'S_Bell_Dur': sBellDur,
      'Status': {'value': status},
      'Update': update,
      'Updated_Time': updatedTime,
      'count': count,
    };
  }
}
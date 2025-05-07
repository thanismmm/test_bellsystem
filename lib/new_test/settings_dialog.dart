import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bell_system_test/new_test/duration_field.dart';
import 'package:bell_system_test/new_test/schedule_provider.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController shortController;
  late TextEditingController longController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    // Convert old bell type values to new ones
  if (provider.bellType == 10) {
    provider.updateBellType(1);
  } else if (provider.bellType == 20) {
    provider.updateBellType(2);
  } else if (provider.bellType == 30) {
    provider.updateBellType(3);
  }
    shortController = TextEditingController(text: provider.shortBellDuration.toString());
    longController = TextEditingController(text: provider.longBellDuration.toString());
  }

  @override
  void dispose() {
    shortController.dispose();
    longController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScheduleProvider>(context, listen: true);
    return AlertDialog(
      title: const Text('System Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBellTypeSelector(provider),
            DurationTextField(
              label: 'Short Bell Duration',
              controller: shortController,
              min: 0,
              max: 10,
            ),
            DurationTextField(
              label: 'Long Bell Duration',
              controller: longController,
              min: 0,
              max: 20,
            ),
            _buildEmergencySwitch(provider),
            _buildBellModeSettings(provider),
            _buildAudioSettings(context, provider),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // Validate and update provider only on save
            final shortValue = int.tryParse(shortController.text) ?? 0;
            final longValue = int.tryParse(longController.text) ?? 0;
            provider.updateShortBellDuration(shortValue.clamp(0, 10));
            provider.updateLongBellDuration(longValue.clamp(0, 20));
            await provider.saveScheduleToFirebase();
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildBellTypeSelector(ScheduleProvider provider) {
    return ListTile(
      title: const Text('Bell Type'),
      trailing: DropdownButton(
        value: provider.bellType,
        items: const [
          DropdownMenuItem(value: 1, child: Text("1")),
          DropdownMenuItem(value: 2, child: Text('2')),
          DropdownMenuItem(value: 3, child: Text('3')),
        ],
        onChanged: (value) => provider.updateBellType(value!),
      ),
    );
  }

  Widget _buildEmergencySwitch(ScheduleProvider provider) {
    return SwitchListTile(
      title: const Text('Emergency Ring'),
      value: provider.emergencyRing,
      onChanged: provider.toggleEmergencyRing,
    );
  }

  Widget _buildBellModeSettings(ScheduleProvider provider) {
    return Column(
      children: [
        _buildModeSelector(
          'Morning Bell Mode',
          'Controls the bell pattern at the start of the day',
          provider.morningBellMode,
          provider.updateMorningBellMode,
        ),
        _buildModeSelector(
          'Interval Bell Mode',
          'Controls the bell pattern during break periods',
          provider.intervalBellMode,
          provider.updateIntervalBellMode,
        ),
        _buildModeSelector(
          'Closing Bell Mode',
          'Controls the bell pattern at the end of the day',
          provider.closingBellMode,
          provider.updateClosingBellMode,
        ),
      ],
    );
  }

  Widget _buildModeSelector(
    String title,
    String description,
    List mode,
    Function(int, int) onUpdate,
  ) 
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
          child: Text(
            title, 
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            )
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              SizedBox(width: 120, child: _buildLabeledModeDropdown('Ring Type', mode, 0, 5, onUpdate)),
              SizedBox(width: 72, child: _buildLabeledModeDropdown('Regular', mode, 1, 15, onUpdate)),
              SizedBox(width: 75, child: _buildLabeledModeDropdown('Friday', mode, 2, 15, onUpdate)),
              SizedBox(width: 75, child: _buildLabeledModeDropdown('Special', mode, 3, 15, onUpdate)),
            ],
          ),
        ),
      ],
    );
  }

  String _getBellModeLabel(int index) {
    switch (index) {
      case 0: return "short once";
      case 1: return "short twice";
      case 2: return "long once";
      case 3: return "long twice";
      case 4: return "short_long";
      default: return index.toString();
    }
  }



Widget _buildLabeledModeDropdown(
  String label,
  List mode,
  int index,
  int itemCount,
  Function(int, int) onUpdate,
) {
  // Ensure the current value is within the valid range
  if (mode[index] >= itemCount) {
    // If the current value is out of range, update it to a valid value
    // This will happen immediately when the widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onUpdate(index, 0); // Reset to first option
    });
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue[700],
          fontWeight: FontWeight.w500,
        ),
      ),
      Container(
        width: label == 'Ring Type' ? 120 : 72,
        margin: const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue[200]!),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
              isExpanded: true,
              // Use a valid value for the dropdown
              value: mode[index] < itemCount ? mode[index] : 0,
              items: List.generate(
                itemCount,
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(
                    label == 'Ring Type' ? _getBellModeLabel(i) : i.toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              onChanged: (value) => onUpdate(index, value ?? mode[index]),
            ),
          ),
        ),
      ),
    ],
  );
}



  Widget _buildAudioSettings(BuildContext context, ScheduleProvider provider) {
    return Column(
      children: [
        const Divider(),
        ListTile(
          title: const Text('Regular Audio Files'),
          subtitle: Text(provider.audioList),
          onTap: () => _showEditDialog(
            context,
            'Regular Audio Files',
            provider.audioList,
            provider.updateAudioList,
          ),
        ),
        ListTile(
          title: const Text('Friday Audio Files'),
          subtitle: Text(provider.audioListF),
          onTap: () => _showEditDialog(
            context,
            'Friday Audio Files',
            provider.audioListF,
            provider.updateAudioListF,
          ),
        ),
      ],
    );
  }

  Future _showEditDialog(
    BuildContext context,
    String title,
    String initialValue,
    Function(String) onSave,
  ) async {
    final controller = TextEditingController(text: initialValue);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

import 'package:bell_system_test/components/system_cart.dart';
import 'package:bell_system_test/screens/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class AttendanceSystem extends StatelessWidget {
  const AttendanceSystem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance System',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SystemCard(
            title: 'Student Attendance',
            description: 'Track daily attendance and generate reports for students',
            icon: Icons.assignment_ind,
            iconColor: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentAttendancePage(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SystemCard(
            title: 'QR Code Scanner',
            description: 'Scan student QR codes to mark attendance',
            icon: Icons.qr_code_scanner,
            iconColor: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRScannerScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class StudentAttendancePage extends StatefulWidget {
  const StudentAttendancePage({super.key});

  @override
  State<StudentAttendancePage> createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  String selectedClass = '10';
  String selectedSection = 'A';
  final List<String> classes = List.generate(11, (index) => (index + 1).toString());
  final List<String> sections = ['A', 'B', 'C', 'D'];
  
  final List<Map<String, dynamic>> students = [
    {'name': 'John Smith', 'present': true},
    {'name': 'Emily Johnson', 'present': true},
    {'name': 'Michael Williams', 'present': false},
    {'name': 'Jessica Brown', 'present': true},
    {'name': 'David Jones', 'present': true},
    {'name': 'Sarah Miller', 'present': false},
    {'name': 'James Davis', 'present': true},
    {'name': 'Jennifer Garcia', 'present': true},
    {'name': 'Robert Wilson', 'present': true},
    {'name': 'Lisa Martinez', 'present': true},
  ];

  String get currentDate {
    return DateFormat('MMMM dd, yyyy').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Class dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedClass,
                    decoration: InputDecoration(
                      labelText: 'Class',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: classes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text('Class $value'),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedClass = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Section dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSection,
                    decoration: InputDecoration(
                      labelText: 'Section',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: sections.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text('Section $value'),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedSection = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Class $selectedClass-$selectedSection',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        currentDate,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return _buildStudentItem(
                    students[index]['name'],
                    students[index]['present'],
                    index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width - 32,
        child: FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attendance saved successfully')),
            );
          },
          label: const Text('Save Attendance'),
          icon: const Icon(Icons.save),
        ),
      ),
    );
  }

  Widget _buildStudentItem(String name, bool present, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Text(
                name.substring(0, 1),
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Switch(
              value: present,
              onChanged: (value) {
                setState(() {
                  students[index]['present'] = value;
                });
              },
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

// class QRScannerPage extends StatefulWidget {
//   const QRScannerPage({super.key});

//   @override
//   State<QRScannerPage> createState() => _QRScannerPageState();
// }

// class _QRScannerPageState extends State<QRScannerPage> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;
//   String result = 'Scan a QR code';
//   bool isScanning = true;

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       setState(() {
//         result = scanData.code ?? 'No data found';
//         isScanning = false;
//       });
      
//       // Show dialog with scanned result
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Scan Result'),
//             content: Text(result),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   setState(() {
//                     isScanning = true;
//                     result = 'Scan a QR code';
//                   });
//                   controller.resumeCamera();
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('QR Code Scanner'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             flex: 5,
//             child: QRView(
//               key: qrKey,
//               onQRViewCreated: _onQRViewCreated,
//               overlay: QrScannerOverlayShape(
//                 borderColor: Colors.blue,
//                 borderRadius: 10,
//                 borderLength: 30,
//                 borderWidth: 10,
//                 cutOutSize: MediaQuery.of(context).size.width * 0.8,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Center(
//               child: Text(
//                 result,
//                 style: const TextStyle(fontSize: 18),
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           if (controller != null) {
//             controller?.resumeCamera();
//             setState(() {
//               isScanning = true;
//               result = 'Scan a QR code';
//             });
//           }
//         },
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }
// }
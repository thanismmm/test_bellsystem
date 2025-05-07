import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String scannedData = "No QR code scanned yet";
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan Qr',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 17),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 60, bottom: 60),
              child: MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    final String? data = barcode.rawValue;
                    setState(() {
                      scannedData = barcode.rawValue ?? "No data found";
                    });

                    if (!_isScanned && data != null) {
                      _isScanned = true; // Prevent further detections
                      _showStudentIDCard(data); // Show alert and close scanner
                    }
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                scannedData,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentIDCard(String data) {
    // Parse QR data - assuming comma-separated values
    // Modify this according to your actual QR data format
    final studentInfo = data.split(',');

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 350),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with university logo/name
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1a237e),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Student Identification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Student Photo
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    child:
                        Icon(Icons.person, size: 50, color: Colors.grey[400]),
                  ),
                ),

                // Student Details
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildInfoRow('Student Index', "12921"),
                      _buildInfoRow('Name',
                          'Mohammed Thanis'), // Replace with actual data
                      _buildInfoRow(
                          'School', 'GMMS'), // Replace with actual data
                      _buildInfoRow('Grade', '4B'),
                    ],
                  ),
                ),

                // QR Code
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.qr_code, size: 40),
                        SizedBox(height: 4),
                        Text(
                          'ID: ${studentInfo[0]}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Buttons
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 48,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context, data);
                          },
                          child: Text(
                            'Confirm',
                            style: TextStyle(
                              color: Color(0xFF1a237e),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Helper function to build info rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
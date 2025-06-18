import 'package:bell_system_test/page/new_login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


PreferredSizeWidget customAppBar(BuildContext context, {PreferredSizeWidget? bottom}) {
  String currentDateTime = DateFormat('yyyy-MM-dd').format(DateTime.now());

   // Confirmation Dialog Function
  Future<void> showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation!'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog first
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }


  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: Colors.blue,
    toolbarHeight: 100,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ClipOval(
              child: Image.asset(
                'lib/images/logo.jpg',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Smart Bell System",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentDateTime,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
              showConfirmationDialog(context);
          },
        ),
    ],
    ),
    bottom: bottom,
  );
}

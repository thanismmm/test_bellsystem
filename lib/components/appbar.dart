import 'package:bell_system_test/page/new_login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

PreferredSizeWidget customAppBar(BuildContext context, {PreferredSizeWidget? bottom}) {

  Future<void> showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmation!'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context); // Close the dialog first
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: Colors.blue.shade700,
    toolbarHeight: 110,
    elevation: 4,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
    ),
    title: Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
      child: Row(
        children: [
          // Logo with border and shadow
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              backgroundImage: AssetImage('lib/images/logo.jpg'),
              radius: 28,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          // School info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "KM/KM/GOVT. MUSLIM MIXED SCHOOL",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 3.5,),

                 Text(
                  "(Sainthamaruthu)",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
              
              ],
            ),
          ),
          // Logout button with tooltip and style
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Tooltip(
              message: "Sign out",
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () async {
                    await showConfirmationDialog(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    bottom: bottom,
  );
}

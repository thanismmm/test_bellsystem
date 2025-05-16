import 'package:bell_system_test/new_test/digital_clock.dart';
import 'package:flutter/material.dart';
import 'package:bell_system_test/components/appbar.dart';
import 'package:bell_system_test/page/new_attendence_page.dart';
import 'package:bell_system_test/page/schedule_screen.dart';

class SystemTabs extends StatefulWidget {
  const SystemTabs({super.key});

  @override
  State<SystemTabs> createState() => _SystemTabsPageState();
}

class _SystemTabsPageState extends State<SystemTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: customAppBar(
  context,
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(50.0), // Ensures proper height for TabBar
    child: Container(
      color: Colors.white, //Set TabBar background color to white
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
            icon: Icon(Icons.notifications, color: Colors.black),
            text: 'Bell System',
          ),
          Tab(
            icon: Icon(Icons.people, color: Colors.black),
            text: 'Attendance System',
          ),
        ],
        indicatorWeight: 3,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
      ),
    ),
  ),
),
  
      body: 
      TabBarView(
        controller: _tabController,
        children: const [
          // Bell System Tab
          BellSystemTab(),
          
          // Attendance System Tab
          AttendanceSystemTab(),
        ],
      ),
    );
  }
}

class BellSystemTab extends StatelessWidget {
  const BellSystemTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bell System',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SystemCard(
              title: 'Automated Bell Schedule',
              description: 'Configure and monitor the automatic bell system for class periods',
              icon: Icons.schedule,
              iconColor: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SystemCard(
              title: 'Manual Bell Control',
              description: 'Manually trigger bells for special events and announcements',
              icon: Icons.notifications_active,
              iconColor: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManualBellPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const DigitalClock()
          ],
        ),
      ),
    );
  }
}

class AttendanceSystemTab extends StatelessWidget {
  const AttendanceSystemTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AttendanceSystem()
        ],
      ),
    );
  }
}

class SystemCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const SystemCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Left - Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              
              // Middle - Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Right - Arrow icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManualBellPage extends StatelessWidget {
  const ManualBellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Bell Control'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manual Bell Controls',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildBellButton(context, 'Regular Bell', Icons.notifications, Colors.blue),
            const SizedBox(height: 16),
            _buildBellButton(context, 'Emergency Bell', Icons.warning_amber, Colors.red),
            const SizedBox(height: 16),
            _buildBellButton(context, 'Assembly Bell', Icons.people, Colors.green),
            const SizedBox(height: 16),
            _buildBellButton(context, 'Dismissal Bell', Icons.exit_to_app, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildBellButton(BuildContext context, String label, IconData icon, Color color) {
    return Card(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label activated')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(fontSize: 18),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label activated')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                ),
                child: const Text('Ring'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
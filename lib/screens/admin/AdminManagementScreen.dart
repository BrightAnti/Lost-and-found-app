import 'package:finderucc/screens/add_item_page.dart';
import 'package:flutter/material.dart';

class AdminManagementScreen extends StatefulWidget {
  final String userId;

  const AdminManagementScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _AdminManagementScreenState createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel - Welcome ${widget.userId.split('@')[0]}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Handle logout logic here
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Manage Items"),
            Tab(text: "Add New Item"),
            Tab(text: "Admin Profile"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Manage Items Tab
          ManageItemsTab(),
          
          // Add New Item Tab
          AddItemPage(userId: widget.userId), // Use the AddItemPage here
          
          // Admin Profile Tab
          AdminProfileTab(userId: widget.userId),
        ],
      ),
    );
  }
}

// Manage Items Tab
class ManageItemsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This would typically involve fetching items from a database
    // and displaying them in a list. Here’s a placeholder implementation.
    return ListView.builder(
      itemCount: 10, // Placeholder for number of items
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item $index'),
          subtitle: Text('Description of item $index'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  // Handle item edit
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  // Handle item delete
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Admin Profile Tab
class AdminProfileTab extends StatelessWidget {
  final String userId;

  const AdminProfileTab({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace with real data fetching logic
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Admin ID: $userId', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Handle edit profile logic here
            },
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}

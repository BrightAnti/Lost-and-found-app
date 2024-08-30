// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({required this.userId, super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, bool> _checkedItems = {};
  DocumentSnapshot<Map<String, dynamic>>? _userData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      setState(() {
        _userData = userDoc;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: const Color(0xFF003366), // UCC color
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profile Details'),
            Tab(text: 'Items Uploaded'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Profile Details Tab
          _buildProfileDetailsTab(),

          // Items Uploaded Tab
          _buildItemsUploadedTab(),
        ],
      ),
    );
  }

  Widget _buildProfileDetailsTab() {
    if (_userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userData = _userData!.data();
    final userName = userData?['name'] ?? 'N/A';
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'N/A';
    final userPhone = userData?['phoneNumber'] ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_circle, color: Colors.blueAccent, size: 30),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Name: $userName',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.email_outlined, color: Colors.blueAccent, size: 30),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Email: $userEmail',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.phone_android, color: Colors.blueAccent, size: 30),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Phone: $userPhone',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsUploadedTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('items')
          .where('userId', isEqualTo: widget.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs;

        if (items.isEmpty) {
          return const Center(child: Text('No items uploaded.'));
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final itemData = items[index].data() as Map<String, dynamic>;
            final itemId = items[index].id;
            final itemStatus = itemData['status'] as String? ?? 'Pending';

            _checkedItems[itemId] = _checkedItems[itemId] ?? (itemStatus == 'Delivered');

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: itemData['imageUrl'] != null
                    ? Image.network(
                        itemData['imageUrl'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image, size: 50),
                title: Text(itemData['itemName'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                subtitle: Text(itemData['description']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      itemStatus,
                      style: TextStyle(
                        color: itemStatus == 'Pending' ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Checkbox(
                      value: _checkedItems[itemId],
                      onChanged: (bool? value) {
                        setState(() {
                          _checkedItems[itemId] = value ?? false;
                          if (_checkedItems[itemId] == true) {
                            _handleItemChecked(itemId);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleItemChecked(String itemId) async {
    try {
      await FirebaseFirestore.instance.collection('items').doc(itemId).update({
        'status': 'Delivered',
      });

      setState(() {
        _checkedItems.remove(itemId);
      });
    } catch (e) {
      print('Error updating item status: $e');
    }
  } 
}

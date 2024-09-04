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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _programmeController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _hallAffiliationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeUserProfile();
  }

  Future<void> _initializeUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (!userDoc.exists) {
        await createUserProfile(
          uid: widget.userId,
          name: user.displayName ?? 'N/A',
          email: user.email ?? 'N/A',
          phoneNumber: user.phoneNumber ?? 'N/A',
        );
        _fetchUserData();
      } else {
        setState(() {
          _userData = userDoc;
          _nameController.text = _userData?.data()?['name'] ?? '';
          _phoneController.text = _userData?.data()?['phoneNumber'] ?? '';
          _programmeController.text = _userData?.data()?['programme'] ?? '';
          _levelController.text = _userData?.data()?['level'] ?? '';
          _hallAffiliationController.text = _userData?.data()?['hallAffiliation'] ?? '';
        });
      }
    } catch (e) {
      print('Error initializing user profile: $e');
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      setState(() {
        _userData = userDoc;
        _nameController.text = _userData?.data()?['name'] ?? '';
        _phoneController.text = _userData?.data()?['phoneNumber'] ?? '';
        _programmeController.text = _userData?.data()?['programme'] ?? '';
        _levelController.text = _userData?.data()?['level'] ?? '';
        _hallAffiliationController.text = _userData?.data()?['hallAffiliation'] ?? '';
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _updateUserProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'name': _nameController.text,
          'phoneNumber': _phoneController.text,
          'programme': _programmeController.text,
          'level': _levelController.text,
          'hallAffiliation': _hallAffiliationController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        _fetchUserData();
      } catch (e) {
        print('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: const Color(0xFF003366),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profile Details'),
            Tab(text: 'Items Uploaded'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileDetailsTab(),
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
    final userProgramme = userData?['programme'] ?? 'N/A';
    final userLevel = userData?['level'] ?? 'N/A';
    final userHallAffiliation = userData?['hallAffiliation'] ?? 'N/A';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        shadowColor: Colors.blueAccent.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileRow(Icons.account_circle, 'Name', userName),
              const SizedBox(height: 12),
              _buildProfileRow(Icons.email_outlined, 'Email', userEmail),
              const SizedBox(height: 12),
              _buildProfileRow(Icons.phone_android, 'Phone', userPhone),
              const SizedBox(height: 12),
              _buildProfileRow(Icons.school, 'Programme', userProgramme),
              const SizedBox(height: 12),
              _buildProfileRow(Icons.grade, 'Level', userLevel),
              const SizedBox(height: 12),
              _buildProfileRow(Icons.home, 'Hall Affiliation', userHallAffiliation),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 30),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
              Text(
                text,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.blueGrey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Future<void> _showEditProfileDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField('Name', _nameController),
                  const SizedBox(height: 12),
                  _buildTextField('Phone', _phoneController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildTextField('Programme', _programmeController),
                  const SizedBox(height: 12),
                  _buildTextField('Level', _levelController, keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildTextField('Hall Affiliation', _hallAffiliationController),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                _updateUserProfile();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleItemChecked(String itemId) async {
    try {
      await FirebaseFirestore.instance.collection('items').doc(itemId).update({'status': 'Delivered'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item marked as delivered!')),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error updating item status: $e');
    }
  }

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    String? phoneNumber,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber ?? '',
        'programme': '',
        'level': '',
        'hallAffiliation': '',
      });
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _programmeController.dispose();
    _levelController.dispose();
    _hallAffiliationController.dispose();
    super.dispose();
  }
}

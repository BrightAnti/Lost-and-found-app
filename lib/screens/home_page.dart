// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finderucc/screens/add_item_page.dart';
import 'package:finderucc/screens/item_detail_page.dart';
import 'package:finderucc/screens/login_page.dart';
import 'package:finderucc/screens/user_profile.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({super.key, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  void _searchItems() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _refreshPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(userId: widget.userId),
      ),
    );
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _refreshPage,
          child: const Text('FINDERUCC'),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'Profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileScreen(userId: widget.userId),
                  ),
                );
              } else if (result == 'Logout') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false,
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'Logout',
                child: Text('Logout'),
              ),
            ],
            child: const CircleAvatar(
              backgroundImage: NetworkImage('https://tamilnaducouncil.ac.in/wp-content/uploads/2020/04/dummy-avatar.jpg'),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              onSubmitted: (value) => _searchItems(),
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _searchItems,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(color: Color(0xFF003366)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(color: Color(0xFF003366)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(color: Color(0xFF003366)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  _buildCategoryButton('All', Icons.all_inclusive),
                  _buildCategoryButton('Electronics', Icons.devices),
                  _buildCategoryButton('Documents', Icons.description),
                  _buildCategoryButton('Clothing', Icons.checkroom),
                  _buildCategoryButton('Accessories', Icons.watch),
                  _buildCategoryButton('Others', Icons.miscellaneous_services),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('items').where(
                  'status', isNotEqualTo: 'Delivered'
                ).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = snapshot.data!.docs;
                  final filteredItems = items.where((item) {
                    final itemData = item.data() as Map<String, dynamic>;
                    final itemCategory = itemData['category'] as String? ?? '';
                    final itemName = itemData['itemName'] as String? ?? '';
                    final matchesCategory = _selectedCategory == 'All' ||
                        itemCategory.toLowerCase() == _selectedCategory.toLowerCase();
                    final matchesSearch = itemName.toLowerCase().contains(_searchQuery.toLowerCase());

                    return matchesCategory && matchesSearch;
                  }).toList();

                  if (filteredItems.isEmpty) {
                    return const Center(child: Text('No items found.'));
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final itemData = filteredItems[index].data() as Map<String, dynamic>;
                      final imageUrl = itemData['imageUrl'] ?? 'https://via.placeholder.com/150';
                      final status = itemData['status'] as String? ?? 'Unknown';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemDetailPage(itemData: itemData, pickupPointName: '',),
                            ),
                          );
                        },
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        color: status == 'Lost' ? Colors.red : Colors.green,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Text(
                                          status,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemData['itemName'] ?? 'No name',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(itemData['description'] ?? 'No description'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItemPage(userId: widget.userId)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003366).withOpacity(0.8), // Navbar color with slight transparency
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Add Lost or Found Item',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Keep the text color white for readability
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String category, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        icon: Icon(
          icon,
          color: _selectedCategory == category ? Colors.white : const Color(0xFF003366),
        ),
        label: Text(
          category,
          style: TextStyle(
            color: _selectedCategory == category ? Colors.white : const Color(0xFF003366),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedCategory == category
              ? const Color(0xFF003366)
              : Colors.white,
          side: const BorderSide(color: Color(0xFF003366)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

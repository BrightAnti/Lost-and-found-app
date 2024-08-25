// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddItemPage extends StatefulWidget {
  final String userId;

  const AddItemPage({required this.userId, super.key});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String _selectedCategory = 'Electronics';
  String _selectedStatus = 'Lost';
  final DateTime _selectedDate = DateTime.now();
  File? _image;
  String? _imageUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    final storageRef = FirebaseStorage.instance.ref().child('item_images/${DateTime.now().toIso8601String()}');
    final uploadTask = storageRef.putFile(_image!);

    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    setState(() {
      _imageUrl = downloadUrl;
    });
  }

  void _addItem() async {
    if (_formKey.currentState!.validate()) {
      await _uploadImage();

      FirebaseFirestore.instance.collection('items').add({
        'itemName': _itemNameController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'status': _selectedStatus,
        'location': _locationController.text,
        'phoneNumber': _phoneNumberController.text,
        'date': _selectedDate.toIso8601String(),
        'imageUrl': _imageUrl,
        'userId': widget.userId, // Save userId with the item
      }).then((_) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        backgroundColor: const Color(0xFF003366), // UCC color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: <String>[
                  'Electronics',
                  'Documents',
                  'Clothing',
                  'Accessories',
                  'Others'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: <String>['Lost', 'Found'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005b99), // UCC color
                ),
                child: const Text(
                  'Pick Image',
                  style: TextStyle(color: Colors.white), // Make text white
                ),
              ),
              const SizedBox(height: 20),
              _image != null
                  ? Image.file(
                      _image!,
                      height: 150,
                    )
                  : const Text('No image selected.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005b99), // UCC color
                ),
                child: const Text(
                  'Add Item',
                  style: TextStyle(color: Colors.white), // Make text white
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

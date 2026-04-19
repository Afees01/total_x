import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:total_x/user/presentation/bloc/User_bloc/user_event.dart';
import 'package:total_x/user/presentation/bloc/User_bloc/user_state.dart';
import '../../domain/entities/user.dart';
import '../bloc/user_bloc.dart';


class HomePage extends StatelessWidget {
  HomePage({super.key});

  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              context.read<UserBloc>().add(SortUserEvent(true));
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search user...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                context.read<UserBloc>().add(SearchUserEvent(value));
              },
            ),
          ),

          // 📋 USER LIST
          Expanded(
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state.filtered.isEmpty) {
                  return const Center(
                    child: Text("No Users Found"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: state.filtered.length,
                  itemBuilder: (context, index) {
                    final user = state.filtered[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: user.image != null
                            ? CircleAvatar(
                                backgroundImage: FileImage(File(user.image!)),
                              )
                            : CircleAvatar(
                                child: Text(user.name[0].toUpperCase()),
                              ),
                              
                        title: Text(user.name),
                        subtitle: Text(user.phone),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Age ${user.age}"),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    user.age >= 60 ? Colors.red : Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                user.age >= 60 ? "Older" : "Younger",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            )
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
    );
  }

  ////////////////////////////////////////////////////////
  // ADD USER DIALOG
  ////////////////////////////////////////////////////////
  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final ageController = TextEditingController();

    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add User"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    // 📸 IMAGE PICKER
                    GestureDetector(
                      onTap: () async {
                        final picked = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);

                        if (picked != null) {
                          setState(() {
                            selectedImage = File(picked.path);
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : null,
                        child: selectedImage == null
                            ? const Icon(Icons.camera_alt)
                            : null,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(hintText: "Name"),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(hintText: "Phone"),
                    ),
                    TextField(
                      controller: ageController,
                      decoration: const InputDecoration(hintText: "Age"),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text("Add"),
                  onPressed: () {
                    final user = User(
                      name: nameController.text,
                      phone: phoneController.text,
                      age: int.parse(ageController.text),
                      image: selectedImage?.path,
                    );

                    context.read<UserBloc>().add(AddUserEvent(user));
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

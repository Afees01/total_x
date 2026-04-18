import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';

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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(user.name[0].toUpperCase()),
                        ),
                        title: Text(user.name),
                        subtitle: Text(user.phone),
                        trailing: Text("Age ${user.age}"),
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

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add User"),
          content: SingleChildScrollView(
            child: Column(
              children: [
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
                );

                context.read<UserBloc>().add(AddUserEvent(user));

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

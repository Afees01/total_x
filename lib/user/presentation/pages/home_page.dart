import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              context.read<UserBloc>().add(SortUserEvent(true));
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Search by name or phone",
              ),
              onChanged: (value) {
                context.read<UserBloc>().add(SearchUserEvent(value));
              },
            ),
          ),

          // 📋 LIST
          Expanded(
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                return ListView.builder(
                  itemCount: state.filtered.length,
                  itemBuilder: (context, index) {
                    final user = state.filtered[index];

                    return ListTile(
                      title: Text(user.name),
                      subtitle: Text(user.phone),
                      trailing: Text("Age: ${user.age}"),
                    );
                  },
                );
              },
            ),
          ),

          // ➕ ADD USER
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: "Name")),
                TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(hintText: "Phone")),
                TextField(
                    controller: ageController,
                    decoration: const InputDecoration(hintText: "Age")),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    final user = User(
                      name: nameController.text,
                      phone: phoneController.text,
                      age: int.parse(ageController.text),
                    );

                    context.read<UserBloc>().add(AddUserEvent(user));

                    nameController.clear();
                    phoneController.clear();
                    ageController.clear();
                  },
                  child: const Text("Add User"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
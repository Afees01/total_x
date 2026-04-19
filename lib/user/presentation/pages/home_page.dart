import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:total_x/core/utils/app_colors.dart';
import 'package:total_x/core/utils/app_text_styles.dart';
import 'package:total_x/core/widgets/app_button.dart';
import 'package:total_x/core/widgets/app_text_field.dart';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search bar row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        controller: searchController,
                        style: AppTextStyles.normal,
                        decoration: InputDecoration(
                          hintText: 'search by name',
                          hintStyle: AppTextStyles.hint,
                          prefixIcon: Icon(Icons.search,
                              color: Colors.grey.shade400, size: 20),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          context.read<UserBloc>().add(SearchUserEvent(value));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showSortDialog(context),
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.sort,
                          color: AppColors.background, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            // ── Section label
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: Text('Users Lists', style: AppTextStyles.subheading),
            ),

            // ── User list
            Expanded(
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state.filtered.isEmpty) {
                    return Center(
                      child: Text('No Users Found', style: AppTextStyles.body),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.filtered.length,
                    itemBuilder: (context, index) {
                      final user = state.filtered[index];
                      return _UserCard(user: user);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 26),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SortDialog(),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    File? selectedImage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add A New User',
                        style: AppTextStyles.subheading),
                    const SizedBox(height: 16),

                    // Avatar picker
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            setState(() => selectedImage = File(picked.path));
                          }
                        },
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: const Color(0xFFE3F0FF),
                          backgroundImage: selectedImage != null
                              ? FileImage(selectedImage!)
                              : null,
                          child: selectedImage == null
                              ? Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    const Icon(Icons.person,
                                        size: 40, color: Color(0xFF90B8E8)),
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: AppColors.accent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.camera_alt,
                                          size: 12,
                                          color: AppColors.background),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Name', style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    AppTextField(
                      controller: nameController,
                      hint: 'Enter name',
                    ),
                    const SizedBox(height: 12),

                    const Text('Age', style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    AppTextField(
                      controller: ageController,
                      hint: 'Enter age',
                      isNumber: true,
                      maxLength: 3,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        AppButton(
                          text: 'Save',
                          width: 90,
                          height: 40,
                          borderRadius: 8,
                          backgroundColor: AppColors.accent,
                          onTap: () {
                            if (nameController.text.isEmpty ||
                                ageController.text.isEmpty) return;
                            final user = User(
                              name: nameController.text,
                              phone: '',
                              age: int.tryParse(ageController.text) ?? 0,
                              image: selectedImage?.path,
                            );
                            context.read<UserBloc>().add(AddUserEvent(user));
                            Navigator.pop(context);
                          },
                        ),
                      ],
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
}

// ── User card
class _UserCard extends StatelessWidget {
  final dynamic user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: user.image != null
            ? CircleAvatar(
                radius: 24,
                backgroundImage: FileImage(File(user.image!)),
              )
            : CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE3F0FF),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.accent),
                ),
              ),
        title: Text(user.name, style: AppTextStyles.subheading),
        subtitle: Text('Age: ${user.age}', style: AppTextStyles.caption),
      ),
    );
  }
}

// ── Sort dialog
class _SortDialog extends StatefulWidget {
  @override
  State<_SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<_SortDialog> {
  String _selected = 'all';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sort', style: AppTextStyles.subheading),
            const SizedBox(height: 12),
            _buildRadio('all', 'All'),
            _buildRadio('elder', 'Age: Elder'),
            _buildRadio('younger', 'Age: Younger'),
          ],
        ),
      ),
    );
  }

  Widget _buildRadio(String value, String label) {
    return InkWell(
      onTap: () {
        setState(() => _selected = value);
        context.read<UserBloc>().add(SortUserEvent(value == 'elder'));
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selected,
              activeColor: AppColors.accent,
              onChanged: (v) {
                if (v != null) setState(() => _selected = v);
              },
            ),
            Text(label, style: AppTextStyles.normal),
          ],
        ),
      ),
    );
  }
}

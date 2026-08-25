import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _universityController;
  late final TextEditingController _professionController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _universityController = TextEditingController(text: user?.university ?? '');
    _professionController = TextEditingController(text: user?.profession ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final success = await context.read<AuthProvider>().updateProfile(
      displayName: _nameController.text.trim(),
      university: _universityController.text.trim(),
      profession: _professionController.text.trim(),
    );
    setState(() => _isSaving = false);
    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated!')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: user?.email ?? '',
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  helperText: 'Email cannot be changed here',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _universityController,
                decoration: const InputDecoration(
                  labelText: 'University / College',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _professionController,
                decoration: const InputDecoration(
                  labelText: 'Profession / Field of study',
                  prefixIcon: Icon(Icons.work_outline_rounded),
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Save Changes',
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

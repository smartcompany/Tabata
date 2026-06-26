import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';

import '../app_auth_provider.dart';
import '../models/user.dart' as tabata;
import '../services/tabata_auth_api_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final profile = AppAuthProvider.shared.userProfile;
    if (profile != null && profile.fullName.isNotEmpty) {
      _nicknameController.text = profile.fullName;
    } else {
      final displayName = FirebaseAuth.instance.currentUser?.displayName;
      if (displayName != null && displayName.trim().isNotEmpty) {
        _nicknameController.text = displayName.trim();
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final fullName = _nicknameController.text.trim();
      final result = await TabataAuthApiService.shared.updateProfile(
        fullName: fullName,
        kakaoId: AppAuthProvider.shared.kakaoId,
      );

      if (!mounted) return;

      if (result is Map && result['custom_token'] != null) {
        await AppAuthProvider.shared.signInWithCustomToken(
          result['custom_token'] as String,
        );
      } else {
        AppAuthProvider.shared.setUserProfile(result as tabata.User);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 설정 실패: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 설정'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '닉네임을 입력해 주세요.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: '닉네임',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.length < 2) {
                      return '2자 이상 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('완료'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_error_mapper.dart';
import '../../core/validators/auth_validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/async_action_button.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/primary_scaffold.dart';
import 'auth_controller.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _errorText;
  String? _successText;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    setState(() {
      _loading = true;
      _errorText = null;
      _successText = null;
    });

    try {
      final password = _passwordController.text;
      validatePassword(password);
      if (password != _confirmPasswordController.text) {
        throw StateError('Passwords do not match.');
      }

      await ref.read(authControllerProvider).updatePassword(password);

      if (!mounted) return;
      setState(() => _successText = 'Password updated. You can now log in.');
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (mounted) context.go('/login');
    } catch (error) {
      if (mounted) setState(() => _errorText = mapToUserFacingError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Choose a new password',
      child: ListView(
        children: <Widget>[
          Text(
            'Enter a new password for your account.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          if (_errorText != null) ...<Widget>[
            ErrorBanner(message: _errorText!),
            const SizedBox(height: 12),
          ],
          if (_successText != null) ...<Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _successText!,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          AppTextField(
            controller: _passwordController,
            hintText: 'New password',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirm new password',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 20),
          AsyncActionButton(
            label: 'Update password',
            loading: _loading,
            onPressed: _updatePassword,
          ),
        ],
      ),
    );
  }
}

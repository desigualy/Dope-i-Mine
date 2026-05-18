import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_error_mapper.dart';
import '../../core/validators/auth_validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/async_action_button.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../providers.dart';
import '../../app/post_auth_route.dart';
import '../core/widgets/dopei_guide.dart';
import 'auth_controller.dart';

class ForcePasswordChangeScreen extends ConsumerStatefulWidget {
  const ForcePasswordChangeScreen({super.key});

  @override
  ConsumerState<ForcePasswordChangeScreen> createState() =>
      _ForcePasswordChangeScreenState();
}

class _ForcePasswordChangeScreenState
    extends ConsumerState<ForcePasswordChangeScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  String? _errorText;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      validatePassword(password);
      if (password != confirmPassword) {
        throw StateError('Passwords do not match.');
      }

      await ref
          .read(authControllerProvider)
          .completeForcedPasswordChange(password);

      final authUser = ref.read(authRepositoryProvider).getCurrentUser();
      if (authUser == null) {
        throw StateError('No authenticated user is available.');
      }

      final targetRoute = await resolvePostAuthRoute(ref, authUser);

      if (mounted) {
        context.go(targetRoute);
      }
    } catch (error) {
      setState(() => _errorText = mapToUserFacingError(error));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Change temporary password',
      child: ListView(
        children: <Widget>[
          const DopeiGuide(
            text:
                'Before continuing, create your own password. This replaces the temporary password used for first sign-in.',
            mood: DopeiMood.happy,
          ),
          const SizedBox(height: 32),
          if (_errorText != null) ...<Widget>[
            ErrorBanner(message: _errorText!),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: AppTextField(
              controller: _passwordController,
              hintText: 'New Password',
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
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppTextField(
              controller: _confirmPasswordController,
              hintText: 'Confirm New Password',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _changePassword(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AsyncActionButton(
            label: 'Update Password',
            loading: _loading,
            onPressed: _changePassword,
          ),
        ],
      ),
    );
  }
}

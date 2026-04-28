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
import 'auth_controller.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorText;
  bool _redirectChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_redirectChecked) return;
    _redirectChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectIfAlreadyAuthenticated();
    });
  }

  Future<void> _redirectIfAlreadyAuthenticated() async {
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser == null || !mounted) return;

    final profileRepository = ref.read(profileRepositoryProvider);
    await profileRepository.ensureProfileExists(
      userId: authUser.id,
      email: authUser.email,
    );
    final onboardingComplete =
        await profileRepository.isOnboardingComplete(authUser.id);

    if (!mounted) return;
    context.go(onboardingComplete ? '/home' : '/branding/intro');
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Create account',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_errorText != null) ...<Widget>[
            ErrorBanner(message: _errorText!),
            const SizedBox(height: 12),
          ],
          AppTextField(controller: _emailController, hintText: 'Email'),
          const SizedBox(height: 12),
          AppTextField(controller: _passwordController, hintText: 'Password'),
          const SizedBox(height: 16),
          AsyncActionButton(
            label: 'Create account',
            loading: _loading,
            onPressed: () async {
              setState(() {
                _loading = true;
                _errorText = null;
              });
              try {
                validateEmail(_emailController.text);
                validatePassword(_passwordController.text);
                final signedUpUser =
                    await ref.read(authControllerProvider).signUp(
                          _emailController.text.trim(),
                          _passwordController.text,
                        );
                final authUser = signedUpUser ??
                    ref.read(authRepositoryProvider).getCurrentUser();
                if (authUser != null) {
                  await ref.read(profileRepositoryProvider).ensureProfileExists(
                        userId: authUser.id,
                        email: authUser.email,
                      );
                }
                if (mounted) {
                  context.go(authUser == null ? '/login' : '/branding/intro');
                }
              } catch (error) {
                setState(() => _errorText = mapToUserFacingError(error));
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
          ),
        ],
      ),
    );
  }
}

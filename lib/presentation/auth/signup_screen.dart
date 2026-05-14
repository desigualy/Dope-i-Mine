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
  String _accountType = 'user';

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

    final targetRoute = await resolvePostAuthRoute(ref, authUser);

    if (!mounted) return;
    context.go(targetRoute);
  }

  bool _obscurePassword = true;

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
          AppTextField(
            controller: _emailController,
            hintText: 'Email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _passwordController,
            hintText: 'Password',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'I am signing up as',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _AccountTypeButton(
                  selected: _accountType == 'user',
                  icon: Icons.self_improvement_rounded,
                  title: 'User',
                  subtitle: 'I want support for my routines and tasks.',
                  onTap: () => setState(() => _accountType = 'user'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AccountTypeButton(
                  selected: _accountType == 'caregiver',
                  icon: Icons.volunteer_activism_rounded,
                  title: 'Caregiver',
                  subtitle: 'I help someone manage support and routines.',
                  onTap: () => setState(() => _accountType = 'caregiver'),
                ),
              ),
            ],
          ),
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
                          accountType: _accountType,
                        );
                final authUser = signedUpUser ??
                    ref.read(authRepositoryProvider).getCurrentUser();
                final targetRoute = authUser == null
                    ? '/login'
                    : await resolvePostAuthRoute(
                        ref,
                        authUser,
                        accountType: _accountType,
                      );
                if (mounted) {
                  context.go(targetRoute);
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

class _AccountTypeButton extends StatelessWidget {
  const _AccountTypeButton({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? scheme.primaryContainer.withOpacity(0.55)
          : scheme.surfaceContainerHighest.withOpacity(0.4),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 142),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.25,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:chinese_lens/common/widgets/app_button.dart';
import 'package:chinese_lens/common/widgets/app_text_field.dart';
import 'package:chinese_lens/config/constants.dart';
import 'package:chinese_lens/features/auth/presentation/bloc/bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(LogInRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ));
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushReplacementNamed(RouteConstants.register);
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(const GoogleSignInRequested());
  }

  void _resetPassword() {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '请输入邮箱地址以重置密码';
      });
      return;
    }

    context.read<AuthBloc>().add(ForgotPasswordRequested(
          email: _emailController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.of(context).pushReplacementNamed(RouteConstants.home);
        } else if (state.status == AuthStatus.unauthenticated &&
            state.errorMessage != null) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.errorMessage;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          _isLoading = state.status == AuthStatus.unknown;

          return Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(UiConstants.paddingL),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        const Icon(
                          Icons.camera_alt,
                          size: 80,
                          color: Color(AppTheme.primaryColor),
                        ),
                        const SizedBox(height: UiConstants.paddingM),

                        // Title
                        Text(
                          'app.title'.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: UiConstants.paddingXs),

                        // Subtitle
                        Text(
                          'app.tagline'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: UiConstants.paddingXl),

                        // Error message
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(UiConstants.paddingM),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.errorContainer,
                              borderRadius:
                                  BorderRadius.circular(UiConstants.cardRadius),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: UiConstants.paddingM),
                        ],

                        // Email field
                        AppTextField(
                          label: 'auth.email'.tr(),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入邮箱地址';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return '请输入有效的邮箱地址';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: UiConstants.paddingM),

                        // Password field
                        AppTextField(
                          label: 'auth.password'.tr(),
                          controller: _passwordController,
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入密码';
                            }
                            if (value.length < 6) {
                              return '密码长度至少为6位';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: UiConstants.paddingS),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _resetPassword,
                            child: Text('auth.forgotPassword'.tr()),
                          ),
                        ),
                        const SizedBox(height: UiConstants.paddingM),

                        // Login button
                        AppButton(
                          text: 'auth.login'.tr(),
                          onPressed: _submitForm,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: UiConstants.paddingM),

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: UiConstants.paddingM),
                              child: Text('auth.or'.tr()),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: UiConstants.paddingM),

                        // Google sign in
                        AppButton(
                          text: 'auth.continueWithGoogle'.tr(),
                          onPressed: _signInWithGoogle,
                          type: ButtonType.secondary,
                          icon: Icons.g_mobiledata,
                        ),
                        const SizedBox(height: UiConstants.paddingL),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('auth.dontHaveAccount'.tr()),
                            TextButton(
                              onPressed: _navigateToRegister,
                              child: Text('auth.signUp'.tr()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

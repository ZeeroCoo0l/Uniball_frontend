import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/components/launch_handler_homepage.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';
import 'package:uniball_frontend_2/services/login_services/email_login_service.dart';
import 'package:uniball_frontend_2/services/login_services/google_login_service.dart';
import 'package:uniball_frontend_2/Screens/restorepassword.dart';
import 'package:uniball_frontend_2/components/MainScaffold/uniballappbar.dart';
import 'create_or_join_team.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailLoginService = EmailLoginService();
  final _backendUserCommunication = BackendUserCommunication();

  final bool _isPasswordVisible = false;
  final bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _loginError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _loginError = null;
    });

    try {
      final success = await _emailLoginService.logIn(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;
      if (success) {
        if (mounted) {
          UserClient? currentUser = await _backendUserCommunication.getCurrentUser();
          if(currentUser == null ){
            throw Exception("Could not find currentUser when logging in.");
          }
          if(currentUser.teamId == "-1"){
            Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const CreateOrJoinTeam()),
            (Route<dynamic> route) => false,
          );
          }
          else{
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LaunchHandlerHomepage()),(Route<dynamic> route) => false);
          }
          
        }
      } else {
        if (mounted) {
          setState(() {
            _loginError = 'invalid credentials';
          });
        }
      }
    } catch (e) {
      debugPrint('Login error caught: ${e.toString()}');
      if (mounted) {
        final errorMessage = e.toString().toLowerCase();
        debugPrint('Error message: $errorMessage');

        if (errorMessage.contains('email not confirmed') ||
            errorMessage.contains('email_not_verified')) {
          debugPrint('Showing verification dialog');
          _showVerificationDialog();
        } else if (errorMessage.contains('invalid login credentials')) {
          setState(() {
            _loginError = 'invalid credentials';
          });
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verifiera din email'),
          content: const Text(
            'Din email är inte verifierad. Vill du att vi skickar ett nytt verifieringsmail?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Avbryt'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _emailLoginService.resendVerificationEmail(
                    _emailController.text,
                  );
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verifieringsmail skickat')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kunde inte skicka verifieringsmail: $e'),
                    ),
                  );
                }
              },
              child: const Text('Skicka verifieringsmail'),
            ),
          ],
        );
      },
    );
  }

  _googleSignUpHandler(BuildContext context) async {
    bool result = await GoogleLoginService().nativeGoogleSignIn();
    if (result) {
      UserClient? currentUser = await _backendUserCommunication.getCurrentUser();
      if(currentUser == null ){
        throw Exception("Could not find currentUser when logging in.");
      }
      if(currentUser.teamId == "-1"){
        Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CreateOrJoinTeam()),
        (Route<dynamic> route) => false,
      );
      }
      else{
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LaunchHandlerHomepage()),
          (Route<dynamic> route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniballAppBar(showBackButton: true),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, size: 80, color: Colors.black),
                  const SizedBox(height: 16),
                  const Text(
                    'Logga in',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Logga in för att fortsätta.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFEAF6EA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Lösenord',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    validator: _validatePassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFEAF6EA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (_loginError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Text(
                        _loginError!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A990E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                if (_formKey.currentState!.validate()) {
                                  _handleLogin();
                                }
                              },
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Logga in',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A990E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed:
                          _isLoading ? null : () => _googleSignUpHandler(context),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestorePassword(),
                        ),
                      );
                    },
                    child: const Text(
                      'Har du glömt ditt lösenord?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

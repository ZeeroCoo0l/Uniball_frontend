import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/Screens/Login&SignUp/create_or_join_team.dart';
import 'package:uniball_frontend_2/Screens/homepage.dart';
import 'package:uniball_frontend_2/Screens/Login&SignUp/login_page.dart';
import 'package:uniball_frontend_2/components/launch_handler_homepage.dart';
import 'package:uniball_frontend_2/services/login_services/email_login_service.dart';
import 'package:uniball_frontend_2/services/login_services/google_login_service.dart';
import 'package:uniball_frontend_2/components/MainScaffold/uniballappbar.dart';

/// Denna sidan sköter inloggning med användaren. Ifall man redan har loggat in, kommer man att
/// automatiskt loggas in till HomePage.


class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<StatefulWidget> createState() => CreateAccountPageState();
}

class CreateAccountPageState extends State<CreateAccountPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @protected
  final TextEditingController emailController = TextEditingController();
  @protected
  final TextEditingController passwordController = TextEditingController();
  @protected
  final TextEditingController confirmPasswordController =
      TextEditingController();
  @protected
  final TextEditingController usernameController = TextEditingController();
  final EmailLoginService service = EmailLoginService();
  bool isLoading = false;
  String? lastRegisteredEmail;

  // Make validation methods accessible for testing
  @protected
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @protected
  String? validatePassword(String? value) {
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
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character (!@#%^&*(),.?":{}|<>)';
    }
    return null;
  }

  @protected
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @protected
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    return null;
  }

  Future<void> _handleSignUp() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      bool result = false;
      try {
        result = await service.signUpNewUser(
          emailController.text,
          passwordController.text,
          usernameController.text,
        );
        if (!mounted) return;
        if (result) {
          lastRegisteredEmail = emailController.text;
          _showVerificationDialog();
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Sign-up failed')));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign-up failed: $e')));
      } finally {
        if (mounted)
          setState(() {
            isLoading = false;
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
            'Vi har skickat ett verifieringsmail till din email. Vänligen verifiera din email för att fortsätta.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (lastRegisteredEmail != null) {
                  try {
                    await service.resendVerificationEmail(lastRegisteredEmail!);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verifieringsmail skickat igen'),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kunde inte skicka verifieringsmail: $e'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Skicka verifieringsmail igen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Jag har verifierat'),
            ),
          ],
        );
      },
    );
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
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  const Icon(Icons.person, size: 80, color: Colors.black),
                  const SizedBox(height: 16),
                  const Text(
                    'Registrera dig',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: usernameController,
                    validator: validateUsername,
                    decoration: InputDecoration(
                      labelText: 'användarnamn',
                      filled: true,
                      fillColor: Color(0xFFEAF6EA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    validator: validateEmail,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Color(0xFFEAF6EA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    validator: validatePassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Lösenord',
                      filled: true,
                      fillColor: Color(0xFFEAF6EA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    validator: validateConfirmPassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Bekräfta lösenord',
                      filled: true,
                      fillColor: Color(0xFFEAF6EA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1A990E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed:
                          isLoading
                              ? null
                              : () => _googleSignUpHandler(context),
                      child:
                          isLoading
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
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1A990E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: isLoading ? null : _handleSignUp,
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Registrera dig',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text(
                      'Har du redan ett konto? Logga in',
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _googleSignUpHandler(BuildContext context) async {
    bool result = await GoogleLoginService().nativeGoogleSignIn();
    if (result) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => CreateOrJoinTeam()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<bool> _openLoginForm(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    EmailLoginService service = EmailLoginService();
    bool result = false;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Log in'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(hintText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(hintText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  emailController.clear();
                  passwordController.clear();
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    result = await service.logIn(
                      emailController.text,
                      passwordController.text,
                    );
                    if (result) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LaunchHandlerHomepage()),
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login failed')),
                      );
                    }
                  }
                },
                child: const Text("Sign Up"),
              ),
            ],
          ),
    );
    return result;
  }
}
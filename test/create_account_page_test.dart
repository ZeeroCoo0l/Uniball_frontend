import 'package:flutter_test/flutter_test.dart';
import 'package:uniball_frontend_2/Screens/Login&SignUp/create_account_page_testable.dart';

void main() {
  group('CreateAccountPage Form Validation', () {
    late CreateAccountPageTestableState pageState;

    setUp(() {
      pageState = CreateAccountPageTestableState();
    });

    group('Email Validation', () {
      test('should return null for valid email', () {
        expect(pageState.validateEmail('test@example.com'), null);
        expect(pageState.validateEmail('user.name@domain.co.uk'), null);
        expect(pageState.validateEmail('user+tag@example.com'), null);
      });

      test('should return error for invalid email', () {
        expect(pageState.validateEmail(''), 'Please enter your email');
        expect(pageState.validateEmail(null), 'Please enter your email');
        expect(
          pageState.validateEmail('invalid-email'),
          'Please enter a valid email address',
        );
        expect(
          pageState.validateEmail('missing@domain'),
          'Please enter a valid email address',
        );
        expect(
          pageState.validateEmail('@missing-local.com'),
          'Please enter a valid email address',
        );
      });
    });

    group('Password Validation', () {
      test('should return null for valid password', () {
        expect(pageState.validatePassword('Test123!@#'), null);
        expect(pageState.validatePassword('Complex1Pass!'), null);
        expect(pageState.validatePassword('Abc123!@#\$%^'), null);
      });

      test('should return error for invalid password', () {
        expect(pageState.validatePassword(''), 'Please enter your password');
        expect(pageState.validatePassword(null), 'Please enter your password');
        expect(
          pageState.validatePassword('short'),
          'Password must be at least 8 characters long',
        );
        expect(
          pageState.validatePassword('lowercase123!'),
          'Password must contain at least one uppercase letter',
        );
        expect(
          pageState.validatePassword('UPPERCASE123!'),
          'Password must contain at least one lowercase letter',
        );
        expect(
          pageState.validatePassword('NoNumbers!'),
          'Password must contain at least one number',
        );
        expect(
          pageState.validatePassword('NoSpecial123'),
          'Password must contain at least one special character (!@#%^&*(),.?":{}|<>)',
        );
      });
    });

    group('Confirm Password Validation', () {
      test('should return null for matching passwords', () {
        pageState.passwordController.text = 'Test123!@#';
        expect(pageState.validateConfirmPassword('Test123!@#'), null);
      });

      test('should return error for non-matching passwords', () {
        pageState.passwordController.text = 'Test123!@#';
        expect(
          pageState.validateConfirmPassword(''),
          'Please confirm your password',
        );
        expect(
          pageState.validateConfirmPassword(null),
          'Please confirm your password',
        );
        expect(
          pageState.validateConfirmPassword('Different123!'),
          'Passwords do not match',
        );
      });
    });

    group('Username Validation', () {
      test('should return null for valid username', () {
        expect(pageState.validateUsername('validuser'), null);
        expect(pageState.validateUsername('user123'), null);
        expect(pageState.validateUsername('user_name'), null);
      });

      test('should return error for invalid username', () {
        expect(pageState.validateUsername(''), 'Please enter a username');
        expect(pageState.validateUsername(null), 'Please enter a username');
        expect(
          pageState.validateUsername('ab'),
          'Username must be at least 3 characters long',
        );
      });
    });
  });
}

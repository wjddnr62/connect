import 'package:connect/utils/regular_expressions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validateEmailFormat(String)#1', () {
    String password = 'aaa';
    bool expected = false;
    bool actual = validateEmailFormat(password);
    expect(expected, actual);

    password = 'aaa@aa';
    expected = false;
    actual = validateEmailFormat(password);
    expect(expected, actual);

    password = 'aaa@aa.aa';
    expected = true;
    actual = validateEmailFormat(password);
    expect(expected, actual);

    password = 'aaa@aa.aa.aa';
    expected = true;
    actual = validateEmailFormat(password);
    expect(expected, actual);

    password = 'ab.ab@abc.co';
    expected = true;
    actual = validateEmailFormat(password);
    expect(expected, actual);

    password = '12ab.ab@abc.co';
    expected = true;
    actual = validateEmailFormat(password);
    expect(expected, actual);
  });

  group('check password lenght', () {
    test('checkPasswordLength(String)#3', () {
      String password = 'aaa';
      bool expected = false;
      bool actual = checkPasswordLength(password);
      expect(expected, actual);
    });
    test('checkPasswordLength(String)#0', () {
      String password = '';
      bool expected = false;
      bool actual = checkPasswordLength(password);
      expect(expected, actual);
    });
    test('checkPasswordLength(String)#7', () {
      String password = 'aaaaaaa';
      bool expected = false;
      bool actual = checkPasswordLength(password);
      expect(expected, actual);
    });
    test('checkPasswordLength(String)#8', () {
      String password = 'aaaaaaaa';
      bool expected = true;
      bool actual = checkPasswordLength(password);
      expect(expected, actual);
    });
    test('checkPasswordLength(String)#9', () {
      String password = 'aaaaaaaaa';
      bool expected = true;
      bool actual = checkPasswordLength(password);
      expect(expected, actual);
    });
    test('checkPasswordLength(String)#19', () {
      String password = 'aaaaaaaaaaaaaaaaaaa';
      bool expected = true;
      bool actual = checkPasswordLength(password);
      expect(expected, actual);
    });
    test('checkPasswordLength(String)#20', () {
      String password = 'aaaaaaaaaaaaaaaaaaaa';
      bool expected = true;
      bool actual = checkPasswordLength(password);
      expect(expected, actual);
    });
    test('checkPasswordLength(String)#21', () {
      String password = 'aaaaaaaaaaaaaaaaaaaaa';
      bool expected = false;
      bool actual = checkPasswordLength(password);
      expect(expected, actual);
    });
  });

  group('check include at least one lower case character', () {
    test('checkPasswordLowerCase(String)#1', () {
      String password = 'aABC';
      bool expected = true;
      bool actual = checkPasswordLowerCase(password);
      expect(expected, actual);
    });

    test('checkPasswordLowerCase(String)#2', () {
      String password = 'ABC';
      bool expected = false;
      bool actual = checkPasswordLowerCase(password);
      expect(expected, actual);
    });

    test('checkPasswordLowerCase(String)#3', () {
      String password = '!@';
      bool expected = false;
      bool actual = checkPasswordLowerCase(password);
      expect(expected, actual);
    });
  });

  group('check include at least one upper case character', () {
    test('checkPasswordUpperCase(String)#1', () {
      String password = 'aaaaaaaaaaaaaaaaaaaaa';
      bool expected = false;
      bool actual = checkPasswordUpperCase(password);
      expect(expected, actual);
    });

    test('checkPasswordUpperCase(String)#2', () {
      String password = 'aaaaaaaaaaaaAaaaaaaaaa';
      bool expected = true;
      bool actual = checkPasswordUpperCase(password);
      expect(expected, actual);
    });
  });

  group('check include at least one special character', () {
    test('checkPasswordSpecialChar(String)#1', () {
      String password = 'AAA';
      bool expected = false;
      bool actual = checkPasswordSpecialChar(password);
      expect(expected, actual);
    });

    test('checkPasswordSpecialChar(String)#2', () {
      String password = 'aaa';
      bool expected = false;
      bool actual = checkPasswordSpecialChar(password);
      expect(expected, actual);
    });

    test('checkPasswordSpecialChar(String)#3', () {
      String password = '!@#';
      bool expected = true;
      bool actual = checkPasswordSpecialChar(password);
      expect(expected, actual);
    });

    test('checkPasswordSpecialChar(String)#4', () {
      String password = '!@#acb';
      bool expected = true;
      bool actual = checkPasswordSpecialChar(password);
      expect(expected, actual);
    });

    test('checkPasswordSpecialChar(String)#5', () {
      String password = '!@#AbcE';
      bool expected = true;
      bool actual = checkPasswordSpecialChar(password);
      expect(expected, actual);
    });
  });

  group('check include at least one numeric character', () {
    test('checkPasswordNumeric(String)#1', () {
      String password = 'abc';
      bool expected = false;
      bool actual = checkPasswordNumeric(password);
      expect(expected, actual);
    });

    test('checkPasswordNumeric(String)#2', () {
      String password = 'ABC!';
      bool expected = false;
      bool actual = checkPasswordNumeric(password);
      expect(expected, actual);
    });

    test('checkPasswordNumeric(String)#3', () {
      String password = '123AB!';
      bool expected = true;
      bool actual = checkPasswordNumeric(password);
      expect(expected, actual);
    });
  });

  group('check invalid character', () {
    test('checkInvalidChar(String)#1', () {
      String password = ' alkj9';
      bool expected = true;
      bool actual = checkInvalidChar(password);
      expect(expected, actual);
    });

    test('checkInvalidChar(String)#2', () {
      String password = 'ABC!';
      bool expected = false;
      bool actual = checkInvalidChar(password);
      expect(expected, actual);
    });

    test('checkInvalidChar(String)#3', () {
      String password = 'ponuco   (';
      bool expected = true;
      bool actual = checkInvalidChar(password);
      expect(expected, actual);
    });
  });

  group('test validate password', () {
    test('length ', () {
      String password = 'aaa';
      PasswordRuleViolation expected = PasswordRuleViolation.Length;
      PasswordRuleViolation actual = validatePassword(password);
      expect(expected, actual);
    });

    test('lower case', () {
      String password = '15357QWER!';
      PasswordRuleViolation expected = PasswordRuleViolation.LowerCase;
      PasswordRuleViolation actual = validatePassword(password);
      expect(expected, actual);
    });

    test('upper case', () {
      String password = '1357qwer!';
      PasswordRuleViolation expected = PasswordRuleViolation.UpperCase;
      PasswordRuleViolation actual = validatePassword(password);
      expect(expected, actual);
    });

    test('numeric', () {
      String password = 'qwertYUIO!';
      PasswordRuleViolation expected = PasswordRuleViolation.Numeric;
      PasswordRuleViolation actual = validatePassword(password);
      expect(expected, actual);
    });

    test('special char', () {
      String password = '1234qwER';
      PasswordRuleViolation expected = PasswordRuleViolation.SpecialChar;
      PasswordRuleViolation actual = validatePassword(password);
      expect(expected, actual);
    });

    test('invalid char', () {
      String password = '1354qwerT YUI!';
      PasswordRuleViolation expected = PasswordRuleViolation.InvalidChar;
      PasswordRuleViolation actual = validatePassword(password);
      expect(expected, actual);
    });
  });

  group('check consecutive character', () {
    test('checkConsecutive character(String)#1', () {
      String password = '1';
      bool expected = false;
      bool actual = checkConsecutiveChar(password);
      expect(actual, expected);
    });

    test('checkConsecutive character(String)#2', () {
      String password = '111';
      bool expected = false;
      bool actual = checkConsecutiveChar(password);
      expect(actual, expected);
    });

    test('checkConsecutive character(String)#2', () {
      String password = 'abc';
      bool expected = true;
      bool actual = checkConsecutiveChar(password);
      expect(actual, expected);
    });

    test('checkConsecutive character(String)#3', () {
      String password = '11111aaaabbbbbb';
      bool expected = false;
      bool actual = checkConsecutiveChar(password);
      expect(actual, expected);
    });

    test('checkConsecutive character(String)#4', () {
      String password = '111abc222';
      bool expected = true;
      bool actual = checkConsecutiveChar(password);
      expect(actual, expected);
    });

    test('checkConsecutive character(String)#5', () {
      String password = '41524145671';
      bool expected = true;
      bool actual = checkConsecutiveChar(password);
      expect(actual, expected);
    });

    test('checkConsecutive character(String)#6', () {
      String password = '';
      bool expected = false;
      bool actual = checkConsecutiveChar(password);
      expect(actual, expected);
    });

  });
}

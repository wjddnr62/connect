import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

const _EMAIL_EXP =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

const _PASSWORD_ALPHABET_EXP = r'(.*[a-zA-Z].*)';
const _PASSWORD_LOWER_EXP = r'(.*[a-z].*)';
const _PASSWORD_UPPER_EXP = r'(.*[A-Z].*)';
const _PASSWORD_NUMERIC_EXP = r'(.*[0-9].*)';
const _PASSWORD_SPECIAL_EXP = r'(.*[\~\!\@\#\$\%\^\&\*\(\)\-\_\+\=].*)';

/// const _PASSWORD_INVALID_CHAR_EXP = r'(.*[^a-zA-Z0-9].*)';
const _PASSWORD_INVALID_CHAR_EXP =
    r'(.*[^a-zA-Z0-9\~\!\@\#\$\%\^\&\*\(\)\-\_\+\=].*)';
const _PASSWORD_LENGTH_EXP = r'^.{10,20}$';
const _PASSWORD_SAME_CHAR_EXP = r'(\w)\1';
const _PASSWORD_CONSECUTIVE_CHAR_LENGTH = 3;

const _URL_EXP = (r'(?:https?):\/\/?[\w/\-?=%.]+\.[\w/\-?=%.]+');

bool validateEmailFormat(String email) {
  RegExp exp = new RegExp(_EMAIL_EXP);
  return exp.hasMatch(email);
}

bool checkPasswordLength(String pwd) {
  return RegExp(_PASSWORD_LENGTH_EXP).hasMatch(pwd);
}

@visibleForTesting
bool checkPasswordAlphabet(String pwd) {
  return RegExp(_PASSWORD_ALPHABET_EXP).hasMatch(pwd);
}

@visibleForTesting
bool checkPasswordLowerCase(String pwd) {
  return RegExp(_PASSWORD_LOWER_EXP).hasMatch(pwd);
}

@visibleForTesting
bool checkPasswordUpperCase(String pwd) {
  return RegExp(_PASSWORD_UPPER_EXP).hasMatch(pwd);
}

@visibleForTesting
bool checkPasswordNumeric(String pwd) {
  return RegExp(_PASSWORD_NUMERIC_EXP).hasMatch(pwd);
}

@visibleForTesting
bool checkPasswordSpecialChar(String pwd) {
  return RegExp(_PASSWORD_SPECIAL_EXP).hasMatch(pwd);
}

@visibleForTesting
bool checkInvalidChar(String pwd) {
  return RegExp(_PASSWORD_INVALID_CHAR_EXP).hasMatch(pwd);
}

@visibleForTesting
bool checkConsecutiveChar(String pwd) {
  if (pwd?.isEmpty == true || pwd.length < _PASSWORD_CONSECUTIVE_CHAR_LENGTH)
    return false;

  List<int> codeUnits = pwd.codeUnits;
  for (int i = 0;
      i < codeUnits.length - (_PASSWORD_CONSECUTIVE_CHAR_LENGTH - 1);
      i++) {
    int lastDiff = 0;
    for (int j = 0; j < _PASSWORD_CONSECUTIVE_CHAR_LENGTH - 1; j++) {
      int diff = (codeUnits[i + j] - codeUnits[i + j + 1]);
      if (diff.abs() != 1) break;
      if (j != 0 && lastDiff != diff) break;
      if (j == _PASSWORD_CONSECUTIVE_CHAR_LENGTH - 2) return true;
      lastDiff = diff;
    }
  }
  return false;
}

@visibleForTesting
bool checkRepeatChar(String pwd) {
  return RegExp(_PASSWORD_SAME_CHAR_EXP).hasMatch(pwd);
}

PasswordRuleViolation validatePassword(String pwd) {
  var validatePassword3 = checkPassword(pwd, true);
  return validatePassword3.isEmpty
      ? PasswordRuleViolation.None
      : validatePassword3.first;
}

List<PasswordRuleViolation> checkPassword(String pwd,
    [bool onlyFirst = false]) {
  List<PasswordRuleViolation> violations = [];

  /// The password should be at least 10 characters.
  if (!checkPasswordLength(pwd)) {
    violations.add(PasswordRuleViolation.Length);
    if (onlyFirst) return violations;
  }

  /// It'll be removed.
  /// if (!checkPasswordAlphabet(pwd)) return PasswordRuleViolation.Alphabet;

  /// if (!checkPasswordLowerCase(pwd)) return PasswordRuleViolation.LowerCase;

  /// if (!checkPasswordUpperCase(pwd)) return PasswordRuleViolation.UpperCase;

  /// if (!checkPasswordNumeric(pwd)) return PasswordRuleViolation.Numeric;

  /// if (!checkPasswordSpecialChar(pwd)) return PasswordRuleViolation.SpecialChar;

  /// if (checkInvalidChar(pwd)) return PasswordRuleViolation.InvalidChar;

  /// The password should be non-continuous characters or numbers.
  if (checkConsecutiveChar(pwd) || checkRepeatChar(pwd) || pwd.length < 2) {
    violations.add(PasswordRuleViolation.Consecutive);
    if (onlyFirst) return violations;
  }

  /// The password should contain at least two types of : Capital letters, Lower case letters, Numbers, and Special characters.
  var checkTypeFunctions = [
    checkPasswordLowerCase,
    checkPasswordUpperCase,
    checkPasswordNumeric,
    checkPasswordSpecialChar
  ];
  var typeCount = 0;
  for (var checkfunc in checkTypeFunctions) {
    if (checkfunc(pwd)) {
      if (++typeCount >= 2) {
        // return PasswordRuleViolation.None;
        return violations;
      }
    }
  }
  violations.add(PasswordRuleViolation.Type);
  return violations;
}

enum PasswordRuleViolation {
  None,
  Length,
  Consecutive,
  Type,

  /// TEMP - It'll be removed
  Alphabet,
  LowerCase,
  UpperCase,
  Numeric,
  SpecialChar,
  InvalidChar,
}

String urlRegexString() {
  return _URL_EXP;
}

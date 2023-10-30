const ROLE_CAREGIVER = 'CAREGIVER';
const ROLE_PATIENT = 'PATIENT';

class SignInfo {
  String password;
  String emailId;
  String role = ROLE_PATIENT;
  String emailVerificationToken;

  static final SignInfo _instance = SignInfo._();

  static SignInfo get instance => _instance;

  SignInfo._();

  void reset() {
    password = '';
    emailId = '';
    role = ROLE_PATIENT;
    emailVerificationToken = '';
  }
}

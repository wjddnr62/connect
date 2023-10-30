import 'package:connect/data/remote/base_service.dart';
import 'package:connect/data/remote/user/register_user_service.dart';
import 'package:connect/models/error.dart';

import '../auth/login_service.dart';

class SignupService {
  final email;
  final password;
  final role;

  // final emailVerificationToken;
  final name;
  final birthday;

  SignupService(
      {@required this.email,
      @required this.password,
      @required this.role,
      // @required this.emailVerificationToken,
      @required this.name,
      this.birthday});

  Future<dynamic> start() async {
    var ret = await RegisterUserService(
            email: email,
            password: password,
            role: role,
            emailVerificationToken: "",
            name: name,
            birthday: birthday)
        .start();

    if (ret is ServiceError) {
      return ret;
    }

    return await LoginService(email: email, password: password).start();
  }
}

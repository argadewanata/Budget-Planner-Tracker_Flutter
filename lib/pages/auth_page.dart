import 'package:auto_size_text/auto_size_text.dart';
import 'package:budgetplannertracker/services/auth_service.dart';
import 'package:budgetplannertracker/widgets/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

const primaryColor = Color(0xFF75A2EA);

enum AuthType { login, register, guest, convert, reset }

class AuthPage extends StatefulWidget {
  final AuthType authType;

  const AuthPage({super.key, required this.authType});

  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  AuthType? authType;

  _AuthPageState();

  @override
  void initState() {
    super.initState();
    authType = widget.authType;
  }

  final formKey = GlobalKey<FormState>();
  String? _email, _password, _name, _warning;

  void switchAuthState(String state) {
    formKey.currentState?.reset();
    if (state == "register") {
      setState(() {
        authType = AuthType.register;
      });
    } else if (state == 'home') {
      Navigator.of(context).pop();
    } else {
      setState(() {
        authType = AuthType.login;
      });
    }
  }

  bool validate() {
    final form = formKey.currentState!;
    if (authType == AuthType.guest) return true;
    form.save();
    if (form.validate() == true) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void submit() async {
    if (!validate()) return;
    try {
      final auth = Provider.of(context).auth;
      switch (authType!) {
        case AuthType.login:
          await auth.loginEmail(_email!, _password!);
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed('/home');
          break;
        case AuthType.register:
          await auth.registerEmail(_email!, _password!, _name!);
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed('/home');
          break;
        case AuthType.guest:
          await auth.loginGuest();
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed('/home');
          break;
        case AuthType.convert:
          await auth.updateUserWithEmail(_email!, _password!, _name!);
          if (!mounted) return;
          Navigator.of(context).pop();
          break;
        case AuthType.reset:
          await auth.forgotPassword(_email!);
          if (!mounted) return;
          setState(() {
            _warning = 'A password reset link has been sent to $_email';
            authType = AuthType.login;
          });
          break;
      }
    } catch (e) {
      setState(() {
        _warning = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (authType == AuthType.guest) {
      submit();
      return const Scaffold(
          backgroundColor: primaryColor,
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SpinKitDoubleBounce(
                  color: Colors.white,
                ),
                Text(
                  "Loading",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ));
    } else {
      return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            color: primaryColor,
            height: height,
            width: width,
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  SizedBox(height: height * 0.025),
                  showAlert(),
                  SizedBox(height: height * 0.025),
                  buildHeaderText(),
                  SizedBox(height: height * 0.05),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: buildInputs() + buildButtons(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget showAlert() {
    if (_warning != null) {
      return Container(
        color: Colors.amberAccent,
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline),
            ),
            Expanded(
              child: AutoSizeText(
                _warning!,
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _warning = null;
                  });
                },
              ),
            )
          ],
        ),
      );
    }
    return const SizedBox(
      height: 0,
    );
  }

  AutoSizeText buildHeaderText() {
    String headerText;
    if (authType == AuthType.login) {
      headerText = "Login";
    } else if (authType == AuthType.reset) {
      headerText = "Reset Password";
    } else {
      headerText = "Create New Account";
    }
    return AutoSizeText(
      headerText,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 35,
        color: Colors.white,
      ),
    );
  }

  List<Widget> buildInputs() {
    List<Widget> textFields = [];

    // if were in the sign up state add name
    if ([AuthType.register, AuthType.convert].contains(authType)) {
      textFields.add(
        TextFormField(
          validator: NameValidator.validate,
          style: const TextStyle(fontSize: 22.0),
          decoration: buildAuthInputDecoration("Name"),
          controller: TextEditingController(text: _name),
          onSaved: (value) => _name = value,
        ),
      );
      textFields.add(const SizedBox(height: 20));
    }

    // add email & password
    if ([AuthType.register, AuthType.convert, AuthType.reset, AuthType.login]
        .contains(authType)) {
      textFields.add(
        TextFormField(
          validator: EmailValidator.validate,
          style: const TextStyle(fontSize: 22.0),
          decoration: buildAuthInputDecoration("Email"),
          controller: TextEditingController(text: _email),
          onSaved: (value) => _email = value,
        ),
      );
      textFields.add(const SizedBox(height: 20));
    }

    if (authType != AuthType.reset) {
      textFields.add(
        TextFormField(
          validator: PasswordValidator.validate,
          style: const TextStyle(fontSize: 22.0),
          decoration: buildAuthInputDecoration("Password"),
          obscureText: true,
          controller: TextEditingController(text: _password),
          onSaved: (value) => _password = value,
        ),
      );
      textFields.add(const SizedBox(height: 20));
    }

    return textFields;
  }

  InputDecoration buildAuthInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      focusColor: Colors.white,
      enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 0.0)),
      contentPadding:
          const EdgeInsets.only(left: 14.0, bottom: 10.0, top: 10.0),
    );
  }

  List<Widget> buildButtons() {
    String switchButtonText, newAuthState, submitButtonText;
    bool showForgotPassword = false;

    if (authType == AuthType.login) {
      switchButtonText = "Don't Have an Account? Register";
      newAuthState = "register";
      submitButtonText = "Log In";
      showForgotPassword = true;
    } else if (authType == AuthType.reset) {
      switchButtonText = "Return to Login";
      newAuthState = "login";
      submitButtonText = "Submit";
    } else if (authType == AuthType.convert) {
      switchButtonText = "Cancel";
      newAuthState = "home";
      submitButtonText = "Register";
    } else {
      switchButtonText = "Have an Account? Login";
      newAuthState = "login";
      submitButtonText = "Register";
    }

    return [
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          color: Colors.white,
          textColor: primaryColor,
          onPressed: submit,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              submitButtonText,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
      buildShowForgotPassword(showForgotPassword),
      TextButton(
        child: Text(
          switchButtonText,
          style: const TextStyle(color: Colors.white),
        ),
        onPressed: () {
          switchAuthState(newAuthState);
        },
      ),
    ];
  }

  Widget buildShowForgotPassword(bool visible) {
    return Visibility(
      visible: visible,
      child: TextButton(
        onPressed: () {
          setState(() {
            authType = AuthType.reset;
          });
        },
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

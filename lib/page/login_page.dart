import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tabnews/model/user.dart';
import 'package:tabnews/page/register_page.dart';
import 'package:tabnews/service/api_user.dart';
import 'package:tabnews/service/authenticated_http.dart';
import 'package:tabnews/service/messenger.dart';
import 'package:tabnews/service/storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthenticatedHttpClient auth = AuthenticatedHttpClient();
  StorageService storage = StorageService();
  ApiUser apiUser = ApiUser();

  MessengerService messengerService = MessengerService();

  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();

  bool _obscurePassword = true;

  bool doingLogin = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controllerEmail.dispose();
    controllerPassword.dispose();
  }

  Future<void> doLogin() async {
    FocusScope.of(context).unfocus();

    try {
      await auth.login(
        controllerEmail.value.text,
        controllerPassword.value.text,
      );

      final User user = User.fromJson(await apiUser.getMe());

      await storage.sharedPreferencesAddString('user_id', user.id);
      await storage.sharedPreferencesAddString('user_username', user.username);
      await storage.sharedPreferencesAddString(
          'user_features', jsonEncode(user.features));

      messengerService.show(context, text: 'Logado com sucesso!');
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        doingLogin = false;
      });
      messengerService.show(context, text: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.close,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 25),
                    child: Image.asset(
                      'assets/images/logo.png',
                      color: (Theme.of(context).brightness == Brightness.light)
                          ? Colors.black
                          : Colors.white,
                      width: 100,
                    ),
                  ),
                  const Text(
                    'Login',
                    style: TextStyle(fontSize: 24),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 30),
                  ),
                  TextField(
                    controller: controllerEmail,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      filled: true,
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                  ),
                  TextField(
                    controller: controllerPassword,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      filled: true,
                      hintText: 'Senha',
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        child: Icon(
                          _obscurePassword
                              ? Icons.remove_red_eye
                              : Icons.emergency,
                          color: Colors.black38,
                          size: 18,
                        ),
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  SizedBox(
                    width: Size.infinite.width,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (!doingLogin) {
                          doLogin();
                          setState(() {
                            doingLogin = true;
                          });
                        }
                      },
                      child: doingLogin
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text('Login'),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  SizedBox(
                    width: Size.infinite.width,
                    child: TextButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text('Criar conta'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:tabnews/service/authenticated_http.dart';
import 'package:tabnews/service/messenger.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  AuthenticatedHttpClient auth = AuthenticatedHttpClient();

  TextEditingController controllerUsername = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();

  MessengerService messengerService = MessengerService();

  bool _obscurePassword = true;

  bool doingRegister = false;

  Future<void> doRegister() async {
    try {
      await auth.register(
        controllerUsername.value.text,
        controllerEmail.value.text,
        controllerPassword.value.text,
      );

      messengerService.show(context, text: 'Conta criada com sucesso!');

      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        doingRegister = false;
      });
      messengerService.show(context, text: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Cadastro',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  maxLength: 30,
                  controller: controllerUsername,
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
                    hintText: 'Nome de usuário',
                    hintStyle: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
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
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                TextField(
                  controller: controllerPassword,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
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
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                SizedBox(
                  width: Size.infinite.width,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (!doingRegister) {
                        doRegister();
                        setState(() {
                          doingRegister = true;
                        });
                      }
                    },
                    child: doingRegister
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('Criar cadastro'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'Após o cadastro, verifique seu email!',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const Text(
                  'Você receberá um link para confirmar seu cadastro e ativar a sua conta.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  @override
  void dispose() {
    super.dispose();

    controllerUsername.dispose();
    controllerEmail.dispose();
    controllerPassword.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/config/router/main_router.dart';
import 'package:frontend_movil_muni/src/pages/auth/widget/header_login.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AuthPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // O
    final textStyles = ShadTheme.of(context).textTheme;
    double topPadd = MediaQuery.of(context).padding.top;
    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   backgroundColor: Color(0x00000000),
      //   scrolledUnderElevation: 0,
      //   shadowColor: Color(0x00000000),
      //   elevation: 0,
      // ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(
            top: topPadd - 1, // use the topPadd here
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey, // Attach the form key
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: size.height * 0.1,
                  ),
                  Image.asset(
                    'assets/logos/muni.png', // Replace with your image

                        width: size.width * 0.6,
                        fit: BoxFit
                            .fitWidth, // Otras opciones: BoxFit.contain, BoxFit.fill, BoxFit.fitHeight
                      ),
                      SizedBox(height: size.height * 0.03),
                      Container(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Gestión de Comedores Solidarios.",
                            style: textStyles.h4.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // Container(
                      //   height: size.height * 0.1,
                      //   width: size.width * 0.2,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.all(Radius.circular(100)),
                      //     color: Colors.blue[500],
                      //   ),
                      //   child: Image.asset(
                      //     'assets/logos/stocknow.png', // Replace with your image
                      //     height: 150,
                      //   ),
                      // ),
                      SizedBox(height: size.height * 0.03),
                      EmailInput(controller: _emailController),

                      SizedBox(height: 20),

                      PasswordInput(
                        controller: _passwordController,
                      ),

                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Handle "Forgot Password" action
                          },
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: textStyles.muted
                                .copyWith(color: Colors.blue[500]),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Login Button
                      ElevatedButton(
                        onPressed: () {
                          // ########### ! Comentar la linea de abajo en ambiente de PROD ##############################
                          context.go('/');
                          if (_formKey.currentState!.validate()) {
                            // If the form is valid, process the login
                            print("Email: ${_emailController.text}");
                            print("Password: ${_passwordController.text}");
                            context.go('/');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[500],
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Entrar',
                          style: textStyles.p.copyWith(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "¿Problemas con tu cuenta?",
                            style: textStyles.p,
                          ),
                          TextButton(
                            onPressed: () {
                              // Handle "Register" action
                            },
                            child: Text(
                              'Ayuda',
                              style: textStyles.p
                                  .copyWith(color: Colors.blue[500]),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text('--'),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                              "Un producto de Sistemas y Servicios Stocknow Ltda.",
                              style: textStyles.muted.copyWith(),
                              textAlign: TextAlign.justify),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordInput extends StatefulWidget {
  const PasswordInput({super.key, required this.controller});
  final TextEditingController controller;
  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return ShadInputFormField(
      controller: widget.controller,
      placeholder: const Text('Password'),
      obscureText: obscure,
      prefix: const Padding(
        padding: EdgeInsets.all(12.0),
        child: ShadImage.square(size: 16, LucideIcons.lock),
      ),
      suffix: ShadButton(
        width: 24,
        height: 24,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.blue[500],
        decoration: const ShadDecoration(
          secondaryBorder: ShadBorder.none,
          secondaryFocusedBorder: ShadBorder.none,
        ),
        icon: ShadImage.square(
          size: 16,
          obscure ? LucideIcons.eyeOff : LucideIcons.eye,
        ),
        onPressed: () {
          setState(() => obscure = !obscure);
        },
      ),
      validator: (value) {
        // Validate password field
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese su contraseña';
        }
        if (value.length < 6) {
          return 'Ingrese una contraseña valida';
        }
        return null;
      },
    );
  }
}

class EmailInput extends StatefulWidget {
  const EmailInput({super.key, required this.controller});
  final TextEditingController controller;
  @override
  State<EmailInput> createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return ShadInputFormField(
      controller: widget.controller,
      placeholder: const Text('Email'),
      prefix: const Padding(
        padding: EdgeInsets.all(12.0),
        child: ShadImage.square(size: 16, LucideIcons.mail),
      ),
      decoration: ShadDecoration(focusedBorder: ShadBorder()),
      validator: (value) {
        // Validate email field
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese su email.';
        }
        // Regular expression for email validation
        final emailRegex =
            RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return 'Ingrese un email valido';
        }
        return null;
      },
    );
  }
}

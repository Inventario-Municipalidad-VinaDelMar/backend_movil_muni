import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/src/pages/auth/widget/header_login.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/provider.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // O
    final textStyles = ShadTheme.of(context).textTheme;

    //Don't delete that, this instance triggers ..renewUser().
    final userProvider = context.watch<UserProvider>();
    //Don't delete that, this instance triggers ..initialize().
    final inventarioProvider = context.watch<InventarioProvider>();
    //Don't delete that, this instance triggers ..initialize().
    final planificacionProvider = context.watch<PlanificacionProvider>();
    //Don't delete that, this instance triggers ..initialize().
    final movimientoProvider = context.watch<MovimientoProvider>();

    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: userProvider.renewingUser
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : SingleChildScrollView(
              child: FadeIn(
                child: Column(
                  children: [
                    HeaderLogin(),
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Form(
                          key: _formKey, // Attach the form key
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/logos/muni.png', // Replace with your image

                                width: size.width * 0.6,
                                fit: BoxFit
                                    .fitWidth, // Otras opciones: BoxFit.contain, BoxFit.fill, BoxFit.fitHeight
                              ),
                              SizedBox(height: size.height * 0.03),
                              SizedBox(
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
                              ShadButton(
                                enabled: !authProvider.authenticating,
                                size: ShadButtonSize.lg,
                                width: double.infinity,
                                backgroundColor: Colors.blue[500],
                                onPressed: () async {
                                  try {
                                    if (_formKey.currentState!.validate()) {
                                      // If the form is valid, process the login
                                      await authProvider
                                          .loginWithEmailAndPassword(
                                        _emailController.value.text,
                                        _passwordController.value.text,
                                      );
                                    }
                                  } catch (e) {
                                    String error = e.toString();
                                    List<String> parts = error.split(':');
                                    String errorName = parts.length > 1
                                        ? parts[1].trim()
                                        : error;
                                    if (error ==
                                        "Exception: Credenciales no validas") {
                                      showErrorToast(
                                          context,
                                          errorName,
                                          "Las credenciales no son validas",
                                          "Intentar de nuevo");
                                    } else {
                                      showErrorToast(
                                          context,
                                          errorName,
                                          "Ha ocurrido un error desconocido",
                                          "Intentar de nuevo");
                                    }
                                  }
                                },
                                icon: !authProvider.inProgressEmailAndPassword
                                    ? null
                                    : const Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: SizedBox.square(
                                          dimension: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                child: authProvider.inProgressEmailAndPassword
                                    ? const Text('Cargando...')
                                    : const Text(
                                        'INGRESAR',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
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
      keyboardType: TextInputType.emailAddress,
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

void showErrorToast(
    BuildContext context, String titulo, String desc, String boton) {
  ShadToaster.of(context).show(
    ShadToast.destructive(
      title: Text(titulo),
      description: Text(desc),
      action: ShadButton.destructive(
        child: Text(boton),
        decoration: ShadDecoration(
          border: ShadBorder.all(
            color: Colors.red,
          ),
        ),
        onPressed: () => ShadToaster.of(context).hide(),
      ),
    ),
  );
}

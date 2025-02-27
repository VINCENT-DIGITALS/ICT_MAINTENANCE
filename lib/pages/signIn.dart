import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:servicetracker_app/api_service/auth_service.dart';
import 'package:servicetracker_app/components/appbar.dart';

import 'package:servicetracker_app/pages/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  // Password visibility
  bool _passwordVisible = false;
  final AuthService authService = AuthService();
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _signin() async {
    setState(() {
      isLoading = true;
    });
    bool success =
        await authService.login(emailController.text, passwordController.text);
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login Successful!")));
      if (context.mounted) {
        setState(() {
          isLoading = false;
        });
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid Credentials")));
      setState(() {
        isLoading = false;
      });
      if (context.mounted) {
        // setState(() {
        //   isLoading = false;
        // });
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  // error message
  //String errorMessage = '';

  // sign user in method
  late AnimationController _controller;
  @override
  void dispose() {
    // Dispose controllers
    emailController.dispose();
    passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 1;

    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Allows the body to resize when keyboard appears
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(), // Prevent excessive scrolling
          child: Column(
            children: [
              Container(
                width: double.infinity, // Ensures full width
                child: CurvedEdgesAppBar(
                  height: MediaQuery.of(context).size.height * 0.5,
                  showFooter: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                          radius: 40, backgroundColor: Colors.white),
                      const SizedBox(height: 10),
                      const Text(
                        'ICT Maintenance',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedPadding(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: _buildLoginForm(containerWidth),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    "DA - Philippine Rice Research Institute",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(containerWidth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Container(
          width: containerWidth,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            boxShadow: [
              // BoxShadow(
              //   color: Colors.grey.withOpacity(0.5),
              //   spreadRadius: 5,
              //   blurRadius: 7,
              //   offset: const Offset(0, 2), // changes position of shadow
              // ),
            ],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10), // Simplified padding
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxWidth: 500), // Max width set to 400px
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width *
                                0.9, // 90% of screen width
                            child: TextFormField(
                              controller: emailController,
                              autofocus: false,
                              obscureText: false,
                              decoration: const InputDecoration(
                                labelText: 'ID Number',
                                labelStyle: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 14,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.normal,
                                ),
                                hintStyle: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 14,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.normal,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF018203),
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFFF5963),
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFFF5963),
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                maxWidth: 500), // Set max width
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.9, // 90% of screen width
                              child: TextFormField(
                                controller: passwordController,
                                autofocus: false,
                                obscureText: !_passwordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 14,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  alignLabelWithHint: false,
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 14,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFF018203),
                                      width: 2,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  focusedErrorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFFF5963),
                                      width: 2,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  errorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFFF5963),
                                      width: 2,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  suffixIcon: InkWell(
                                    onTap: () => setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    }),
                                    focusNode: FocusNode(skipTraversal: true),
                                    child: Icon(
                                      _passwordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF57636C),
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      ),
                      // if (errorMessage.isNotEmpty)
                      //   Padding(
                      //     padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 5),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         AutoSizeText(
                      //           errorMessage,
                      //           maxLines: 2,
                      //           softWrap: true,
                      //           overflow: TextOverflow.ellipsis,
                      //           minFontSize: 8,
                      //           stepGranularity: 1,
                      //           style: const TextStyle(
                      //             fontFamily: 'Inter',
                      //             color: Colors.red,
                      //             fontSize: 11,
                      //             letterSpacing: 0,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Center the button
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 10, 0, 0),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxWidth: 500), // Max width of 400px
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.9, // 80% of screen width
                                child: ElevatedButton(
                                  onPressed: () {
                                    _signin();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15), // Responsive padding
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    backgroundColor:
                                        const Color(0xFF007A33), // Button color
                                  ),
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                          color:
                                              Colors.white) // Loading indicator
                                      : const Text(
                                          "Sign In",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

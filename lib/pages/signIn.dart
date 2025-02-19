import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:servicetracker_app/api_service/auth_service.dart';

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
    bool success =
        await authService.login(emailController.text, passwordController.text);
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login Successful!")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid Credentials")));
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
    final containerWidth = screenWidth * 0.8; // 80% of the screen width
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 219, 180, 39),
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   icon: Icon(Icons.phone, color: Colors.green, size: 40),
        //   onPressed: () => _dialNumber(phoneNumber),
        // ),
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HomePage()), // Replace `HomePage` with your target page
            );
          },
          child: const Text(' '),
        ),
        centerTitle: false,
        elevation: 2,
        actions: [],
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Column(
              children: [
                Expanded(
                    child: Row(
                  children: [
                    // Expanded(
                    //   child: Padding(
                    //     padding: const EdgeInsetsDirectional.fromSTEB(
                    //         10, 10, 10, 10),
                    //     child: Image.asset(
                    //       logoPath,
                    //       width: constraints.maxWidth *
                    //           0.5, // Adjust width based on screen size
                    //       height: constraints.maxHeight *
                    //           0.5, // Adjust height based on screen size
                    //     ),
                    //   ),
                    // ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildLoginForm(containerWidth),
                      ),
                    ),
                  ],
                ))
              ],
            );
          } else {
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Padding(
                          //   padding: const EdgeInsetsDirectional.fromSTEB(
                          //       10, 10, 10, 10),
                          //   child: Image.asset(
                          //     logoPath,
                          //     width: MediaQuery.of(context).size.width *
                          //         1.6, // Adjust width based on screen size
                          //     height: MediaQuery.of(context).size.height *
                          //         0.2, // Adjust height based on screen size
                          //   ),
                          // ),
                          _buildLoginForm(containerWidth)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          }
        }),
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
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 2), // changes position of shadow
              ),
            ],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        AutoSizeText(
                          "Sign in here",
                          maxLines: 2,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFF14181B),
                            fontSize: 25,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 10, 0, 10),
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
                                    alignLabelWithHint: false,
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

                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 10, 0, 10),
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
                                    focusedErrorBorder:
                                        const OutlineInputBorder(
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
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 10, 0, 0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _signin();
                                      },
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all(
                                          const EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 15),
                                        ),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        backgroundColor: MaterialStateProperty
                                            .resolveWith<Color>((states) {
                                          if (states.contains(
                                              MaterialState.pressed)) {
                                            return const Color.fromARGB(255, 93,
                                                255, 68); // Pressed color
                                          }
                                          return Colors.blue; // Default color
                                        }),
                                      ),
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors
                                                  .white) // Loading indicator
                                          : Text(
                                              "Sign In",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

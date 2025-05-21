import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:servicetracker_app/api_service/auth_service.dart';
import 'package:servicetracker_app/auth/sessionmanager.dart';
import 'package:servicetracker_app/components/appbar.dart';
import 'package:servicetracker_app/components/buildtextField.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final session = SessionManager();
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
    final result =
        await authService.login(emailController.text, passwordController.text);
    if (result["success"]) {
      await session.saveSession(result['token'], result['user']);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login Successful!")));
      if (context.mounted) {
        setState(() {
          isLoading = false;
        });
        Navigator.pushReplacementNamed(context, '/auth');
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid Credentials")));
      setState(() {
        isLoading = false;
      });
   
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
          false, // Allows the body to resize when keyboard appears
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: CurvedEdgesAppBar(
                              height: MediaQuery.of(context).size.height * 0.5,
                              showFooter: true,
                              backgroundImage:
                                  'assets/images/Maintenance-Login-bg.png',
                              child: const Center(
                                child: Text(
                                  'ICT Maintenance & Service Management',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          AnimatedPadding(
                            duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: _buildLoginForm(
                                MediaQuery.of(context).size.width),
                          ),
                          SizedBox(
                              height:
                                  100), // Prevent SignIn button from being too close to footer
                        ],
                      ),
                    ),
                  ),
                ),

                // Sticky Footer
                Positioned(
                  bottom: constraints.maxHeight * 0.015,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text:
                                    "© 2025 PhilRice - Information Systems Division",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Roboto",
                                ),
                              ),
                              TextSpan(
                                text: ". All rights reserved.",
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
                                0.85, // 90% of screen width
                            child: buildTextField("Philrice ID", emailController),
                            //  TextFormField(
                            //   controller: emailController,
                            //   autofocus: false,
                            //   obscureText: false,
                            //   decoration: const InputDecoration(
                            //     labelText: 'ID Number',
                            //     labelStyle: TextStyle(
                            //       fontFamily: 'Inter',
                            //       color: Color.fromARGB(255, 0, 0, 0),
                            //       fontSize: 14,
                            //       letterSpacing: 0,
                            //       fontWeight: FontWeight.normal,
                            //     ),
                            //     hintStyle: TextStyle(
                            //       fontFamily: 'Inter',
                            //       color: Color.fromARGB(255, 0, 0, 0),
                            //       fontSize: 14,
                            //       letterSpacing: 0,
                            //       fontWeight: FontWeight.normal,
                            //     ),
                            //     focusedBorder: OutlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: Color(0xFF018203),
                            //         width: 2,
                            //       ),
                            //       borderRadius:
                            //           BorderRadius.all(Radius.circular(12)),
                            //     ),
                            //     focusedErrorBorder: OutlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: Color(0xFFFF5963),
                            //         width: 2,
                            //       ),
                            //       borderRadius:
                            //           BorderRadius.all(Radius.circular(12)),
                            //     ),
                            //     enabledBorder: OutlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: Colors.black,
                            //         width: 2,
                            //       ),
                            //       borderRadius:
                            //           BorderRadius.all(Radius.circular(12)),
                            //     ),
                            //     errorBorder: OutlineInputBorder(
                            //       borderSide: BorderSide(
                            //         color: Color(0xFFFF5963),
                            //         width: 2,
                            //       ),
                            //       borderRadius:
                            //           BorderRadius.all(Radius.circular(12)),
                            //     ),
                            //   ),
                            // ),
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
                                  0.85, // 90% of screen width
                              child: TextFormField(
                                controller: passwordController,
                                autofocus: false,
                                obscureText: !_passwordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 18,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  alignLabelWithHint: false,
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 18,
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
                                      color: Color(0xFFB0B0B0),
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
                                0, 15, 0, 0),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxWidth: 500), // Max width of 400px
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.85, // 80% of screen width
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
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "LOG IN",
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

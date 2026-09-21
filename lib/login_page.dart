import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'driver_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // =========================================================
  // CONTROLLERS
  // =========================================================

  final TextEditingController usernameController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  // =========================================================
  // VARIABLES
  // =========================================================

  bool isLoading = false;
  bool hidePassword = true;

  // =========================================================
  // API URL
  // =========================================================

  final String loginUrl =
      'http://mileplusapi.f-studio.in/login';

  // =========================================================
  // LOGIN API
  // =========================================================

  Future<void> login() async {
    final String userName =
    usernameController.text.trim();

    final String password =
        passwordController.text;

    // ---------------------------------------------------------
    // USERNAME CHECK
    // ---------------------------------------------------------

    if (userName.isEmpty) {
      showMessage('Please enter username');
      return;
    }

    // ---------------------------------------------------------
    // PASSWORD CHECK
    // ---------------------------------------------------------

    if (password.isEmpty) {
      showMessage('Please enter password');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print('==============================');
      print('API LOGIN STARTED');
      print('URL: $loginUrl');
      print('USERNAME: $userName');
      print('==============================');

      // =======================================================
      // API REQUEST
      // =======================================================

      final http.Response response = await http
          .post(
        Uri.parse(loginUrl),

        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },

        // IMPORTANT:
        // API expects userName
        // NOT username
        body: jsonEncode({
          'userName': userName,
          'password': password,
        }),
      )
          .timeout(
        const Duration(seconds: 15),
      );

      // =======================================================
      // RESPONSE
      // =======================================================

      print('==============================');
      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE: ${response.body}');
      print('==============================');

      // =======================================================
      // HTTP SUCCESS
      // =======================================================

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final dynamic result =
        jsonDecode(response.body);

        if (result is Map<String, dynamic>) {
          final String status =
              result['status']?.toString() ?? '';

          final String message =
              result['message']?.toString() ?? '';

          print('API STATUS: $status');
          print('API MESSAGE: $message');

          // ===================================================
          // API LOGIN SUCCESS
          // ===================================================

          if (status.toLowerCase() == 'success' &&
              message.toLowerCase() == 'valid') {
            final dynamic data =
            result['data'];

            if (data is Map<String, dynamic>) {
              await saveSession(data);

              if (!mounted) return;

              // ===============================================
              // GO TO HOME PAGE
              // ===============================================

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const DriverHomePage(),
                ),
                    (route) => false,
              );
            } else {
              showMessage(
                'User data not found',
              );
            }
          }

          // ===================================================
          // LOGIN FAILED
          // ===================================================

          else {
            showMessage(
              message.isNotEmpty
                  ? message
                  : 'Invalid username or password',
            );
          }
        } else {
          showMessage(
            'Invalid server response',
          );
        }
      }

      // =======================================================
      // HTTP ERROR
      // =======================================================

      else {
        print(
          'HTTP ERROR: ${response.statusCode}',
        );

        showMessage(
          'Login failed. Server error ${response.statusCode}',
        );
      }
    }

    // =========================================================
    // TIMEOUT ERROR
    // =========================================================

    on TimeoutException {
      print(
        'API ERROR: TIMEOUT',
      );

      showMessage(
        'Server response timed out',
      );
    }

    // =========================================================
    // CONNECTION / OTHER ERROR
    // =========================================================

    catch (e) {
      print(
        'API ERROR: $e',
      );

      showMessage(
        'Unable to connect to server',
      );
    }

    // =========================================================
    // STOP LOADING
    // =========================================================

    finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =========================================================
  // SAVE API DATA
  // =========================================================

  Future<void> saveSession(
      Map<String, dynamic> data,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    // ---------------------------------------------------------
    // API DATA
    // ---------------------------------------------------------

    final String userId =
        data['userId']?.toString() ?? '';

    final String userName =
        data['userName']?.toString() ?? '';

    final String email =
        data['email']?.toString() ?? '';

    final String phoneNo =
        data['phoneNo']?.toString() ?? '';

    final String userType =
        data['userType']?.toString() ?? '';

    final String isAdmin =
        data['isAdmin']?.toString() ?? '';

    // ---------------------------------------------------------
    // LOGIN SESSION
    // ---------------------------------------------------------

    await prefs.setBool(
      'isLoggedIn',
      true,
    );

    // ---------------------------------------------------------
    // USER ID
    // ---------------------------------------------------------

    await prefs.setString(
      'driverId',
      userId,
    );

    // ---------------------------------------------------------
    // NAME
    // ---------------------------------------------------------

    await prefs.setString(
      'driverName',
      userName,
    );

    // ---------------------------------------------------------
    // USERNAME
    // ---------------------------------------------------------

    await prefs.setString(
      'username',
      userName,
    );

    // ---------------------------------------------------------
    // EMAIL
    // ---------------------------------------------------------

    await prefs.setString(
      'driverEmail',
      email,
    );

    // ---------------------------------------------------------
    // PHONE NUMBER
    // ---------------------------------------------------------

    await prefs.setString(
      'driverPhone',
      phoneNo,
    );

    // ---------------------------------------------------------
    // USER TYPE
    // ---------------------------------------------------------

    await prefs.setString(
      'userType',
      userType,
    );

    // ---------------------------------------------------------
    // ADMIN
    // ---------------------------------------------------------

    await prefs.setString(
      'isAdmin',
      isAdmin,
    );

    // =======================================================
    // DEBUG
    // =======================================================

    print('==============================');
    print('SESSION SAVED');
    print('User ID   : $userId');
    print('Name      : $userName');
    print('Email     : $email');
    print('Phone No  : $phoneNo');
    print('User Type : $userType');
    print('Is Admin  : $isAdmin');
    print('==============================');
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void showMessage(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF4F8F6),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.all(24),

            child: Column(
              children: [

                // =================================================
                // LOGO
                // =================================================

                Image.asset(
                  'assets/milepluslogo.png',
                  height: 100,

                  errorBuilder:
                      (context, error, stackTrace) {
                    return const Icon(
                      Icons.directions_car,
                      size: 80,
                      color:
                      Color(0xFF08743F),
                    );
                  },
                ),

                const SizedBox(
                  height: 20,
                ),

                // =================================================
                // TITLE
                // =================================================

                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    Color(0xFF12372A),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(
                  'Login to continue to MilePlus',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // =================================================
                // LOGIN CARD
                // =================================================

                Container(
                  width:
                  double.infinity,

                  padding:
                  const EdgeInsets.all(22),

                  decoration:
                  BoxDecoration(
                    color:
                    Colors.white,

                    borderRadius:
                    BorderRadius.circular(
                      24,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(
                          0.08,
                        ),
                        blurRadius: 20,
                        offset:
                        const Offset(
                          0,
                          8,
                        ),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [

                      // ===========================================
                      // USERNAME
                      // ===========================================

                      TextField(
                        controller:
                        usernameController,

                        decoration:
                        InputDecoration(
                          labelText:
                          'Username',

                          hintText:
                          'Enter username',

                          prefixIcon:
                          const Icon(
                            Icons
                                .person_outline,
                          ),

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ===========================================
                      // PASSWORD
                      // ===========================================

                      TextField(
                        controller:
                        passwordController,

                        obscureText:
                        hidePassword,

                        decoration:
                        InputDecoration(
                          labelText:
                          'Password',

                          hintText:
                          'Enter password',

                          prefixIcon:
                          const Icon(
                            Icons
                                .lock_outline,
                          ),

                          suffixIcon:
                          IconButton(
                            icon: Icon(
                              hidePassword
                                  ? Icons
                                  .visibility_off_outlined
                                  : Icons
                                  .visibility_outlined,
                            ),

                            onPressed: () {
                              setState(() {
                                hidePassword =
                                !hidePassword;
                              });
                            },
                          ),

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      // ===========================================
                      // LOGIN BUTTON
                      // ===========================================

                      SizedBox(
                        width:
                        double.infinity,

                        height: 54,

                        child:
                        ElevatedButton(
                          onPressed:
                          isLoading
                              ? null
                              : login,

                          style:
                          ElevatedButton
                              .styleFrom(
                            backgroundColor:
                            const Color(
                              0xFF08743F,
                            ),

                            foregroundColor:
                            Colors.white,

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                14,
                              ),
                            ),
                          ),

                          child: isLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,

                            child:
                            CircularProgressIndicator(
                              strokeWidth:
                              2.5,
                              color:
                              Colors.white,
                            ),
                          )
                              : const Text(
                            'LOGIN',

                            style:
                            TextStyle(
                              fontSize:
                              16,
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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
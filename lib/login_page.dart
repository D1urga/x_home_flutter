// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
// import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
// import 'package:x_home/home_page.dart';
import 'package:x_home/main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final Dio _dio = Dio();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      try {
        final response = await _dio.post(
          'https://xhomebackend.onrender.com/api/v1/user/login',
          data: {
            'email': email,
            'password': password,
          },
        );

        if (response.statusCode == 200) {
          var data = response.data;
          print(data["data"]["user"]["_id"]);
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setString("email", email);
          pref.setString("id", data["data"]["user"]["_id"]);

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const MyHomePage(
                        title: "x",
                      )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed:')),
          );
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: something went wrong')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          centerTitle: true,
          title: const Text(''),
        ),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const Text(
                "Welcome",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
              ),
              const Text(
                "Log in to your account",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 2.h,
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 3.w, right: 3.w, top: 1.h, bottom: 1.h),
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      isDense: true,
                      filled: true,
                      hintStyle: TextStyle(fontSize: 15),
                      prefixIcon: Icon(
                        Icons.email,
                        size: 23,
                      ),
                      hintText: "Enter email",
                      fillColor: Color.fromARGB(255, 237, 240, 242),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                          borderSide: BorderSide(color: Colors.transparent)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                          borderSide: BorderSide(color: Colors.transparent))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 3.w, right: 3.w, top: 1.h, bottom: 1.h),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                      isDense: true,
                      filled: true,
                      hintStyle: TextStyle(fontSize: 15),
                      prefixIcon: Icon(
                        Icons.password,
                        size: 23,
                      ),
                      hintText: "Enter password",
                      fillColor: Color.fromARGB(255, 226, 232, 236),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                          borderSide: BorderSide(color: Colors.transparent)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                          borderSide: BorderSide(color: Colors.transparent))),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              Padding(
                padding: EdgeInsets.only(right: 7.w, left: 7.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                    ),
                    const Text(
                      "  Remember me",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const Expanded(child: SizedBox()),
                    const Text(
                      "Forget Password",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 56, 89, 161)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.5.h),
              InkWell(
                onTap: () {
                  _login();
                },
                child: Container(
                  height: 50,
                  width: 92.w,
                  decoration: const BoxDecoration(
                      color: Color.fromRGBO(180, 221, 255, 1),
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                            ),
                          )
                        : const Text(
                            "login",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                  ),
                ),
              ),
              // _isLoading
              //     ? CircularProgressIndicator()
              //     : ElevatedButton(
              //         onPressed: _login,
              //         style: ButtonStyle(),
              //         child: Text('Login'),

              //       ),
              const Expanded(child: SizedBox()),
              const Text(
                "Sign in with",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 0, 0, 0)),
              ),
              SizedBox(
                height: 1.5.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.facebookF,
                      color: Color.fromARGB(255, 11, 139, 243),
                      size: 23,
                    ),
                    FaIcon(
                      FontAwesomeIcons.xTwitter,
                      color: Colors.black,
                      size: 23,
                    ),
                    FaIcon(
                      FontAwesomeIcons.google,
                      color: Color.fromARGB(255, 213, 92, 92),
                      size: 23,
                    ),
                    FaIcon(
                      FontAwesomeIcons.instagram,
                      color: Colors.pink,
                      size: 23,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 3.h,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Dont have an account?",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  Text(
                    "  Signup",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 7, 128, 227)),
                  ),
                ],
              ),
              SizedBox(
                height: 4.h,
              )
            ],
          ),
        ),
      ),
    );
  }
}

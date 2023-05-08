// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/ForgetPassword/forget_password_screen.dart';
import 'package:final_project/Services/global_methods.dart';
import 'package:final_project/Services/global_variables.dart';
import 'package:final_project/Signup%20Page/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void dispose() {
    _animationController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((animationStatus) {
            if (animationStatus == AnimationStatus.completed) {
              _animationController.reset();
              _animationController.forward();
            }
          });
    _animationController.forward();
    super.initState();
  }

  final _loginFormKey = GlobalKey<FormState>();
  final FocusNode _passFocusNode = FocusNode();
  final TextEditingController _emailTextController =
      TextEditingController(text: "");
  final TextEditingController _passTextController =
      TextEditingController(text: "");
  bool _obscureText = true;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _submitFormOnLogin() async {
    final isValid = _loginFormKey.currentState!.validate();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _auth.signInWithEmailAndPassword(
            email: _emailTextController.text.trim().toLowerCase(),
            password: _passTextController.text.trim());
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
        print("error occurred $error");
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: loginUrlImage,
            placeholder: (context, url) => Image.asset(
              "assests/logo1.jpg",
              fit: BoxFit.fill,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: FractionalOffset(_animation.value, 0),
          ),
          Container(
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 80, right: 80),
                    child: Image.asset("assests/login.png"),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Form(
                    key: _loginFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context)
                              .requestFocus(_passFocusNode),
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailTextController,
                          validator: (value) {
                            if (value!.isEmpty || !value.contains("@")) {
                              return "Please Enter a Valid Email";
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              labelText: "Enter Your Email",
                              labelStyle: const TextStyle(color: Colors.white),
                              hintText: "Email",
                              hintStyle: const TextStyle(color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.cyan),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(20),
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          focusNode: _passFocusNode,
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passTextController,
                          obscureText: _obscureText,
                          validator: (value) {
                            if (value!.isEmpty || value.length < 7) {
                              return "Please Enter a Valid Password";
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                              ),
                              labelText: "Enter Your Password",
                              labelStyle: const TextStyle(color: Colors.white),
                              hintText: "Password",
                              hintStyle: const TextStyle(color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20)),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(20),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgetPassword(),
                                    ));
                              },
                              child: const Text(
                                "Forget Password ?",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                        ),
                        MaterialButton(
                          onPressed: _submitFormOnLogin,
                          color: Colors.cyan,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: RichText(
                              text: TextSpan(children: [
                            const TextSpan(
                                text: "Do Not have a account?",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            const TextSpan(text: "     "),
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignupScreen(),
                                      )),
                                text: "Signup",
                                style: const TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ])),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      // Padding(padding: EdgeInsets.all(16.0),
      // child: Form(
      //   key: _loginFormKey,
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Padding(
      //         padding: const EdgeInsets.all(16.0),
      //         child: TextFormField(
      //           controller: _emailTextController,
      //           validator: (value){
      //             if(value!.isEmpty ||!value.contains("@")){
      //               return "Please Enter a Valid Email";
      //
      //             }else{
      //               return null;
      //             }
      //           },
      //           decoration: InputDecoration(
      //             labelText: "Enter Your Email",
      //             hintText: "Email",
      //             border: OutlineInputBorder(
      //               borderRadius: BorderRadius.circular(20),
      //
      //             )
      //           ),
      //
      //         ),
      //
      //       ),
      //
      //       Padding(
      //         padding: const EdgeInsets.all(16.0),
      //         child: TextFormField(
      //           keyboardType: TextInputType.visiblePassword,
      //           controller: _passTextController,
      //           obscureText: !_obscureText,
      //           validator: (value){
      //             if(value!.isEmpty || value.length <7){
      //               return "Please Enter a Valid Password";
      //             }else{
      //               return null;
      //             }
      //           },
      //           decoration: InputDecoration(
      //             suffixIcon: GestureDetector(
      //               onTap: (){
      //                 setState(() {
      //                   _obscureText = !_obscureText;
      //                 });
      //               },
      //               child: Icon(
      //                 _obscureText ? Icons.visibility : Icons.visibility_off
      //               ),
      //             ),
      //             labelText: "Enter Your Password",
      //             hintText: "Password",
      //             border: OutlineInputBorder(
      //               borderRadius: BorderRadius.circular(20)
      //             )
      //           ),
      //         ),
      //
      //       ),
      //       Padding(
      //         padding: const EdgeInsets.only(right: 16.0),
      //         child: Align(
      //           alignment: Alignment.bottomRight,
      //           child: TextButton(
      //             onPressed: (){
      //               Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPassword(),));
      //
      //             },child: Text("Forget Password"),
      //
      //           ),
      //         ),
      //
      //       ),
      //       MaterialButton(onPressed: _submitFormOnLogin,
      //       color: Colors.cyan,
      //       elevation: 8,
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(13),
      //
      //       ),
      //       child: Padding(
      //         padding: EdgeInsets.symmetric(vertical: 16),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             Text("Login",
      //             style: TextStyle(
      //               fontWeight: FontWeight.bold,
      //               fontSize: 20
      //             ),)
      //           ],
      //         ),
      //       ),),
      //       SizedBox(height: 20,),
      //       Center(
      //         child: RichText(text: TextSpan(children: [
      //           TextSpan(
      //             text: "Do Not have a account?",
      //             style: TextStyle(
      //               color: Colors.black ,
      //               fontWeight: FontWeight.bold,
      //               fontSize: 16
      //             )
      //           ),
      //           TextSpan(text: "     "),
      //           TextSpan(
      //             recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen(),)),
      //             text: "Signup",
      //             style: TextStyle(
      //               color: Colors.cyan,
      //               fontSize: 16,
      //               fontWeight: FontWeight.bold
      //             )
      //           ),
      //         ])),
      //       )
      //     ],
      //   ),
      //
      // )),
    );
  }
}

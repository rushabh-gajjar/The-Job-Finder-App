import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Services/global_methods.dart';
import 'package:final_project/Services/global_variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _phoneController.dispose();
    _emailFocusNode.dispose();
    _passFocusFocusNode.dispose();
    _positionCPFocusNode.dispose();
    _phoneNumberFocusFocusNode.dispose();
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

  final TextEditingController _fullNameController =
      TextEditingController(text: "");
  final TextEditingController _emailTextController =
      TextEditingController(text: "");
  final TextEditingController _passTextController =
      TextEditingController(text: "");
  final TextEditingController _phoneController =
      TextEditingController(text: "");
  final TextEditingController _locationController =
      TextEditingController(text: "");

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passFocusFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusFocusNode = FocusNode();
  final FocusNode _positionCPFocusNode = FocusNode();

  final _signUpFormKey = GlobalKey<FormState>();
  File? imageFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscureText = true;
  bool _isLoading = false;
  String? imageUrl;

  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Please choose an option"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    _getFormCamera();
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera,
                          color: Colors.purple,
                        ),
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(color: Colors.purple),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    _getFormGallery();
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.image,
                          color: Colors.purple,
                        ),
                      ),
                      Text(
                        "Gallery",
                        style: TextStyle(color: Colors.purple),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  void _getFormCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFormGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void _submitFormOnSignUp() async {
    final isValid = _signUpFormKey.currentState!.validate();
    if (isValid) {
      if (imageFile == null) {
        GlobalMethod.showErrorDialog(
            error: "Please Pick An Image", ctx: context);
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        await _auth.createUserWithEmailAndPassword(
            email: _emailTextController.text.trim().toLowerCase(),
            password: _passTextController.text.trim());
        final User? user = _auth.currentUser;
        final _uid = user!.uid;
        final ref = FirebaseStorage.instance
            .ref()
            .child("userImages")
            .child(_uid + ".jpg");
        await ref.putFile(imageFile!);
        imageUrl = await ref.getDownloadURL();
        FirebaseFirestore.instance.collection("users").doc(_uid).set({
          "id": _uid,
          "name": _fullNameController.text,
          "email": _emailTextController.text,
          "userImage": imageUrl,
          "phoneNumber": _phoneController.text,
          "location": _locationController.text,
          "createdAt": Timestamp.now(),
        });
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

// void _submitFormOnSignUp() async {
//   final isValid = _signUpFormKey.currentState!.validate();
//   if (isValid) {
//     if (imageFile == null) {
//       GlobalMethod.showErrorDialog(
//           error: "Please pick an image", ctx: context);
//     }
//     return;
//   }
//   setState(() {
//     _isLoading = true;
//   });
//   try {
//     await _auth.createUserWithEmailAndPassword(
//         email: _emailTextController.text.trim().toLowerCase(),
//         password: _passTextController.text.trim());
//     final User? user = _auth.currentUser;
//     final _uid = user!.uid;
//     final ref = FirebaseStorage.instance
//         .ref()
//         .child("userImages")
//         .child(_uid + ".jpg");
//     await ref.putFile(imageFile!);
//     imageUrl = await ref.getDownloadURL();
//     FirebaseFirestore.instance.collection("users").doc(_uid).set({
//       "id": _uid,
//       "name": _fullNameController.text,
//       "email": _emailTextController.text,
//       "userImage": imageUrl,
//       "phoneNumber": _phoneController.text,
//       "location": _locationController.text,
//       "createdAt": Timestamp.now(),
//     });
//     Navigator.canPop(context) ? Navigator.of(context) : null;
//   } catch (error) {
//     setState(() {
//       _isLoading = false;
//       print("error----------------------------------------------$error");
//     });
//     print("error----------------------------------------------$error");
//     GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
//   }
//   setState(() {
//     _isLoading = true;
//   });
// }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: signUpUrlImage,
            errorWidget: (context, url, error) => const Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: FractionalOffset(_animation.value, 0),
          ),
          Container(
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
              child: ListView(
                children: [
                  Form(
                    key: _signUpFormKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showImageDialog();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: size.width * 0.24,
                              height: size.width * 0.24,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.cyanAccent),
                                  borderRadius:
                                      BorderRadiusDirectional.circular(20)),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: imageFile == null
                                      ? const Icon(
                                          Icons.camera_enhance_sharp,
                                          color: Colors.cyan,
                                          size: 30,
                                        )
                                      : Image.file(
                                          imageFile!,
                                          fit: BoxFit.fill,
                                        )),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context)
                              .requestFocus(_emailFocusNode),
                          keyboardType: TextInputType.name,
                          controller: _fullNameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "This Field is missing";
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              labelText: "Name / Company Name",
                              labelStyle: const TextStyle(color: Colors.white),
                              hintText: "Enter Your Name / Company Name",
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
                          height: 10,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context)
                              .requestFocus(_passFocusFocusNode),
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
                              labelText: "Email",
                              labelStyle: const TextStyle(color: Colors.white),
                              hintText: "Enter Your Email",
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
                          height: 10,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context)
                              .requestFocus(_phoneNumberFocusFocusNode),
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passTextController,
                          obscureText: !_obscureText,
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
                              labelText: "Password",
                              labelStyle: const TextStyle(color: Colors.white),
                              hintText: "Enter Your Password",
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
                          height: 10,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context)
                              .requestFocus(_positionCPFocusNode),
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "This Field is missing";
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              labelText: "Phone Number",
                              labelStyle: const TextStyle(color: Colors.white),
                              hintText: "Enter Your Phone Number",
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
                          height: 10,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context)
                              .requestFocus(_positionCPFocusNode),
                          keyboardType: TextInputType.text,
                          controller: _locationController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "This Field is missing";
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              labelText: "Company Address",
                              labelStyle: const TextStyle(color: Colors.white),
                              hintText: "Enter Your Company Address",
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
                          height: 10,
                        ),
                        _isLoading
                            ? Center(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  child: const CircularProgressIndicator(),
                                ),
                              )
                            : MaterialButton(
                                onPressed: () {
                                  _submitFormOnSignUp();
                                  print("clicked");
                                },
                                color: Colors.cyan,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "Signup",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: RichText(
                              text: TextSpan(children: [
                            const TextSpan(
                                text: "Already have an account?",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            const TextSpan(text: "     "),
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.canPop(context)
                                      ? Navigator.pop(context)
                                      : null,
                                text: "Login",
                                style: const TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold))
                          ])),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      // body: Container(
      //   child: Padding(
      //     padding: EdgeInsets.symmetric(horizontal: 16,vertical: 60),
      //     child: ListView(
      //       children: [
      //         Form(
      //           key:  _signUpFormKey,
      //           child: Column(
      //             children: [
      //               GestureDetector(
      //                 onTap: (){
      //                   _showImageDialog();
      //
      //                 },
      //                 child: Padding(
      //                   padding: EdgeInsets.all(8.0),
      //                   child: Container(
      //                     width: size.width * 0.24,
      //                     height: size.width * 0.24,
      //                     decoration: BoxDecoration(
      //                       border: Border.all(width: 1,color: Colors.cyanAccent),
      //                       borderRadius: BorderRadiusDirectional.circular(20)
      //                     ),
      //                     child: ClipRRect(
      //                       borderRadius: BorderRadius.circular(16),
      //                       child:imageFile == null ? Icon(Icons.camera_enhance_sharp,color: Colors.cyan,size: 30,) : Image.file(imageFile!,fit:  BoxFit.fill,)
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //               SizedBox(height: 10,),
      //               TextFormField(
      //                 controller: _fullNameController,
      //                 validator: (value){
      //                   if(value!.isEmpty ){
      //                     return "This Field is missing";
      //
      //                   }else{
      //                     return null;
      //                   }
      //                 },
      //                 decoration: InputDecoration(
      //                     labelText: "Enter Your Name",
      //                     hintText: "Full Name / Company Name",
      //                     border: OutlineInputBorder(
      //                       borderRadius: BorderRadius.circular(20),
      //
      //                     )
      //                 ),
      //
      //               ),
      //               SizedBox(height: 10,),
      //               TextFormField(
      //                 controller: _emailController,
      //                 validator: (value){
      //                   if(value!.isEmpty || !value.contains("@") ){
      //                     return "Please Enter a Valid Email Address";
      //
      //                   }else{
      //                     return null;
      //                   }
      //                 },
      //                 decoration: InputDecoration(
      //                     labelText: "Enter Your Email",
      //                     hintText: "Email",
      //                     border: OutlineInputBorder(
      //                       borderRadius: BorderRadius.circular(20),
      //
      //                     )
      //                 ),
      //
      //               ),
      //               SizedBox(height: 10,),
      //               TextFormField(
      //                 keyboardType: TextInputType.visiblePassword,
      //                 controller: _passController,
      //                 obscureText: !_obscureText,
      //                 validator: (value){
      //                   if(value!.isEmpty || value.length < 7 ){
      //                     return "Please Enter a Valid Password";
      //
      //                   }else{
      //                     return null;
      //                   }
      //                 },
      //                 decoration: InputDecoration(
      //                     suffixIcon: GestureDetector(
      //                       onTap: (){
      //                         setState(() {
      //                           _obscureText = !_obscureText;
      //                         });
      //                       },
      //                       child: Icon(
      //                           _obscureText ? Icons.visibility : Icons.visibility_off
      //                       ),
      //                     ),
      //                     labelText: "Enter Your Password",
      //                     hintText: "Password",
      //                     border: OutlineInputBorder(
      //                       borderRadius: BorderRadius.circular(20),
      //
      //                     )
      //                 ),
      //
      //               ),
      //               SizedBox(height: 10,),
      //               TextFormField(
      //                 keyboardType: TextInputType.phone,
      //                 controller: _phoneController,
      //                 validator: (value){
      //                   if(value!.isEmpty ){
      //                     return "This Field is missing";
      //
      //                   }else{
      //                     return null;
      //                   }
      //                 },
      //                 decoration: InputDecoration(
      //
      //                     labelText: "Enter Your PhoneNumber",
      //                     hintText: "PhoneNumber",
      //                     border: OutlineInputBorder(
      //                       borderRadius: BorderRadius.circular(20),
      //
      //                     )
      //                 ),
      //
      //               ),
      //               SizedBox(height: 10,),
      //               TextFormField(
      //                 keyboardType: TextInputType.text,
      //                 controller:_locationController ,
      //                 validator: (value){
      //                   if(value!.isEmpty ){
      //                     return "This Field is missing";
      //
      //                   }else{
      //                     return null;
      //                   }
      //                 },
      //                 decoration: InputDecoration(
      //
      //                     labelText: "Enter Your Company Address",
      //                     hintText: "Company Address",
      //                     border: OutlineInputBorder(
      //                       borderRadius: BorderRadius.circular(20),
      //
      //                     )
      //                 ),
      //
      //               ),
      //               SizedBox(height: 10,),
      //               _isLoading ? Center(
      //                 child: Container(
      //                   width: 50,
      //                   height: 50,
      //                   child: CircularProgressIndicator(),
      //                 ),
      //               ) : MaterialButton(onPressed: (){
      //                 _submitFormOnSignUp();
      //                 print("clicked");
      //               },color: Colors.cyan,
      //               elevation: 8,
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(13)
      //               ),
      //               child: Padding(
      //                 padding: EdgeInsets.symmetric(vertical: 14),
      //                 child: Row(
      //                   mainAxisAlignment: MainAxisAlignment.center,
      //                   children: [
      //                     Text("Signup",
      //                     style: TextStyle(
      //                       color: Colors.black,
      //                       fontWeight: FontWeight.bold,
      //                       fontSize: 15
      //                     ),)
      //                   ],
      //                 ),
      //               ),),
      //               SizedBox(height: 10,),
      //               Center(
      //                 child: RichText(text: TextSpan(children: [
      //                   TextSpan(
      //                     text: "Already have an account?",
      //                     style: TextStyle(
      //                       color: Colors.black,
      //                       fontWeight: FontWeight.bold,
      //                       fontSize: 16
      //                     )
      //                   ),
      //                   TextSpan(text: "     "),
      //                   TextSpan(
      //                       recognizer: TapGestureRecognizer()..onTap = () => Navigator.canPop(context) ? Navigator.pop(context) : null,
      //
      //                       text: "Login",
      //                       style: TextStyle(
      //                           color: Colors.cyan,
      //                           fontSize: 16,
      //                           fontWeight: FontWeight.bold
      //                       )
      //                   )
      //                 ])),
      //               )
      //
      //
      //             ],
      //           ),
      //         )
      //       ],
      //   ),
      //   ),
      // ),
    );
  }
}

import 'package:clone_whatsapp_base_code/services/firebase_auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPages extends StatefulWidget {
  const LoginPages({super.key});

  @override
  State<LoginPages> createState() => _LoginPagesState();
}

class _LoginPagesState extends State<LoginPages> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoarding = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.black,
        leading: Icon(Icons.arrow_back, color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    // hintText: "Numéro mobile ou e-mail",
                    // hintStyle: TextStyle(color: Colors.white),
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.white),
                    suffixIcon: Icon(Icons.email),
                    suffixIconColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    // hintText: "Mot de passe",
                    // hintStyle: TextStyle(color: Colors.white),
                    labelText: "Mot de passe",
                    labelStyle: TextStyle(color: Colors.white),
                    suffixIcon: Icon(Icons.visibility_off),
                    suffixIconColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  child: ElevatedButton(
                    onPressed: _isLoarding
                        ? null
                        : () async {
                            setState(() {_isLoarding = true;});

                            if (_formKey.currentState!.validate()) {
                              try {
                                await Auth().loginWithEmailAndPassword(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                                setState(() {_isLoarding = false;});
                              } on FirebaseAuthException catch (e) {
                                setState(() {_isLoarding = false;});
                                //Message Error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("${e.message}"),
                                    behavior: SnackBarBehavior.floating,
                                    showCloseIcon: true,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE50914),
                      padding: EdgeInsets.only(left: 125, right: 125),
                    ),
                    child: _isLoarding ? CircularProgressIndicator(): Text(
                      "Se connecter",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Mot de passe oublié ?",
                    style: TextStyle(color: Colors.white),
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

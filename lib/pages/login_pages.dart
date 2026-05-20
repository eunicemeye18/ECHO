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
  final _passwordComfimationController = TextEditingController();

  bool _isLoarding = false;
  bool _forLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("ECHO", style: TextStyle(color: Color(0xFFE50914)),),
        backgroundColor: Colors.black,
        
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Mot de passe requis";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 20),
                if (_forLogin)
                  TextFormField(
                    controller: _passwordComfimationController,
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      // hintText: "Mot de passe",
                      // hintStyle: TextStyle(color: Colors.white),
                      labelText: "Confirmer votre Mot de passe",
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Mot de passe de confimation requis";
                      } else if (value != _passwordController.text) {
                        return "Mot de passe de confimation incorrect";
                      } else {
                        return null;
                      }
                    },
                  ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  child: ElevatedButton(
                    onPressed: _isLoarding
                        ? null
                        : () async {
                            setState(() {
                              _isLoarding = true;
                            });
                            //Login
                            if (_formKey.currentState!.validate()) {
                              try {
                                if (_forLogin) {
                                  await Auth().loginWithEmailAndPassword(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                                } else {
                                  await Auth().createUserWithEmailAndPassword(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                                }

                                setState(() {
                                  _isLoarding = false;
                                });
                              } on FirebaseAuthException catch (e) {
                                setState(() {
                                  _isLoarding = false;
                                });
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
                      padding: EdgeInsets.only(left: 120, right: 120),
                    ),
                    child: _isLoarding
                        ? CircularProgressIndicator()
                        : Text(
                            _forLogin ? "Se connecter" : "S'inscrire",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _emailController.text = "";
                    _passwordController.text = "";
                    _passwordComfimationController.text = "";
                    setState(() {
                      _forLogin = !_forLogin;
                    });
                  },
                  child: Text(
                    _forLogin ? "Créer un compte" : "J'ai déjà un compte",
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

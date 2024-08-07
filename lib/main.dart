import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tabs/tab_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SumoVista',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigningIn = false;

  Future<void> _login(BuildContext context) async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      /*final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);*/
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TabNavigation()),
        );
      //}
    } catch (error) {
      print(error);
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  Future<void> _signup(BuildContext context) async {
    // You can implement the sign-up logic here similarly
    _login(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SumoVista',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome to SumoVista',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 50),
              _isSigningIn
                  ? CircularProgressIndicator()
                  : Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _login(context),
                    child: Text('Sign In With Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(color: Colors.black),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _signup(context),
                    child: Text('Sign Up With Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

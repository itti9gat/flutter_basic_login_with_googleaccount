import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Login Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();

  var userEmail;

  Future<FirebaseUser> loginWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return user;
  }

  void logoutWithGoogle() {
    _googleSignIn.signOut();
    setState(() {
        userEmail = null;
    });
  }


  @override
  Widget build(BuildContext context) {

    Widget child;
    if (userEmail == null) {
      child = RaisedButton(
              onPressed: (){
                loginWithGoogle().then((FirebaseUser user) {

                  setState(() {
                    userEmail = user.email;
                  });
                  
                  print("EMAIL : ${user.email}");
                  print("UID : ${user.uid}");
                }).catchError((e){
                  print(e);
                });
              },
              color: Colors.green,
              child: Text("Login Google"),
            );
    } else {
      child = RaisedButton(
              onPressed: (){
                logoutWithGoogle();
              },
              color: Colors.amber,
              child: Text(userEmail),
            );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            child
          ],
        ),
      ),
    );
  }

}

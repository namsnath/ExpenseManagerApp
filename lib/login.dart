import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
	LoginPage({Key key, this.title}) : super(key: key);
	final String title;

	@override
	_LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

	final GoogleSignIn _googleSignIn = GoogleSignIn();
	final FirebaseAuth _auth = FirebaseAuth.instance;
	SharedPreferences prefs;

	bool isLoading = false;
	bool isLoggedIn = false;
	FirebaseUser currentUser;

	@override
	void initState() {
		super.initState();
		isSignedIn();
	}

	void isSignedIn() async {
		this.setState(() {
			isLoading = true;
		});

		prefs = await SharedPreferences.getInstance();

		isLoggedIn = await _googleSignIn.isSignedIn();

		if (isLoggedIn)
			Navigator.pushReplacementNamed(context, 'homePage');

		this.setState(() {
			isLoading = false;
		});
	}

	Future<Null> handleSignIn() async {
		prefs = await SharedPreferences.getInstance();
		
		this.setState(() {
			isLoading = true;
		});

		GoogleSignInAccount googleUser = await _googleSignIn.signIn();
		GoogleSignInAuthentication googleAuth = await googleUser.authentication;
		final AuthCredential credential = GoogleAuthProvider.getCredential(
			accessToken: googleAuth.accessToken,
			idToken: googleAuth.idToken,
		);
		final FirebaseUser user = await _auth.signInWithCredential(credential);
		currentUser = await _auth.currentUser();
		assert(user.uid == currentUser.uid);

		if(user != null) {
			final QuerySnapshot result = await Firestore.instance.collection('users')
					.where('id', isEqualTo: user.uid).getDocuments();
			final List<DocumentSnapshot> documents = result.documents;

			if(documents.length == 0) {		// If no user exists
				Firestore.instance
						.collection('users')
						.document(user.uid)
						.setData({
							'name': user.displayName,
							'photoUrl': user.photoUrl,
							'id': user.uid,
							'email': user.email,
						});

				await prefs.setString('id', currentUser.uid);
				await prefs.setString('name', currentUser.displayName);
				await prefs.setString('photoUrl', currentUser.photoUrl);
				await prefs.setString('email', currentUser.email);
			} else {	// If user exists, get details from documents
				await prefs.setString('id', documents[0]['id']);
				await prefs.setString('name', documents[0]['name']);
				await prefs.setString('photoUrl', documents[0]['photoUrl']);
				await prefs.setString('email', documents[0]['email']);
			}

			this.setState(() {
				isLoading = false;
			});

			var email = currentUser.email;
			var name = currentUser.displayName;
			Fluttertoast.showToast(msg: 'Signed in as $name - $email');
			Navigator.pushReplacementNamed(context, 'homePage');
		} else {
			Fluttertoast.showToast(msg: "Sign In Failed");
			this.setState(() {
				isLoading = false;
			});
		}

	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('Login')),
			body: _buildBody(context),
		);
	}

	Widget _buildBody(BuildContext context) {
		return Center(
			child: MaterialButton(
					onPressed: handleSignIn,
					child: Text(
						'Sign in with Google'
					),
			),
		);
	}
}
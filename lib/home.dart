import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'utility.dart';
import 'Transaction.dart';

class HomePage extends StatefulWidget {
	HomePage({Key key, this.title}) : super(key: key);
	final String title;

	@override
	_HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

	String _userID;

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('Home Page')),
			body: _buildBody(context),
		);
	}

	Widget _buildBody(BuildContext context) {
		return Center();
	}
}
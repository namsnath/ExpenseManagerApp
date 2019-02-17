import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:charts_flutter/flutter.dart';

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
	var formatter = new DateFormat.yMEd();

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('Home Page')),
			body: _buildBody(context),
		);
	}

	Widget _buildBody(BuildContext context) {
		return FutureBuilder<String>(
			future: SharedPreferencesHelper.getUserID(),
			initialData: null,
			builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
				switch (snapshot.connectionState) {
					case ConnectionState.none:
						return Text('Press button to start.');
					case ConnectionState.active:
					case ConnectionState.waiting:
						return Text('Awaiting result...');
					case ConnectionState.done:
						if (snapshot.hasError)
							return Text('Error: ${snapshot.error}');
						return _buildBodyLayout(context, snapshot.data);
				}
				return null; // unreachable
			}
		);
	}

	Widget _buildBodyLayout(BuildContext context, String data) {
		var startMonth, endMonth, startWeek, endWeek, startDay, endDay;
		var currentDate = new DateTime.now();
		var date = new DateTime(currentDate.year, currentDate.month, currentDate.day);

		startDay = date;
		endDay = date.add(new Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 999, microseconds: 999));

		startMonth = new DateTime(date.year, date.month);
		endMonth = (date.month == 12) ? new DateTime(date.year + 1, 12, 31, 23, 59, 59, 999, 999): new DateTime(date.year, date.month+1, 0, 23, 59, 59, 999, 999);

		startWeek = (date.weekday == 7) ? date : date.subtract(new Duration(days: date.weekday));
		endWeek = (date.weekday == 7) ? date.add(new Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999, microseconds: 999))
				: date.add(new Duration(days: 6 - date.weekday, hours: 23, minutes: 59, seconds: 59, milliseconds: 999, microseconds: 999));

		print('Today: ${date.toString()}');
		print('startWeek: ${startWeek.toString()}');
		print('endWeek: ${endWeek.toString()}');
		print('startMonth: ${startMonth.toString()}');
		print('endMonth: ${endMonth.toString()}');


		return ListView(
			children: <Widget>[
				_balanceStreamBuilder(data),
				_summaryStreamBuilder(data, startDay, endDay, "Today"),
				_summaryStreamBuilder(data, startWeek, endWeek, "This Week"),
				_summaryStreamBuilder(data, startMonth, endMonth, "This Month")
			],
		);
	}

	Widget _balanceStreamBuilder(String data) {
		var sum = 0;
		return StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance.collection('transactions')
					.where('user', isEqualTo: data)
					.snapshots(),
			builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
				if (!snapshot.hasData) return LinearProgressIndicator();
				var docs = snapshot.data.documents;
				print('balanceStream = ${docs.length}');
				/*if(docs.length == 0) {
					return _buildBalanceTile(sum);
				} else {*/
					var list = docs.map((doc) {
						var txn = TransactionModel.fromSnapshot(doc);
						if(txn.type == 'income')
							return txn.amount;
						else
							return -1*txn.amount;
					}).toList();
					sum = list.reduce((sum, i) => sum + i);

					return _buildBalanceTile(sum);
//				}
			},
		);
	}

	Widget _buildBalanceTile(sum) {
		return ListTile(
			title: ListTile(
				title: Text('Current Balance'),
				trailing: Text(sum.toString(), style: TextStyle(color: (sum >= 0) ? Colors.green : Colors.red)),
			),
		);

	}

	Widget _summaryStreamBuilder(String data, DateTime start, DateTime end, String timeframe) {
		var sum = 0, income = 0, expense = 0;
		return StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance.collection('transactions')
					.where('user', isEqualTo: data)
					.where('timestamp', isGreaterThanOrEqualTo: start)
					.where('timestamp', isLessThanOrEqualTo: end)
					.snapshots(),
			builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
				if (!snapshot.hasData) return LinearProgressIndicator();
				var docs = snapshot.data.documents;
				print('summaryStream = ${docs.length}');
				/*if(docs.length == 0) {
					return _buildSummaryTile(timeframe, income, expense, sum, start, end);
				}*/

				var list = docs.map((doc) {
					var txn = TransactionModel.fromSnapshot(doc);
					if(txn.type == 'income') {
						income += txn.amount;
						return txn.amount;
					}
					else {
						expense += txn.amount * -1;
						return -1*txn.amount;
					}
				}).toList();

//				income = list.reduce((income, i) => (i >= 0) ? sum + i : 0);
//				expense = list.reduce((income, i) => (i < 0) ? sum + i : 0);
				sum = list.reduce((sum, i) => sum + i);

				return _buildSummaryTile(timeframe, income, expense, sum, start, end);
			},
		);
	}

	Widget _buildSummaryTile(String text, income, expense, sum, start, end) {
		print('Income: $income');
		print('Expense: $expense');
		print('Sum: $sum');
		var dateText = ((text.compareTo("Today") == 0) ? formatter.format(start) : formatter.format(start) + " - " + formatter.format(end));
		return ListTile(
			title: ListTile(
				title: Text(text),
				trailing: Text(dateText),
			),
			subtitle: Row(
				children: <Widget>[
					new Flexible(
						child: Card(
							child: ListTile(
								title: Text('Income'),
								subtitle: Text(income.toString(), style: TextStyle(color: Colors.green)),
							),
						),
					),
					new Flexible(
							child: Card(
									child: ListTile(
										title: Text('Expense'),
										subtitle: Text(expense.toString(), style: TextStyle(color: Colors.red)),
									)
							)
					),
					new Flexible(
							child: Card(
									child: ListTile(
										title: Text('Balance'),
										subtitle: Text(sum.toString(), style: TextStyle(color: (sum >= 0) ? Colors.green : Colors.red)),
									)
							)
					),
				],
			),
		);
	}
}
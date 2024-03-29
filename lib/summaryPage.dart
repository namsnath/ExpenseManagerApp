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

class SummaryPage extends StatefulWidget {
  SummaryPage({
    Key key,
    this.title,
  }) : super(key: key);

  final String title;

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  String _userID;
  var formatter = new DateFormat.yMEd();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: (widget.title != "") ? AppBar(title: Text(widget.title)) : null,
      body: _buildBody(context),
//			floatingActionButton: _buildFAB(context),
//			floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//			bottomNavigationBar: _buildBottomBar(context),
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
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              return _buildSummaryLayout(context, snapshot.data);
          }
          return null; // unreachable
        });
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
//			key: page.fabKey,
      tooltip: 'Show explanation',
//			backgroundColor: page.fabColor,
      child: Icon(Icons.add),
//			onPressed: _showExplanatoryText
    );
  }

  Widget _buildSummaryLayout(BuildContext context, String data) {
    var startMonth, endMonth, startWeek, endWeek, startDay, endDay;
    var currentDate = new DateTime.now();
    var date =
        new DateTime(currentDate.year, currentDate.month, currentDate.day);

    startDay = date;
    endDay = date.add(new Duration(
        hours: 23,
        minutes: 59,
        seconds: 59,
        milliseconds: 999,
        microseconds: 999));

    startMonth = new DateTime(date.year, date.month);
    endMonth = (date.month == 12)
        ? new DateTime(date.year + 1, 12, 31, 23, 59, 59, 999, 999)
        : new DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999, 999);

    startWeek = (date.weekday == 7)
        ? date
        : date.subtract(new Duration(days: date.weekday));
    endWeek = (date.weekday == 7)
        ? date.add(new Duration(
            days: 6,
            hours: 23,
            minutes: 59,
            seconds: 59,
            milliseconds: 999,
            microseconds: 999))
        : date.add(new Duration(
            days: 6 - date.weekday,
            hours: 23,
            minutes: 59,
            seconds: 59,
            milliseconds: 999,
            microseconds: 999));

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
        _summaryStreamBuilder(data, startMonth, endMonth, "This Month"),
      ],
    );
  }

  Widget _balanceStreamBuilder(String data) {
    double sum = 0;
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('transactions')
          .where('user', isEqualTo: data)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return _buildLoadingBalanceTile();
        var docs = snapshot.data.documents;
        print('balanceStream = ${docs.length}');

        if (docs.length != 0) {
          var list = docs.map((doc) {
            var txn = TransactionModel.fromSnapshot(doc);
            if (txn.type == 'income')
              return txn.amount;
            else
              return -1 * txn.amount;
          }).toList();
          sum = list.reduce((sum, i) => sum + i);
        }

        return _buildBalanceTile(sum);
      },
    );
  }

  Widget _buildBalanceTile(sum) {
    return ListTile(
      title: ListTile(
        title: Text('Current Balance'),
        trailing: Text(sum.toString(),
            style: TextStyle(color: (sum >= 0) ? Colors.green : Colors.red)),
      ),
    );
  }

  Widget _buildLoadingBalanceTile() {
    return ListTile(
      title: ListTile(
        title: Text('Current Balance'),
        subtitle: new LinearProgressIndicator(),
      ),
    );
  }

  Widget _summaryStreamBuilder(
      String data, DateTime start, DateTime end, String timeframe) {
    double sum = 0, income = 0, expense = 0;
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('transactions')
          .where('user', isEqualTo: data)
          .where('timestamp', isGreaterThanOrEqualTo: start)
          .where('timestamp', isLessThanOrEqualTo: end)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData)
          return _buildLoadingSummaryTile(timeframe, start, end);
        var docs = snapshot.data.documents;
        print('summaryStream = ${docs.length}');
        if (docs.length != 0) {
          var list = docs.map((doc) {
            var txn = TransactionModel.fromSnapshot(doc);
            if (txn.type == 'income') {
              income += txn.amount;
              return txn.amount;
            } else {
              expense += txn.amount * -1;
              return -1 * txn.amount;
            }
          }).toList();

          sum = list.reduce((sum, i) => sum + i);
        }

        return _buildSummaryTile(timeframe, income, expense, sum, start, end);
      },
    );
  }

  Widget _buildSummaryTile(String text, income, expense, sum, start, end) {
    var dateText = ((text.compareTo("Today") == 0)
        ? formatter.format(start)
        : formatter.format(start) + " - " + formatter.format(end));
    return ListTile(
      title: ListTile(
        title: Text(text),
        trailing: Text(dateText),
      ),
      subtitle: Row(
        children: <Widget>[
          new Flexible(
            child: Card(
              color: Theme.of(context).cardColor,
              child: ListTile(
                title: Text('Income'),
                subtitle: Text(income.toString(),
                    style: TextStyle(color: Colors.green)),
              ),
            ),
          ),
          new Flexible(
              child: Card(
                  child: ListTile(
            title: Text('Expense'),
            subtitle:
                Text(expense.toString(), style: TextStyle(color: Colors.red)),
          ))),
          new Flexible(
              child: Card(
                  child: ListTile(
            title: Text('Balance'),
            subtitle: Text(sum.toString(),
                style:
                    TextStyle(color: (sum >= 0) ? Colors.green : Colors.red)),
          ))),
        ],
      ),
    );
  }

  Widget _buildLoadingSummaryTile(String text, start, end) {
    var dateText = ((text.compareTo("Today") == 0)
        ? formatter.format(start)
        : formatter.format(start) + " - " + formatter.format(end));
    return ListTile(
      title: ListTile(
        title: Text(text),
        trailing: Text(dateText),
      ),
      subtitle: new LinearProgressIndicator(),
    );
  }
}

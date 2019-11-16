import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'utility.dart';
import 'Transaction.dart';

class TransactionListPage extends StatefulWidget {
  TransactionListPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TransactionListPageState createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  SharedPreferences prefs;
  String _userID;
  double sum = 0;

  var formatter = new DateFormat.yMEd();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: (widget.title != "") ? AppBar(title: Text(widget.title)) : null,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<String>(
        future: SharedPreferencesHelper.getUserID(),
        initialData: null,
        builder: (BuildContext context, AsyncSnapshot<String> stringSnapshot) {
          print(_userID);
          return StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('transactions')
                .where('user', isEqualTo: _userID)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();
              var docs = snapshot.data.documents;

              var list = docs.map((doc) {
                var txn = TransactionModel.fromSnapshot(doc);
                if (txn.type == 'income')
                  return txn.amount;
                else
                  return -1 * txn.amount;
              }).toList();

              sum = list.reduce((sum, i) => sum + i);

              return _buildSummary(context, snapshot.data.documents, sum);
            },
          );
        });
  }

  Widget _buildSummary(
      BuildContext context, List<DocumentSnapshot> snapshot, sum) {
    var items = snapshot.map((data) => _buildListItem(context, data)).toList();
    items.add(_buildSummaryItem(context, sum));

    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: items,
    );
  }

  Widget _buildSummaryItem(BuildContext context, sum) {
    return Padding(
      key: ValueKey(sum),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        child: ListTile(
          title: Text('Balance'),
          trailing: Text(sum.toString(),
              style: TextStyle(color: (sum >= 0) ? Colors.green : Colors.red)),
          onTap: () => print(sum),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final txn = TransactionModel.fromSnapshot(data);
    var type = txn.type;

    return Padding(
      key: ValueKey(txn.amount),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          children: <Widget>[
            new Flexible(
              child:Card(
                color: Theme.of(context).backgroundColor,
                child: ListTile(
                  title: Text(formatter.format(txn.timestamp)),
                  subtitle: Text(
                    ((type == 'income') ? '+' : '-') + txn.amount.toString(),
                    style: TextStyle(color: (type == 'income') ? Colors.green : Colors.red)
                  ),
                ),
              ),
            ),
            new Flexible(
              child:Card(
                color: Theme.of(context).backgroundColor,
                child: ListTile(
                  trailing: MaterialButton(
                    child: Text('Delete'),
                    color: Colors.red,
                    onPressed: () => doDelete(txn.reference.documentID),
                  )
                ), 
              ),
            ),
            // MaterialButton(
            //   child: Text('Delete'),
            //   color: Colors.red,
            // ),
          ],
        ),
      ),
    );
  }


  doDelete(String ref) {
    print('Delete for ' + ref + ' clicked');
    Firestore.instance.collection('transactions').document(ref).delete();
  }
}

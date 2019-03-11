import 'package:expense_manager/utility.dart';
import 'package:flutter/material.dart';

import 'layout.dart';
import 'FABWithIcons.dart';
import 'FABBottomAppBar.dart';

import 'summaryPage.dart';
import 'category.dart';
import 'transactionList.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  static final tabPage = [
    SummaryPage(
      title: '',
    ),
    TransactionListPage(
      title: '',
    ),
//		CategoryPage(title: 'Categories',),
//		TransactionListPage(title: 'Transactions',),
  ];

  StatefulWidget _lastSelected = tabPage[0];

  void _selectedTab(int index) {
    setState(() {
      _lastSelected = tabPage[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _lastSelected,
      ),
      bottomNavigationBar: FABBottomAppBar(
        centerItemText: '',
        color: Colors.grey,
        selectedColor: Colors.red,
        notchedShape: CircularNotchedRectangle(),
        onTabSelected: _selectedTab,
        items: [
          FABBottomAppBarItem(iconData: Icons.pie_chart, text: 'Summary'),
          FABBottomAppBarItem(iconData: Icons.list, text: 'Transactions'),
//					FABBottomAppBarItem(iconData: Icons.dashboard, text: 'Bottom'),
//					FABBottomAppBarItem(iconData: Icons.info, text: 'Bar'),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildFab(BuildContext context) {
    void _onClicked() => Navigator.pushNamed(context, 'addTransactionPage');

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
              return FloatingActionButton(
                onPressed: () => Navigator.pushNamed(
                        context, 'addTransactionPage',
                        arguments: <String, String>{
                          'userID': snapshot.data,
                        }),
                tooltip: 'Add transaction',
                child: Icon(Icons.add),
                elevation: 2.0,
              );
          }
          return null; // unreachable
        });
  }
}

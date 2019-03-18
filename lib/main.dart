import 'package:flutter/material.dart';

import 'login.dart';
import 'category.dart';
import 'transactionList.dart';
import 'summaryPage.dart';
import 'homePage.dart';
import 'addTransaction.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        'categoryPage': (context) =>
            CategoryPage(title: 'Expense Manager Category Page'),
        '/': (context) => LoginPage(title: 'Expense Manager Login Page'),
        'transactionListPage': (context) =>
            TransactionListPage(title: 'Expense Manager Transaction List Page'),
        'summaryPage': (context) =>
            SummaryPage(title: 'Expense Manager Home Page'),
        'homePage': (context) => MyHomePage(title: 'Home Page'),
        'addTransactionPage': (context) => AddTransactionPage(title: ''),
      },
      title: 'Expense Manager',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        accentColor: Color.fromRGBO(0, 148, 255, 1.0),
        bottomAppBarColor: Colors.black,
        backgroundColor: Colors.black,
        cardColor: Color.fromRGBO(35, 43, 43, 1.0),
        buttonColor: Color.fromRGBO(0, 148, 255, 1.0),
      ),
    );
  }
}

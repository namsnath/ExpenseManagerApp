import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utility.dart';
import 'Category.dart';

class AddTransactionPage extends StatefulWidget {
  AddTransactionPage({
    Key key,
    this.title,
  }) : super(key: key);

  final String title;

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var dropdownValue;
  final amountController = new TextEditingController();
  final descriptionController = new TextEditingController();
  var selectedCategory;
  var categoryData = {};
  bool _expense = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: (widget.title != "") ? AppBar(title: Text(widget.title)) : null,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return _buildFormLayout(context, '');
  }

  Widget _buildFormLayout(BuildContext context, String userID) {
    String _userID;
    void _onChanged2(bool value) => setState(() => _expense = value);

    return new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Form(
          key: this._formKey,
          child: new ListView(
            children: <Widget>[
              new SwitchListTile(
                activeColor: Theme.of(context).accentColor,
                value: _expense,
                onChanged: _onChanged2,
                title: new Text('Expense'),
                secondary: new Text('Income'),
              ),
              new TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: new InputDecoration(
                    hintText: 'Some insane amount', labelText: 'Amount'),
              ),
              _expense ? _categoryStreamBuilder(context): new Text(''),
              new TextFormField(
                controller: descriptionController,
                keyboardType: TextInputType.text,
                // maxLines: null,
                decoration: new InputDecoration(
                    hintText: 'Describe that money here',
                    labelText: 'Description'),
              ),
              new MaterialButton(
                child: new Text('Add'),
                color: Theme.of(context).buttonColor,
                // textColor: Colors.black,
                onPressed: doSubmit,
              )
            ],
          ),
        ));
  }

  Widget _categoryStreamBuilder(BuildContext context) {
    var categories;
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('categories').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new LinearProgressIndicator();
        var docs = snapshot.data.documents;
        print('categoryStream = ${docs.length}');

        if (docs.length != 0) {
          categories = docs.map((doc) {
            var category = CategoryModel.fromSnapshot(doc);
            categoryData[category.name] = doc.documentID;
            return category.name;
          }).toList();
        }

        return _buildCategoryCombo(context, categories);
      },
    );
  }

  Widget _buildCategoryCombo(BuildContext context, categories) {
    print('Building again!');
    List<DropdownMenuItem<String>> categoryList =
        categories.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem(
        value: value,
        child: Text(value),
      );
    }).toList();
    // var dropdownValue = categoryList[0].value;
    print(dropdownValue);

    return ListTile(
      title: new Text('Choose a Category: '),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: dropdownValue,
          items: categoryList,
          onChanged: (selectedItem) {
            print('Selected = ' + selectedItem);
            setState(() {
              dropdownValue = selectedItem;
            });
          },
        ),
      ),
    );
  }

  doSubmit() async {
    var _userID = await SharedPreferencesHelper.getUserID();
    // print(_userID);
    // print(categoryData);
    
    Firestore.instance.collection('transactions').add({
      'user': _userID,
      'category': categoryData[dropdownValue],
      'amount': double.parse(amountController.text),
      'description': descriptionController.text,
      'timestamp': DateTime.now(),
      'type': _expense ? 'expense' : 'income',
    });

    Navigator.of(context).pop();
  }
}

class TransactionData {
  String description;
  String categoryID;
  bool expense;
  double amount;
}

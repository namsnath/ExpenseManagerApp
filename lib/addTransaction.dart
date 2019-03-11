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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.title != "") ? AppBar(title: Text(widget.title)) : null,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return _buildFormLayout(context, '');
  }

  Widget _buildFormLayout(BuildContext context, String userID) {
    bool _expense = true;
    void _onChanged2(bool value) => setState(() => _expense = value);

    return new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Form(
          key: this._formKey,
          child: new ListView(
            children: <Widget>[
              new SwitchListTile(
                value: _expense,
                onChanged: _onChanged2,
                title: new Text('Expense'),
                secondary: new Text('Income'),
              ),
              new TextFormField(
                keyboardType: TextInputType.number,
                decoration: new InputDecoration(
                    hintText: 'Some insane amount', labelText: 'Amount'),
              ),
              _categoryStreamBuilder(context),
              new TextFormField(
                keyboardType: TextInputType.text,
                // maxLines: null,
                decoration: new InputDecoration(
                    hintText: 'Describe that money here',
                    labelText: 'Description'),
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
            return category.name;
          }).toList();
        }

        return _buildCategoryCombo(context, categories);
      },
    );
  }

  Widget _buildCategoryCombo(BuildContext context, categories) {
    print('Building again!');
    List<DropdownMenuItem<String>> categoryList = categories.map<DropdownMenuItem<String>>((String value) {
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
}

class TransactionData {
  String description;
  String categoryID;
  bool expense;
  double amount;
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryPage extends StatefulWidget {
	CategoryPage({Key key, this.title}) : super(key: key);
	final String title;

	@override
	_CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: (widget.title != "") ? AppBar(title: Text(widget.title)) : null,
			body: _buildBody(context),
		);
	}

	Widget _buildBody(BuildContext context) {
		return StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance.collection('categories').snapshots(),
			builder: (context, snapshot) {
				if (!snapshot.hasData) return LinearProgressIndicator();

				return _buildList(context, snapshot.data.documents);
			},
		);
	}

	Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
		return ListView(
			padding: const EdgeInsets.only(top: 20.0),
			children: snapshot.map((data) => _buildListItem(context, data)).toList(),
		);
	}

	Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
		final record = Record.fromSnapshot(data);

		return Padding(
			key: ValueKey(record.name),
			padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
			child: Container(
				decoration: BoxDecoration(
					border: Border.all(color: Colors.grey),
					borderRadius: BorderRadius.circular(5.0),
				),
				child: ListTile(
					title: Text(record.name),
					onTap: () => print(record),
				),
			),
		);
	}
}

class Record {
	final String name;
	final DocumentReference reference;

	Record.fromMap(Map<String, dynamic> map, {this.reference})
			: assert(map['name'] != null),
				name = map['name'];

	Record.fromSnapshot(DocumentSnapshot snapshot)
			: this.fromMap(snapshot.data, reference: snapshot.reference);

	@override
	String toString() => "Record<$reference:$name>";
}
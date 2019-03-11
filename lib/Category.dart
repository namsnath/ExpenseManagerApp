import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
	final String name;
	final DocumentReference reference;
	/*final String parentCategory;*/

	CategoryModel.fromMap(Map<String, dynamic> map, {this.reference})
			: assert(map['name'] != null),
	name = map['name'];

	CategoryModel.fromSnapshot(DocumentSnapshot snapshot)
			: this.fromMap(snapshot.data, reference: snapshot.reference);

	@override
	String toString() => "Category < $reference : $name >";
}

import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
	final double amount;
	final String description;
	final String type;
	final DateTime timestamp;
	final DocumentReference reference;
	// final String category;
	// final String type;
	// final String user;

	TransactionModel.fromMap(Map<String, dynamic> map, {this.reference})
			: assert(map['amount'] != null && map['description'] != null && map['type'] != null && map['timestamp'] != null /*&& map['category'] != null && map['user'] != null*/),
	amount = map['amount'].toDouble(),
	description = map['description'],
	type = map['type'],
	timestamp = map['timestamp'];
  // category = map['category'];
  // user = map['user'];


	TransactionModel.fromSnapshot(DocumentSnapshot snapshot)
			: this.fromMap(snapshot.data, reference: snapshot.reference);

	@override
	String toString() => "Transaction < $reference : $amount >";
}

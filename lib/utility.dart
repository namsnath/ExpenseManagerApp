import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {

	static Future<String> getUserID() async {
		final SharedPreferences prefs = await SharedPreferences.getInstance();
		return prefs.getString('id');
	}
}
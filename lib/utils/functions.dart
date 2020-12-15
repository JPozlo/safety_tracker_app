import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:safety_tracker_app/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

String convertDateToString(DateTime time) {
  var dateRange = DateFormat("MM-dd-yy, HH:mm").format(time);
  return dateRange;
}

String convertTimestampToString(Timestamp time) {
  var format = DateFormat("dd-MM-yyyy, HH:mm");
  var date = time.toDate();
  var mytime = format.format(date);
  return mytime;
}

String convertTimestampToStringOnlyTime(Timestamp time) {
  var format = DateFormat("HH:mm");
  var date = time.toDate();
  var mytime = format.format(date);
  return mytime;
}

DateTime convertTimestampToDatetime(Timestamp time) {
  var date = time.toDate();
  return date;
}

addStringToPrefs(String nameOfKey, String nameOfValue) async{
  SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
  _sharedPreferences.setString(nameOfKey, nameOfValue);
}


Future<String> getStringPrefs(String key) async{
  SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
  var person = _sharedPreferences.getString(key);
  return person;
}

String getGroupID() {
  var mine =  "";
  getStringPrefs(Constants.groupID).then((value) => {
    mine = value
  }).catchError((err) => {
    print("Error due to: $err")
  });
  return mine;
}

import 'package:intl/intl.dart';

String convertDateToString(DateTime time){
  var dateRange = DateFormat("MM-dd-yy, hh:mm").format(time);
  return dateRange;
}
import 'package:timeago/timeago.dart' as timeago;

class AppLocale {
  static void init() {
    timeago.setLocaleMessages('vi', timeago.ViMessages());
  }
}

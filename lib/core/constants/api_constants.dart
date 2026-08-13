import 'dart:io';

class ApiConstants {
  /// 🟢 Set to [true] to target local backend (10.0.2.2 for Android Emulator, 127.0.0.1 for iOS/Web).
  /// 🔴 Set to [false] to target the live server (https://api.orcasportsclub.in).
  static const bool useLocalApi = true;

  /// Your local port if running local server (default Node.js port)
  static const int localPort = 5000;

  static String get domain {
    if (!useLocalApi) {
      return "https://api.orcasportsclub.in";
    }
    // Android emulator host loopback is 10.0.2.2; iOS/Web is 127.0.0.1
    if (Platform.isAndroid) {
      return "http://10.0.2.2:$localPort";
    } else {
      return "http://127.0.0.1:$localPort";
    }
  }

  static String get apiBase => "$domain/api";
  static String get userBase => "$apiBase/user";
  static String get gymOwnerBase => "$apiBase/gym-owner";
  static String get fitnessExercisesBase => "$apiBase/fitness/exercises";
  static String get workoutLogBase => "$apiBase/user/workout-log";
  static String get challengesBase => "$apiBase/user/challenges";
  static String get shopProductsBase => "$apiBase/user/shop-products";
  static String get ordersBase => "$apiBase/orders";
  static String get cartBase => "$apiBase/user/cart";
  static String get addressesBase => "$apiBase/user/addresses";
}

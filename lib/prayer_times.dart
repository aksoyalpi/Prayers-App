import 'dart:convert';
import 'dart:io';
import 'package:location/location.dart';
import 'package:prayer_times/time.dart';
import 'package:http/http.dart' as http;
import 'consts/strings.dart';
import 'main.dart';

class PrayerTimes {
  static final List<String> calcMethods = [
    "Shia Ithna-Ansari",
    "University of Islamic Sciences, Karachi",
    "Islamic Society of North America",
    "Muslim World League",
    "Umm Al-Qura University, Makkah",
    "Egyptian General Authority of Survey",
    "Institute of Geophysics, University of Tehran",
    "Gulf Region",
    "Kuwait",
    "Qatar",
    "Majlis Ugama Islam Singapura, Singapore",
    "Union Organization islamic de France",
    "Diyanet İşleri Başkanlığı, Turkey",
    "Spiritual Administration of Muslims of Russia",
    "Moonsighting Committee Worldwide",
    /*(also requires shafaq parameter)*/
    "Dubai (unofficial)"
  ];
  static final prayerTimeZones = [
    "Fajr",
    "Sunrise",
    "Dhuhr",
    "Asr",
    "Maghrib",
    "Isha"
  ];

  int day = 0;
  Future<Time?>? time;
  late Time times;
  double? latitude;
  double? longitude;
  String city = "";

  PrayerTimes() {
    day = DateTime.now().day;
  }

  Future<double> setLocation() async {
    var location = Location();

    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return -1;
    }

    var permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return -1;
      }
    }

    var currentLocation = await location.getLocation();
    longitude = currentLocation.longitude;
    latitude = currentLocation.latitude;
    return 0;
  }


  /// Function to fetch Prayer times for today
  Future<Time?>? fetchPost(bool gps) async {
    day = DateTime.now().day;
    final year = DateTime.now().year;
    final month = DateTime.now().month;
    var method = prefs.getInt(Strings.prefs["calculationMethod"]!)!;
    if (method > 5) method++;
    final city = prefs.getString(Strings.prefs["city"]!);
    final country = prefs.getString(Strings.prefs["country"]!);

    Uri uri;

    if (gps) {
      await setLocation();
      uri = Uri.parse(
          "https://api.aladhan.com/v1/calendar/$year/$month?latitude=$latitude&longitude=$longitude&method=$method");
    } else {
      uri = Uri.parse(
          "https://api.aladhan.com/v1/calendarByCity/$year/$month?city=$city&country=$country&method=$method");
    }

    try{
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        times = Time.fromJson(json.decode(response.body), day);
        return Time.fromJson(json.decode(response.body), day);
      } else {
        throw Exception("Failed to load Times");
      }
    }on SocketException catch(_){
      throw Exception("Please check your internet connection.");
    }
  }


  /// Function to fetch prayer times by a given date
  Future<Time?>? fetchPostByDate(bool gps, DateTime date) async {
    final day = date.day;
    final year = date.year;
    final month = date.month;
    var method = prefs.getInt(Strings.prefs["calculationMethod"]!)!;
    if (method > 5) method++;
    final city = prefs.getString(Strings.prefs["city"]!);
    final country = prefs.getString(Strings.prefs["country"]!);

    Uri uri;

    if (gps) {
      await setLocation();
      uri = Uri.parse(
          "https://api.aladhan.com/v1/calendar/$year/$month?latitude=$latitude&longitude=$longitude&method=$method");
    } else {
      uri = Uri.parse(
          "https://api.aladhan.com/v1/calendarByCity/$year/$month?city=$city&country=$country&method=$method");
    }

    try{
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        times = Time.fromJson(json.decode(response.body), day);
        return Time.fromJson(json.decode(response.body), day);
      } else {
        throw Exception("Failed to load Times");
      }
    }on SocketException catch(_){
      throw Exception("Please check your internet connection.");
    }
  }




  /// Method to get the prayertimes for given param time
  String? getPrayerTime(String time) {
    switch (time) {
      case "Fajr":
        return times.fajr.substring(0, 5);
      case "Sunrise":
        return times.sunrise.substring(0, 5);
      case "Dhuhr":
        return times.dhuhr.substring(0, 5);
      case "Asr":
        return times.asr.substring(0, 5);
      case "Maghrib":
        return times.maghrib.substring(0, 5);
      case "Isha":
        return times.isha.substring(0, 5);
    }
    return "";
  }

  /// Function returns time that is left until next prayer
  static DateTime getTimeUntilNextPrayer(snapshot){
    // TODO: implement
    return DateTime.now();
  }

  /// Method to just get the hour of the given prayertime as int
  int getPrayerTimeHour(String time) {
    return int.parse(getPrayerTime(time)!.substring(0, 2));
  }

  /// Method to just get the minutes of the given prayertime as int
  int getPrayerTimeMin(String time) {
    return int.parse(getPrayerTime(time)!.substring(3, 5));
  }
}

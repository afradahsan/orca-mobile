import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orca/core/constants/api_constants.dart';
import 'banner_model.dart';

class BannerService {
  final String userBannersUrl = "${ApiConstants.userBase}/banners";
  final String apiBannersUrl = "${ApiConstants.apiBase}/banners";

  /// Fetch admin-configured home banners from the backend API
  Future<List<HomeBanner>> fetchAdminBanners() async {
    try {
      // Try user banners route first
      final res = await http.get(Uri.parse(userBannersUrl));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List rawList = [];
        if (data is List) {
          rawList = data;
        } else if (data is Map && data['banners'] != null) {
          rawList = data['banners'];
        }
        if (rawList.isNotEmpty) {
          return rawList.map((e) => HomeBanner.fromJson(e)).toList();
        }
      }

      // Try api banners route if needed
      final fallbackRes = await http.get(Uri.parse(apiBannersUrl));
      if (fallbackRes.statusCode == 200) {
        final data = jsonDecode(fallbackRes.body);
        List rawList = [];
        if (data is List) {
          rawList = data;
        } else if (data is Map && data['banners'] != null) {
          rawList = data['banners'];
        }
        return rawList.map((e) => HomeBanner.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching admin banners: $e");
    }
    return [];
  }
}

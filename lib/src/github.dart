import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:http/http.dart';

import 'tuple.dart';

Uri _get_release_uri({required String username, required String repository, List<String> path = const []}) =>
    Uri(scheme: "https", host: "api.github.com", pathSegments: ["repos", username, repository, "releases"] + path);

Future<Tuple2<String, String>?> get_latest_asset({String username = "zarainia", required String repository, required String filename}) async {
  try {
    Response response = await get(_get_release_uri(username: username, repository: repository));
    if (response.statusCode == 200) {
      List<Map<String, dynamic>> json = (jsonDecode(response.body) as List).cast();
      json.sort((a, b) => (b["published_at"] as String).compareTo(a["published_at"] as String)); //reversed
      Map<String, dynamic>? matching_release = json.firstWhereOrNull((release) => (release["assets"] as List<dynamic>).any((e) => e["name"] == filename));
      if (matching_release != null) return Tuple2((matching_release["assets"] as List<dynamic>).firstWhere((e) => e["name"] == filename)["browser_download_url"], matching_release["tag_name"]);
    }
  } catch (e) {
    log("failed to get asset url", error: e);
  }
  return null;
}

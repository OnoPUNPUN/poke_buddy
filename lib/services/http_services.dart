import 'package:dio/dio.dart';

class HttpServices {
  HttpServices();

  final _dio = Dio();

  Future<Response?> get(String url) async {
    try {
      Response response = await _dio.get(url);
      return response;
    } catch(e) {
      print(e);
    }
    return null;
  }
}

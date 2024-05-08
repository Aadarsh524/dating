import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  Future postDataMobile(
      {required String endpoint, required Map<String, dynamic> data}) async {
    final Dio dio = Dio(BaseOptions(baseUrl: URI, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }));
    try {
      final result = await dio.post(endpoint, data: data);
      return result.data;
    } catch (e) {
      return e.toString();
    }
  }

  Future postDataDesktop(
      {required String endpoint, required Map<String, dynamic> data}) async {
    final Dio dio = Dio(BaseOptions(baseUrl: URI_DESKTOP, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }));
    try {
      final result = await dio.post(endpoint, data: data);
      return result.data;
    } catch (e) {
      return e.toString();
    }
  }

  Future getDataMobile({required String endpoint, required String uid}) async {
    final Dio dio = Dio(BaseOptions(baseUrl: URI, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }));
    try {
      final result = await dio.get('$endpoint/$uid');

      return result;
    } catch (e) {
      throw e.toString();
    }
  }

  Future getDataDesktop({required String endpoint, required String uid}) async {
    final Dio dio = Dio(BaseOptions(baseUrl: URI_DESKTOP, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }));
    try {
      final result = await dio.get('$endpoint/$uid');
      return result.data;
    } catch (e) {
      return e.toString();
    }
  }

  Future updateDataMobile(
      {required String endpoint,
      required String uid,
      required Map<String, dynamic> data}) async {
    final Dio dio = Dio(BaseOptions(baseUrl: URI, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }));
    try {
      final result = await dio.put('$endpoint/$uid', data: data);
      return result.data;
    } catch (e) {
      return e.toString();
    }
  }

  Future updateDataDesktop(
      {required String endpoint,
      required String uid,
      required Map<String, dynamic> data}) async {
    final Dio dio = Dio(BaseOptions(baseUrl: URI_DESKTOP, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }));
    try {
      final result = await dio.put('$endpoint/$uid', data: data);
      return result.data;
    } catch (e) {
      return e.toString();
    }
  }
}

import 'dart:convert';

import 'package:dating/backend/MongoDB/token_manager.dart';
import 'package:dating/datamodel/subscription_model.dart';
import 'package:dating/platform/platform_mobile.dart';
import 'package:dating/providers/loading_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SubscriptionProvider extends ChangeNotifier {
  SubscriptionModel? subscriptionProvider;

  SubscriptionModel? get getSubcriptionModel => subscriptionProvider;

  void setSubscriptionModel(SubscriptionModel subscriptionData) {
    subscriptionProvider = subscriptionData;
    notifyListeners();
  }

  Future<bool> buySubcription(
      SubscriptionModel subscription, BuildContext context) async {
    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    context.read<LoadingProvider>().setLoading(true);
    try {
      final response = await http.post(Uri.parse('$api/Subscription'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(subscription.toJson()));

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString());
      rethrow;
    } finally {
      context.read<LoadingProvider>().setLoading(false);
    }
  }

  createPaymentIntent(SubscriptionModel subscription) async {
    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    try {
      Map<String, dynamic> body = {
        "amount": "10",
        "currency": "USD",
        "payment_method_types[]": "card",
      };
      http.Response response =
          await http.post(Uri.parse('$api/Subscription'), body: body, headers: {
        "Authorization": "Bearer sk_test_4eC39HqLyjWDarjtT1zdp7dc",
        "Content-Type": "application/x-www-form-urlencoded",
      });
      return json.decode(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

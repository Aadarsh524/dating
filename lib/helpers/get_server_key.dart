import 'package:googleapis_auth/auth_io.dart';

class GetServieKey {
  Future<String> getServerKeyToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/firebase.messaging',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database'
    ];

    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "dating-e74fa",
          "private_key_id": "a52daee9a2fd9ff19ea53a740b4048946a07708e",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDqDg42LDdLgGpE\nsQCpDoNeB2bOi/+aVqJ5F4ONlO00crgONIwEnKCRczSYr9Dqe+2xr9+HwDtfOzlb\n/dCNMiRB34YKXgKvNo3gf7yWijvYz1GYoBibR6W+tuBEbcE9jIp8GKfVwzx0hHov\n5EQ/F9pokDTz83HGdDeZZxM59PD45vdg/Lg0s1zyZ6B/bNBVYZjKYPmh83o/3+rq\nri5LdpnEsttn2kiiIJfAzkB/ckjZ5W1BI6vPZSRO4nxqZFgr/9VNkHG0LXImPi8n\nTZhNDAovKSMxpxo3lMfTX/GZTpbrB7e/TadW3qFwMdK1V4WdfJEtp7DeeC+NMzn/\nNKnC+o8/AgMBAAECggEAYxj4Y29tKgaA9/yJbwq6DEHOAX29BzfPKr4N8RAxLpez\n3i/ZaMp4IZ1Jk6w9JEq8ZRM17WAywytsKcrZVi74svtU4WbUdCMBByCOVJ7KoA2H\nWrvOL1CymIENi2t8+fZbXBeEWDmFiz/cDBL14lDTJJqKEQ/uCDyEnerKdSuEK52v\nr2Hm2K/pWDQj3ZB1bvBrkW8GcrXcqvvA4+g1SOWsz+lyOi1AAJ16XldNgXH/OYyN\n2dFbMW2G3lKKtcBnD9VRbePV/kjKtfeR+IoH9gYTYbWYznOMZsHp8ybzLpG/MYZ0\nwMGJG4CCyY92/+Wr/+efOyg0WZh55ur7J2qScwp5QQKBgQD1vm2Jr04/T+Fke5BK\n1LykwXf7CYuJzEO5iJ77oXh797k7hFAErA/5zZQccyJcBMWErvyMsrvbMm0/CCnn\nwt0SPdfmxH6Kex7ElGto4ebPp58YEZQiUbBvsGNs9D0NyQVNczw5PpGwIxRiBZ0U\nQRTFIYJXQRCB9t7ctyZsTVdDtwKBgQDz0r2fbA2/DMr8MW8vfGIierJg2n9Xg/Rb\nTwHKeZ8l1L2sZxG35RzN9ptYoPbe4xz2NA5ZlBMV2n+QMU1maFt4mOqoqTVoxL/p\nFAJS2G9a2+RJTq4VqG0aM+FDBCkQWq2W/p+QvOAhOEfWUyGNZKNw8Z4Q72WnK+2t\n96nrQqpguQKBgB1teGCMhao/PpZx1Y2gfBaetGdzdSpDM7j8C03GwE7YE251Ib/t\netxHKf1eLDcoux5wdf3DSYuuNjbeG2aNhzuv/DK+RQkARWb0/wfIRYOIZxzSvhJ+\nBcraLI3XkZgdAm2L5yJTw8575Oz4Dx9ly77vjFQ2jmuBzJ5RsGA3wsNxAoGAc2+u\n/y91QqKX59avwVeuToywr1JDP/flVOWO/4Gda5fRRTJ3HQ2IGatL2SY8O0Jjj90N\nfjOw5YPRKT9uWbHGvM4JK1kRRE0CXyNuBjMaZXX+Gwb5PJ/FJ8awO75YgrmrvfVH\nLot9wbyXpk0tcXfYObzrDTGKex89JERBWnTxnWECgYEAnTFmd0w7jfCyfEEUF/Lt\nwUFs4twYhSX98lFUKpOrjmkhB1z43EBIR4gomNb0K3pFtIKv5829mTW6kDRE8Zir\n8kISOOjqJAmfj0Twl/fY3zf/ZlWMB+JJxsLYZx8hBIu3oGT5vBfYLu0OeYbNxI5N\nJgbSrACxQevTdaxNImVEoNQ=\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-k8ld1@dating-e74fa.iam.gserviceaccount.com",
          "client_id": "105479986128371289396",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-k8ld1%40dating-e74fa.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        scopes);
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}

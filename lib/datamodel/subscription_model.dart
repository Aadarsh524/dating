class SubscriptionModel {
  String? userId;
  String? productId;
  String? duration;
  String? planType;
  // String? paymentMethod;
  // String? paymentToken;

  SubscriptionModel({
    this.userId,
    this.productId,
    this.duration,
    this.planType,
    // this.paymentMethod,
    // this.paymentToken
  });

  SubscriptionModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    productId = json['productId'];
    duration = json['duration'];
    planType = json['planType'];
    // paymentMethod = json['paymentMethod'];
    // paymentToken = json['paymentToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['productId'] = this.productId;
    data['duration'] = this.duration;
    data['planType'] = this.planType;
    // data['paymentMethod'] = this.paymentMethod;
    // data['paymentToken'] = this.paymentToken;
    return data;
  }
}

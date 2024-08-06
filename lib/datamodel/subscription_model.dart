class SubscriptionModel {
  String? userId;
  String? duration;
  String? planType;
  String? paymentMethod;
  String? paymentId;

  SubscriptionModel(
      {this.userId,
      this.duration,
      this.planType,
      this.paymentMethod,
      this.paymentId});

  SubscriptionModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    duration = json['duration'];
    planType = json['planType'];
    paymentMethod = json['paymentMethod'];
    paymentId = json['paymentId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['duration'] = this.duration;
    data['planType'] = this.planType;
    data['paymentMethod'] = this.paymentMethod;
    data['paymentId'] = this.paymentId;
    return data;
  }
}

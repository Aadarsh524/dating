// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class DashboardResponseModel {
  List<Data> data;
  DashboardResponseModel({
    required this.data,
  });

  DashboardResponseModel copyWith({
    List<Data>? data,
  }) {
    return DashboardResponseModel(
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'data': data.map((x) => x.toMap()).toList(),
    };
  }

  factory DashboardResponseModel.fromMap(Map<String, dynamic> map) {
    return DashboardResponseModel(
      data: List<Data>.from((map['data'] as List<int>).map<Data>((x) => Data.fromMap(x as Map<String,dynamic>),),),
    );
  }

  String toJson() => json.encode(toMap());

  factory DashboardResponseModel.fromJson(String source) => DashboardResponseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'DashboardResponseMode(data: $data)';

  @override
  bool operator ==(covariant DashboardResponseModel other) {
    if (identical(this, other)) return true;
  
    return 
      listEquals(other.data, data);
  }

  @override
  int get hashCode => data.hashCode;
}

class Data {
  String uid;
  String image;
  String name;
  String address;
  String age;
  String gender;
  Upload? upload;
  Data({
    required this.uid,
    required this.image,
    required this.name,
    required this.address,
    required this.age,
    required this.gender,
    this.upload,
  });

  Data copyWith({
    String? uid,
    String? image,
    String? name,
    String? address,
    String? age,
    String? gender,
    Upload? upload,
  }) {
    return Data(
      uid: uid ?? this.uid,
      image: image ?? this.image,
      name: name ?? this.name,
      address: address ?? this.address,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      upload: upload ?? this.upload,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'image': image,
      'name': name,
      'address': address,
      'age': age,
      'gender': gender,
      'upload': upload?.toMap(),
    };
  }

  factory Data.fromMap(Map<String, dynamic> map) {
    return Data(
      uid: map['uid'] as String,
      image: map['image'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      age: map['age'] as String,
      gender: map['gender'] as String,
      upload: map['upload'] != null ? Upload.fromMap(map['upload'] as Map<String,dynamic>) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Data.fromJson(String source) => Data.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Data(uid: $uid, image: $image, name: $name, address: $address, age: $age, gender: $gender, upload: $upload)';
  }

  @override
  bool operator ==(covariant Data other) {
    if (identical(this, other)) return true;
  
    return 
      other.uid == uid &&
      other.image == image &&
      other.name == name &&
      other.address == address &&
      other.age == age &&
      other.gender == gender &&
      other.upload == upload;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
      image.hashCode ^
      name.hashCode ^
      address.hashCode ^
      age.hashCode ^
      gender.hashCode ^
      upload.hashCode;
  }
}

class Upload {
  String id;
  String file;
  String name;
  String uploadData;
  Upload({
    required this.id,
    required this.file,
    required this.name,
    required this.uploadData,
  });

  Upload copyWith({
    String? id,
    String? file,
    String? name,
    String? uploadData,
  }) {
    return Upload(
      id: id ?? this.id,
      file: file ?? this.file,
      name: name ?? this.name,
      uploadData: uploadData ?? this.uploadData,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'file': file,
      'name': name,
      'uploadData': uploadData,
    };
  }

  factory Upload.fromMap(Map<String, dynamic> map) {
    return Upload(
      id: map['id'] as String,
      file: map['file'] as String,
      name: map['name'] as String,
      uploadData: map['uploadData'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Upload.fromJson(String source) => Upload.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Upload(id: $id, file: $file, name: $name, uploadData: $uploadData)';
  }

  @override
  bool operator ==(covariant Upload other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.file == file &&
      other.name == name &&
      other.uploadData == uploadData;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      file.hashCode ^
      name.hashCode ^
      uploadData.hashCode;
  }
}

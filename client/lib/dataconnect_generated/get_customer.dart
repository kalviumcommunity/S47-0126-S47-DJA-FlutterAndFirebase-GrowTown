part of 'generated.dart';

class GetCustomerVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  GetCustomerVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<GetCustomerData> dataDeserializer = (dynamic json)  => GetCustomerData.fromJson(jsonDecode(json));
  Serializer<GetCustomerVariables> varsSerializer = (GetCustomerVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetCustomerData, GetCustomerVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetCustomerData, GetCustomerVariables> ref() {
    GetCustomerVariables vars= GetCustomerVariables(id: id,);
    return _dataConnect.query("GetCustomer", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetCustomerCustomer {
  final String id;
  final String name;
  final String? email;
  final String? address;
  final String? phone;
  GetCustomerCustomer.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']),
  email = json['email'] == null ? null : nativeFromJson<String>(json['email']),
  address = json['address'] == null ? null : nativeFromJson<String>(json['address']),
  phone = json['phone'] == null ? null : nativeFromJson<String>(json['phone']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCustomerCustomer otherTyped = other as GetCustomerCustomer;
    return id == otherTyped.id && 
    name == otherTyped.name && 
    email == otherTyped.email && 
    address == otherTyped.address && 
    phone == otherTyped.phone;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode, email.hashCode, address.hashCode, phone.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    if (email != null) {
      json['email'] = nativeToJson<String?>(email);
    }
    if (address != null) {
      json['address'] = nativeToJson<String?>(address);
    }
    if (phone != null) {
      json['phone'] = nativeToJson<String?>(phone);
    }
    return json;
  }

  GetCustomerCustomer({
    required this.id,
    required this.name,
    this.email,
    this.address,
    this.phone,
  });
}

@immutable
class GetCustomerData {
  final GetCustomerCustomer? customer;
  GetCustomerData.fromJson(dynamic json):
  
  customer = json['customer'] == null ? null : GetCustomerCustomer.fromJson(json['customer']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCustomerData otherTyped = other as GetCustomerData;
    return customer == otherTyped.customer;
    
  }
  @override
  int get hashCode => customer.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (customer != null) {
      json['customer'] = customer!.toJson();
    }
    return json;
  }

  GetCustomerData({
    this.customer,
  });
}

@immutable
class GetCustomerVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetCustomerVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCustomerVariables otherTyped = other as GetCustomerVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  GetCustomerVariables({
    required this.id,
  });
}


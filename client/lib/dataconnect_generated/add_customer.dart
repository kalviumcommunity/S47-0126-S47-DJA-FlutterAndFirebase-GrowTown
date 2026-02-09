part of 'generated.dart';

class AddCustomerVariablesBuilder {
  String name;
  String email;
  Timestamp createdAt;

  final FirebaseDataConnect _dataConnect;
  AddCustomerVariablesBuilder(this._dataConnect, {required  this.name,required  this.email,required  this.createdAt,});
  Deserializer<AddCustomerData> dataDeserializer = (dynamic json)  => AddCustomerData.fromJson(jsonDecode(json));
  Serializer<AddCustomerVariables> varsSerializer = (AddCustomerVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddCustomerData, AddCustomerVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AddCustomerData, AddCustomerVariables> ref() {
    AddCustomerVariables vars= AddCustomerVariables(name: name,email: email,createdAt: createdAt,);
    return _dataConnect.mutation("AddCustomer", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AddCustomerCustomerInsert {
  final String id;
  AddCustomerCustomerInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddCustomerCustomerInsert otherTyped = other as AddCustomerCustomerInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const AddCustomerCustomerInsert({
    required this.id,
  });
}

@immutable
class AddCustomerData {
  final AddCustomerCustomerInsert customerInsert;
  AddCustomerData.fromJson(dynamic json):
  
  customerInsert = AddCustomerCustomerInsert.fromJson(json['customer_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddCustomerData otherTyped = other as AddCustomerData;
    return customerInsert == otherTyped.customerInsert;
    
  }
  @override
  int get hashCode => customerInsert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['customer_insert'] = customerInsert.toJson();
    return json;
  }

  const AddCustomerData({
    required this.customerInsert,
  });
}

@immutable
class AddCustomerVariables {
  final String name;
  final String email;
  final Timestamp createdAt;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddCustomerVariables.fromJson(Map<String, dynamic> json):
  
  name = nativeFromJson<String>(json['name']),
  email = nativeFromJson<String>(json['email']),
  createdAt = Timestamp.fromJson(json['createdAt']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddCustomerVariables otherTyped = other as AddCustomerVariables;
    return name == otherTyped.name && 
    email == otherTyped.email && 
    createdAt == otherTyped.createdAt;
    
  }
  @override
  int get hashCode => Object.hashAll([name.hashCode, email.hashCode, createdAt.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    json['email'] = nativeToJson<String>(email);
    json['createdAt'] = createdAt.toJson();
    return json;
  }

  const AddCustomerVariables({
    required this.name,
    required this.email,
    required this.createdAt,
  });
}


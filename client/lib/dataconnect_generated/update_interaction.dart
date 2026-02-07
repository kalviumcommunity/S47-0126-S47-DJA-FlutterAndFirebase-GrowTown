part of 'generated.dart';

class UpdateInteractionVariablesBuilder {
  String id;
  String summary;

  final FirebaseDataConnect _dataConnect;
  UpdateInteractionVariablesBuilder(this._dataConnect, {required  this.id,required  this.summary,});
  Deserializer<UpdateInteractionData> dataDeserializer = (dynamic json)  => UpdateInteractionData.fromJson(jsonDecode(json));
  Serializer<UpdateInteractionVariables> varsSerializer = (UpdateInteractionVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateInteractionData, UpdateInteractionVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateInteractionData, UpdateInteractionVariables> ref() {
    UpdateInteractionVariables vars= UpdateInteractionVariables(id: id,summary: summary,);
    return _dataConnect.mutation("UpdateInteraction", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateInteractionInteractionUpdate {
  final String id;
  UpdateInteractionInteractionUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateInteractionInteractionUpdate otherTyped = other as UpdateInteractionInteractionUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpdateInteractionInteractionUpdate({
    required this.id,
  });
}

@immutable
class UpdateInteractionData {
  final UpdateInteractionInteractionUpdate? interaction_update;
  UpdateInteractionData.fromJson(dynamic json):
  
  interaction_update = json['interaction_update'] == null ? null : UpdateInteractionInteractionUpdate.fromJson(json['interaction_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateInteractionData otherTyped = other as UpdateInteractionData;
    return interaction_update == otherTyped.interaction_update;
    
  }
  @override
  int get hashCode => interaction_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (interaction_update != null) {
      json['interaction_update'] = interaction_update!.toJson();
    }
    return json;
  }

  UpdateInteractionData({
    this.interaction_update,
  });
}

@immutable
class UpdateInteractionVariables {
  final String id;
  final String summary;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateInteractionVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  summary = nativeFromJson<String>(json['summary']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateInteractionVariables otherTyped = other as UpdateInteractionVariables;
    return id == otherTyped.id && 
    summary == otherTyped.summary;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, summary.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['summary'] = nativeToJson<String>(summary);
    return json;
  }

  UpdateInteractionVariables({
    required this.id,
    required this.summary,
  });
}


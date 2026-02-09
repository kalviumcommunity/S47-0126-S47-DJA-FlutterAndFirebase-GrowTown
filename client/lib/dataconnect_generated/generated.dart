
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'add_customer.dart';

part 'get_customer.dart';

part 'update_interaction.dart';

part 'list_products.dart';







class ExampleConnector {
  
  
  AddCustomerVariablesBuilder addCustomer ({required String name, required String email, required Timestamp createdAt, }) {
    return AddCustomerVariablesBuilder(dataConnect, name: name,email: email,createdAt: createdAt,);
  }
  
  
  GetCustomerVariablesBuilder getCustomer ({required String id, }) {
    return GetCustomerVariablesBuilder(dataConnect, id: id,);
  }
  
  
  UpdateInteractionVariablesBuilder updateInteraction ({required String id, required String summary, }) {
    return UpdateInteractionVariablesBuilder(dataConnect, id: id,summary: summary,);
  }
  
  
  ListProductsVariablesBuilder listProducts () {
    return ListProductsVariablesBuilder(dataConnect, );
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'example',
    'client',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}

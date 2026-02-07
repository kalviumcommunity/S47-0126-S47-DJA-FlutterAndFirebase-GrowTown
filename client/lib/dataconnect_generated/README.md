# dataconnect_generated SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
ExampleConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### GetCustomer
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.getCustomer(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetCustomerData, GetCustomerVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getCustomer(
  id: id,
);
GetCustomerData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.getCustomer(
  id: id,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListProducts
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listProducts().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListProductsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listProducts();
ListProductsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listProducts().ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### AddCustomer
#### Required Arguments
```dart
String name = ...;
String email = ...;
Timestamp createdAt = ...;
ExampleConnector.instance.addCustomer(
  name: name,
  email: email,
  createdAt: createdAt,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<AddCustomerData, AddCustomerVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.addCustomer(
  name: name,
  email: email,
  createdAt: createdAt,
);
AddCustomerData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String name = ...;
String email = ...;
Timestamp createdAt = ...;

final ref = ExampleConnector.instance.addCustomer(
  name: name,
  email: email,
  createdAt: createdAt,
).ref();
ref.execute();
```


### UpdateInteraction
#### Required Arguments
```dart
String id = ...;
String summary = ...;
ExampleConnector.instance.updateInteraction(
  id: id,
  summary: summary,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<UpdateInteractionData, UpdateInteractionVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.updateInteraction(
  id: id,
  summary: summary,
);
UpdateInteractionData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String summary = ...;

final ref = ExampleConnector.instance.updateInteraction(
  id: id,
  summary: summary,
).ref();
ref.execute();
```


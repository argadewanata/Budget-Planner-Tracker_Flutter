import 'package:budgetplannertracker/services/auth_service.dart';
import 'package:flutter/widgets.dart';

class Provider extends InheritedWidget {
  final AuthService auth;

  const Provider({super.key, required super.child, required this.auth});

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static Provider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>()!;
  }
}

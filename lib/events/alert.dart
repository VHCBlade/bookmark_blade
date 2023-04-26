import 'package:event_bloc/event_bloc.dart';

enum AlertEvent<T> {
  alert<String>(),
  error<String>(),
  warning<String>(),
  noInternetAccess<void>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}

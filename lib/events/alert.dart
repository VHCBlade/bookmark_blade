import 'package:event_bloc/event_bloc.dart';

enum AlertEvent<T> {
  alert<String>("Alert"),
  error<String>("Error"),
  warning<String>("Warning"),
  noInternetAccess<void>("No Internet"),
  ;

  const AlertEvent(this.label);

  final String label;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}

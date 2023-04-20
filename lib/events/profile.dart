import 'package:event_bloc/event_bloc.dart';

enum ProfileEvent<T> {
  load<void>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}

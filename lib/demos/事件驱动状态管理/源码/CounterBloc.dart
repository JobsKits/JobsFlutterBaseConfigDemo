// counter_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/BLoC（未验证）/CounterEvent.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/BLoC（未验证）/CounterState.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState(counter: 0)) {
    on<IncrementCounter>((event, emit) {
      emit(CounterState(counter: state.counter + 1));
    });
  }
}

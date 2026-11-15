// counter_state.dart
import 'package:equatable/equatable.dart';

class CounterState extends Equatable {
  final int counter;
  const CounterState({required this.counter});
  @override
  List<Object> get props => [counter];
}

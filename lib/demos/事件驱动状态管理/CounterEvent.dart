// ignore: depend_on_referenced_packages
import 'package:equatable/equatable.dart';

abstract class CounterEvent extends Equatable {
  const CounterEvent();
  @override
  List<Object> get props => [];
}

class IncrementCounter extends CounterEvent {}

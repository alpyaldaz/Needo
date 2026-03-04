import 'package:flutter_bloc/flutter_bloc.dart';

class LocationCubit extends Cubit<String> {
  LocationCubit() : super('Warsaw, Poland');

  void selectLocation(String city) => emit(city);
}

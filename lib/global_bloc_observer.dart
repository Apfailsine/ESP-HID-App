import 'package:bloc/bloc.dart';

class GlobalBlocObserver extends BlocObserver {
  const GlobalBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    // print('${bloc.runtimeType} ${change.currentState} -> ${change.nextState}');
  }
}

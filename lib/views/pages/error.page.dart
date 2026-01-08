import 'package:flutter/material.dart';
import 'package:gamerch_shinyhunter/bloc/ble/ble_cubit.bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({super.key});

  final String title = 'ErrorPage';

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  final List<String> _errorMessages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BlocListener<BleCubit, BleState>(
        listener: (context, state) {
          print('i listened');
          if (state is BleStateError) {
            print('state : $state');
            setState(() {
              _errorMessages.add(state.errorMessage);
            });
          } else if (state is BleStateErrorInterface) {
            print('state 2: $state');
            setState(() {
              _errorMessages.add(state.errorMessage);
            });
          }
        },
        child: ListView.builder(
          itemCount: _errorMessages.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_errorMessages[index]),
            );
          },
        ),
      ),
    );
  }
}

import 'package:drip/drip.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/drip/drip_todo.dart';

import 'views/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dropper(
      create: DripToDo(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ToDo App',
        home: HomeView(),
      ),
    );
  }
}

import 'package:drip/drip.dart';
import 'package:flutter/material.dart';

import 'drip_example.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: DripProvider<DripCounter>(
        create: (_) => DripCounter(),
        child: DripCounterPage(),
      ),
    );
  }
}

class DripCounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DripBuilder<DripCounter, DripCounterState>(
              streamListener: true,
              builder: (context, state) => Text('Counter: ${state.count}'),
            ),
            DripListener<DripCounter, DripCounterState>(
              listener: (context, state) {},
              child: Text('Listener'),
            ),
            DripConsumer<DripCounter, DripCounterState>(
              listener: (context, state) {},
              builder: (context, state) => Text('Counter: ${state.count}'),
            ),
            SizedBox(height: 20),
            DripSelect<DripCounter, DripCounterState, String>(
              builder: (context, state) {
                return Text('Freeze $state');
              },
              selector: (state) => state.strNum,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 40, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                DripProvider.of<DripCounter>(context).dispatch(IncrementCountAction());
              },
              child: Icon(Icons.plus_one),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                DripProvider.of<DripCounter>(context).dispatch(ClearEvent());
              },
              child: Icon(Icons.close),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                DripProvider.of<DripCounter>(context).freeze();
              },
              child: Icon(Icons.numbers),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                DripProvider.of<DripCounter>(context).dispatch(Drain());
              },
              child: Icon(Icons.clear_all),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                DripProvider.of<DripCounter>(context).dispatch(Undo());
              },
              child: Icon(Icons.undo),
            ),
          ],
        ),
      ),
    );
  }
}

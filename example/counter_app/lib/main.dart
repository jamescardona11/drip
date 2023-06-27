import 'package:drip/drip.dart';
import 'package:flutter/material.dart';

import 'drip_counter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: Dropper<DripCounter>(
        create: DripCounter(),
        child: DripCounterPage(),
      ),
    );
  }
}

class DripCounterPage extends StatelessWidget {
  const DripCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Dripper<DripCounter, DripCounterState>(
              builder: (context, state) => Text('Counter: ${state.count}'),
            ),
            const SizedBox(height: 20),
            DropWidget<DripCounter, DripCounterState, String>(
              builder: (context, state) {
                return Text('Freeze $state');
              },
              selector: (state) => state.strNum,
            ),
            SizedBox(height: 60),
            Wrap(
              children: [
                TextButton(
                    onPressed: () {
                      Dropper.of<DripCounter>(context).increment();
                    },
                    child: const Text('Add +')),
                TextButton(
                    onPressed: () {
                      Dropper.of<DripCounter>(context).clear();
                    },
                    child: const Text('Clear')),
                TextButton(
                    onPressed: () {
                      Dropper.of<DripCounter>(context).freeze();
                    },
                    child: const Text('Freeze')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

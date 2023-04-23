<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->
# DRIP


<p align="center">
<img src="https://github.com/jamescardona11/drip/blob/main/base_logo.png?raw=true" height="250" alt="Drip Package" />
</p>

Drip is a wrapper for InheritedWidget to be able to handle the state management using Streams.
This is a personal project and is under-construction.

## Features

- Divide the handlers in small `DripActions`
- Provider different widgets to react a new changes in the state
- Have the possibility to use Interceptor

## Getting started

Import this library into your project:

```yaml
drip: ^latest_version
```

## Basic Usage

```dart
DripProvider<DripCounter>(
  create: (_) => DripCounter(),
  child: DripCounterPage(),
)


class DripCounterPage extends StatelessWidget {
  const DripCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Dripper<DripCounter, int>(
              builder: (context, state) => Text('Counter: ${state.count}'),
            ),
            TextButton(
              onPressed: () {
                DripProvider.of<DripCounter>(context).increment();
              },
              child: const Text('Add +'),
            ),
          ]
        ),
      ),
    );
  }
}



class DripCounter extends Drip<int> {
  DripCounter() : super(0);

  void increment() {
    print('Increment');
    leak(state + 1);
  }
}


```

#### DripActions
DripActions allow us to execute code in isolation, as if it were an extension of the main Drip.

```dart
class IncrementCountAction extends DripAction<DripCounterState> {
  @override
  Stream<DripCounterState> call(DripCounterState state) async* {
    yield state.copyWith(count: state.count + 1);
  }
}
```


#### Interceptors

Interceptors allow us to change or modify state before it is processed as an Action or Event.

```dart
class MemoryInterceptor<DState> extends BaseInterceptor<DState> {
  MemoryInterceptor({
    this.historySize = 50,
  });

  /// The size of the history
  final int historySize;

  /// The history list of the Drip
  final List<DState> _history = [];

  @override
  Stream<DState> call(DripEvent event, DState state) async* {
    if (event is UndoMemory<DState> && _history.isNotEmpty) {
      yield _history.removeLast();
    } else if (event is DrainMemory<DState>) {
      _history.clear();
      yield state;
    } else {
      if (_history.length >= historySize) {
        _history.removeAt(0);
      }
      _history.add(state);
      yield state;
    }
  }
}

```


### Examples

1. [Counter](https://github.com/jamescardona11/drip/tree/main/example/counter_app): Simple example of use the drip
2. [Todo](https://github.com/jamescardona11/drip/tree/main/example/todo_app): More complex example to use drip



Flutter is a game-changing technology that will revolutionize not just development, but software itself. A big thank you to the Flutter team for building such an amazing platform 💙 

<a href="https://github.com/flutter/flutter">
  <img alt="Flutter"
       src="https://github.com/jamescardona11/argo/blob/main/img/flutter_logo.png?raw=true" />
</a>




## Maintainers

- [James Cardona](https://github.com/jamescardona11)

You are welcome to contribute :3


## TODO
- Create test
- Improve de readme

## License

    MIT License
    Copyright (c) 2023 James Cardona

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
import 'package:drip/drip.dart';

import '../model/todo.dart';
import 'drip_todo_state.dart';

class DripToDo extends Drip<DripToDoState> with DefaultDripLoggerMixin {
  DripToDo()
      : super(DripToDoState(), interceptors: [
          MemoryInterceptor(),
          _DripInnerInterceptorCounter(),
        ]) {
    _initToDo();
  }

  void _initToDo() {
    leak(state.copyWith(toDos: [
      ToDo(id: '01', todoText: 'Morning Exercise', isDone: true),
      ToDo(id: '02', todoText: 'Buy Groceries', isDone: true),
      ToDo(id: '03', todoText: 'Check Emails'),
      ToDo(id: '04', todoText: 'Team Meeting'),
      ToDo(id: '05', todoText: 'Work on mobile apps for 2 hour'),
      ToDo(id: '06', todoText: 'Dinner with Jenny'),
    ]));
  }

  @override
  Stream<DripToDoState> mutableStateOf(DripEvent event, DripToDoState state) async* {
    if (event is ToDoDeletedEvent) {
      final todoList = state.toDos;
      todoList.removeWhere((item) => item.id == event.id);

      yield state.copyWith(toDos: todoList);
    }
  }

  void handleToDoChange(String id) {
    final toDos = state.toDos;
    final index = state.toDos.indexWhere((element) => element.id == id);
    final todo = state.toDos[index].copyWith(isDone: !toDos[index].isDone);

    toDos[index] = todo;
    leak(state.copyWith(toDos: toDos));
  }

  void handleUndo() {
    dispatch(UndoMemory());
  }
}

/// this is handle in the DripTodo for mutableStateOf
class ToDoDeletedEvent extends DripEvent<DripToDoState> {
  final String id;

  ToDoDeletedEvent(this.id);
}

/// The DripAction is triggered by the Drip.dispatch
/// Is handle in _eventControllerTransformer in the _BaseDrip
class DripAddNewToDo extends DripAction<DripToDoState> {
  final String toDoText;

  DripAddNewToDo(this.toDoText);

  @override
  Stream<DripToDoState> call(DripToDoState state) {
    final newToDo = ToDo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      todoText: toDoText,
    );

    return Stream.value(state.copyWith(toDos: List.from(state.toDos)..add(newToDo)));
  }
}

class _DripInnerInterceptorCounter extends BaseInterceptor<DripToDoState> {
  @override
  Stream<DripToDoState> call(DripEvent event, DripToDoState state) {
    if (event is ToDoDeletedEvent) {
      return Stream.value(state.copyWith(deletedToDos: state.deletedToDos + 1));
    }

    return Stream.value(state);
  }
}

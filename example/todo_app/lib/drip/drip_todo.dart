import 'package:drip/drip.dart';

import '../model/todo.dart';
import 'drip_todo_state.dart';

class DripToDo extends Drip<DripToDoState> {
  DripToDo() : super(DripToDoState()) {
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

  void delete(String id) {
    final todoList = state.toDos;
    todoList.removeWhere((item) => item.id == id);

    leak(state.copyWith(toDos: todoList));
  }

  void handleToDoChange(String id) {
    final toDos = state.toDos;
    final index = state.toDos.indexWhere((element) => element.id == id);
    final todo = state.toDos[index].copyWith(isDone: !toDos[index].isDone);

    toDos[index] = todo;
    leak(state.copyWith(toDos: toDos));
  }

  void addNewToDoItem(String toDoText) {
    final newToDo = ToDo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      todoText: toDoText,
    );

    return leak(state.copyWith(toDos: List.from(state.toDos)..add(newToDo)));
  }
}

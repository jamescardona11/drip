// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

import '../model/todo.dart';

class DripToDoState {
  final List<ToDo> toDos;

  final String searchText;
  final int deletedToDos;

  DripToDoState({
    this.toDos = const [],
    this.searchText = '',
    this.deletedToDos = 0,
  });

  factory DripToDoState.initialState() => DripToDoState(
        toDos: [],
      );

  DripToDoState copyWith({
    List<ToDo>? toDos,
    List<ToDo>? searchResults,
    String? searchText,
    int? deletedToDos,
  }) {
    return DripToDoState(
      toDos: List.from(toDos ?? this.toDos),
      searchText: searchText ?? this.searchText,
      deletedToDos: deletedToDos ?? this.deletedToDos,
    );
  }

  @override
  int get hashCode {
    return toDos.hashCode ^ searchText.hashCode ^ deletedToDos.hashCode;
  }

  @override
  bool operator ==(covariant DripToDoState other) {
    if (identical(this, other)) return true;

    return listEquals(other.toDos, toDos) && other.searchText == searchText && other.deletedToDos == deletedToDos;
  }
}

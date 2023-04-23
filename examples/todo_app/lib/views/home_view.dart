import 'package:drip/drip.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../drip/drip_todo.dart';
import '../drip/drip_todo_state.dart';
import 'todo_item.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _todoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Dripper<DripToDo, DripToDoState>(
          builder: (drip, state) {
            return Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Column(
                    children: [
                      const SearchBoxWidget(),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 50,
                          bottom: 20,
                        ),
                        child: const Text(
                          'All ToDos',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Deleted ToDos: (${state.deletedToDos})',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: drip.handleUndo,
                              child: Container(
                                padding: const EdgeInsets.all(0),
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: greyColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Icon(
                                  Icons.restart_alt,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.toDos.length,
                          itemBuilder: (context, index) => ToDoItemWidget(
                            todo: state.toDos[index],
                            // to show how can call methods from drip
                            toDoChanged: () => drip.handleToDoChange(state.toDos[index].id),
                            // other way to handle the state mutation, the event trigger drip.mutableStateOf
                            toDoDeleted: () => drip.dispatch(ToDoDeletedEvent(state.toDos[index].id)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                          bottom: 20,
                          right: 20,
                          left: 20,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 0.0),
                              blurRadius: 10.0,
                              spreadRadius: 0.0,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: _todoController,
                          decoration: const InputDecoration(hintText: 'Add a new todo item', border: InputBorder.none),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: 20,
                        right: 20,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_todoController.text.isNotEmpty) drip.dispatch(DripAddNewToDo(_todoController.text));
                        },
                        style: ElevatedButton.styleFrom(
                          primary: blueColor,
                          minimumSize: Size(60, 60),
                          elevation: 10,
                        ),
                        child: const Text(
                          '+',
                          style: TextStyle(
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SearchBoxWidget extends StatelessWidget {
  const SearchBoxWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) {
          if (value.length >= 3) {
            // other way to handle the state mutation, trigger individual actions
            context.read<DripToDo>().dispatch(DripSearchAction(value));
          }
        },
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: blackColor,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: greyColor),
        ),
      ),
    );
  }
}

// Import MaterialApp and other widgets which we can use to quickly create a material app
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

void main() => runApp(new TodoApp());

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Todo List',
        home: new TodoList()
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  List<String> _todoItems = [];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    log('init');
  }

  void _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for(var key in prefs.getKeys()){
      await _todoItems.add(prefs.getString(key));
    }
  }

  // Instead of autogenerating a todo item, _addTodoItem now accepts a string
  void _addTodoItem(String task) {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    // Putting our code inside "setState" tells the app that our state has changed,
    // and it will automatically re-render the list
    //             ^^^^^^^^^^^^^^^^^^^^^^^
    // ==> calling setState() to invoke TodoList.createState(),
    //     and that cause re-render
    //debugPrint('add task ${task}');
    if( task.length > 0 ){
      setState( () {
        _todoItems.add(task);
        //prefs.setString(task, task);
      });
    }
  }

  // Much like _addTodoItem, this modifies the array of todo strings and
  // notifies the app that the state has changed by using setState
  void _removeTodoItem(int index){
    setState( () => _todoItems.removeAt(index));
  }

  void _promptRemoveTodoItem(int index){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Mark "${_todoItems[index]}" ad done?'),

              actions: <Widget>[
                new FlatButton(
                    child: new Text('CANCEL'),
                    onPressed: () => Navigator.of(context).pop()
                ),

                new FlatButton(
                    child: new Text('DONE'),
                    onPressed: (){
                      _removeTodoItem(index);
                      Navigator.of(context).pop();
                    }
                ),
              ]
          );
        }
    );
  }

  // Build the whole list of todo items
  Widget _buildTodoList() {
    return new ListView.builder(
      // itemBuilder will be automatically be called as many times as it takes
      // for the list to fill up its available space, which is most likely
      // more than the number of todo items we have.
      // So, we need to check the index is OK.
      // ignore: missing_return
      itemBuilder: (context, index) {
        if(index < _todoItems.length){
          return _buildTodoItem(_todoItems[index], index);
        }
      },
    );
  }

  // Build a single todo item
  Widget _buildTodoItem(String todoText, int index){
    return new ListTile(
        title: new Text(todoText),
        onTap: () => _promptRemoveTodoItem(index)
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Todo List')
      ),

      body: _buildTodoList(),

      floatingActionButton: new FloatingActionButton(
        // pressing this button now opens the new screen
          onPressed: _pushAddTodoScreen,
          tooltip: 'Add task',
          child: new Icon(Icons.add)
      ),
    );
  }

  void _pushAddTodoScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
      // MaterialPageRoute will automatically animate the screen entry,
      // as well as adding a back button to close it
        new MaterialPageRoute(
            builder: (BuildContext context) {
              return new Scaffold(
                appBar: new AppBar(
                    title: new Text('Add new Task')
                ),

                body: new TextField(
                  autofocus: true,
                  onSubmitted: (val) async {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString(val, val);
                    _addTodoItem(val);
                    Navigator.pop(context); // Close the add todo screen
                  },
                  decoration: new InputDecoration(
                      hintText: 'Enter something todo ...',
                      contentPadding: const EdgeInsets.all(16.0)
                  ),
                ),
              );
            }
        )
    );
  }
}

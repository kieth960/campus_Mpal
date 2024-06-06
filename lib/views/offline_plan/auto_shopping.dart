import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class GroceryListScreen extends StatefulWidget {
  final List<String> ingredients;

  const GroceryListScreen({Key? key, required this.ingredients})
      : super(key: key);

  @override
  _GroceryListScreenState createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  late Box box;
  late List<String> _ingredients;
  late Set<int> _boughtItems;

  @override
  void initState() {
    super.initState();
    box = Hive.box('groceryBox');
    _ingredients = List<String>.from(widget.ingredients);
    _boughtItems = Set<int>.from(box.get('boughtItems', defaultValue: []));
  }

  void _toggleBought(int index) {
    setState(() {
      if (_boughtItems.contains(index)) {
        _boughtItems.remove(index);
      } else {
        _boughtItems.add(index);
      }
      box.put('boughtItems', _boughtItems.toList());
    });
  }

  void _removeItem(int index) {
    final removedItem = _ingredients[index];
    setState(() {
      _ingredients.removeAt(index);
      _boughtItems.remove(index);
      box.put('ingredients', _ingredients);
      box.put('boughtItems', _boughtItems.toList());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$removedItem removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _ingredients.insert(index, removedItem);
              box.put('ingredients', _ingredients);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grocery List'),
        backgroundColor: Color(0xff0cb945),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: _ingredients.length,
          separatorBuilder: (context, index) => Divider(height: 1),
          itemBuilder: (context, index) {
            final ingredient = _ingredients[index];
            final isBought = _boughtItems.contains(index);

            return ListTile(
              title: Text(
                ingredient,
                style: TextStyle(
                  fontSize: 16,
                  decoration: isBought ? TextDecoration.lineThrough : null,
                ),
              ),
              leading: Icon(
                isBought ? Icons.check_box : Icons.check_box_outline_blank,
                color: isBought ? Colors.green : null,
              ),
              onTap: () => _toggleBought(index),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _removeItem(index),
              ),
            );
          },
        ),
      ),
    );
  }
}

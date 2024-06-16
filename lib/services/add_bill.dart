import 'package:flutter/material.dart';

class AddBill extends StatefulWidget {
  final Function addBill;

  AddBill(this.addBill);

  @override
  _AddBillState createState() => _AddBillState();
}

class _AddBillState extends State<AddBill> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;

  void _submitData() {
    if (_amountController.text.isEmpty) {
      return;
    }

    final enteredDescription = _descriptionController.text;
    final enteredAmount = double.parse(_amountController.text);

    if (enteredDescription.isEmpty ||
        enteredAmount <= 0 ||
        _selectedDate == null) {
      return;
    }

    widget.addBill(
      enteredDescription,
      enteredAmount,
      _selectedDate!,
    );

    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            Container(
              height: 70,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No Date Chosen!'
                          : 'Picked Date: ${_selectedDate.toString()}',
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      'Choose Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _presentDatePicker,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              child: Text('Add Bill'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                Theme.of(context).primaryColor, // Button text color
              ),
              onPressed: _submitData,
            ),
          ],
        ),
      ),
    );
  }
}

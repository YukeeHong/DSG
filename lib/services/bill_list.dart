import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nus_orbital_chronos/services/bill.dart';

class BillList extends StatelessWidget {
  final List<Bill> bills;
  late Box<Bill> billsBox = Hive.box<Bill>('Bills');

  BillList(this.bills);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bills.length,
      itemBuilder: (ctx, index) {
        return Card(
          child: ListTile(
            title: Text(bills[index].description),
            subtitle: Text(
              '\$${bills[index].amount.toStringAsFixed(2)} - ${bills[index].date.toString()}',
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                billsBox.delete(bills[index].id);
              },
            ),
          ),
        );
      },
    );
  }
}

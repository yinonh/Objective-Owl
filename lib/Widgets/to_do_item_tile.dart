import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/to_do_list.dart';
import '../Screens/single_list_screen.dart';

class ToDoItemTile extends StatelessWidget {
  final ToDoList item;
  final Function(ToDoList) onDelete;
  // bool is_done = false;

  ToDoItemTile({required this.item, required this.onDelete});

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Deletion',
            style: TextStyle(color: Color(0xFF864879)),
          ),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF864879),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFF864879),
                ),
              ),
            ),
          ],
        );
      },
    ).then((value) {
      if (value == true) {
        onDelete(item);
      }
    });
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // is_done = item.deadline.isBefore(DateTime.now()) ||
    //     item.totalItems == item.accomplishedItems;
    final DateTime currentDate = DateTime.now();

    final int totalDays = item.deadline.difference(item.creationDate).inDays;
    final int remainingDays = item.deadline.difference(currentDate).inDays;
    double progressPercentage;
    if (item.totalItems != 0) {
      progressPercentage = (item.accomplishedItems / item.totalItems);
    } else {
      progressPercentage = 1;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, SingleListScreen.routeName,
            arguments: item.id);
      },
      child: Container(
        decoration: BoxDecoration(
          // border:
          //     is_done ? Border.all(color: Color(0xFF936995), width: 5) : null,
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Checkbox(
                  //   value: is_done,
                  //   onChanged: (value) {},
                  //   activeColor: Color(0xFF945985),
                  // ),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF864879),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        _showDeleteConfirmation(context);
                      },
                      icon: Icon(Icons.delete, color: Colors.black))
                  // Icon(Icons.delete, color: Colors.black),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDate(item.creationDate), // Format creationDate
                    style: const TextStyle(
                      // fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    formatDate(item.deadline), // Format deadline
                    style: const TextStyle(
                      // fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              LinearProgressIndicator(
                value: remainingDays <= 0
                    ? 1
                    : (totalDays - remainingDays) / totalDays,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF393053)),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Remaining Days: ${remainingDays <= 0 ? "done" : remainingDays}',
                // style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Items: ${item.totalItems}',
                    // style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Accomplished Items: ${item.accomplishedItems}',
                    // style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              LinearProgressIndicator(
                value: progressPercentage,
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF635985)),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Progress: ${(progressPercentage * 100).toStringAsFixed(0)}%',
                // style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

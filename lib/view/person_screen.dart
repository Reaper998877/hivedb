import 'package:flutter/material.dart';
import 'package:hive_db/controller/person_controller.dart';
import 'package:hive_db/model/person_model.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class PersonScreen extends StatefulWidget {
  const PersonScreen({super.key});

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  final PersonController _controller =
      PersonController(); // Provides database CRUD functions.
  DateTime _selectedDate = DateTime.now();

  // Add, Update dialog
  void _showInputDialog(DateTime date, [Person? existing]) {
    final nameC = TextEditingController(text: existing?.name ?? '');
    final ageC = TextEditingController(text: existing?.age.toString() ?? '');
    final contactC = TextEditingController(text: existing?.contactNumber ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? "Add Details" : "Edit Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              style: TextStyle(fontFamily: 'poppins'),
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: ageC,
              keyboardType: TextInputType.number,
              style: TextStyle(fontFamily: 'poppins'),
              decoration: InputDecoration(labelText: 'Age'),
            ),
            TextField(
              controller: contactC,
              keyboardType: TextInputType.phone,
              style: TextStyle(fontFamily: 'poppins'),
              decoration: InputDecoration(labelText: 'Contact Number'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.red.shade800,
                fontFamily: 'amaranth',
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Stores input from input fields.
              final name = nameC.text;
              final age = int.tryParse(ageC.text);
              final contact = contactC.text;

              if (name.isEmpty || age == null || contact.isEmpty) return;

              if (existing != null) {
                // If the object exists, then only it updates.  // Handles update operation.
                await _controller.updatePerson(
                  existing,
                  Person(
                    name: name,
                    age: age,
                    contactNumber: contact,
                    dateTime: date,
                  ),
                );
              } else {
                // If the object doesn't exists, add new one.  // Handles add operation.
                await _controller.addPerson(
                  Person(
                    name: name,
                    age: age,
                    contactNumber: contact,
                    dateTime: date,
                  ),
                );
              }
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(
              "Save",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.blue.shade800,
                fontFamily: 'amaranth',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hive DB CRUD (MVC)",
          style: TextStyle(fontFamily: 'poppins'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              TableCalendar(
                focusedDay: _selectedDate, // Shows initial date
                // Starts from the year 2000 to 2150.
                firstDay: DateTime(2000),
                lastDay: DateTime(2150),
                // Highlights currently selected date
                selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                onDaySelected: (selected, _) {
                  setState(
                    () => _selectedDate = selected,
                  ); // Updates selected date when tapped
                },
                eventLoader: _controller
                    .getPersonsForDay, // Shows events (Person entries) for each day
              ),
              Expanded(
                child: ValueListenableBuilder(
                  // Updates UI when there is change in database, via CRUD operations.
                  valueListenable: _controller.listenToPersons(),
                  builder: (context, box, _) {
                    final persons = _controller.getPersonsForDay(_selectedDate);
                    // Creates a list of objects stored in db, based on a specific date.

                    if (persons.isEmpty) {
                      // If list is empty, shows a message and add button.
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No entries for ${DateFormat.yMMMd().format(_selectedDate)}",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'poppins',
                              ),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              // Add Button
                              onPressed: () => _showInputDialog(_selectedDate),
                              child: Text(
                                "Add Entry",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.blue.shade800,
                                  fontFamily: 'amaranth',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      // Displays a list of objects stored in db, based on a specific date.
                      itemCount: persons.length,
                      itemBuilder: (_, index) {
                        final p = persons[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              p.name,
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: .w600,
                              ),
                            ),
                            subtitle: Text(
                              "Age: ${p.age}, \nContact: ${p.contactNumber}",
                              style: TextStyle(fontFamily: 'poppins'),
                            ),
                            trailing: Row(
                              mainAxisSize: .min,
                              children: [
                                IconButton(
                                  // Update Button
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _showInputDialog(p.dateTime, p);
                                  },
                                ),
                                IconButton(
                                  // Delete Button
                                  icon: Icon(Icons.delete),
                                  onPressed: () async =>
                                      _controller.deletePerson(p),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Add Button
        shape: CircleBorder(),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        onPressed: () => _showInputDialog(_selectedDate),
        child: Icon(Icons.add),
      ),
    );
  }
}

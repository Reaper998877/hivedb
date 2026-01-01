import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_db/model/person_model.dart';

// PersonController is a controller class that handles all operations related to the Person Hive box.
class PersonController {
  final Box<Person> _personBox = Hive.box<Person>('persons');
  // Opens the Hive box named "persons" which stores Person objects.
  // This allows the controller to read/write/update/delete data.

  /// Add a new person object
  Future<void> addPerson(Person person) async {
    await _personBox.add(person);
  }

  /// Update an existing person
  Future<void> updatePerson(Person oldPerson, Person newPerson) async {
    // Converts all entries to a list.
    // Finds the index of the old person/object.
    final index = _personBox.values.toList().indexOf(oldPerson);
    if (index != -1) {
      // Checks if index is valid.
      await _personBox.putAt(index, newPerson);
      // putAt(index, value) updates the object at that specific Hive position.
    }
  }

  /// Delete a person
  Future<void> deletePerson(Person person) async {
    await person.delete();
    // Since Person extends HiveObject, every object knows its box + key.
    // person.delete() removes that entry from Hive automatically.
  }

  /// Get persons for specific date
  List<Person> getPersonsForDay(DateTime date) {
    return _personBox.values
        .where(
          (p) =>
              p.dateTime.year == date.year &&
              p.dateTime.month == date.month &&
              p.dateTime.day == date.day,
        )
        .toList();
    // Loops through all persons in the database.
    // Filters and returns a list of those whose dateTime matches the selected date.
  }

  /// Listenable for UI
  ValueListenable<Box<Person>> listenToPersons() {
    return _personBox.listenable();
    // This allows your UI to automatically refresh when data changes.
    // Used with: ValueListenableBuilder()
  }
}

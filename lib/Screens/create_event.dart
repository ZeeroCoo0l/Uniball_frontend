import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';
import 'package:uniball_frontend_2/entities/practice.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_practice_communication.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final backend = BackendUserCommunication();
  final practiceBackend = BackendPracticeCommunication();
  final _formKey = GlobalKey<FormState>();

  String location = "Plats";
  String information = "Information";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  UserClient? currentUser;

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  void fetchCurrentUser() async {
    currentUser = await backend.getCurrentUser();
    setState(() {});
  }

  void _showCupertinoDatePicker() {
    DateTime tempPickedDate = selectedDate ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempPickedDate,
                  onDateTimeChanged: (DateTime newDate) {
                    tempPickedDate = newDate;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Avbryt'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedDate = tempPickedDate;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCupertinoTimePicker() {
    DateTime tempPickedTime = DateTime.now();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: tempPickedTime,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newTime) {
                    tempPickedTime = newTime;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Avbryt'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedTime = TimeOfDay.fromDateTime(tempPickedTime);
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate() &&
        selectedDate != null &&
        selectedTime != null) {
      _formKey.currentState!.save();

      final dateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      if (currentUser == null) {
        showDialog(
          context: context,
          builder:
              (_) => const AlertDialog(
                content: Text("Kunde inte hämta användare. Försök igen!"),
              ),
        );
        return;
      }

      final newPractice = Practice(
        id: null,
        name: "Träning",
        location: location,
        dateTime: dateTime,
        information: information,
        teamId: currentUser!.teamId,
      );
      debugPrint('TEST: ${currentUser!.teamId}');

      try {
        await practiceBackend.createPractice(newPractice);

        showDialog(
          context: context,
          builder:
              (_) =>
                  const AlertDialog(content: Text("Aktiviteten har skapats!")),
        );

        Future.delayed(const Duration(milliseconds: 1200), () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      } catch (e) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(content: Text("Något gick fel!: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      selectedIndex: -1,
      onTabChange: (index) => handleTabChange(context, index),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Skapa Träningstillsfälle",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(158, 158, 158, 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Aktivitetstyp",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 70,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6CBC8C),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Center(
                              child: const Text(
                                "Träning",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Datum",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          GestureDetector(
                            onTap: _showCupertinoDatePicker,
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText:
                                      selectedDate == null
                                          ? "Välj datum"
                                          : "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Tid",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          GestureDetector(
                            onTap: _showCupertinoTimePicker,
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText:
                                      selectedTime == null
                                          ? "Välj tid"
                                          : selectedTime!.format(context),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(Icons.access_time),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Plats",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Plats",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? "Fyll i plats"
                                        : null,
                            onSaved: (value) => location = value!,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Information",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Information (valfritt)",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator:
                                (value) =>
                                    null,
                            onSaved:
                                (value) =>
                                    information =
                                        value ??
                                        '',
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: null,
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  const Color(0xFF094A1C),
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              child: const Text(
                                "Lägg till",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

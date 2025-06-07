import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';
import 'package:uniball_frontend_2/entities/practice.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_practice_communication.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';

class EditPractice extends StatefulWidget {
  final Practice practice;
  const EditPractice({super.key, required this.practice});

  @override
  State<EditPractice> createState() => _EditPracticeState();
}

class _EditPracticeState extends State<EditPractice> {
  final backend = BackendUserCommunication();
  final practiceBackend = BackendPracticeCommunication();
  final _formKey = GlobalKey<FormState>();

  String location = "";
  String information = "";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  UserClient? currentUser;
  Practice? currentPractice;
  late TextEditingController locationController;
  late TextEditingController informationController;

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
    locationController = TextEditingController();
    informationController = TextEditingController();
    loadPracticeInfo();
  }

  @override
  void dispose() {
    locationController.dispose();
    informationController.dispose();
    super.dispose();
  }

  void fetchCurrentUser() async {
    currentUser = await backend.getCurrentUser();
    setState(() {});
  }

  void loadPracticeInfo() async {
    try {
      currentPractice = await practiceBackend.getPractice(
        widget.practice.id.toString(),
      );
      if (currentPractice == null) return;

      final practiceDateTime = currentPractice!.date;

      setState(() {
        selectedDate = DateTime(
          practiceDateTime.year,
          practiceDateTime.month,
          practiceDateTime.day,
        );
        selectedTime = TimeOfDay(
          hour: practiceDateTime.hour,
          minute: practiceDateTime.minute,
        );
        location = currentPractice!.location;
        information = currentPractice!.information;
        locationController.text = location;
        informationController.text = information;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kunde inte ladda träningen.')));
    }
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
    DateTime remakeTime = convertTimeOfDayToDateTime(
      selectedTime ?? TimeOfDay.now(),
    );
    DateTime tempPickedTime = remakeTime;

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
                  initialDateTime: remakeTime,
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
                        selectedTime = TimeOfDay(
                          hour: tempPickedTime.hour,
                          minute: tempPickedTime.minute,
                        );
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

  DateTime convertTimeOfDayToDateTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
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
        id: widget.practice.id,
        name: "Träning",
        location: location,
        dateTime: dateTime,
        information: information,
        teamId: currentUser!.teamId,
        attendees: widget.practice.attendees,
        isRead: widget.practice.isRead,
        isCancelled: widget.practice.isCancelled,
      );

      try {
        await practiceBackend.updatePractice(newPractice);

        showDialog(
          context: context,
          builder:
              (_) => const AlertDialog(
                content: Text("Aktiviteten har uppdaterats!"),
              ),
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

  void _toggleCancelPractice() async{
    Practice currentPractice = widget.practice;
      try {
        final result = await practiceBackend.toggleCancelledPractice(currentPractice);
        if(!result){
          showDialog(
          context: context,
          builder:
              (_) => const AlertDialog(
                content: Text("Aktiviteten kunde inte ställas in, testa igen om en stund."),
              ),

        );
        }
        else{
          showDialog(
          context: context,
          builder:
              (_) => const AlertDialog(
                content: Text("Aktiviteten har uppdaterats!"),
              ),
        );
        }

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
                      "Ändra Träningstillsfälle",
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
                            child: const Center(
                              child: Text(
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
                                          : formatDate(selectedDate!),
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
                                          : formatTime(selectedTime!),
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
                            controller: locationController,
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
                            controller: informationController,
                            decoration: InputDecoration(
                              labelText: "Information (valfritt)",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onSaved: (value) => information = value ?? '',
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: null,
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize
                                      .min, // Viktigt för att inte ta upp hela bredden
                              children: [
                                ElevatedButton(
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
                                    "Uppdatera",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                ElevatedButton(
                                  onPressed: _toggleCancelPractice,
                                  style: ButtonStyle(
                                    backgroundColor: !widget.practice.isCancelled ?  WidgetStateProperty.all(
                                      Colors.red,
                                    ) : WidgetStateProperty.all(Colors.green),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  child: Text( !widget.practice.isCancelled ?
                                    "Ställ in" : "Återställ",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
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

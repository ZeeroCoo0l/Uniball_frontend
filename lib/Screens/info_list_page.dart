import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';
import 'package:uniball_frontend_2/entities/practice.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:uniball_frontend_2/services/backend_practice_communication.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';
import 'add_info_page.dart';

//den här sidan används inte men finns kvar ifall det är något som vill läggas till i framtiden

class InfoListPage extends StatefulWidget {
  @override
  _InfoListPageState createState() => _InfoListPageState();
}

class _InfoListPageState extends State<InfoListPage> {
  BackendPracticeCommunication practiceCommunication = BackendPracticeCommunication();
  BackendUserCommunication userCommunication = BackendUserCommunication();
  late final List<Practice> items = [];
  bool isAdmin = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInformation();
  }

  Future<void> _loadInformation() async {
    items.clear();
    UserClient? currentUser = await userCommunication.getCurrentUser();
    if (currentUser == null) {
      debugPrint("Could not load information, becuase current user not found.");
      return;
    }
    List<Practice>? practices = await practiceCommunication.getPracticeForTeam(
      currentUser.teamId,
    );

    if (practices == null) {
      debugPrint("Could not load information, because no practices was found.");
      return;
    }

    bool temp = await _isCurrentUserAdmin();
    setState(() {
      items.addAll(practices);
      isAdmin = temp;
    });
  }

  Future<bool> _isCurrentUserAdmin() async {
    // TODO: Check if currentUser is admin
    return false;
  }



  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
    handleTabChange(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      selectedIndex: -1,
      onTabChange: _onTabChange,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Information',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                radius: Radius.circular(10),
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        GestureDetector(
                          onLongPress:
                              () => showDialog(
                                context: context,
                                builder:
                                    (context) =>
                                        _editItem(items.elementAt(index)),
                              ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F3ED),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ExpansionTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              tilePadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              title: Text(
                                formatDateForTitle(index),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    20,
                                  ),
                                  child: Text(
                                    items
                                        .elementAt(index)
                                        .information,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: -4,
                          left: 0,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Ta bort'),
                                      content: Text(
                                        'Är du säker på att du vill ta bort ${formatDateForTitle(index)}', 
                                      ),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context),
                                          child: const Text('Nej'),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              items.remove(
                                                items.elementAt(index),
                                              );
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Ja'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            child: const Icon(Icons.close, color: Colors.black),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isAdmin)
              Align(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddInfoPage()),
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String formatDateForTitle(int index) {
    DateTime date = items.elementAt(index).date;
    final DateFormat formatter = DateFormat("d MMMM yy", "sv_SE");
    String title = formatter.format(date);

    return title;
  }

  Widget _editItem(Practice practiceToEdit) {
    TextEditingController infoController = TextEditingController(
      text: practiceToEdit.information,
    );
    return AlertDialog(
      title: Text("Redigera information"),
      content: TextFormField(
        controller: infoController,
        maxLines: 5,
        decoration: const InputDecoration(
          label: Text('Information'),
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Avbryt'),
        ),
        ElevatedButton(
          onPressed: () async {
            setState(() {
              practiceToEdit.information = infoController.text;
            });
            Practice? practice = await practiceCommunication.getPractice(
              practiceToEdit.id.toString(),
            );
            bool result = await practiceCommunication.updateInformation(
              practice,
            );
            print("Result:" + result.toString());
            if (!result) {
              return;
            }
            await _loadInformation();
            Navigator.pop(context);
            infoController.clear();
          },
          child: const Text('Spara'),
        ),
      ],
    );
  }
}

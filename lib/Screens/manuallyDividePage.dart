import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';
import 'package:uniball_frontend_2/constants.dart';

//denna sida används inte men kan läggas till om vi vill för framtida utveckling

class ManuallyDividePage extends StatefulWidget {
  final List<String> attendees;
  final int teamSize;

  const ManuallyDividePage({
    super.key,
    this.attendees = const [],
    this.teamSize = 0,
  });

  @override
  _ManuallyDividePageState createState() => _ManuallyDividePageState();
}

class _ManuallyDividePageState extends State<ManuallyDividePage> {
  late List<String> allPlayers;
  late int teamSize;
  late List<String?> teamAPlayers;
  late List<String?> teamBPlayers;

  @override
  void initState() {
    super.initState();
    allPlayers = widget.attendees;
    teamSize = widget.teamSize;
    teamAPlayers = List.filled(teamSize, null);
    teamBPlayers = List.filled(teamSize, null);
  }

  void _saveTeams() {
    // Kontroll så att inga dubbletter väljs
    final allSelectedPlayers = [...teamAPlayers, ...teamBPlayers];
    final uniquePlayers = allSelectedPlayers.toSet();

    if (allSelectedPlayers.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Välj spelare till alla positioner.")),
      );
      return;
    }
    if (uniquePlayers.length != teamSize + teamSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("En spelare kan inte vara i två lag.")),
      );
      return;
    }

    print("Lag A: $teamAPlayers");
    print("Lag B: $teamBPlayers");

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Lag sparade!")));
    //byter sida och kanske ska skicka med det här men då måste vi ändra så att
    //det finns en konstruktor i shuffledteams som tar emot informationen
    /*Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => ManuallyDividePage(
                          teamA: teamAPlayers,
                          teamB: teamBPlayers,
                          teamSize: teamSize, //behövs denna?
                          groupByPosition: groupByPosition,

                        ),
                  ),
                );
                */
  }

  Widget _buildDropdown(
    int index,
    List<String?> selectedPlayers,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedPlayers[index],
      items:
          allPlayers
              .map(
                (player) =>
                    DropdownMenuItem(value: player, child: Text(player)),
              )
              .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.softMint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: Color(0xFFE6F0E6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      selectedIndex: -1,
      onTabChange: (index) => handleTabChange(context, index),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Center(
              child: Text(
                "Redigera lag",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Lag A", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Lag B", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            // Dropdown-rader
            Expanded(
              child: ListView.builder(
                itemCount: teamSize,
                itemBuilder:
                    (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          // Lag A Dropdown
                          Flexible(
                            child: _buildDropdown(
                              index,
                              teamAPlayers,
                              (value) =>
                                  setState(() => teamAPlayers[index] = value),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Lag B Dropdown
                          Flexible(
                            child: _buildDropdown(
                              index,
                              teamBPlayers,
                              (value) =>
                                  setState(() => teamBPlayers[index] = value),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
            // Spara-knapp
            ElevatedButton(
              onPressed: _saveTeams,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkGreen,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Spara ändringar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

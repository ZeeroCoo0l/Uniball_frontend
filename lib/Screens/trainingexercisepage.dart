import 'package:flutter/material.dart';
import 'dart:math';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';

class TrainingExercisePage extends StatefulWidget {
  @override
  _TrainingExercisePageState createState() => _TrainingExercisePageState();
}

class _TrainingExercisePageState extends State<TrainingExercisePage> {
  final List<String> categories = [
    'Uppvärmning',
    'Huvudövning',
    'Stretch/Avslut',
  ];

  bool isLoading = false;
  int numberOfPlayers = 0;
  bool forceExpand = false;

  Map<String, List<Map<String, String>>> groupedTrainingExercises = {};
  Map<String, bool> expandedTiles = {};


  @override
  void initState() {
    super.initState();
    fetchRandomTrainingExercises();
  }

  Future<void> fetchRandomTrainingExercises() async {
    setState(() {
      isLoading = true;
    });

    final random = Random();
    

    final allExercises = {
      'Uppvärmning': [
        {'name': 'Jogga på stället','description': 'Lätt uppvärmning i 2 minuter'},
        {'name': 'Armrotationer', 'description': '10 reps framåt och bakåt'},
        {'name': 'Höga knän', 'description': '30 sekunder höga knän'},
        {'name': 'Hopprep', 'description': '1 minut intensivt'},
        {'name': 'Sidosteg', 'description': 'Snabba sidosteg i 30 sek'},
        {'name': 'Knäböj', 'description': 'Lätta knäböj 15 reps'},
      ],
      'Huvudövning': [
        {'name': 'Dribblingsövning', 'description': 'Snabba fötter med boll'},
        {'name': 'Passningskombination', 'description': 'Passa och rör dig'},
        {'name': 'Träningsmatch', 'description': 'spela en kort match'},
        {'name': 'Målövning', 'description': 'Avslut från olika vinklar'},
        {'name': 'Spel 3v3', 'description': 'Litet spel med högt tempo'},
        {'name': 'Konditionsbana', 'description': 'Runda koner och hinder'},
        {'name': 'Backintervaller', 'description': 'Spring i backe 5 gånger'},
      ],
      'Stretch/Avslut': [
        {'name': 'Sittande tå-touch', 'description': 'Stretch för baksida lår'},
        {'name': 'Armsträckningar', 'description': 'Öppna upp bröst och axlar'},
        {'name': 'Djupa andetag', 'description': 'Varva ner i 2 minuter'},
        {'name': 'Barnets position', 'description': 'Yoga stretch i 1 minut'},
        {'name': 'Väggstretch', 'description': 'Stretch för vader och lår'},
        {
          'name': 'Liggande vridning',
          'description': 'Stretch för rygg och bål',
        },
      ],
    };
    
    final newExercises = allExercises.map((category, exercises) {
    exercises.shuffle(random);
    return MapEntry(category, exercises.take(3).toList());
  });

    final newExpandedTiles = {
    for (var category in categories) category: true,
  };

    setState(() {
      
       groupedTrainingExercises = newExercises;
       expandedTiles = {
        for (var category in categories) category: true,
      };
      forceExpand = true; // öppna allt automatiskt
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (forceExpand) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        forceExpand = false;
      });
    });
  }
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
                children: [
                  const Center(
                    child: Text(
                      "Träningsövningar",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Slumpa nya övningar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF094A1C),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 6,
                      ),
                      onPressed: () {
                        fetchRandomTrainingExercises();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nya övningar har slumpats!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
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
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children:
                            categories.map((category) {
                              final exercises =
                                  groupedTrainingExercises[category] ?? [];
                            
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ExpansionTile(
                                    key: ValueKey(category),
                                    title: Text(
                                      category,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                    ),
                                    initiallyExpanded: forceExpand || (expandedTiles[category] ?? false),
                                    onExpansionChanged: (isExpanded) {
                                       setState(() {
                                         expandedTiles[category] = isExpanded;
                                        });
                                       },
                                    children: [
                                      Container(
                                        width:
                                            double
                                                .infinity, 
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 0,
                                          vertical: 0,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.15,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children:
                                              exercises.map((exercise) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 12,
                                                      ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        exercise['name']!,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        exercise['description']!,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                      
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

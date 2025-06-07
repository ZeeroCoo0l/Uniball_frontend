import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';
import 'package:uniball_frontend_2/services/backend_user_communication.dart';
import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uniball_frontend_2/components/buildeditableinfofield.dart';
import 'package:uniball_frontend_2/services/backend_team_communication.dart';
import 'package:uniball_frontend_2/entities/team.dart';
import 'package:uniball_frontend_2/components/buildFavoritePositionDropdown.dart';
import 'package:uniball_frontend_2/components/saveProfileHandler.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  int currentIndex = -1;
  final backendUser = BackendUserCommunication();
  final backendTeam = BackendTeamCommunication();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();
  final teamController = TextEditingController();

  final _usernameConfirmController = TextEditingController();
  final _emailConfirmController = TextEditingController();
  Position _selectedPosition = Position.NOPOSITION;
  final Map<Position, String> _positionLabels = {
    Position.GOALKEEPER: 'Målvakt',
    Position.DEFENDER: 'Försvarare',
    Position.MIDFIELDER: 'Mittfältare',
    Position.FORWARD: 'Anfallare',
    Position.NOPOSITION: 'Ingen position',
  };
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  UserClient? user;
  String teamName = 'lagnamn';
  late Team team;
  late String profilePicture;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    bioController.dispose();
    _usernameConfirmController.dispose();
    _emailConfirmController.dispose();
    teamController.dispose();
    super.dispose();
  }

  void _loadUserInfo() async {
    try {
      UserClient? currentUser = await backendUser.getCurrentUser();
      if (currentUser == null) return;

      String urlString = await backendUser.getProfilePic(
        currentUser.profilePic,
      );
      String teamId = currentUser.teamId;
      Team? currentTeam = await backendTeam.getTeam(teamId);
      if (currentTeam == null) return;

      setState(() {
        user = currentUser;
        usernameController.text = currentUser.name;
        emailController.text = currentUser.email;
        _selectedPosition = currentUser.favoritePosition ?? Position.NOPOSITION;
        bioController.text = currentUser.description;
        profilePicture = urlString;
        teamController.text = currentTeam.name;
      });
    } catch (e) {
      print('Fel vid hämtning av användarinformation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte ladda användarinformation.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      selectedIndex: currentIndex,
      onTabChange: (index) => handleTabChange(context, index),
      child: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 75,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            backgroundImage:
                                _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : (user?.profilePic != null &&
                                            user!.profilePic.isNotEmpty
                                        ? NetworkImage(user!.profilePic)
                                        : null),
                            child:
                                _profileImage == null &&
                                        (user?.profilePic == null ||
                                            user!.profilePic.isEmpty)
                                    ? Center(
                                      child: Icon(
                                        Icons.person,
                                        size: 75,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    )
                                    : null,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Redigera profilbild',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6CBC8C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  EditableInfoField(
                    title: "Användarnamn",
                    controller: usernameController,
                    hint: "Ange ditt användarnamn",
                    readOnly: false,
                  ),
                  EditableInfoField(
                    title: "E-postadress, går inte att redigera",
                    controller: emailController,
                    hint: "",
                    readOnly: true,
                  ),
                  FavoritePositionDropdown(
                    selectedPosition: _selectedPosition,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPosition = newValue;
                        });
                      }
                    },
                    positionLabels: _positionLabels,
                  ),
                  EditableInfoField(
                    title: 'Mitt Lag',
                    controller: teamController,
                    hint: "",
                    readOnly: true,
                  ),
                  EditableInfoField(
                    title: "Biografi",
                    controller: bioController,
                    hint: "Skriv en kort biografi",
                    maxLines: 5,
                    readOnly: false,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final handler = SaveProfileHandler(
                            context: context,
                            usernameController: usernameController,
                            bioController: bioController,
                            backendUser: backendUser,
                            backendTeam: backendTeam,
                            selectedPosition: _selectedPosition,
                            profileImage: _profileImage,
                          );
                          await handler.saveProfile();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6CBC8C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Spara",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/profilepageshort');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Avbryt",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(
          pickedFile.path,
        ); 
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profilbild uppdaterad!')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ingen bild valdes.')));
    }
  }
}

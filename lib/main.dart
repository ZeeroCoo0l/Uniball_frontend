import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniball_frontend_2/Screens/Hamburgar_menu/aboutpage.dart';
import 'package:uniball_frontend_2/Screens/Hamburgar_menu/privacy_policy_page.dart';
import 'package:uniball_frontend_2/Screens/Hamburgar_menu/terms_page.dart';
import 'package:uniball_frontend_2/Screens/Login&SignUp/create_or_join_team.dart';
import 'package:uniball_frontend_2/Screens/Login&SignUp/login_page.dart';
import 'package:uniball_frontend_2/Screens/create_event.dart';
import 'package:uniball_frontend_2/Screens/editprofilepage.dart';
import 'package:uniball_frontend_2/Screens/editpractice.dart';
import 'package:uniball_frontend_2/Screens/homepage.dart';
import 'package:uniball_frontend_2/Screens/homepage_admin.dart';
import 'package:uniball_frontend_2/Screens/info_list_page.dart';
import 'package:uniball_frontend_2/Screens/knappsida.dart';
import 'package:uniball_frontend_2/Screens/leaderboard.dart';
import 'package:uniball_frontend_2/Screens/manuallyDividePage.dart';
import 'package:uniball_frontend_2/Screens/profilepage.dart';
import 'package:uniball_frontend_2/Screens/Login&SignUp/launch_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uniball_frontend_2/Screens/shuffled_teams.dart';
import 'package:uniball_frontend_2/Screens/shakesqaud.dart';
import 'package:uniball_frontend_2/Screens/toDividePage.dart';
import 'package:uniball_frontend_2/Screens/voting1Best.dart';
import 'package:uniball_frontend_2/Screens/voting2Mvp.dart';
import 'package:uniball_frontend_2/Screens/voting3Goal.dart';
import 'package:uniball_frontend_2/components/launch_handler_homepage.dart';
import 'package:uniball_frontend_2/components/votingpopup.dart';
import 'package:uniball_frontend_2/Screens/trainingexercisepage.dart';
import 'package:uniball_frontend_2/Screens/admin_player_settings.dart';
import 'package:uniball_frontend_2/entities/practice.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('sv_SE');
  await Supabase.initialize(
    url: 'URL_TO_SUPABASE',
    anonKey:
        'ANON_KEY_TO_SUPABASE',
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  void userTapped() {
    debugPrint("user tapped");
  }

  Future<bool> checkLoginStatus() async {
    print("Checking if user is logged in on device.");
    final currentSession = Supabase.instance.client.auth.currentSession;

    print("User has active login-session:${currentSession != null}");
    return currentSession != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      home: FutureBuilder(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator.adaptive()),
            );
          }

          if (snapshot.hasData && snapshot.data == true) {
            return const LaunchHandlerHomepage();
          } else {
            return LaunchPage();
          }
        },
      ),

      routes: {
        '/knappsida': (context) => KnappSida(),
        '/Login&SignUp/launchpage': (context) => LaunchPage(),
        '/profilepage': (context) => ProfilePage(),
        '/profilepageshort': (context) => ProfilePageShortcut(),
        '/homepage': (context) => HomePage(),
        '/leaderboard': (context) => LeaderBoard(),
        '/createaccount': (context) => LoginPage(),
        '/editprofilepage': (context) => EditProfilePage(),
        '/informationpage': (context) => InfoListPage(),
        '/create_event': (context) => CreateEvent(),
        '/trainingexercisepage': (context) => TrainingExercisePage(),
        '/admin_player_settings': (context) => PlayerSettings(),
        '/homepage_admin': (context) => HomePageAdmin(),
        '/toDividePage': (context) => ToDividePage(),
        '/manuallyDividePage': (context) => ManuallyDividePage(),
        '/create_or_join_team': (context) => const CreateOrJoinTeam(),
        '/privacypolicypage': (context) => const PrivacyPolicyPage(),
        '/termspage': (context) => const TermsPage(),
        '/aboutpage': (context) => const AboutPage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/shuffledteams') {
          final practice = settings.arguments as Practice;
          return MaterialPageRoute(
            builder: (context) => ShuffledTeams(currentPractice: practice),
          );
        }

        if (settings.name == '/shakesquad') {
          final practice = settings.arguments as Practice;
          return MaterialPageRoute(
            builder: (context) => ShakeSqaudPage(practice: practice),
          );
        }

        if (settings.name == '/voting1Best') {
          final practice = settings.arguments as Practice;
          return MaterialPageRoute(
            builder: (context) => Voting1Best(currentPractice: practice),
          );
        }

        if (settings.name == '/voting2Mvp') {
          final practice = settings.arguments as Practice;
          return MaterialPageRoute(
            builder: (context) => Voting2Mvp(currentPractice: practice),
          );
        }

        if (settings.name == '/voting3Goal') {
          final practice = settings.arguments as Practice;
          return MaterialPageRoute(
            builder: (context) => Voting3Goal(currentPractice: practice),
          );
        }

        if (settings.name == '/editpractice') {
          final practice = settings.arguments as Practice;
          return MaterialPageRoute(
            builder: (context) => EditPractice(practice: practice),
          );
        }

        if (settings.name == '/votingpopup') {
          final practice = settings.arguments as Practice;
          return MaterialPageRoute(
            builder: (context) => VotePopup(onContinue: () {}, onClose: () {}, practice: practice,),
          );
        }

        return null; // fallback
      },
    );
  }
}

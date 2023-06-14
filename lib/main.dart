import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maruchat/screen/chat_screen.dart';
import 'package:maruchat/screen/login_screen.dart';
import 'package:maruchat/screen/register_screen.dart';
import 'package:maruchat/screen/welcome_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Marugo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: WelcomeScreen.routeName,
      routes : {
        WelcomeScreen.routeName:(context)=> const WelcomeScreen(),
        RegistrationScreen.routeName:(context)=> const RegistrationScreen(),
        LoginScreen.routeName:(context)=> const LoginScreen(),
        ChatScreen.routeName:(context)=> const ChatScreen(),
      },
    );
  }
}



import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'home_page.dart';
import 'util/my_http_overrides .dart';
import 'util/restapi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //* Required to override the default bad cert settings
  HttpOverrides.global = MyHttpOverrides();
  runApp(const SatsMe());
}

class SatsMe extends StatelessWidget {
  const SatsMe({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SatsMe',
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          } else if (snapshot.hasData) {
            return const LoginPage();
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      initialRoute: '/',
      routes: {
        '/HomePage': (context) => const HomePage(),
        // '/CreateCampaign': (context) => const CreateCampaignPage(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.only(top: 95),
                child: Column(children: [
                  //Title
                  const Text.rich(
                    TextSpan(
                        text: 'Sats',
                        children: [
                          TextSpan(
                            text: 'me',
                            style: TextStyle(
                                fontSize: 54.5,
                                fontWeight: FontWeight.w300,
                                color: Colors.black),
                          ),
                        ],
                        style: TextStyle(
                          fontSize: 55,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        )),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 110),
                    child: Text(
                      'Bitcoin crowd fund',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  //Form
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.25,
                    child: Column(children: [
                      //Username
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Username',
                          ),
                          onChanged: (text) {
                            globals.loggedInUserName = text;
                          },
                        ),
                      ),
                      //Password
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                            ),
                            //forgotpassword?
                            TextButton(
                              onPressed: () async {
                                RestApi api = RestApi();
                                var result = await api.getLightningBalance();
                                print(result);
                              },
                              style: TextButton.styleFrom(primary: Colors.blue),
                              child: const Text('Forgot Password?'),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),

            //login button at bottom
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.25,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepOrange,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/HomePage');
                },
                child: const Text('Login'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(2.0),
              child: SizedBox(),
            )
          ],
        ),
      ),
    );
  }
}

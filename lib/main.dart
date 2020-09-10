import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isBusy = false;
  final FlutterAppAuth _appAuth = FlutterAppAuth();

  final String _clientId = 'SocailLogin';
  final String _redirectUrl =
      'https://34.204.16.224:8458/auth/realms/smartcity/broker/gitlab/endpoint';
  final String _discoveryUrl =
      'https://34.204.16.224:8458/auth/realms/smartcity/.well-known/openid-configuration';
  final List<String> _scopes = <String>[
    'openid',
    'profile',
    'email',
    'offline_access',
    'api'
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App Auth'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: _isBusy,
                child: const LinearProgressIndicator(),
              ),
              RaisedButton(
                child: const Text('Sign in with no code exchange'),
                onPressed: () async {
                  try {
                    final AuthorizationResponse result =
                        await _appAuth.authorize(
                      AuthorizationRequest(_clientId, _redirectUrl,
                          discoveryUrl: _discoveryUrl, scopes: _scopes),
                    );
                    if (result != null) {
                      print("Here the result: $result");
                    }
                  } catch (e) {
                    print("Result not found due to :$e");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

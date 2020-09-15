import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:openid_client/openid_client.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';

const html = """
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Grant Access to Flutter</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    html, body { margin: 0; padding: 0; }

    main {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      font-family: -apple-system,BlinkMacSystemFont,Segoe UI,Helvetica,Arial,sans-serif,Apple Color Emoji,Segoe UI Emoji,Segoe UI Symbol;
    }

    #icon {
      font-size: 96pt;
    }

    #text {
      padding: 2em;
      max-width: 260px;
      text-align: center;
    }

    #button a {
      display: inline-block;
      padding: 6px 12px;
      color: white;
      border: 1px solid rgba(27,31,35,.2);
      border-radius: 3px;
      background-image: linear-gradient(-180deg, #34d058 0%, #22863a 90%);
      text-decoration: none;
      font-size: 14px;
      font-weight: 600;
    }

    #button a:active {
      background-color: #279f43;
      background-image: none;
    }
  </style>
</head>
<body>
  <main>
    <div id="icon">&#x1F3C7;</div>
    <div id="text">Press the button below to sign in using your Localtest.me account.</div>
    <div id="button"><a href="foobar://success?code=1337">Sign in</a></div>
  </main>
</body>
</html>
""";

class Client2Check extends StatefulWidget {
  @override
  _Client2CheckState createState() => _Client2CheckState();
}

class _Client2CheckState extends State<Client2Check> {
  bool _isBusy = false;
  String _status = '';
  String _appAuthStatus = '';
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final String _clientId = 'SocailLogin';
  final String _redirectUrl = 'https://34.204.16.224:8458/auth/realms/smartcity/broker/gitlab/endpoint';
  final String _discoveryUrl = 'https://34.204.16.224:8458/auth/realms/smartcity/.well-known/openid-configuration';
  final List<String> _scopes = <String>[
    'openid',
    'profile',
    'email',
    'offline_access',
    'api'
  ];

  authenticate() async {
    var uri = Uri.parse('http://34.204.16.224:8458/auth/realms/smartcity');
    var clientId = 'SmartLightDashboard';
    var scopes = List<String>.of(
        ['openid', 'profile', 'email', 'offline_access', 'api']);
    var port = 8458;
    var redirectUri = Uri.parse('https://34.204.16.224:8458/auth/realms/smartcity/broker/gitlab/endpoint');
    var issuer = await Issuer.discover(uri);
    var client = new Client(issuer, clientId);

    urlLauncher(String url) async {
      if (await canLaunch(url)) {
        await launch(url, forceWebView: true);
      } else {
        throw 'Could not launch $url';
      }
    }

    var authenticator = new Authenticator(client,
        scopes: scopes,
        port: port,
        urlLancher: urlLauncher,
        redirectUri: redirectUri);

    var c = await authenticator.authorize();
    closeWebView();

    var token = await c.getTokenResponse();
    print(token);
    return token;
  }

  @override
  void initState() {
    super.initState();
    startServer();
  }

  Future<void> startServer() async {
    final server = await HttpServer.bind('127.0.0.1', 43823);
    server.listen((req) async {
      setState(() {
        _status = 'Received request!';
      });
      req.response.headers.add('Content-Type', 'text/html');
      req.response.write(html);
      req.response.close();
    });
  }

  void _authenticate() async {
    final url = 'https://34.204.16.224:8458/auth/realms/smartcity/broker/gitlab/endpoint';
    final callbackUrlScheme = 'foobar';

    try {
      final result = await FlutterWebAuth.authenticate(
          url: url, callbackUrlScheme: callbackUrlScheme);
      setState(() {
        _status = 'Got result: $result';
      });
    } on PlatformException catch (e) {
      setState(() {
        _status = 'Got error: $e';
      });
    }
  }

  final AuthorizationServiceConfiguration _serviceConfiguration =
  AuthorizationServiceConfiguration(
      'http://34.204.16.224:8095/auth/realms/smartcity/protocol/openid-connect/auth',
      'http://34.204.16.224:8095/auth/realms/smartcity/protocol/openid-connect/token');
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Visibility(
              visible: _isBusy,
              child: const LinearProgressIndicator(),
            ),
            RaisedButton(
              child: const Text('Login using  app_auth'),
              onPressed: () async {
                try {
                  final AuthorizationResponse result = await _appAuth.authorize(
                    AuthorizationRequest(
                      _clientId,
                      _redirectUrl,
                      discoveryUrl: _discoveryUrl,
                      scopes: _scopes,
                      allowInsecureConnections: true,
                      serviceConfiguration: _serviceConfiguration
                    ),
                  );
                  if (result != null) {
                    print("Here the result: $result");
                    setState(() {
                      _appAuthStatus = result.authorizationCode.toString();
                    });
                  }
                } catch (e) {
                  setState(() {
                    _appAuthStatus = e.toString();
                  });
                  print("Result not found due to :$e");
                }
              },
            ),
            RaisedButton(
              child: Text("Login usein open client id"),
              onPressed: authenticate,
            ),
            RaisedButton(
              child: Text("Login using webauth"),
              onPressed: () {
                _authenticate();
              },
            ),
            Text("In app auth status : $_appAuthStatus"),
            Text("Webauth status : $_status")
          ],
        ),
      ),
    )));
  }
}

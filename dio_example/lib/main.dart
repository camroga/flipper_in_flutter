import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'http.dart'; // make dio as global top-level variable
import 'package:flutter_flipperkit/flutter_flipperkit.dart';
import 'routes/request.dart';

// Must be top-level function
_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

void main() {
  FlipperClient flipperClient = FlipperClient.getDefault();

  flipperClient.addPlugin(new FlipperNetworkPlugin());
  flipperClient.start();

  // add interceptors
  dio.interceptors..add(CookieManager(CookieJar()))..add(LogInterceptor());
  (dio.transformer as DefaultTransformer).jsonDecodeCallback = parseJson;
  dio.options.receiveTimeout = 15000;
//  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
//      (client) {
//    client.findProxy = (uri) {
//      //proxy to my PC(charles)
//      return "PROXY 10.1.10.250:8888";
//    };
//  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _text = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          RaisedButton(
            child: Text("Request"),
            onPressed: () {
//              dio.get("https://baidu.com").then((r) {
//                setState(() {
//                  _text = r.data.replaceAll(RegExp(r"\s"), "");
//                });
//              });

              dio.post("http://10.1.10.250:3000",data:{"a":1}).then((r) {
                setState(() {
                  _text = r.data.replaceAll(RegExp(r"\s"), "");
                });
              }).catchError(print);
            },
          ),
          RaisedButton(
            child: Text("RequestJson"),
            onPressed: () {
              dio.get("https://www.v2ex.com/api/topics/hot.json",).then((r) {
                print(r);
              }).catchError(print);
            },
          ),
          RaisedButton(
            child: Text("Open new page"),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return RequestRoute();
              }));
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Text(_text),
            ),
          )
        ]),
      ),
    );
  }
}

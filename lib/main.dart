import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:sendfile/utils.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: Homepage());
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final client = Client();
  late Account account;
  late Databases databases;
  late Functions functions;
  UrlModel? urlModel;
  bool? isLoading;

  String databaseID = "url_database";
  String collectionID = "url_collection";
  String documentID = "document1";
  String functionID = "6418523e6138d22728cd";

  @override
  void initState() {
    urlModel = null;
    isLoading = false;
    client
      ..setEndpoint("https://cloud.appwrite.io/v1")
      ..setProject("64185217b0571f7fafc6");

    account = Account(client);
    databases = Databases(client);
    functions = Functions(client);
    createAccount();
    super.initState();
  }

  // create anonymous account
  void createAccount() async {
    try {
      await account.get();
    } catch (_) {
      await account.createAnonymousSession();
    }
  }

  // initiate button onpressed function
  void initiateSender() async {
    setState(() {
      isLoading = true;
    });

    urlModel = await getcontent();

    // execute the function
    try {
      final funtionResult = await functions.createExecution(
          functionId: functionID, data: urlModel!.url);

      // condition to display snackbar
      switch (funtionResult.status) {
        case "failed":
          setState(() {
            isLoading = false;
          });
          failed();
          break;
        case "completed":
          setState(() {
            isLoading = false;
          });
          success();
          break;
        default:
      }
    } catch (e) {
      print("This function is throwing $e");
    }
  }

  // map the content to the model class
  Future<UrlModel?> getcontent() async {
    try {
      final databasesResult = await databases.getDocument(
          databaseId: databaseID,
          collectionId: collectionID,
          documentId: documentID);

      var data = jsonEncode(databasesResult.data);
      var jsondata = jsonDecode(data);
      return UrlModel.fromJson(jsondata);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
        ),
        body: Center(
          child: ElevatedButton(
              onPressed: initiateSender,
              child: isLoading == false
                  ? const Text("Submit")
                  : Padding(
                      padding: EdgeInsets.all(5.0),
                      child: circularloader(),
                    )),
        ),
      );

  void success() {
    final snackBar = SnackBar(
      content: const Text('SUCCESS'),
      backgroundColor: (Colors.green),
      action: SnackBarAction(
        label: 'dismiss',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  void failed() {
    final snackBar = SnackBar(
      content: const Text('FAILED'),
      backgroundColor: (Colors.red),
      action: SnackBarAction(
        label: 'dismiss',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  Widget circularloader() {
    return const CircularProgressIndicator.adaptive(
      backgroundColor: Colors.white,
    );
  }
}

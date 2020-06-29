import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

String get host => Platform.isAndroid ? '10.0.2.2' : 'localhost';

const String uploadImage = r"""
mutation($file: Upload!) {
  upload(file: $file)
}
""";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final httpLink = HttpLink(
      uri: 'http://$host:8080/query',
    );

    var client = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
        link: httpLink,
      ),
    );

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GraphQLProvider(
        client: client,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Graphql Upload Image Demo"),
          ),
          body: MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  bool _uploadInProgress = false;
  final picker = ImagePicker();

  Future selectImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          if (_image != null)
            Flexible(
              flex: 9,
              child: Image.file(_image),
            )
          else
            Flexible(
              flex: 9,
              child: Center(
                child: Text("No Image Selected"),
              ),
            ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                FlatButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.photo_library),
                      SizedBox(
                        width: 5,
                      ),
                      Text("Select File"),
                    ],
                  ),
                  onPressed: () => selectImage(),
                ),
                if (_image != null)
                  Mutation(
                    options: MutationOptions(
                        documentNode: gql(uploadImage),
                        onCompleted: (d) {
                          print(d);
                          setState(() {
                            _uploadInProgress = false;
                          });
                        },
                        update: (cache, results) {
                          var message = results.hasException
                              ? '${results.exception}'
                              : "Image was uploaded successfully!";
                          var snackBar = SnackBar(content: Text(message));
                          Scaffold.of(context).showSnackBar(snackBar);
                        }),
                    builder: (
                      RunMutation runMutation,
                      QueryResult result,
                    ) {
                      return FlatButton(
                        child: _isLoadingInProgress(),
                        onPressed: () {
                          setState(() {
                            _uploadInProgress = true;
                          });

                          var byteData = _image.readAsBytesSync();

                          var multipartFile = MultipartFile.fromBytes(
                            'photo',
                            byteData,
                            filename: '${DateTime.now().second}.jpg',
                            contentType: MediaType("image", "jpg"),
                          );

                          runMutation(<String, dynamic>{
                            "file": multipartFile,
                          });
                        },
                      );
                    },
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _isLoadingInProgress() {
    return _uploadInProgress
        ? CircularProgressIndicator()
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.file_upload),
              SizedBox(
                width: 5,
              ),
              Text("Upload File"),
            ],
          );
  }
}

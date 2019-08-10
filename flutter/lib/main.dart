import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

String get host => Platform.isAndroid ? '10.0.2.2' : 'localhost';

const uploadImage = r"""
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
    final HttpLink httpLink = HttpLink(
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

  uploadAsset(BuildContext context) async {
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

    var opts = MutationOptions(
      document: uploadImage,
      variables: {
        "file": multipartFile,
      },
    );

    var client = GraphQLProvider.of(context).value;
    var results = await client.mutate(opts);

    setState(() {
      _uploadInProgress = false;
    });

    var message = results.hasErrors
        ? '${results.errors.join(", ")}'
        : "Image was uploaded successfully!";

    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Future selectImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
              child: Text("No Image Selected"),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: FlatButton(
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
              ),
              if (_image != null)
                Mutation(
                  options: MutationOptions(
                    document: uploadImage,
                  ),
                  builder: (RunMutation runMutation, QueryResult result) {
                    return FlatButton(
                      child: _uploadInProgress
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
                            ),
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
                  onCompleted: (d) {
                    print(d);
                    setState(() {
                      _uploadInProgress = false;
                    });
                  },
                  update: (cache, results) {
                    var message = results.hasErrors
                        ? '${results.errors.join(", ")}'
                        : "Image was uploaded successfully!";

                    final snackBar = SnackBar(content: Text(message));
                    Scaffold.of(context).showSnackBar(snackBar);
                  },
                ),
              // if (_image != null)
              //   FlatButton(
              //     child: _uploadInProgress
              //         ? CircularProgressIndicator()
              //         : Row(
              //             mainAxisSize: MainAxisSize.min,
              //             children: <Widget>[
              //               Icon(Icons.file_upload),
              //               SizedBox(
              //                 width: 5,
              //               ),
              //               Text("Upload File"),
              //             ],
              //           ),
              //     onPressed: () => uploadAsset(context),
              //   ),
            ],
          )
        ],
      ),
    );
  }
}

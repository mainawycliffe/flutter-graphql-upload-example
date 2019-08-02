import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

import 'dart:io';

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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'GraphQL Upload Demo'),
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
  File _image;

  uploadAsset() async {
    final HttpLink httpLink = HttpLink(
      uri: 'http://$host:8080/query',
    );

    var client = GraphQLClient(
      cache: InMemoryCache(),
      link: httpLink,
    );

    // var byteData = await image[0].requestOriginal();
    var byteData = _image.readAsBytesSync();
    // List<int> imageData = byteData.buffer.asUint8List();

    var multipartFile = MultipartFile.fromBytes(
      'photo',
      byteData,
      filename: 'some-file-name.jpg',
      contentType: MediaType("image", "jpg"),
    );

    var opts = MutationOptions(
      document: uploadImage,
      variables: {
        "file": multipartFile,
      },
    );

    var results = await client.mutate(opts);

    print(results.data);
    print(results.errors);
  }

  uploadFile() async {
    final HttpLink httpLink = HttpLink(
      uri: 'http://$host:8080/query',
    );

    var client = GraphQLClient(
      cache: InMemoryCache(),
      link: httpLink,
    );

    MutationOptions opts = MutationOptions(
      document: uploadImage,
      variables: {
        "file": _image,
      },
    );

    var results = await client.mutate(opts);

    print(results.data);
    print(results.errors);
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
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
                    onPressed: () => getImage(),
                  ),
                ),
                FlatButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.file_upload),
                      SizedBox(
                        width: 5,
                      ),
                      Text("Upload File"),
                    ],
                  ),
                  onPressed: () => uploadAsset(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

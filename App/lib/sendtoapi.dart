import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:statues/CheckStatue.dart';
import 'package:statues/t.dart';

import 'mp3widget.dart';
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final List<Map<String, dynamic>> statue ;

  const DisplayPictureScreen({Key? key, required this.imagePath , required this.statue})
      : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {


  String responseText = '';
  // List<Map<String, dynamic>> statue = [];
  Map<String, dynamic> foundstatue ={};

  String _selectedLanguageId = '';
  void _onLanguageChanged(String languageId) {
    setState(() {
      _selectedLanguageId = languageId;
    });
  }

  @override
   initState()  {
    super.initState();
    sendImageToAPI();
  }

  Future<void> sendImageToAPI() async {
    try {
      final Uri apiUrl = Uri.parse(
          'https://AbdullahElbarrany.pythonanywhere.com/detect'); // Replace with the correct API URL

      // Create a http.MultipartRequest
      final request = http.MultipartRequest('POST', apiUrl);

      // Read the image file as bytes
      final imageFile = File(widget.imagePath);
      final bytes = await imageFile.readAsBytes();

      // Create a http.MultipartFile from the bytes
      final imageFilePart =
      http.MultipartFile.fromBytes('image', bytes, filename: 'image.jpg');

      // Add the image file part to the request
      request.files.add(imageFilePart);

      // Send the request and get the response
      final response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        // Request successful, handle the response here
        final responseString = response.body;
        setState(() {
          responseText = responseString
              .replaceAll(RegExp(r'\d+'), '')
              .replaceAllMapped(RegExp(r'(s)$'), (match) => '')
              .replaceAll(' ', '')
              .toLowerCase();
          print('respooooooooooonse $responseText');
          if (responseText=='themeshastele'){
            print('yessssssssssssssssssssssssssssssssssssssss');
          }

          for (final Map<String, dynamic> statueMap in widget.statue) {
            // if(responseText.contains('mesha'))
            //   {
            //
            //   if (statueMap['statueName']=='The Mesha Stele' ) {
            //     print('meshhhhhhhhhhhhhhhhhhhhha');
            //
            //     print('Found statue:'+ statueMap['statueId']);
            //       foundstatue= statueMap;
            //
            //       break; // Exit the loop if a match is found
            //     }
            //   }
            // else
            //   {
              final String statueName = statueMap['statueName'].toString().toLowerCase().replaceAll(' ', '');

              if (responseText.contains(statueName)|| responseText==statueName ) {
                print('Found statue: $statueName');
                foundstatue= statueMap;

                break; // Exit the loop if a match is found
              }}

          // }
        });
      }

      else {
        // Request failed, handle the error here
        print(
            'Error sending image to API. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending image to API: $e');
    }
  }

  // Future<void> playAudio(BytesSource audioUrl) async {
  //   await audioPlayer.stop();
  //   await audioPlayer.play(audioUrl);
  // }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statue')),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,

        child: Column(
          children: [

            Container(
              height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - 20,
              alignment: Alignment.center,
              child: foundstatue.isNotEmpty
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    foundstatue['statueName'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  // const Divider(
                  //   color: Colors.blueGrey,
                  //   thickness: 0.5,
                  // ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 2,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(height: 20),
                  if (foundstatue.isNotEmpty)
                    Image.network(
                      foundstatue['imagePath'],
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SpinKitPouringHourGlassRefined(
                          color: Colors.orange,
                          size: 50.0,
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png',
                          width: 150,
                          height: 150,
                        );
                      },
                    ),
                  const SizedBox(height: 20),

                  if (foundstatue.isNotEmpty && foundstatue['voicePaths']!= null)
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.vertical,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final voicePathData in foundstatue['voicePaths'])
                          if (voicePathData['languageId'] == _selectedLanguageId)
                            PlayMp3Widget(audioUrl: voicePathData['voicePath']),
                      ],
                    ),
                  LanguageButton(
                    initialLanguageId: _selectedLanguageId, // Pass the initial language ID
                    onLanguageChanged: _onLanguageChanged,
                  ),
                    // ),
                  // PlayMp3Widget(audioUrl: 'https://firebasestorage.googleapis.com/v0/b/statues-data.appspot.com/o/Voice%2FA%20-%20Ar.mp3?alt=media&token=f91f267e-63eb-48a6-b746-1832164709a1'),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      onPressed: () async {
                        final cameras = await availableCameras();
                        final firstCamera = cameras.first;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TakePictureScreen(
                              camera: firstCamera,
                            ),
                          ),
                        );
                      },
                      child: Icon(Icons.camera_alt),
                    ),
                  ),
                ],

              )
                  : FutureBuilder<void>(
                future: Future.delayed(const Duration(seconds: 30)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SpinKitPouringHourGlassRefined(
                      color: Colors.orange,
                      size: 50.0,
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Statue not found',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),

                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FloatingActionButton(
                            onPressed: () async {
                              final cameras = await availableCameras();
                              final firstCamera = cameras.first;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TakePictureScreen(
                                    camera: firstCamera,
                                  ),
                                ),
                              );
                            },
                            child: Icon(Icons.camera_alt),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class Language {
  final String id;
  final String name;

  Language(this.id, this.name);
}
class LanguageButton extends StatefulWidget {
  final String? initialLanguageId;
  final Function(String) onLanguageChanged;

  LanguageButton({this.initialLanguageId, required this.onLanguageChanged});

  @override
  _LanguageButtonState createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<LanguageButton> {
  List<Language> _languages = [];
  String? _selectedLanguageId;

  Future<List<Language>> _fetchLanguages() async {
    final CollectionReference languagesRef =
    FirebaseFirestore.instance.collection('Languages');

    try {
      final QuerySnapshot snapshot = await languagesRef.get();
      List<Map<String, String>> languageDataList = [];

      for (final DocumentSnapshot languageDocument in snapshot.docs) {
        final String languageId = languageDocument.id;
        final String languageName = languageDocument.get('Name');

        Map<String, String> languageData = {
          'id': languageId,
          'name': languageName,
        };

        languageDataList.add(languageData);
      }

      List<Language> languages = languageDataList.map((data) {
        return Language(data['id']!, data['name']!);
      }).toList();

      return languages;
    } catch (e) {
      print('Error fetching languages: $e');
      throw Exception('Failed to load languages');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLanguages().then((languages) {
      setState(() {
        _languages = languages;
        _selectedLanguageId = widget.initialLanguageId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];
    List<Widget> rowChildren = [];

    for (Language language in _languages) {
      rowChildren.add(
        ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedLanguageId = language.id;
              widget.onLanguageChanged(language.id);
            });
          },
          style: ElevatedButton.styleFrom(
            primary: _selectedLanguageId == language.id
                ? Colors.blue // Use a different color for the selected language
                : Colors.brown,
          ),
          child: Text(language.name),
        ),
      );

      if (rowChildren.length == 3) {
        rows.add(Row(
          children: rowChildren,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Add horizontal spacing
        ));
        rowChildren = [];
      }
    }

    if (rowChildren.isNotEmpty) {
      rows.add(Row(
        children: rowChildren,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Add horizontal spacing
      ));
    }

    return Column(
      children: rows
          .map((row) => Column(
        children: [
          SizedBox(height: 10), // Add vertical spacing between rows
          row,
        ],
      ))
          .toList(),
    );
  }
}


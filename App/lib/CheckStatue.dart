import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:statues/sendtoapi.dart';
import 'package:http/http.dart' as http;

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  List<Map<String, dynamic>> statue = [];

  late Future<void> _initializeControllerFuture;
  Future<void> searchStatues() async {
    final CollectionReference statuesRef =
    FirebaseFirestore.instance.collection('Statues');
    final CollectionReference imageRef =
    FirebaseFirestore.instance.collection('Images');
    final CollectionReference voiceRef =
    FirebaseFirestore.instance.collection('Voice');

    final QuerySnapshot snapshot = await statuesRef.get();

    for (final DocumentSnapshot statueDocument in snapshot.docs) {
      final String statueId = statueDocument.id;
      final String statueName = statueDocument.get('Name');

      final QuerySnapshot imageSnapshot =
      await imageRef.where('statue_id', isEqualTo: statueId).limit(1).get();

      final String imagePath;
      if (imageSnapshot.size > 0) {
        final DocumentSnapshot imageDoc = imageSnapshot.docs[0];
        imagePath = imageDoc.get('image_path');
      } else {
        imagePath =
        'https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png';
      }

      final QuerySnapshot voiceSnapshot =
      await voiceRef.where('statue_id', isEqualTo: statueId).get();

      final List<Map<String, String>> voicePaths = [];
      for (final DocumentSnapshot voiceDoc in voiceSnapshot.docs) {
        final String voicePath = voiceDoc.get('voice_path');
        final String languageId = voiceDoc.get('language_id');

        final Map<String, String> voiceData = {
          'voicePath': voicePath,
          'languageId': languageId,
          'statueId':statueId,
        };
        print('found  BIT $statueId   :::::::: $voicePath');
        voicePaths.add(voiceData);
      }

      final Map<String, dynamic> statueMap = {
        'statueId': statueId,
        'statueName': statueName,
        'imagePath': imagePath,
        'voicePaths': voicePaths,
      };

      setState(() {
        statue.add(statueMap);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,

    );
    _controller.setFlashMode(FlashMode.off);


    searchStatues();

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();

            if (!mounted) return;
            print('in');

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path, statue: statue,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}



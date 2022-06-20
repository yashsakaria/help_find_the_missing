import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:help_find_the_missing/loading_widget.dart';
import 'package:help_find_the_missing/my_elevated_button.dart';
import 'package:help_find_the_missing/screens/search_results_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_face_api/face_api.dart' as Regula;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:haversine_distance/haversine_distance.dart';

double? latitude, longitude;
Location? endCoordinate;
final _firestore = FirebaseFirestore.instance;

Future<void> getLocation() async {
  LocationPermission permission = await Geolocator.requestPermission();
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  latitude = position.latitude;
  longitude = position.longitude;
  endCoordinate = Location(latitude!, longitude!);
}

Map<QueryDocumentSnapshot, List> documentAccuracyMap = {};

class SearchPerson extends StatefulWidget {
  const SearchPerson({Key? key}) : super(key: key);

  @override
  State<SearchPerson> createState() => _SearchPersonState();
}

class _SearchPersonState extends State<SearchPerson> {
  var image1 = Regula.MatchFacesImage();
  var image2 = Regula.MatchFacesImage();
  var img1 = Image.asset('images/no_image.jpg');
  bool isLoading = false;

  void initState() {
    getLocation();
    print(latitude.toString() + ' ' + longitude.toString());
  }

  Map<QueryDocumentSnapshot, List> sortMap(
      Map<QueryDocumentSnapshot, List> mp) {
    var sortedKeys = mp.keys.toList(growable: false)
      ..sort((k1, k2) {
        return mp[k2]!.elementAt(0)!.compareTo(mp[k1]!.elementAt(0));
      });

    var newMap = {for (var k in sortedKeys) k: mp[k]!};
    for (List f in newMap.values) {
      print(f[0].toString() + ' ' + f[1].toString());
    }
    return newMap;
  }

  setImage(Uint8List imageFile, int type) {
    if (imageFile == null) return;
    image1.bitmap = base64Encode(imageFile);
    image1.imageType = type;
    setState(() {
      img1 = Image.memory(imageFile);
    });
  }

  matchFaces() async {
    documentAccuracyMap.clear();
    final haversineDistance = HaversineDistance();
    var result = [];

    print('before snapshot');
    var snapshot = await _firestore.collection('missing_person').get();
    print('after');
    final cache = DefaultCacheManager();
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      var file = await cache.getSingleFile(doc.get('image'));
      print(file.path.toString());
      Uint8List img2 = File(file.path).readAsBytesSync();
      image2.bitmap = base64Encode(img2);
      image2.imageType = Regula.ImageType.PRINTED;

      var request = Regula.MatchFacesRequest();
      request.images = [image1, image2];
      await Regula.FaceSDK.matchFaces(jsonEncode(request)).then((value) async {
        var response = Regula.MatchFacesResponse.fromJson(json.decode(value));
        await Regula.FaceSDK.matchFacesSimilarityThresholdSplit(
                jsonEncode(response!.results), 0.75)
            .then((str) {
          var split = Regula.MatchFacesSimilarityThresholdSplit.fromJson(
              json.decode(str));
          var acc;
          try {
            print(split!.matchedFaces.length);
            acc = (split.matchedFaces.elementAt(0)!.similarity! * 100)
                .toStringAsFixed(2);
            result.add(doc.get('name'));
            result.add(acc);
            final startCoordinate = Location(doc.get('lat'), doc.get('long'));
            final distance = haversineDistance
                .haversine(startCoordinate, endCoordinate!, Unit.KM)
                .floor();
            documentAccuracyMap[doc] = [acc, distance];
          } catch (e) {
            acc = 0;
            print('error');
          }
          print(acc);
        });
      });
    }
    documentAccuracyMap = sortMap(documentAccuracyMap);
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text('Search'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              child: ClipRRect(
                child: Image(
                  image: img1.image,
                  height: 250,
                  width: 250,
                ),
                borderRadius: kDefaultBorderRadius,
              ),
              onTap: () {
                showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  context: context,
                  builder: (context) {
                    return SizedBox(
                      height: 142,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 70,
                            child: TextButton(
                              child: const Text(
                                'From Camera',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () {
                                ImagePicker()
                                    .pickImage(source: ImageSource.camera)
                                    .then((value) => setImage(
                                        File(value!.path).readAsBytesSync(),
                                        Regula.ImageType.PRINTED));
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const Divider(
                            height: 0,
                            thickness: 2,
                            color: themeColor,
                          ),
                          SizedBox(
                            height: 70,
                            child: TextButton(
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(
              height: 12,
            ),
            MyElevatedButton(
              onPress: () async {
                if (isLoading) return;

                setState(() {
                  isLoading = true;
                });

                print('before call');
                await matchFaces();

                setState(() {
                  isLoading = false;
                });

                print('after match faces');

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResults(
                      documentAccuracyMap: documentAccuracyMap,
                    ),
                  ),
                );

                print('after push');

                Navigator.of(context).pop();
              },
              buttonLabel: (!isLoading)
                  ? const Text(
                      'Match Faces',
                      style: kButtonTextStyle,
                    )
                  : const LoadingWidget(newText: 'Matching...'),
              w: w,
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:help_find_the_missing/constants/constants.dart';
import 'package:help_find_the_missing/my_widgets/loading_widget.dart';
import 'package:help_find_the_missing/my_widgets/my_alert_dialog.dart';
import 'package:help_find_the_missing/my_widgets/my_elevated_button.dart';
import 'package:help_find_the_missing/screens/search_results_screen.dart';

import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_face_api/face_api.dart' as Regula;
import 'package:haversine_distance/haversine_distance.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class SearchPerson extends StatefulWidget {
  const SearchPerson({Key? key}) : super(key: key);

  @override
  State<SearchPerson> createState() => _SearchPersonState();
}

class _SearchPersonState extends State<SearchPerson> {
  var image1 = Regula.MatchFacesImage();
  var image2 = Regula.MatchFacesImage();
  var img1 = Image.asset('images/no_image.jpg');

  String selectedState = 'All of India';
  bool isLoading = false;
  bool isImageSelected = false;

  double? latitude, longitude;
  Location? endCoordinate;

  Map<QueryDocumentSnapshot, List> documentAccuracyMap = {};

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
    // if (imageFile == null) return;
    image1.bitmap = base64Encode(imageFile);
    image1.imageType = type;
    setState(() {
      img1 = Image.memory(imageFile);
      isImageSelected = true;
    });
  }

  matchFaces() async {
    documentAccuracyMap.clear();
    final haversineDistance = HaversineDistance();
    final cache = DefaultCacheManager();
    var result = [];
    QuerySnapshot<Map<String, dynamic>> snapshot;

    if (selectedState != states[0]) {
      snapshot = await _firestore
          .collection('missing_person')
          .where("state", isEqualTo: selectedState)
          .get();
    } else {
      snapshot = await _firestore.collection('missing_person').get();
    }

    if (isImageSelected) {
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        var file = await cache.getSingleFile(doc.get('image'));
        print(file.path.toString());
        Uint8List img2 = File(file.path).readAsBytesSync();
        image2.bitmap = base64Encode(img2);
        image2.imageType = Regula.ImageType.PRINTED;

        var request = Regula.MatchFacesRequest();
        request.images = [image1, image2];
        await Regula.FaceSDK.matchFaces(jsonEncode(request))
            .then((value) async {
          var response = Regula.MatchFacesResponse.fromJson(json.decode(value));
          await Regula.FaceSDK.matchFacesSimilarityThresholdSplit(
                  jsonEncode(response!.results), 0.75)
              .then((str) {
            var split = Regula.MatchFacesSimilarityThresholdSplit.fromJson(
                json.decode(str));
            Object acc;
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
    } else {
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        documentAccuracyMap[doc] = [];
      }
    }
  }

  Future<void> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    latitude = position.latitude;
    longitude = position.longitude;
    endCoordinate = Location(latitude!, longitude!);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text('Search Reports'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  elevation: 2,
                  borderRadius: kDefaultBorderRadius,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      value: selectedState,
                      underline: Container(
                        color: Colors.white,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedState = newValue!;
                        });
                      },
                      buttonWidth: w * 3 / 4,
                      dropdownMaxHeight: 300,
                      dropdownDecoration: const BoxDecoration(
                        borderRadius: kDefaultBorderRadius,
                      ),
                      items: states.map<DropdownMenuItem<String>>((itemValue) {
                        return DropdownMenuItem(
                          value: itemValue,
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                itemValue,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            MyElevatedButton(
              onPress: () async {
                try {
                  if (isLoading) return;

                  setState(() {
                    isLoading = true;
                  });

                  LocationPermission permission =
                      await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                    if (permission == LocationPermission.denied) {
                      throw 'Cannot proceed without GeoLocation';
                    }
                  }
                  if (permission == LocationPermission.deniedForever) {
                    throw 'Enable Location Services from settings.';
                  }

                  await getLocation();
                  await matchFaces();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchResults(
                        documentAccuracyMap: documentAccuracyMap,
                      ),
                    ),
                  );

                  Navigator.of(context).pop();
                } catch (e) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return MyAlertDialog(
                            title: 'Location', content: e.toString());
                      });
                } finally {
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              buttonLabel: (!isLoading)
                  ? const Text(
                      'Search',
                      style: kButtonTextStyle,
                    )
                  : const LoadingWidget(newText: 'Searching...'),
              w: w,
            ),
          ],
        ),
      ),
    );
  }
}

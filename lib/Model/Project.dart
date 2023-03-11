import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  String name;
  String type;
  String location;
  String? coverPhoto;
  DocumentReference reference;

  Project({
    required this.name,
    required this.type,
    required this.location,
    this.coverPhoto,
    required this.reference,
  });

  List<String> get search {
    List<String> returns = [];
    returns.addAll(makeSearchstring(name));
    returns.addAll(makeSearchstring(location));
    returns.addAll(makeSearchstring(type));
    return returns;
  }

  List<String> makeSearchstring(String string) {
    List<String> wordList = string.split(' ');
    Set<String> list = {};
    for (var element in wordList) {
      for (int i = 1; i < element.length; i++) {
        list.add(element.substring(0, i).trim().toLowerCase());
      }
      list.add(element.trim().toLowerCase());
    }
    list.add(string.toLowerCase());
    return list.toList();
  }

  toJson() {
    return {
      "name": name,
      "type": type,
      "location": location,
      "coverPhoto": coverPhoto,
      "search": search,
      "reference": reference,
    };
  }

  factory Project.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> json = snapshot.data()!;
    json['reference'] = snapshot.reference;
    return Project.fromJson(json);
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json["name"],
      type: json["type"],
      location: json["location"],
      coverPhoto: json["coverPhoto"],
      reference: json["reference"],
    );
  }

  copyWith({String? name, String? type, String? location, String? coverPhoto}) {
    this.name = name ?? this.name;
    this.type = type ?? this.type;
    this.location = location ?? this.location;
    this.coverPhoto = coverPhoto ?? this.coverPhoto;
  }

  Future<void> delete() {
    var batch = FirebaseFirestore.instance.batch();
    reference.collection("properties").get().then((value) {
      for (var propertyDoc in value.docs) {
        propertyDoc.reference.collection("leads").get().then((leadDocs) {
          for (var leadDoc in leadDocs.docs) {
            batch.delete(leadDoc.reference);
          }
        });
        batch.delete(propertyDoc.reference);
      }
      batch.delete(reference);
    });
    return batch.commit();
  }
}

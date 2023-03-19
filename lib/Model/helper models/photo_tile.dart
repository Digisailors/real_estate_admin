import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PhotoTile {
  final String? url;
  final Uint8List? rawData;
  final void Function() remove;

  PhotoTile(this.url, this.rawData, this.remove);

  ImageProvider get provider {
    ImageProvider provider;
    if (rawData != null) {
      provider = MemoryImage(rawData!);
    } else {
      provider = NetworkImage(url!);
    }
    return provider;
  }
}

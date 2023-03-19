import 'dart:typed_data';

class Attachment {
  final String name;
  String url;
  final AttachmentLocation attachmentLocation;
  Uint8List? rawData;
  Attachment({required this.name, required this.url, required this.attachmentLocation, this.rawData});

  toJson() => {
        'name': name,
        'url': url,
      };
  factory Attachment.fromJson(json) => Attachment(
        name: json['name'],
        url: json['url'],
        attachmentLocation: AttachmentLocation.cloud,
      );
}

enum AttachmentLocation { local, cloud }

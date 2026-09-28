import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from Gallery or Camera
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    return await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  }

  /// Uploads image bytes to Firebase Storage and returns the public download URL
  Future<String> uploadProductImage(XFile file) async {
    Uint8List data = await file.readAsBytes();
    String extension = file.name.split('.').last;
    if (extension.isEmpty) extension = 'jpg';
    String fileName = 'products/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

    SettableMetadata metadata = SettableMetadata(
      contentType: 'image/$extension',
    );

    Reference ref = _storage.ref().child(fileName);
    UploadTask uploadTask = ref.putData(data, metadata);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}

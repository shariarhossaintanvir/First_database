import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Maximum allowed file size: 5MB (matches Storage Security Rules)
  static const int maxFileSizeBytes = 5 * 1024 * 1024;
  static const List<String> allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
  ];

  /// Picks an image from Gallery or Camera
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    return await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  }

  /// Uploads image bytes to Firebase Storage with strict client-side validation
  Future<String> uploadProductImage(XFile file) async {
    // 1. File size validation
    final length = await file.length();
    if (length <= 0) {
      throw Exception('Selected image is empty.');
    }
    if (length > maxFileSizeBytes) {
      throw Exception(
        'Image exceeds 5MB size limit. Please select a smaller image.',
      );
    }

    // 2. File type / extension validation
    String rawExt = file.name.contains('.')
        ? file.name.split('.').last.toLowerCase()
        : 'jpg';
    if (!allowedExtensions.contains(rawExt)) {
      throw Exception(
        'Invalid file extension: .$rawExt. Only JPG, PNG, WEBP, and GIF images are allowed.',
      );
    }

    // 3. MIME type mapping
    String mimeSubtype = rawExt == 'jpg' ? 'jpeg' : rawExt;
    String contentType = 'image/$mimeSubtype';

    // 4. Sanitize file name to prevent directory traversal or special characters
    Uint8List data = await file.readAsBytes();
    String safeBaseName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    String fileName =
        'products/${DateTime.now().millisecondsSinceEpoch}_$safeBaseName';

    SettableMetadata metadata = SettableMetadata(contentType: contentType);

    Reference ref = _storage.ref().child(fileName);
    UploadTask uploadTask = ref.putData(data, metadata);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}

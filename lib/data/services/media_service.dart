import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/media_attachment.dart';
import '../models/social_platform.dart';

/// Wraps image picking and per-platform cropping so ViewModels stay free of
/// plugin details.
class MediaService {
  MediaService({ImagePicker? picker, ImageCropper? cropper})
      : _picker = picker ?? ImagePicker(),
        _cropper = cropper ?? ImageCropper();

  final ImagePicker _picker;
  final ImageCropper _cropper;
  final Uuid _uuid = const Uuid();

  /// Picks up to [limit] images from the gallery.
  Future<List<MediaAttachment>> pickImages({int limit = 10}) async {
    final List<XFile> files = await _picker.pickMultiImage(limit: limit);
    return files
        .map((XFile f) => MediaAttachment(id: _uuid.v4(), originalPath: f.path))
        .toList();
  }

  /// Takes a single photo with the camera.
  Future<MediaAttachment?> capturePhoto() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) return null;
    return MediaAttachment(id: _uuid.v4(), originalPath: file.path);
  }

  /// Crops [media] to [platform]'s [option] ratio and records the result.
  Future<MediaAttachment> cropFor(
    MediaAttachment media,
    SocialPlatform platform,
    AspectRatioOption option,
  ) async {
    final CroppedFile? cropped = await _cropper.cropImage(
      sourcePath: media.originalPath,
      aspectRatio: CropAspectRatio(ratioX: option.ratio, ratioY: 1),
      uiSettings: <PlatformUiSettings>[
        AndroidUiSettings(
          toolbarTitle: 'Crop for ${platform.label}',
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Crop for ${platform.label}',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    if (cropped == null) return media;
    return media.withCrop(platform.id, cropped.path);
  }
}

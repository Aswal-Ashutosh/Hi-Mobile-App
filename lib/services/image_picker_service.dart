import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static ImagePicker _imagePicker = ImagePicker();

  static Future<File?> pickImageFromGallery() async{
    XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }

  static Future<List<File>> pickMultiImagesFromGallery() async{
    List<XFile>? xImages = await _imagePicker.pickMultiImage();
    List<File> images = [];
    if(xImages != null && xImages.isNotEmpty){
      xImages.forEach((element) {
        images.add(File(element.path));
      });
    }
    return images;
  }
}
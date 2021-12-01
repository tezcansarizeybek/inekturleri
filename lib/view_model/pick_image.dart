import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

///Bu kısımda anlık görüntüden değil, fotoğraf üzerinden sınıflandırmalar yapılır.
class PickImage extends GetxController {
  var picker = ImagePicker();
  var image;
  var loading = false.obs;
  openCamera() async {
    var img = await picker.getImage(source: ImageSource.camera);
    image = img;
  }

  openGallery() async {
    var picture = await picker.getImage(source: ImageSource.gallery);
    image = picture;
  }

  pickImage() async {
    var img = await picker.getImage(source: ImageSource.gallery);
    if (img == null) return null;
    loading.value = true;
    image = img;
  }
}

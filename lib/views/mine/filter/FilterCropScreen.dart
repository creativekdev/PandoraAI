// import 'dart:io';
//
// import 'package:cartoonizer/common/importFile.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
//
// class ImageCropperPage extends StatefulWidget {
//   const ImageCropperPage({super.key});
//
//
//   @override
//   State<ImageCropperPage> createState() => _ImageCropperPageState();
// }
//
// class _ImageCropperPageState extends State<ImageCropperPage> {
//
//   final ImagePicker _picker = ImagePicker();
//   File? image;
//
//   Future <void> imageCropper() async {
//     XFile? images = await _picker.pickImage(source: ImageSource.gallery);
//     if (images != null) {
//       var cropper = (await ImageCropper().cropImage(sourcePath: images.path,
//           aspectRatioPresets: [
//             CropAspectRatioPreset.square,
//             CropAspectRatioPreset.ratio3x2,
//             CropAspectRatioPreset.original,
//             CropAspectRatioPreset.ratio4x3,
//             CropAspectRatioPreset.ratio16x9,
//             CropAspectRatioPreset.ratio7x5
//           ],
//           uiSettings: [
//             AndroidUiSettings(
//                 toolbarTitle: 'Cropper',
//                 toolbarColor: Theme
//                     .of(context)
//                     .colorScheme
//                     .primary,
//                 toolbarWidgetColor: Theme
//                     .of(context)
//                     .colorScheme
//                     .onPrimary,
//                 initAspectRatio: CropAspectRatioPreset.original,
//                 lockAspectRatio: false,
//                 cropFrameColor: Theme
//                     .of(context)
//                     .colorScheme
//                     .primary,
//                 cropGridColor: Colors.red,
//                 showCropGrid: false
//             ),
//           ]
//       ));
//
//       if (cropper != null) {
//         setState(() {
//           image = File(cropper.path ?? "");
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Image Cropper"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text("Add Image Here",
//               style: TextStyle(color: Colors.redAccent, fontSize: 22),),
//             Padding(
//               padding: EdgeInsets.only(top: 30),
//               child: Container(
//                 width: MediaQuery
//                     .of(context)
//                     .size
//                     .width / 1.5,
//                 height: MediaQuery
//                     .of(context)
//                     .size
//                     .width / 1.5,
//                 decoration: const BoxDecoration(
//                   borderRadius: BorderRadius.all(Radius.circular(10)),
//                 ),
//                 child: Card(
//                   shape: const RoundedRectangleBorder(
//                       side: BorderSide(
//                         width: 2,
//                         color: Colors.grey,
//                       ),
//                       borderRadius: BorderRadius.all(Radius.circular(10))
//                   ),
//                   child: InkWell(
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: image != null ? Image.file(
//                         width: MediaQuery
//                             .of(context)
//                             .size
//                             .width / 4,
//                         height: MediaQuery
//                             .of(context)
//                             .size
//                             .width / 4,
//                         image!,
//                         fit: BoxFit.fill,
//                       ) : Center(
//                         child: Text(
//                           "Click here to select Image", style: TextStyle(
//                             color: Colors.redAccent),),
//                       ),
//
//                     ),
//                     onTap: () {
//                       imageCropper();
//                     },
//                   ),
//                 ),
//               ),
//             )
//
//           ],
//         ),
//       ),
//     );
//   }
// }
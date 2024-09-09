import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:image_picker/image_picker.dart';
import 'package:vayu_agent/core/text.dart';
import 'package:vayu_agent/widgets/hspace.dart';
import 'package:vayu_agent/widgets/vspace.dart';

class ImagePickerUtil {
  XFile? _selectedImagePath = XFile("");
  File _pickedImage =File("") ;
  final ImagePicker _pickedFile = ImagePicker();

  void showImagePicker(BuildContext context, Function() updateState) {
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            height: 160,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Vspace(12),
                  SvgPicture.asset("assets/icons/rect.svg"),
                  const Vspace(32),
                  InkWell(
                    onTap: () {
                      getImage(ImageSource.camera, context, updateState);
                      Navigator.pop(context);
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: ColoredBox(
                      color: Colors.transparent,
                      child: SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/camera.svg",
                              color: Colors.black,
                            ),
                            const Hspace(18),
                            const TextWidget(
                              text: "Take a Photo",
                              fontSize: 16,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Vspace(16),
                  const Divider(
                    color: Color(0xff353637),
                    height: 0,
                    thickness: 1,
                  ),
                  const Vspace(16),
                  InkWell(
                    onTap: () {
                      getImage(ImageSource.gallery, context, updateState);
                      Navigator.pop(context);
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: ColoredBox(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/gallery.svg",

                              color: Colors.black,
                            ),
                            const Hspace(18),
                            const TextWidget(
                              text: "Open Gallery",
                              fontSize: 16,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void getImage(ImageSource imageSource, BuildContext context,
      Function() updateState) async {
    _selectedImagePath = (await _pickedFile.pickImage(source: imageSource));
    _pickedImage = File(_selectedImagePath?.path ?? "");
    updateState();
  }

  void uploadImage(BuildContext context, Function(FormData) uploadApi,
      String keyName) async {
    String fileName = _pickedImage.path.split('/').last;
    FormData formData = FormData.fromMap({
      keyName:
          await MultipartFile.fromFile(_pickedImage.path, filename: fileName),
    });

    if (_pickedImage.path.isNotEmpty) {
      uploadApi(formData);
    }
  }

  File pickedImage() {
    return _pickedImage;
  }


}

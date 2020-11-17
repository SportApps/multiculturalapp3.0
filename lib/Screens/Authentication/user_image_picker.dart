import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class UserImagePicker extends StatefulWidget {
  UserImagePicker(this.imagePickFn,this.initalLoad,this.initialPhoto);

  final void Function(File pickedImage) imagePickFn;
  final bool initalLoad;
  final String initialPhoto;


  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage;
  bool choosePickedphoto;

  @override
  void initState() {
    // TODO: implement initState

    choosePickedphoto = widget.initalLoad;


    super.initState();
  }

  void _pickImage() async {
    final pickedImageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    setState(() {
      _pickedImage = pickedImageFile;

    });
    widget.imagePickFn(pickedImageFile);
    Navigator.of(context).pop();
  }

  void _pickImageStorage() async {
    final pickedImageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );
    setState(() {
      _pickedImage = pickedImageFile;
      choosePickedphoto =true;
    });
    widget.imagePickFn(pickedImageFile);
    Navigator.of(context).pop();
  }

  // user defined function
  void chooseFotoDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Show us your best smile"),
          content: Container(
            height: 160,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Choose a foto where you are easily recognizable."),
                SizedBox(height: 20,),
                FlatButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(
                    Icons.camera,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  label: Text(
                    'Camara',
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                ),
                FlatButton.icon(
                  onPressed: _pickImageStorage,
                  icon: Icon(
                    Icons.image,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  label: Text(
                    'Gallery',
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 85,
          backgroundColor: HexColor("ffe664"),
          child: InkWell(
            onTap: () {
              chooseFotoDialog();
            },
            child:
            choosePickedphoto?
            CircleAvatar(
              child: _pickedImage != null
                  ? SizedBox(
                      height: 0,
                    )
                  : Center(
                      child: Icon(
                        MdiIcons.camera,
                        size: 40,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
              radius: 80,
              backgroundColor: Colors.white,
              backgroundImage:
                  _pickedImage != null ? FileImage(_pickedImage) : null,

            ):


            CircleAvatar(
              child: _pickedImage != null
                  ? SizedBox(
                height: 0,
              )
                  : Center(
                child: Icon(
                  MdiIcons.camera,
                  size: 40,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
              radius: 80,
              backgroundColor: Colors.white,
              backgroundImage:
              NetworkImage(widget.initialPhoto)

            ),




          ),
        ),
      ],
    );
  }
}

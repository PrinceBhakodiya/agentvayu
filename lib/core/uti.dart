import 'package:flutter/material.dart';
import 'package:vayu_agent/core/appcolors.dart';
import 'package:vayu_agent/widgets/vspace.dart';

class UtilDialog {
  static showInformation(
    BuildContext context, {
    String? title,
    String? content,
    Function()? onClose,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            title ?? "Alert !!",
          ),
          content: Text(content!),
          actions: <Widget>[
            TextButton(
              onPressed: onClose ?? () => Navigator.of(context).pop(),
              child: const Text(
                "Okay",
              ),
            )
          ],
        );
      },
    );
  }

  static showWaiting(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            height: 100,
            alignment: Alignment.center,
            child:  const Center(
              child: Column(
                mainAxisAlignment:MainAxisAlignment.center ,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryGreen,),
                  Vspace(20),
                  Text('Loading ...',style: TextStyle(fontSize: 14,color: AppColors.primaryGreen,fontWeight: FontWeight.bold),)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static hideWaiting(BuildContext context) {
    Navigator.pop(context);
  }

  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required void Function() onYesPressed,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            title,style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            Column(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    elevation: 5,
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    "No",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    elevation: 5,
                  ),
                  onPressed: onYesPressed,
                  child: const Text(
                    "Yes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            )

          ],
        );
      },
    );
  }
}

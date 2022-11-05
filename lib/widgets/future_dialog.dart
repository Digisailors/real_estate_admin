import 'package:flutter/material.dart';
import '../Model/Result.dart';

showFutureDialog(
  BuildContext context, {
  required Future<Result> future,
  void Function(dynamic value)? onSucess,
}) {
  return showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<Result>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return AlertDialog(
                    title: Text(snapshot.data!.tilte),
                    content: Text(snapshot.data!.message),
                    actions: [
                      TextButton(
                          onPressed: () {
                            if (onSucess != null && snapshot.data?.tilte == Result.success) {
                              onSucess(snapshot.data!.data);
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text("OKAY"))
                    ],
                  );
                } else {
                  return AlertDialog(
                    title: const Text("SNAPSHOT RETURNED NULL"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("OKAY"))
                    ],
                  );
                }
              }
              if (snapshot.hasError) {
                return AlertDialog(
                  title: const Text("Error Occured"),
                  content: Text(snapshot.error.toString()),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            });
      });
}

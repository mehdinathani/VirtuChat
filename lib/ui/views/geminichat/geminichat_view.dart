import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:virtuchat/ui/views/geminichat/geminichat_viewmodel.dart';

class GeminichatView extends StatelessWidget {
  const GeminichatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GeminichatViewModel>.reactive(
      viewModelBuilder: () => GeminichatViewModel(),
      onViewModelReady: (viewModel) =>
          viewModel.initialize(viewModel.currentPrompt),
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Schedule scrollToTheEnd after the widget has been fully built
          viewModel.scrollToTheEnd();
        });
        return Scaffold(
          appBar: AppBar(
            title: Text(
              viewModel.currentPrompt,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Container(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            child: Column(
              children: [
                // Display chat messages
                Expanded(
                  child: ListView.builder(
                    controller: viewModel.controller,
                    itemCount: viewModel.chatMessages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onDoubleTap: () {},
                        onLongPress: () {
                          Clipboard.setData(
                            ClipboardData(
                                text: viewModel.chatMessages[index]['message']),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Message copied to clipboard')),
                          );
                        },
                        child: Container(
                          alignment:
                              viewModel.chatMessages[index]["role"] == "User"
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                viewModel.chatMessages[index]["role"] == "User"
                                    ? Colors.blue
                                    : Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        viewModel.currentUserDPUrl.isNotEmpty
                                            ? NetworkImage(
                                                viewModel.currentUserDPUrl)
                                            : null,
                                    backgroundColor:
                                        viewModel.currentUserDPUrl.isNotEmpty
                                            ? Colors.transparent
                                            : Colors.black,
                                    radius: 20,
                                    child: viewModel.currentUserDPUrl.isEmpty
                                        ? Text(
                                            viewModel.chatMessages[index]
                                                        ["role"] ==
                                                    "User"
                                                ? viewModel.currentUserName
                                                        .isNotEmpty
                                                    ? viewModel
                                                        .currentUserName[0]
                                                    : 'U'
                                                : "V",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(
                                      width:
                                          8), // Add spacing between CircleAvatar and role/timestamp
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        viewModel.chatMessages[index]
                                            ['role'], // Add role here
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      Text(
                                        viewModel.chatMessages[index]
                                                ["timestamp"]
                                            .toString(), // Add timestamp here
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                  height:
                                      8), // Add spacing between timestamp and text message
                              Text(
                                viewModel.chatMessages[index]
                                    ['message'], // Add text message here
                                style: const TextStyle(color: Colors.white),
                              ),
                              if (viewModel.chatMessages[index]["imageUrl"]
                                  .toString()
                                  .isNotEmpty)
                                Image.file(
                                  File(viewModel.chatMessages[index]
                                      ["imageUrl"]),
                                  width: 90,
                                  height: 90,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Visibility(
                    visible: viewModel.imageFile != null,
                    child: viewModel.imageFile != null
                        ? Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: FileImage(viewModel.imageFile!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container()),

                // Add UI for sending messages (e.g., a text field and a send button)
                Container(
                  alignment: Alignment.bottomRight,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: viewModel.usermsg,
                          decoration: InputDecoration(
                            hintText: "Ask any thing...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Colors.transparent,
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,

                          // Implement text editing controller and handling user input
                        ),
                      ),
                      Visibility(
                        visible: !kIsWeb,
                        child: IconButton(
                          icon: const Icon(Icons.add_a_photo),
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['jpg', 'jpeg', 'png'],
                            );

                            if (result != null) {
                              viewModel.updateImageFile(
                                  File(result.files.single.path!));
                              // viewModel.imageFile =
                              //     File(result.files.single.path!);
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: viewModel.isBusy
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.send),
                        onPressed: () async {
                          if (!viewModel.isBusy) {
                            if (viewModel.usermsg.text.isNotEmpty &&
                                viewModel.imageFile == null) {
                              await viewModel
                                  .sendMessageOnlyText(viewModel.usermsg.text);
                              viewModel.usermsg.clear();
                            } else if (viewModel.imageFile != null) {
                              viewModel.getImagePath();
                              // await viewModel.uploadImageToFirestorega();
                              await viewModel
                                  .sendMessagewithImage(viewModel.usermsg.text);
                              viewModel.usermsg.clear();

                              viewModel.imageFile = null;
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

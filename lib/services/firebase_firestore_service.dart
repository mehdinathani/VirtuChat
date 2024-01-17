import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPrompt(String uid, String promptName) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('prompts')
        .doc(promptName)
        .set({});
  }

  Future<void> addMessage(
    String uid,
    String promptName,
    String senderId,
    String message,
    String imageUrl,
    String role,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('prompts')
        .doc(promptName)
        .collection('messages')
        .add({
      'senderId': senderId,
      'message': message,
      'role': role,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<String>> getPrompts(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('prompts')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getMessages(
    String uid,
    String promptName,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('prompts')
        .doc(promptName)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageReference.putFile(imageFile);

      // Wait for the upload to complete and get the download URL
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  // Function to edit a message
  Future<void> editMessage(
    String uid,
    String promptName,
    String messageId,
    String editedMessage,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('prompts')
        .doc(promptName)
        .collection('messages')
        .doc(messageId)
        .update({
      'message': editedMessage,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Function to delete a message
  Future<void> deleteMessage(
    String uid,
    String promptName,
    String messageId,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('prompts')
        .doc(promptName)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  // Function to edit a prompt
  Future<void> editPrompt(
    String uid,
    String oldPromptName,
    String newPromptName,
  ) async {
    // Rename the prompt document
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('prompts')
        .doc(oldPromptName)
        .update({'promptName': newPromptName});

    // Update all messages under the prompt with the new prompt name
    QuerySnapshot messagesSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('prompts')
        .doc(oldPromptName)
        .collection('messages')
        .get();

    for (QueryDocumentSnapshot messageDoc in messagesSnapshot.docs) {
      await messageDoc.reference.update({'promptName': newPromptName});
    }
  }

  // Function to delete a prompt
  Future<void> deletePrompt(
    String uid,
    String promptName,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('prompts')
        .doc(promptName)
        .delete();
  }
}

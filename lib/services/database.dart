import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final String uid;
  DatabaseService({this.uid});
  // Collection Reference
  // Checks if there is a collection named profile, if not it creates new one.
  final CollectionReference userProfileCollection = Firestore.instance.collection('userProfile');
  final CollectionReference projectCollection = Firestore.instance.collection('projects');


  Future setNewUserProfile (String username, String email, String password, String name, String birthDate) async {
    // Creating new profile after registration
    await userProfileCollection.document(uid).setData({
      'username': username,
      'email': email,
      'password': password,
      'name': name,
      'birthDate': birthDate,
    });

    // Creating a sub collection for private tasks folder
   return await userProfileCollection.document(uid).collection('privateTasksFolder').document().setData({});
  }


  // Get users stream
  Stream<QuerySnapshot> get users{
    return userProfileCollection.snapshots();
  }
}
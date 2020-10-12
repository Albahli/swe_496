import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:swe496/models/Chat.dart';
import 'package:swe496/models/Event.dart';
import 'package:swe496/models/Members.dart';
import 'package:swe496/models/Message.dart';
import 'package:swe496/models/Project.dart';
import 'package:swe496/models/SubTask.dart';
import 'package:swe496/models/TaskOfProject.dart';
import 'package:swe496/models/User.dart';
import 'package:uuid/uuid.dart';

class ProjectCollection {
  final Firestore _firestore = Firestore.instance;

  Future<void> createNewProject(String projectName, User user) async {
    String projectID =
        Uuid().v1(); // Project ID, UuiD is package that generates random ID.

    // Add the creator of the project to the members list and assign him as admin.
    var member = Member(
      memberUID: user.userID,
      isAdmin: true,
    );
    List<Member> membersList = new List();
    membersList.add(member);

    // Save his ID in the membersUIDs list
    List<String> membersIDs = new List();
    membersIDs.add(user.userID);

    List<TaskOfProject> listOfTasks = new List();
    // Create chat for the new project
    var chat = Chat(chatID: projectID);

    // Create the project object
    var newProject = Project(
      projectID: projectID,
      projectName: projectName,
      image: '',
      joiningLink: '$projectID',
      isJoiningLinkEnabled: true,
      pinnedMessage: '',
      chat: chat,
      members: membersList,
      membersIDs: membersIDs,
      task: listOfTasks,
    );

    // Add the new project ID to the user's project list.
    user.userProjectsIDs.add(projectID);
    try {
      // Convert the project object to be a JSON.
      var jsonUser = user.toJson();

      // Send the user JSON data to the fire base.
      await Firestore.instance
          .collection('userProfile')
          .document(user.userID)
          .setData(jsonUser);

      // Convert the project object to be a JSON.
      var jsonProject = newProject.toJson();

      // Send the project JSON data to the fire base.
      return await Firestore.instance
          .collection('projects')
          .document(projectID)
          .setData(jsonProject);
    } catch (e) {
      print(e);
    }
  }

  Future<void> createNewTask(
      String projectID,
      String _taskName,
      String _taskDescription,
      String _taskStartDate,
      String _taskDueDate,
      String _taskPriority,
      String _taskAssignedTo,
      String _taskAssignedBy,
      String _taskStatus) async {
    String taskID =
        Uuid().v1(); // Task ID, UuiD is package that generates random ID.

    // Creating a list of sub tasks for that task.
    List<TaskOfProject> subTasksList = new List();

    // Creating a list of messages/comment for that task.
    List<Message> messagesList = new List();

    // Splitting the username and the ID by (,)
    List listOfUserNameAndID = _taskAssignedTo.split(',');

    // Creating the task object for the project
    TaskOfProject taskOfProject = new TaskOfProject(
      taskID: taskID,
      taskName: _taskName,
      taskDescription: _taskDescription,
      startDate: _taskStartDate,
      dueDate: _taskDueDate,
      taskPriority: _taskPriority,
      isAssigned: _taskAssignedTo.isEmpty ? 'false' : 'true',
      // Determine if the task is assigned or not.
      assignedTo: _taskAssignedTo.isEmpty ? '' : listOfUserNameAndID[1],
      // Storing only the user ID
      assignedBy: _taskAssignedBy,
      taskStatus: _taskStatus,
      subtask: subTasksList,
      message: messagesList,
    );

    // Creating the list of tasks for that project.
    List<TaskOfProject> listOfTasks = new List();

    // Adding the task to the list of tasks
    listOfTasks.add(taskOfProject);

    // Convert the task object to JSON
    try {
      var listOfTasksJson = taskOfProject.toJson();

      print(listOfTasksJson);

      return await _firestore
          .collection('projects')
          .document(projectID)
          .collection('tasks')
          .document(taskID)
          .setData(listOfTasksJson);
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> createNewSubtask(
      String projectID,
      String mainTaskID,
      String _subtaskName,
      String _subtaskDescription,
      String _subtaskStartDate,
      String _subtaskDueDate,
      String _subtaskPriority,
      String _subtaskStatus) async {
    String subtaskID =
        Uuid().v1(); // Task ID, UuiD is package that generates random ID.

    // Creating the task object for the project
    TaskOfProject newSubtaskOfProject = new TaskOfProject(
      taskID: subtaskID,
      taskName: _subtaskName,
      taskDescription: _subtaskDescription,
      startDate: _subtaskStartDate,
      dueDate: _subtaskDueDate,
      taskPriority: _subtaskPriority,
      taskStatus: _subtaskStatus,
      isAssigned: 'true',
    );
    // Convert the sub task object to JSON
    var newSubtaskJSON = newSubtaskOfProject.toJson();
    try {
      DocumentReference documentReference = _firestore
          .collection('projects')
          .document(projectID)
          .collection('tasks')
          .document(mainTaskID);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(documentReference);
        if (!snapshot.exists) {
          throw Exception("data does not exist!");
        }
        //TODO: STOPPED HERE
        await transaction.update(
            documentReference,
            ({
              'subTask': FieldValue.arrayUnion([
                newSubtaskJSON,
              ]),
            }));

      });
      Get.back();
      Get.snackbar('Success', "Subtask '$_subtaskName' has been added successfully");
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> createNewEvent(
      String projectID,
      String eventName,
      String eventDescription,
      String startDate,
      String endDate,
      String location) async {
    String eventID =
        Uuid().v1(); // Event ID, UuiD is package that generates random ID.

    Event event = new Event(
      eventID: eventID,
      eventName: eventName.trim(),
      eventDescription: eventDescription,
      eventStartDate: startDate,
      eventEndDate: endDate,
      eventLocation: location,
    );

    try {
      var eventJson = event.toJson();

      return await _firestore
          .collection('projects')
          .document(projectID)
          .collection('events')
          .document(eventID)
          .setData(eventJson);
    } on Exception catch (e) {
      print(e);
    }
  }

  // To view the tasks in the "tasks & events" tab for the admin.
  Stream<QuerySnapshot> getTasksOfProject(String projectID, String assignedBy) {
    return _firestore
        .collection('projects')
        .document(projectID)
        .collection('tasks')
        .where('assignedBy', isEqualTo: assignedBy)
        .snapshots();
  }

  Stream<QuerySnapshot> getEventsOfProject(String projectID) {
    return _firestore
        .collection('projects')
        .document(projectID)
        .collection('events')
        .snapshots();
  }

  // To view the tasks in the "tasks & events" tab for the user.
  Stream<List<TaskOfProject>> tasksOfProjectStream(
      String projectID, String assignedTo) {
    return _firestore
        .collection('projects')
        .document(projectID)
        .collection('tasks')
        .where('assignedTo', isEqualTo: assignedTo)
        .snapshots()
        .map((QuerySnapshot query) {
      List<TaskOfProject> retVal = List();
      query.documents.forEach((element) {
        retVal.add(TaskOfProject.fromJson(element.data));
      });
      return retVal;
    });
  }
}

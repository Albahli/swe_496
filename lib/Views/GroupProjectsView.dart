import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:multilevel_drawer/multilevel_drawer.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:swe496/Views/Project/CreateProjectView.dart';
import 'package:swe496/Views/friendsView.dart';
import 'package:swe496/Views/MessagesView.dart';
import 'package:swe496/Views/Project/TasksAndEventsView.dart';
import 'package:swe496/controllers/ProjectControllers/ListOfProjectsContoller.dart';
import 'package:swe496/controllers/ProjectControllers/projectController.dart';
import 'package:swe496/controllers/UserControllers/authController.dart';
import 'package:swe496/controllers/UserControllers/userController.dart';
import 'package:swe496/models/Project.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'AccountSettings.dart';

class GroupProjectsView extends StatefulWidget {
  @override
  _GroupProjectsViewState createState() => _GroupProjectsViewState();
}

class _GroupProjectsViewState extends State<GroupProjectsView> {
  AuthController authController = Get.find<AuthController>();
  UserController userController = Get.find<UserController>();
  final formKey = GlobalKey<FormState>();
  final TextEditingController _newProjectNameController =
      TextEditingController();
  int barIndex = 0;

  String keyword = '';
  List<Project> filteredProjectsListBySearch = new List<Project>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        // still not working in landscape mode
        appBar: AppBar(
          title: const Text('Group Projects'),
          centerTitle: true,
          actions: <Widget>[],
        ),
        drawer: MultiLevelDrawer(
          header: Container(
            // Header for Drawer
            height: MediaQuery.of(context).size.height * 0.25,
            child: Center(
                child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.account_circle,
                    size: 90,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  userController.user.userName == null
                      ? Text('NULL ?')
                      : Text('${userController.user.userName}'),
                ],
              ),
            )),
          ),
          children: [
            // Child Elements for Each Drawer Item
            MLMenuItem(
                leading: Icon(
                  Icons.person,
                ),
                content: Text("My Profile"),
                onClick: () {
                  Get.to(AccountSettings());
                  FocusScope.of(context).unfocus();
                }),
            MLMenuItem(
              leading: Icon(
                Icons.settings,
              ),
              content: Text("Settings"),
              onClick: () {},
            ),
            MLMenuItem(
                leading: Icon(
                  Icons.power_settings_new,
                ),
                content: Text(
                  "Log out",
                ),
                onClick: () async {
                  authController.signOut();
                  print("Signed Out");
                }),
          ],
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              _searchBar(),
              getListOfProjects(),
            ],
          ),
        ),
        bottomNavigationBar: bottomCustomNavigationBar(),
        floatingActionButton: floatingButtons(context));
  }

  _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(hintText: 'Search'),
        onChanged: (textVal) {
          setState(() {
            keyword = textVal;
          });
        },
      ),
    );
  }

  Widget getListOfProjects() {
    return Expanded(
      child: GetX<ListOfProjectsController>(
          init: Get.put<ListOfProjectsController>(ListOfProjectsController()),
          builder: (ListOfProjectsController listOfProjectsController) {
            if (listOfProjectsController != null &&
                listOfProjectsController.projects != null &&
                !listOfProjectsController.projects.isNullOrBlank &&
                !listOfProjectsController.projects.isNull &&
                listOfProjectsController.projects.length != 0 &&
                listOfProjectsController.projects.isNotEmpty) {
              filteredProjectsListBySearch = listOfProjectsController.projects
                  .where((project) => project.projectName
                      .toLowerCase()
                      .contains(keyword.toLowerCase()))
                  .toList();

              return ListView.builder(
                  itemCount: filteredProjectsListBySearch.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.supervised_user_circle),
                      title:
                          Text(filteredProjectsListBySearch[index].projectName),
                      subtitle: Text('Details...'),
                      onTap: () async {
                        Get.put<ProjectController>(ProjectController(
                            projectID:
                                filteredProjectsListBySearch[index].projectID));
                        // sleep(Duration(milliseconds:600));
                        ProjectController projectController =
                            Get.find<ProjectController>();
                        if (projectController.initialized) {
                          Get.to(TasksAndEventsView(),
                              transition: Transition.rightToLeft,
                              duration: Duration(milliseconds: 300));
                          FocusScope.of(context).unfocus();
                        }
                      },
                    );
                  });
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text("You don't have any projects")),
            );
          }),
    );
  }

  Widget bottomCustomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Groups',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_turned_in),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.contacts),
          label: 'Friends',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
      ],
      currentIndex: barIndex,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) {
        setState(() {
          barIndex = index;

          if (barIndex == 0) // Do nothing, stay in the same page
            return;
          else if (barIndex == 1)
            return;
          else if (barIndex == 2)
            Get.off(FriendsView(), transition: Transition.noTransition);
          else if (barIndex == 3)
            Get.off(MessagesView(), transition: Transition.noTransition);
        });

        print(index);
      },
    );
  }

  Widget floatingButtons(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 25.0),
      marginRight: 14,
      marginBottom: 16,
      // this is ignored if animatedIcon is non null
      // child: Icon(Icons.add),
      // If true user is forced to close dial manually
      // by tapping main button and overlay is not rendered.
      closeManually: false,
      curve: Curves.bounceIn,
      overlayOpacity: 0.5,
      onOpen: () => print('OPENING MENU'),
      onClose: () => print('MENU CLOSED'),
      tooltip: 'Menu',
      heroTag: '',
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
          child: Icon(
            Icons.calendar_today,
            size: 25,
          ),
          label: 'Upcoming',
          onTap: () => Get.bottomSheet(
            Container(
              child: Column(
                children: [
                  AppBar(
                    title: Text('Timeline'),
                    centerTitle: true,
                    leading: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  Expanded(child: viewTimeLineOfTasksAndEvents()),
                ],
              ),
            ),
            backgroundColor: Get.theme.canvasColor,
            isScrollControlled: true,
            ignoreSafeArea: false,
          ),
        ),
        SpeedDialChild(
          child: Icon(
            Icons.group_add,
            size: 25,
          ),
          label: 'Join Project',
          onTap: () => print('SECOND CHILD'),
        ),
        SpeedDialChild(
            child: Icon(
              Icons.add,
              size: 25,
            ),
            label: 'New Project ',
            onTap: () {
                Get.to(CreateProjectView());
                FocusScope.of(context).unfocus();
            }
            ),
      ],
    );
  }

  Widget viewTimeLineOfTasksAndEvents() {
    List<TimelineModel> items = [
      TimelineModel(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(spreadRadius: 0.5),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: 300, minWidth: 200, minHeight: 200),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Task name: ',
                        ),
                        Text(
                          'Description: ',
                        ),
                        Text(
                          'Status: ',
                        ),
                        Text(
                          'Priority: ',
                        ),
                        Text(
                          'Start date: ',
                        ),
                        Text(
                          'End date: ',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          position: TimelineItemPosition.right,
          isFirst: true,
          icon: Icon(
            Icons.assignment,
          )),
      TimelineModel(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(spreadRadius: 0.5),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: 300, minWidth: 200, minHeight: 200),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Event name: ',
                        ),
                        Text(
                          'Description: ',
                        ),
                        Text(
                          'Location: (optional) ',
                        ),
                        Text(
                          'Date: ',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          position: TimelineItemPosition.left,
          isFirst: true,
          icon: Icon(
            Icons.event,
          )),
      TimelineModel(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(spreadRadius: 0.5),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: 300, minWidth: 200, minHeight: 200),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Task name: ',
                        ),
                        Text(
                          'Description: ',
                        ),
                        Text(
                          'Status: ',
                        ),
                        Text(
                          'Priority: ',
                        ),
                        Text(
                          'Start date: ',
                        ),
                        Text(
                          'End date: ',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          position: TimelineItemPosition.right,
          isFirst: true,
          icon: Icon(
            Icons.assignment,
          )),
    ];

    return Timeline(children: items, position: TimelinePosition.Center);
  }

  void alertCreateProjectForm(BuildContext context) {
    Alert(
        context: context,
        title: 'Create New Project',
        closeFunction: () => null,
        style: AlertStyle(
            animationType: AnimationType.fromBottom,
            animationDuration: Duration(milliseconds: 300),
            descStyle: TextStyle(
              fontSize: 12,
            )),
        content: Theme(
          data: Get.theme,
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  validator: (value) =>
                      value.isEmpty ? "Project name can't be empty" : null,
                  controller: _newProjectNameController,
                  onSaved: (projectNameVal) =>
                      _newProjectNameController.text = projectNameVal,
                  decoration: InputDecoration(
                    icon: Icon(Icons.edit),
                    focusedBorder: UnderlineInputBorder(),
                    hintText: 'Graduation Project',
                    labelText: 'Project Name',
                  ),
                ),
                CheckboxListTile(
                  title: Text("title text"),
                  value: false,
                  onChanged: (newValue) {},
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                )
              ],
            ),
          ),
        ),
        buttons: [
          DialogButton(
            radius: BorderRadius.circular(30),
            onPressed: () async {
              formKey.currentState.save();
              if (formKey.currentState.validate()) {
                try {
                  //  ProjectCollection().createNewProject(
                  //    _newProjectNameController.text, userController.user);
                  Get.back();
                  // Display success message
                  Get.snackbar(
                    "Success !", // title
                    "Project '${_newProjectNameController.text}' has been created successfully.",
                    // message
                    icon: Icon(
                      Icons.check_circle_outline,
                    ),
                    shouldIconPulse: true,
                    borderWidth: 1,
                    barBlur: 20,
                    isDismissible: true,
                    duration: Duration(seconds: 5),
                  );
                  _newProjectNameController.clear();
                } catch (e) {
                  print(e.message);
                }
              }
            },
            child: Text(
              "Submit",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
            ),
          )
        ]).show();
  }
}

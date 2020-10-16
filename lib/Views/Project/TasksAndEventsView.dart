import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/Views/Project/CreateEventView.dart';
import 'package:swe496/Views/Project/CreateTaskView.dart';
import 'package:swe496/Views/Project/MembersView.dart';
import 'package:swe496/Views/Project/TaskView.dart';
import 'package:swe496/controllers/ListOfTasksOfProjectConrtoller.dart';
import 'package:swe496/controllers/TaskOfProjectController.dart';
import 'package:swe496/controllers/projectController.dart';
import 'package:swe496/controllers/EventsController.dart';
import 'package:swe496/controllers/userController.dart';
import 'package:swe496/models/Event.dart';
import 'package:swe496/models/TaskOfProject.dart';
import 'package:swe496/utils/root.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

class TasksAndEventsView extends StatefulWidget {
  TasksAndEventsView({Key key}) : super(key: key);

  @override
  _TasksAndEvents createState() => _TasksAndEvents();
}

class _TasksAndEvents extends State<TasksAndEventsView>
    with TickerProviderStateMixin {
  int barIndex = 0; // Current page index in bottom navigation bar
  ProjectController projectController = Get.find<ProjectController>();
  UserController userController = Get.find<UserController>();
  TabController
      tabController; // Top bar navigation between the tasks and events

  @override
  void initState() {
    super.initState();
    this.tabController = new TabController(length: 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            Get.offAll(Root());
            projectController.clear();
            tabController.dispose();
            print("back to 'Root' from 'TaskAndEventsView'");
          },
        ),
        title: Text(projectController.project.projectName),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Open project settings page
            },
          )
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: Container(
                  height: 50.0,
                  child: new TabBar(
                    indicatorColor: Get.theme.indicatorColor,
                    unselectedLabelColor: Get.theme.unselectedWidgetColor,
                    labelColor: Get.theme.indicatorColor,
                    tabs: [
                      Tab(
                        text: "Tasks",
                      ),
                      Tab(
                        text: "Events",
                      ),
                    ],
                  ),
                ),
              ),
              body: TabBarView(
                children: [
                  tasksTab(),
                  eventsTab(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomCustomNavigationBar(),
      floatingActionButton: floatingButtons(),
    );
  }

  // Search Bar
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
        ),
        onChanged: (textVal) {
          textVal = textVal.toLowerCase();
        },
      ),
    );
  }

  // Bottom Navigation Bar
  Widget bottomCustomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.inbox),
          title: Text('Tasks & Events'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          title: Text('Chat'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_work),
          title: Text('Members'),
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
            Get.off(MembersView(), transition: Transition.noTransition);
        });
        print(index);
      },
    );
  }

  Widget floatingButtons() {
    return SpeedDial(
      // both default to 16
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 25.0),
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
            Icons.timeline,
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
            Icons.event,
            size: 25,
          ),
          label: 'New Event',
          onTap: () {
            Get.to(CreateEventView(),
                transition: Transition.downToUp,
                duration: Duration(milliseconds: 250));
          },
        ),
        SpeedDialChild(
            child: Icon(
              Icons.assignment,
              size: 25,
            ),
            label: 'New Task',
            onTap: () {
              Get.to(CreateTaskView(),
                  transition: Transition.downToUp,
                  duration: Duration(milliseconds: 250));
            }),
      ],
    );
  }

  Widget viewTimeLineOfTasksAndEvents() {
//TODO: Fix the timeline model
    List<Event> eventList = new List<Event>();
    GetX<EventController>(
        init: Get.put<EventController>(EventController()),
        builder: (EventController eventController) {
          print('test1');
          if (eventController != null && eventController.events != null) {
            eventController.events.forEach((element) {
              eventList.add(element);
            });
          }
          //  }
          return;
        });
    /*items.add();*/
    EventController eventController = Get.put<EventController>(EventController());
    ListOfTasksOfProjectController listOfTasksOfProjectController = Get.put<ListOfTasksOfProjectController>(ListOfTasksOfProjectController());
    var newList = [...eventController.events, ...listOfTasksOfProjectController.tasks];

    return Timeline(children: List<TimelineModel>.generate((newList.length), (index) {
      if (newList[index] is Event) {
        TimelineModel(
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: 300, minWidth: 200, minHeight: 200),
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'Event name:}',
                                ),
                                Text(
                                  'Description: ${eventController.events[index].eventDescription} ',
                                ),

                                Text(
                                  'Start date: ${eventController.events[index].eventStartDate}',
                                ),
                                Text(
                                  'End date: ${eventController.events[index].eventEndDate}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  position: TimelineItemPosition.right,
                  icon: Icon(
                    Icons.assignment,
                  ));
      }
      return TimelineModel(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey),
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
          icon: Icon(
            Icons.assignment,
          ));
    }), position: TimelinePosition.Center);
  }

  List<TimelineModel> timelineItems() {
    List<TimelineModel> items = [];
    GetX<EventController>(
        init: Get.put<EventController>(EventController()),
        builder: (EventController eventController) {
          if (eventController != null && eventController.events != null) {
            for (var event in eventController.events) {
              items.add(TimelineModel(
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
                                  'Event name: ${event.eventName}',
                                ),
                                Text(
                                  'Description: ${event.eventDescription}',
                                ),
                                Text(
                                  'Start date: ${event.eventStartDate} ',
                                ),
                                Text(
                                  'End date:${event.eventEndDate} ',
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
                  )));
            }
          }
          //  }
          return;
        });
    /*items.add(TimelineModel(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey),
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
        icon: Icon(
          Icons.assignment,
        )));*/
    return items;
  }

  Widget tasksTab() {
    return Column(
      children: [
        _searchBar(),
        Expanded(child: getListOfTasks()),
      ],
    );
  }

  Widget eventsTab() {
    return Column(
      children: [
        _searchBar(),
        Expanded(child: getListOfEvents()),
      ],
    );
  }

  Widget getListOfTasks() {
    return GetX<ListOfTasksOfProjectController>(
        init: Get.put<ListOfTasksOfProjectController>(
            ListOfTasksOfProjectController()),
        builder:
            (ListOfTasksOfProjectController listOfTasksOfProjectController) {
          if (listOfTasksOfProjectController != null &&
              listOfTasksOfProjectController.tasks != null &&
              listOfTasksOfProjectController.tasks.isNotEmpty) {
            return ListView.builder(
                itemCount: listOfTasksOfProjectController.tasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.assignment),
                    title: Text(
                        listOfTasksOfProjectController.tasks[index].taskName),
                    subtitle: Text('Details ...'),
                    onTap: () async {
                      Get.put<TaskOfProjectController>(TaskOfProjectController(
                          taskID: listOfTasksOfProjectController
                              .tasks[index].taskID));
                      Get.to(TaskView());
                    },
                  );
                });
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text("There is no tasks.")),
          );
        });
  }

  Widget getListOfEvents() {
    return GetX<EventController>(
        init: Get.put<EventController>(EventController()),
        builder: (EventController eventController) {
          if (eventController != null &&
              eventController.events != null &&
              eventController.events.isNotEmpty) {
            return ListView.builder(
                itemCount: eventController.events.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.event),
                    title: Text(eventController.events[index].eventName),
                    subtitle: Text('Details ...'),
                    onTap: () async {},
                  );
                });
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text("There is no events.")),
          );
        });
  }
}
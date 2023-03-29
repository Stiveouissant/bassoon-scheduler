import 'package:bassoon_scheduler_app/models/attendant.dart';
import 'package:bassoon_scheduler_app/models/bassoon_class.dart';
import 'package:bassoon_scheduler_app/models/bassoon_lesson.dart';
import 'package:bassoon_scheduler_app/screens/account_screen.dart';
import 'package:bassoon_scheduler_app/shared/nav_menu.dart';
import 'package:bassoon_scheduler_app/shared/translations.dart';
import 'package:bassoon_scheduler_app/shared/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:bassoon_scheduler_app/data/shared_prefs.dart';

class BassoonLessonsScreen extends StatefulWidget {
  const BassoonLessonsScreen({Key? key}) : super(key: key);

  @override
  State<BassoonLessonsScreen> createState() => _BassoonLessonsScreenState();
}

class _BassoonLessonsScreenState extends State<BassoonLessonsScreen> {
  int settingColor = 0xff1976d2;
  double settingFontSize = 16;
  String settingLanguage = "PL";
  SPSettings settings = SPSettings();
  late Map<String, dynamic> translations;
  final formKey = GlobalKey<FormState>();

  final TextEditingController bassoonLessonDescController =
      TextEditingController();
  final TextEditingController bassoonLessonDateController =
      TextEditingController();
  final TextEditingController bassoonLessonNumberController =
      TextEditingController();

  @override
  void dispose() {
    bassoonLessonDescController.dispose();
    bassoonLessonDateController.dispose();
    bassoonLessonNumberController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    getSettingsAndTranslations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (userSnapshot.hasError) {
            return Center(child: Text(translations["Somthingwong"]));
          } else if (userSnapshot.hasData) {
            return Scaffold(
                appBar: AppBar(
                    backgroundColor: Color(settingColor),
                    title: Text(translations["Lessons"])),
                drawer: const NavMenu(),
                floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    showBassoonLessonAddDialog(context);
                  },
                ),
                body: StreamBuilder<List<String>>(
                  stream: readAttendedClasses(),
                  builder: (context, attendedClassesSnapshot) {
                    if (attendedClassesSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                    } else if (attendedClassesSnapshot.hasError) {
                    return Center(child: Text(translations["Somthingwong"]));
                    } else if (attendedClassesSnapshot.hasData) {
                      if(attendedClassesSnapshot.data!.isEmpty){
                        return Center(child: Text(translations["NoAttendedClasses"]));
                      }
                      return StreamBuilder<List<BassoonLesson>>(
                          stream: readBassoonLessonsByAttendedClasses(attendedClassesSnapshot.data ?? []),
                          builder: (context, lessonSnapshot) {
                            if (lessonSnapshot.hasError) {
                              return Center(
                                  child: Text(translations["Somthingwong"]));
                            } else if (lessonSnapshot.hasData) {
                              final bassoonLessons = lessonSnapshot.data!;
                              return ListView(
                                padding: const EdgeInsets.all(8),
                                children: bassoonLessons
                                    .map(buildBassoonLessonsList)
                                    .toList(),
                              );
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          });
                    }else{
                      return Center(child: Text(translations["NoAttendedClasses"]));
                    }
                  }
                ));
          } else {
            return AccountScreen();
          }
        });
  }

  Future<dynamic> showBassoonLessonAddDialog(BuildContext context) async {
    List<DropdownMenuItem<String>> items = [];
    DateTime? newDate;
    String? selectedItem;
    await FirebaseFirestore.instance
        .collection("bassoon class")
        .where('created by id',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((res) => res.docs.forEach((element) {
              items.add(DropdownMenuItem(
                  value: element['class name'],
                  child: Text(element['class name'])));
            }));
    if (items.isEmpty) {
      Utils.showSnackBar(translations["NoOwnedClass"]);
      return;
    }
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(translations["NewLesson"]),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                          controller: bassoonLessonDescController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) =>
                              !RegExp(r"^[a-zA-Z0-9\sżźćńółęąśŻŹĆĄŚĘŁÓŃ]*$")
                                      .hasMatch(value!)
                                  ? translations["NoSpecialChars"]
                                  : null,
                          decoration: InputDecoration(
                              hintText: translations["OptDesc"])),
                      TextFormField(
                        controller: bassoonLessonDateController,
                        showCursor: false,
                        readOnly: true,
                        decoration: InputDecoration(
                            hintText: translations["Date"],
                            suffixIcon: const Icon(Icons.date_range)),
                        validator: (date) =>
                            date == null ? translations["ChooseDate"] : null,
                        onTap: () async {
                          DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2022),
                              lastDate: DateTime(2100));
                          if (date == null) return;
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 12, minute: 0),
                          );
                          if (time == null) return;
                          newDate = DateTime(date.year, date.month, date.day,
                              time.hour, time.minute);
                          bassoonLessonDateController.text =
                              "${newDate?.day}.${newDate?.month}.${newDate?.year}"
                              " ${newDate!.hour < 10 ? newDate!.hour.toString().padLeft(2, '0') : newDate!.hour}"
                              ":${newDate!.minute < 10 ? newDate!.minute.toString().padLeft(2, '0') : newDate!.minute}";
                        },
                      ),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: translations["Class"],
                        ),
                        value: selectedItem,
                        items: items,
                        onChanged: (item) =>
                            setState(() => selectedItem = item),
                      ),
                      TextFormField(
                          controller: bassoonLessonNumberController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              !RegExp(r"^([1-9]|10)$").hasMatch(value!)
                                  ? translations["OnlyNums"]
                                  : null,
                          decoration: InputDecoration(
                              hintText: translations["LesAmount"])),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      bassoonLessonDescController.text = '';
                      bassoonLessonDateController.text = '';
                      bassoonLessonNumberController.text = '';
                    },
                    child: Text(translations["Cancel"])),
                ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        createNewBassoonLesson(selectedItem!, newDate!);
                        Navigator.pop(context);
                        bassoonLessonDescController.text = '';
                        bassoonLessonDateController.text = '';
                        bassoonLessonNumberController.text = '';
                      }
                    },
                    child: Text(translations["Create"]))
              ]);
        });
  }

  Future createNewBassoonLesson(String className, DateTime date) async {
    final lessonDesc = bassoonLessonDescController.text.trim();
    final lessonDate = Timestamp.fromDate(date);
    int lessonsAmount = int.parse(bassoonLessonNumberController.text);
    List<SingleLesson> lessonList = [];
    for (int i = 0; i < lessonsAmount; i++) {
      DateTime timeadder = date.add(Duration(minutes: 45 * i));
      Timestamp lessonTime = Timestamp.fromDate(timeadder);
      SingleLesson indLesson = SingleLesson([], lessonTime);
      lessonList.add(indLesson);
    }
    final docBassoonLesson =
        FirebaseFirestore.instance.collection("bassoon lesson").doc();
    BassoonLesson bLesson = BassoonLesson(
        docBassoonLesson.id,
        className,
        FirebaseAuth.instance.currentUser!.uid,
        FirebaseAuth.instance.currentUser!.displayName,
        lessonDate,
        lessonDesc,
        lessonList);
    docBassoonLesson.set(bLesson.toJson());
  }

  Stream<List<String>> readAttendedClasses() {
    List<String> attendedClasses = [];
    return FirebaseFirestore.instance
        .collection("bassoon class")
        .where("attendees", arrayContains: {
          'uid': FirebaseAuth.instance.currentUser!.uid,
          'name': FirebaseAuth.instance.currentUser!.displayName
        })
        .snapshots()
        .map((snapshot) {
          snapshot.docs.forEach((element) {
            attendedClasses.add(element['class name']);
          });
          return attendedClasses;
        });
  }

  Stream<List<BassoonLesson>>? readBassoonLessonsByAttendedClasses(List<String> attendedClasses) {
    return FirebaseFirestore.instance
        .collection("bassoon lesson")
        .where("bassoon class", whereIn: attendedClasses)
        .orderBy("date")
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => BassoonLesson.fromJson(doc.data()))
        .toList());
  }

  Widget buildBassoonLessonsList(BassoonLesson bLesson) {
    var lessonTiles = <ListTile>[];
    var myId = FirebaseAuth.instance.currentUser!.uid;
    var docRef = FirebaseFirestore.instance
        .collection('bassoon lesson')
        .doc(bLesson.lesson_id);
    bLesson.lessons?.asMap().forEach((key, lesson) {
      bool isAttending = false;
      late int deleteIndex;
      lesson.attendants!.asMap().forEach((index, attendant) {
        if (attendant.uid == myId) {
          deleteIndex = index;
          isAttending = true;
        }
      });
      Color joinLessonIconColor;
      IconData joinLessonIcon;
      if (isAttending) {
        joinLessonIconColor = Colors.green;
        joinLessonIcon = Icons.check_box;
      } else {
        joinLessonIconColor = Colors.blueGrey;
        joinLessonIcon = Icons.add;
      }
      DateTime? timeOfLessonD =
          DateTime.tryParse(lesson.time.toDate().toString());
      String timeOfLesson =
          "${timeOfLessonD!.hour.toString().length == 1 ? timeOfLessonD.hour.toString().padLeft(2, '0') : timeOfLessonD.hour}:${timeOfLessonD.minute.toString().length == 1 ? timeOfLessonD.minute.toString().padLeft(2, '0') : timeOfLessonD.minute}";
      String allAttendants = '';
      if (lesson.attendants!.isNotEmpty) {
        lesson.attendants!.asMap().forEach((key, attendant) {
          allAttendants += '${attendant.name}, ';
        });
        allAttendants = allAttendants.substring(0, allAttendants.length - 2);
      } else {
        allAttendants = translations["NoAttendees"];
      }
      lessonTiles.add(ListTile(
        title: Text("${key + 1}: $timeOfLesson - $allAttendants"),
        contentPadding: const EdgeInsets.only(left: 40, right: 20),
        trailing: Icon(
          joinLessonIcon,
          color: joinLessonIconColor,
        ),
        onTap: () {
          if (isAttending) {
            bLesson.lessons![key].attendants?.removeAt(deleteIndex);
            docRef.update(bLesson.lessonsToJson());
          } else {
            List<Attendant>? newAttendeesList = lesson.attendants;
            newAttendeesList?.add(Attendant(
                myId, FirebaseAuth.instance.currentUser!.displayName));
            SingleLesson updateLesson =
                SingleLesson(newAttendeesList, lesson.time);
            bLesson.lessons![key] = updateLesson;
            docRef.update(bLesson.lessonsToJson());
          }
        },
      ));
    });
    DateTime? dateFromFirebase =
        DateTime.tryParse(bLesson.date!.toDate().toString());
    var dateString =
        "${dateFromFirebase!.day}.${dateFromFirebase.month}.${dateFromFirebase.year}";
    return ExpansionTile(
        leading: getLessonOptions(
            myId, bLesson.created_by_id, bLesson.lesson_id, context),
        title: Text("${translations["Class"]}: ${bLesson.bassoon_class}\n"
            "${bLesson.description!.isEmpty ? "" : "${translations["Desc"]}: ${bLesson.description!}\n"}"
            "${translations["Date"]}: $dateString"),
        backgroundColor: const Color(0xffdce7f7),
        children: lessonTiles);
  }

  Widget? getLessonOptions(userId, lessonCreatorId, lessonId, context) {
    if (userId == lessonCreatorId) {
      return IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () {
          showDeleteBassoonLessonDialog(context, lessonId);
        },
      );
    }
    return null;
  }

  Future<dynamic> showDeleteBassoonLessonDialog(
      BuildContext context, String lessonIdToBeDeleted) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(translations["Options"]),
            content: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
              onPressed: () async {
                bool confirmation = await confirmationDialog(context);
                if (confirmation) {
                  final docRef = FirebaseFirestore.instance
                      .collection('bassoon lesson')
                      .doc(lessonIdToBeDeleted);
                  docRef.delete();
                }
                Navigator.pop(context);
              },
              child: Text(translations["DeleteThis"]),
            ),
          );
        });
  }

  Future<bool> confirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(translations["AreYouSure"]),
        actions: [
          TextButton(
              child: Text(translations["No"],
                  style: const TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.pop(context, false);
              }),
          TextButton(
              child: Text(translations["Yes"],
                  style: const TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.pop(context, true);
              })
        ],
      ),
    );
  }

  Future getSettingsAndTranslations() async {
    settings = SPSettings();
    settings.init().then((value) async {
      setState(() {
        settingColor = settings.getColor();
        settingFontSize = settings.getFontSize();
        settingLanguage = settings.getLanguage();
      });
      getTranslations();
    });
  }

  Future getTranslations() async {
    const String field = "lessons";
    Translations translator = Translations(settingLanguage);
    translations = await translator.readTranslations(field);
  }
}

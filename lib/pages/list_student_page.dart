import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_app/pages/add_student_page.dart';
// import 'package:student_app/utils/data.dart';
import 'package:student_app/utils/theme.dart';
import '../utils/student_provider.dart';

class ListStudentPage extends StatefulWidget {
  const ListStudentPage({Key? key}) : super(key: key);
  @override
  State<ListStudentPage> createState() => _ListStudentPageState();
}

class _ListStudentPageState extends State<ListStudentPage> {
  List<StudentModel> studentList = [];
  StudentProvider studentProvider = StudentProvider();
  final filterController = TextEditingController();
  bool isLoading = false;

  loadStudents() async {
    setState(() => isLoading = true);
    studentList = await studentProvider.getAll();
    // studentList.forEach(print);
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  @override
  void dispose() {
    filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Liste des étudiants"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 14, left: 14),
              child: CustomTextField(
                controller: filterController,
                hintText: "Rechercher",
                suffixIcon: Icons.search,
                onChanged: (e) => setState(() {}),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CupertinoActivityIndicator(color: primaryColor, radius: 20),
                    )
                  : filterByText(filterController.text).isNotEmpty
                      ? ListView.builder(
                          itemCount: filterByText(filterController.text).length,
                          itemBuilder: (BuildContext context, int index) => StudentWidget(
                              student: filterByText(filterController.text)[index],
                              onReload: () => loadStudents()),
                        )
                      : Center(
                          child: Text(
                            studentList.isEmpty ? "Aucun étudiant enregistré" : "Aucun résultat",
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                  context, MaterialPageRoute(builder: (context) => const AddStudentPage()));
              if (result != null && result) loadStudents();
            }));
  }

  List<StudentModel> filterByText(String name) => name.trim().isEmpty
      ? studentList
      : studentList
          .where((element) =>
              ("${element.firstName} ${element.lastName}").toLowerCase().contains(name.toLowerCase()))
          .toList();
}

class StudentWidget extends StatefulWidget {
  const StudentWidget({super.key, required this.student, required this.onReload});
  final StudentModel student;
  final void Function() onReload;

  @override
  State<StudentWidget> createState() => _StudentWidgetState();
}

class _StudentWidgetState extends State<StudentWidget> {
  final color = randomColor();
  final genderList = ["Masculin", "Féminin", "Neutre"];
  final genderIconList = [Icons.male, Icons.female, Icons.transgender];
  bool isDeleting = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 120,
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(color: Colors.black.withAlpha(90), borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Container(
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Icon(CupertinoIcons.person, size: 65, color: color),
        ),
        const SizedBox(width: 5),
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.student.matricule,
                  style: TextStyle(fontSize: 17, color: Colors.white.withOpacity(.5)),
                ),
                const SizedBox(width: 5),
                Icon(
                  genderIconList[genderList.indexOf(widget.student.gender)],
                  color: color,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "${widget.student.lastName} ${widget.student.firstName}",
                // textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontSize: 21, fontFamily: "CenturyGothic"),
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.call, color: color, size: 18),
                    const SizedBox(width: 3),
                    Text(
                      widget.student.phone,
                      style: TextStyle(fontSize: 13.5, color: Colors.white.withOpacity(.5)),
                    )
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: color,
                      size: 18,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      "${DateFormat.MMMd('fr_FR').format(widget.student.birthday)} ${widget.student.birthday.year}",
                      style: TextStyle(fontSize: 13.5, color: Colors.white.withOpacity(.5)),
                    )
                  ],
                )
              ],
            )
          ],
        )),
        const SizedBox(width: 5),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (e) => AddStudentPage(item: widget.student)),
                );
                if (result != null && result) widget.onReload();
              },
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.blue),
                height: 25,
                width: 25,
                child: Icon(
                  Icons.edit,
                  color: appTheme.scaffoldBackgroundColor,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(height: 50),
            InkWell(
              onTap: () async {
                if (isDeleting) return;
                setState(() => isDeleting = true);
                final result = await StudentProvider().delete(widget.student.id!);
                setState(() => isDeleting = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(result == 0 ? "Suppression échouée" : "Suppression éffectuée"),
                  duration: const Duration(seconds: 5),
                ));
                if (result != 0) widget.onReload();
              },
              child: isDeleting
                  ? const CupertinoActivityIndicator(color: Colors.red)
                  : Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.red),
                      height: 25,
                      width: 25,
                      child: Icon(
                        Icons.delete,
                        color: appTheme.scaffoldBackgroundColor,
                        size: 16,
                      ),
                    ),
            ),
          ],
        )
      ]),
    );
  }
}

Color randomColor() {
  final Random random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}

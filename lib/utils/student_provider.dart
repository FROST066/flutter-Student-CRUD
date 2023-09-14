import 'package:sqflite/sqflite.dart';

const String tableStudent = 'students';
const String columnId = 'id';
const String columnMatricule = 'matricule';
const String columnFirstname = 'firstName';
const String columnLastname = 'lastName';
const String columnGender = 'gender';
const String columnPhone = 'phone';
const String columnBirthday = 'birthday';
const String databaseName = "students.db";

class StudentModel {
  int? id;
  String matricule;
  String firstName;
  String lastName;
  String phone;
  String gender;
  DateTime birthday;

  StudentModel({
    this.id,
    required this.matricule,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.gender,
    required this.birthday,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: json[columnId],
        matricule: json[columnMatricule],
        firstName: json[columnFirstname],
        lastName: json[columnLastname],
        phone: json["phone"],
        gender: json["gender"],
        birthday: DateTime.parse(json["birthday"]),
      );

  Map<String, dynamic> toJson() => {
        columnId: id,
        columnMatricule: matricule,
        columnFirstname: firstName,
        columnLastname: lastName,
        "phone": phone,
        "gender": gender,
        "birthday": birthday.toIso8601String(),
      };

  @override
  String toString() => "$matricule $firstName $lastName";
}

class StudentProvider {
  Database? db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('''
            create table $tableStudent ( 
              $columnId integer primary key autoincrement, 
              $columnLastname varchar(255) not null,
              $columnFirstname varchar(255) not null,
              $columnGender varchar(255) not null,
              $columnBirthday varchar(255) not null,
              $columnMatricule varchar(255) not null,
              $columnPhone varchar(255) not null)
            ''');
    });
  }

  Future close() async => db!.close();

  Future<int> create(StudentModel student) async {
    await open(databaseName);
    final result = await db!.insert(tableStudent, student.toJson());
    await close();
    return result;
  }

  Future<StudentModel?> getStudentByMatricule(String matricule) async {
    await open(databaseName);
    List<Map<String, dynamic>> maps = await db!.query(tableStudent,
        columns: [
          columnId,
          columnFirstname,
          columnLastname,
          columnGender,
          columnBirthday,
          columnMatricule,
          columnPhone
        ],
        where: '$columnMatricule = ?',
        whereArgs: [matricule]);
    await close();
    if (maps.isNotEmpty) {
      return StudentModel.fromJson(maps.first);
    }
    return null;
  }

  Future<List<StudentModel>> getAll() async {
    try {
      await open(databaseName);
      List<Map<String, dynamic>> maps = await db!.query(tableStudent);
      await close();
      return maps.map((e) => StudentModel.fromJson(e)).toList();
    } catch (e) {
      print("Error $e");
      return [];
    }
  }

  Future<int> delete(int id) async {
    await open(databaseName);
    var result = await db!.delete(tableStudent, where: '$columnId = ?', whereArgs: [id]);
    await close();
    return result;
  }

  Future<int> update(StudentModel student) async {
    await open(databaseName);
    var result =
        await db!.update(tableStudent, student.toJson(), where: '$columnId = ?', whereArgs: [student.id]);
    return result;
  }
}
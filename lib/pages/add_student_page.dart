import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:student_app/utils/student_provider.dart';
import 'package:student_app/utils/theme.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key, this.item});
  final StudentModel? item;
  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final matriculeController = TextEditingController();
  final phoneController = TextEditingController();
  final birthdayController = TextEditingController();
  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    matriculeController.dispose();
    phoneController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  final formKey = GlobalKey<FormState>();
  final genderList = ["Masculin", "Féminin", "Neutre"];
  final genderIconList = [Icons.male, Icons.female, Icons.transgender];
  bool isUpdate = false, isLoading = false;
  String selectedGender = "Masculin";
  DateTime birthday = DateTime.now();
  @override
  void initState() {
    super.initState();
    isUpdate = widget.item != null;
    if (isUpdate) {
      firstnameController.text = widget.item!.firstName;
      lastnameController.text = widget.item!.lastName;
      matriculeController.text = widget.item!.matricule;
      phoneController.text = widget.item!.phone;
      selectedGender = widget.item!.gender;
      birthdayController.text =
          "${DateFormat.MMMd('fr_FR').format(widget.item!.birthday)} ${widget.item!.birthday.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${isUpdate ? "Modifier" : "Ajouter"} un étudiant"),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 100,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                            controller: matriculeController, hintText: "Matricule", suffixIcon: Icons.tag),
                        CustomTextField(
                            controller: lastnameController, hintText: "Nom", suffixIcon: Icons.person),
                        CustomTextField(
                            controller: firstnameController, hintText: "Prénom(s)", suffixIcon: Icons.person),
                        CustomTextField(
                          controller: phoneController,
                          hintText: "Téléphone",
                          suffixIcon: Icons.call,
                          inputType: InputType.number,
                        ),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            filled: true,
                            prefixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(genderIconList[genderList.indexOf(selectedGender)])),
                                Container(color: Colors.black.withOpacity(.6), height: 30, width: 1.1),
                                const SizedBox(width: 10)
                              ],
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            constraints: const BoxConstraints(maxWidth: 330),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.white.withOpacity(.5)),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.white.withOpacity(.5)),
                            ),
                          ),
                          value: selectedGender,
                          isExpanded: true,
                          items: genderList
                              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (e) => e != null ? setState(() => selectedGender = e) : null,
                        ),
                        const SizedBox(height: 11),
                        CustomTextField(
                          controller: birthdayController,
                          hintText: "Date de naissance",
                          suffixIcon: Icons.calendar_month,
                          readOnly: true,
                          onTap: () => showDatePicker(
                                  context: context,
                                  locale: const Locale('fr', 'FR'),
                                  initialDate: isUpdate ? widget.item!.birthday : DateTime(2010),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)))
                              .then((value) {
                            if (value == null) return;
                            birthday =
                                DateTime(value.year, value.month, value.day, birthday.hour, birthday.minute);
                            birthdayController.text =
                                "${DateFormat.MMMd('fr_FR').format(birthday)} ${birthday.year}";
                            setState(() {});
                          }),
                        )
                      ],
                    )),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                constraints: const BoxConstraints(maxWidth: 330),
                child: isLoading
                    ? const CupertinoActivityIndicator(color: primaryColor, radius: 20)
                    : ElevatedButton(
                        child: Text(isUpdate ? "Modifier" : "Ajouter"),
                        onPressed: () async {
                          if (isLoading) return;
                          if (formKey.currentState!.validate()) {
                            final student = StudentModel(
                              id: widget.item?.id,
                              matricule: matriculeController.text,
                              firstName: firstnameController.text,
                              lastName: lastnameController.text,
                              phone: phoneController.text,
                              gender: selectedGender,
                              birthday: birthday,
                            );
                            setState(() => isLoading = true);

                            //ensure that studen is Unique in creation
                            if (!isUpdate) {
                              final tempStudent =
                                  await StudentProvider().getStudentByMatricule(matriculeController.text);
                              print("Student got $tempStudent");
                              if (tempStudent != null) {
                                setState(() => isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "Le matricule ${matriculeController.text} à déja été attibué à l'étudiant ${tempStudent.firstName} ${tempStudent.lastName}"),
                                ));
                                return;
                              }
                            }
                            //If unique , continue operation
                            final result = isUpdate
                                ? await StudentProvider().update(student)
                                : await StudentProvider().create(student);
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                isUpdate
                                    ? result == 0
                                        ? "Modification échouée"
                                        : "Modification éffectuée"
                                    : result == 0
                                        ? "Enregistrement échouée"
                                        : "Enregistrement éffectuée",
                              ),
                            ));

                            if (result != 0 && mounted) Navigator.pop(context, true);
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  const CustomTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.suffixIcon,
      this.onTap,
      this.onChanged,
      this.readOnly = false,
      this.inputType = InputType.text});
  final TextEditingController controller;
  final String hintText;
  final IconData suffixIcon;
  final InputType inputType;
  final bool readOnly;
  final void Function()? onTap;
  final void Function(String)? onChanged;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool show = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: TextFormField(
        onChanged: widget.onChanged,
        style: const TextStyle(fontSize: 15),
        controller: widget.controller,
        readOnly: widget.readOnly,
        keyboardType: widget.inputType == InputType.number ? TextInputType.number : TextInputType.text,
        inputFormatters:
            widget.inputType == InputType.number ? [FilteringTextInputFormatter.digitsOnly] : null,
        onTap: widget.onTap,
        decoration: InputDecoration(
          // fillColor: Colors.white,
          filled: true,
          constraints: const BoxConstraints(maxWidth: 330),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white.withOpacity(.5)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white.withOpacity(.5)),
          ),
          contentPadding: const EdgeInsets.all(8),
          hintText: widget.hintText,

          suffixIcon: widget.inputType == InputType.password
              ? InkWell(
                  onTap: () => setState(() => show = !show),
                  child: Icon(show ? Icons.visibility : Icons.visibility_off))
              : null,
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(padding: const EdgeInsets.all(8.0), child: Icon(widget.suffixIcon)),
              Container(color: Colors.black.withOpacity(.6), height: 30, width: 1.1),
              const SizedBox(width: 10)
            ],
          ),
        ),
        validator: (value) => value == null || value == "" ? "Ce champ est obligatoire" : null,
      ),
    );
  }
}

enum InputType { text, password, number }

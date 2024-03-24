import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:report/const/app_const.dart';
import 'package:report/screens/auth/log_in_screen.dart';
import 'package:report/widget/custom_drop_down.dart';
import 'package:report/widget/custom_scafold_massage.dart';
import 'package:report/widget/custom_text_feild.dart';
import 'package:intl/intl.dart';

class SendReport extends StatefulWidget {
  const SendReport({super.key});

  @override
  _SendReportState createState() => _SendReportState();
}

class _SendReportState extends State<SendReport> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  bool _isLoading = false; // لتتبع حالة الإرسال

  //step 1
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  String? selectedGender;
  String? selectedReportSubmitter;
  String? governorates;

  // step 2   medicament name
  final TextEditingController medicamentNameController =TextEditingController();
  final TextEditingController batchNumberController = TextEditingController();
  final TextEditingController theFocusController = TextEditingController();
  final TextEditingController reasonForUsingTheMedicineController =TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  String? theActionTaken;
  String? similarReaction;
  //step 3  Description of the adverse effect
  final TextEditingController descriptionEffect =TextEditingController();
  String ? symptomsAppearOfAnyDevice ;
  String ? thePatientConditionNow ;
  String ? chronicDiseases ;
  String ? takingMedicationChronically ;

  int currentStep = 0;

  bool get isFirstStep => currentStep == 0;

  bool get isLastStep => currentStep == 2;

  bool isComplete = false;
  File? photo;

  Future getImage() async {
    await ImagePicker()
        .pickImage(source: ImageSource.camera)
        .then((value) {
      if (value!=null){
        setState(() {
          photo=File(value.path);
        });
      }
    });
  }
  deleteImage(){
    photo=null;
    setState(() {
    });
  }

  void _createUserAndSendReport() async {
    if (!_formKey.currentState!.validate()&!_formKey2.currentState!.validate()&!_formKey2.currentState!.validate()) {
      // إذا لم يتم ملء الحقول بشكل صحيح
      showCustomSnackBar(context, "الرجاء ملئ جميع الحقول");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await FirebaseFirestore.instance.collection('reports').add({
        'name': nameController.text,
        'age': ageController.text,
        'weight': weightController.text,
        'gender': selectedGender,
        'governorate': governorates,
        'user_id': userCredential.user!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      showCustomSnackBar(context, "'تم إرسال التقرير بنجاح!'");

      _resetFields();
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _containValidator() {
    if (!_formKey.currentState!.validate()&&currentStep==0) {
      // إذا لم يتم ملء الحقول بشكل صحيح
      showCustomSnackBar(context, "الرجاء ملئ جميع الحقول بيانات مقدم التقرير");
      return;
    } else if (!_formKey1.currentState!.validate()&&currentStep==1) {
      showCustomSnackBar(context, "الرجاء ملئ جميع الحقول المستحضر الطبي المشتبه به");
      return;
    }
    setState(() => currentStep += 1);
  }

  void _cancelValidator() {
    setState(() => currentStep -= 1);
  }

  void _resetFields() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    ageController.clear();
    weightController.clear();
    phoneNumberController.clear();
    medicamentNameController.clear();
    batchNumberController.clear();
    theFocusController.clear();
    reasonForUsingTheMedicineController.clear();
    startDateController.clear();
    endDateController.clear();
    descriptionEffect.clear();
    setState(() {
      selectedGender = null;
      governorates = null;
      selectedReportSubmitter=null;
      theActionTaken=null;
      similarReaction=null;
      symptomsAppearOfAnyDevice=null;
      thePatientConditionNow=null;
      chronicDiseases=null;
      takingMedicationChronically=null;
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LogInScreen(),));
  }

  void _handleFirebaseAuthError(FirebaseAuthException e) {
    String errorMessage = 'حدث خطأ، الرجاء المحاولة مرة أخرى';
    switch (e.code) {
      case 'weak-password':
        errorMessage = 'الباسورد ضعيف';
        break;
      case 'email-already-in-use':
        errorMessage = 'تم استخدام هذا الايميل من قبل';
        break;
      case 'invalid-email':
        errorMessage = 'الايميل غير صحيح';
        break;
      default:
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        errorMessage,
        //textDirection: TextDirection.rtl,
      ),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('إرسال تقرير')),
      body: isComplete
          ? Container()
          : Align(
              alignment: Alignment.topLeft,
              child: Stepper(
                // type: StepperType.horizontal,
                steps: steps(context),
                currentStep: currentStep,
                onStepContinue: () {
                  if (isLastStep) {
                    setState(() {
                      _isLoading = true;
                    });
                  } else {
                    _containValidator();
                  }
                },
                onStepCancel: () {
                  if (isFirstStep) {
                  } else {
                    _cancelValidator();
                  }
                },
              //  onStepTapped: (step) => setState(() => currentStep = step),
                controlsBuilder: (context, details) => Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: details.onStepContinue,
                            child: Text(isLastStep ? 'Confirm' : 'Next')),
                      ),
                      if (!isFirstStep) ...[
                        SizedBox(width: myWidth * .1),
                        Expanded(
                          child: ElevatedButton(
                              onPressed:
                                  isFirstStep ? null : details.onStepCancel,
                              child: Text('Back')),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  List<Step> steps(context) => [
        Step(
          state: currentStep > 0 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 0,
          title: Text('بيانات مقدم التقرير'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CustomTextField(
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  hint: 'البريد الإلكتروني',
                  controller: emailController,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'الرجاء إدخال بريد إلكتروني صالح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  prefixIcon: const Icon(Icons.lock_outline),
                  hint: 'كلمة المرور',
                  controller: passwordController,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'كلمة المرور يجب أن تكون أطول من 6 أحرف';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hint: 'الاسم',
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  keyboardType: TextInputType.number,
                  hint: 'العمر',
                  controller: ageController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال العمر';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // إضافة CustomDropdownButton لاختيار الجنس
                CustomDropdownButton(
                  label: "النوع",
                  hint: "اختر النوع",
                  items: DropdownItems.genders,
                  selectedItem: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // إضافة CustomDropdownButton لاختيار مقدم التقرير
                CustomDropdownButton(
                  label: "مقدم التقرير",
                  hint: "مقدم التقرير ",
                  items: DropdownItems.reportSubmitter,
                  selectedItem: selectedReportSubmitter,
                  onChanged: (value) {
                    setState(() {
                      selectedReportSubmitter = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // إضافة CustomDropdownButton لاختيار المحافظة
                CustomDropdownButton(
                  label: "المحافظة",
                  hint: "اختر المحافظة",
                  items: DropdownItems.governorates,
                  selectedItem: governorates,
                  onChanged: (value) {
                    setState(() {
                      governorates = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                  hint: 'رقم التليفون',
                  controller: phoneNumberController,
                  validator: (value) {
                    if (value == null || value.isEmpty&& value!=11) {
                      return 'الرجاء رقم التليفون';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  keyboardType: TextInputType.number,
                  hint: 'الوزن',
                  controller: weightController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الوزن';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        Step(
          state: currentStep > 1 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 1,
          title: Text('المستحضر الطبي المشتبه به'),
          content: Form(
            key: _formKey1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CustomTextField(
                  prefixIcon: const Icon(Icons.medical_services_outlined),
                  keyboardType: TextInputType.text,
                  hint: 'اسم الدواء',
                  controller: medicamentNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم الدواء';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [

                    photo == null
                        ? InkWell(
                      onTap: () => getImage(),
                      child: Container(
                        margin: EdgeInsets.all(8),
                        height: MediaQuery.of(context).size.height * .1,
                        width: MediaQuery.of(context).size.width * .25,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.grey.shade300),
                        child: Icon(Icons.add),
                      ),
                    )
                        : Row(
                      children: [
                        Container(
                          margin: EdgeInsets.all(8),
                          height:MediaQuery.of(context).size.height * .1,
                          width: MediaQuery.of(context).size.width * .25,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.grey.shade300,
                              image: DecorationImage(
                                  image: FileImage(photo!))),
                        ),
                        IconButton(onPressed: () =>deleteImage() , icon: Icon(Icons.delete,color: Colors.red,))
                      ],
                    ),

                    Text('اختار صوره')
                  ],
                ),
                CustomTextField(
                  prefixIcon: const Icon(Icons.numbers),
                  hint: 'رقم التشغيله',
                  controller: batchNumberController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم التشغيله';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hint: 'التركيز',
                  keyboardType: TextInputType.number,
                  controller: theFocusController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال التركيز';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  onTap: () {
                    showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.parse('2000-01-01'),
                            lastDate: DateTime.now())
                        .then((value) => startDateController.text =
                            DateFormat.yMMMd().format(value!));
                  },
                  controller: startDateController,
                  decoration: InputDecoration(
                    label: const Text('تاريخ بدء اﻻستخدام'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'الرجاء ادخال تاريخ بدء اﻻستخدام';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  onTap: () {
                    showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            lastDate: DateTime.now(),
                            firstDate: DateTime.parse('2000-01-01'))
                        .then((value) => endDateController.text =
                            DateFormat.yMMMd().format(value!));
                  },
                  controller: endDateController,
                  decoration: InputDecoration(
                    label: const Text('تاريخ وقف اﻻستخدام'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'الرجاء ادخال تاريخ وقف اﻻستخدام';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // إضافة CustomDropdownButton لاختيار الجنس
                CustomDropdownButton(
                  label: "اﻻلجراء الذي تم اتخازه",
                  hint: "اﻻلجراء الذي تم اتخازه",
                  items: DropdownItems.theActionTaken,
                  selectedItem: theActionTaken,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // إضافة CustomDropdownButton لاختيار المحافظة todo
                CustomTextField(
                  keyboardType: TextInputType.text,
                  hint: 'سبب استخدام الدواء',
                  controller: reasonForUsingTheMedicineController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال سبب استخدام الدواء';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomDropdownButton(
                  label: "هل تسبب الدواء برد فعل مماثل من قبل",
                  hint: "هل تسبب الدواء برد فعل مماثل من قبل",
                  items: DropdownItems.trueOrFalse,
                  selectedItem: similarReaction,
                  onChanged: (value) {
                    setState(() {
                      governorates = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        Step(
          state: currentStep > 2 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 2,
          title: Text('اﻻثار العكسيه المشتبه'),
          content: Form(
            key: _formKey2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CustomTextField(
                  prefixIcon: const Icon(Icons.medical_services_outlined),
                  keyboardType: TextInputType.text,
                  hint: 'وصف اﻻثر العكسي بشكل موجز',
                  controller: descriptionEffect,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم الدواء';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomDropdownButton(
                  label: "ظهور اﻻعراض في اي جهاز",
                  hint: "ظهور اﻻعراض في اي جهاز",
                  items: DropdownItems.symptomsAppear,
                  selectedItem: symptomsAppearOfAnyDevice,
                  onChanged: (value) {
                    setState(() {
                      symptomsAppearOfAnyDevice = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                CustomDropdownButton(
                  label: "حاله المريض اﻻن",
                  hint: "حاله المريض اﻻن",
                  items: DropdownItems.conditionNow,
                  selectedItem: thePatientConditionNow,
                  onChanged: (value) {
                    setState(() {
                      thePatientConditionNow = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                CustomDropdownButton(
                  label: "هل تعاني من امراض مزمنه",
                  hint: "هل تعاني من امراض مزمنه",
                  items: DropdownItems.chronicDiseasesList,
                  selectedItem: chronicDiseases,
                  onChanged: (value) {
                    setState(() {
                      chronicDiseases = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                CustomDropdownButton(
                  label: "هل تتناول دواء بشكل مزمن",
                  hint: "هل تتناول دواء بشكل مزمن",
                  items: DropdownItems.trueOrFalse,
                  selectedItem: takingMedicationChronically,
                  onChanged: (value) {
                    setState(() {
                      takingMedicationChronically = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ];
}

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:report/const/app_const.dart';
import 'package:report/screens/auth/log_in_screen.dart';
import 'package:report/screens/pages/show_report.dart';
import 'package:report/widget/custom_drop_down.dart';
import 'package:report/widget/custom_scafold_massage.dart';
import 'package:report/widget/custom_text_feild.dart';

import '../../widget/custom_show_data_picker.dart';

class SendReport extends StatefulWidget {
  const SendReport({super.key});

  @override
  _SendReportState createState() => _SendReportState();
}

class _SendReportState extends State<SendReport> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

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
  final TextEditingController medicamentNameController =
      TextEditingController();
  final TextEditingController batchNumberController = TextEditingController();
  File? batchNumberPhoto;
  final TextEditingController theFocusController = TextEditingController();
  final TextEditingController reasonForUsingTheMedicineController =
      TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  String? theActionTaken;
  String? similarReaction;

  //step 3  Description of the adverse effect
  final TextEditingController descriptionEffect = TextEditingController();
  final TextEditingController otherChronicDiseaseController =
      TextEditingController();
  final TextEditingController otherMedicinesController =
      TextEditingController();
  final TextEditingController commentController = TextEditingController();

  String? symptomsAppearOfAnyDevice;

  String? thePatientConditionNow;
  String? otherMedicines;

  String? chronicDiseases;

  String? takingMedicationChronically;

  int currentStep = 0;

  bool get isFirstStep => currentStep == 0;

  bool get isLastStep => currentStep == 2;

  bool isComplete = false;
  File? photo;
  bool _isLoading = false; // متغير لتتبع حالة الإرسال

  Future<void> _pickBatchNumberImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("اختر المصدر"),
        actions: <Widget>[
          TextButton(
            child: const Text("الكاميرا"),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          TextButton(
            child: const Text("المعرض"),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source != null) {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          batchNumberPhoto = File(pickedFile.path);
        });
        // هنا يمكنك تحميل الصورة إلى الخدمة السحابية وحفظ الرابط إذا لزم الأمر
      }
    }
  }

  Future getImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('المعرض'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('الكاميرا'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        photo = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName =
          'reports/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      print('Start uploading: $fileName'); // بدء عملية الرفع
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final result = await ref.putFile(imageFile);
      final imageUrl = await result.ref.getDownloadURL();
      print('Image URL: $imageUrl'); // طباعة رابط الصورة بعد الرفع
      return imageUrl; // هذا الرابط هو الذي ستحفظه في Firestore
    } catch (e) {
      print('Error uploading image: $e'); // طباعة الخطأ إذا حدث
      return null;
    }
  }

  deleteImage() {
    photo = null;
    setState(() {});
  }

  void _createUserAndSendReport() async {
    if (!_formKey.currentState!.validate() ||
        !_formKey1.currentState!.validate() ||
        !_formKey2.currentState!.validate()) {
      // إذا لم يتم ملء الحقول بشكل صحيح
      showCustomSnackBar(context, "الرجاء ملئ جميع الحقول");
      return;
    }

    setState(() {
      _isLoading = true; // بدء الإرسال وتفعيل مؤشر التحميل
    });
    String chronicDiseasesValue;
    if (chronicDiseases == "اخرى") {
      chronicDiseasesValue = otherChronicDiseaseController.text;
    } else {
      chronicDiseasesValue = chronicDiseases ?? "لم يتم الاختيار";
    }

    String? imageUrl;
    if (photo != null) {
      imageUrl = await uploadImage(photo!);
    }

    // استخدم batchNumberImageUrl إذا كانت هناك صورة محملة، وإلا استخدم النص المدخل
    String? batchNumberOrImageURL;
    if (batchNumberPhoto != null) {
      batchNumberOrImageURL =
          await uploadImage(batchNumberPhoto!); // رفع الصورة والحصول على الرابط
    } else {
      batchNumberOrImageURL =
          batchNumberController.text; // استخدام النص المدخل يدويًا
    }
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await FirebaseFirestore.instance.collection('reports').add({
        'user_id': userCredential.user!.uid,
        'name': nameController.text,
        'age': ageController.text,
        'weight': weightController.text,
        'gender': selectedGender,
        'governorate': governorates,
        'phone_number': phoneNumberController.text,
        'medicament_name': medicamentNameController.text,
        'batch_number': batchNumberOrImageURL,
        'the_focus': theFocusController.text,
        'reason_for_using': reasonForUsingTheMedicineController.text,
        'start_date': startDateController.text,
        'end_date': endDateController.text,
        'the_action_taken': theActionTaken,
        'similar_reaction': similarReaction,
        'description_effect': descriptionEffect.text,
        'symptoms_appear_of_any_device': symptomsAppearOfAnyDevice,
        'the_patient_condition_now': thePatientConditionNow,
        'taking_medication_chronically': takingMedicationChronically,
        'image_url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'chronic_diseases': chronicDiseasesValue,
        'other_medicines': otherMedicines != "نعم"
            ? otherMedicines
            : otherMedicinesController.text,
        'comment':
            commentController.text.isEmpty ? null : commentController.text,
      });

      showCustomSnackBar(context, "تم إرسال التقرير بنجاح!");
      _resetFields();
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } finally {
      setState(() {
        _isLoading = false; // إيقاف مؤشر التحميل بعد الانتهاء من الإرسال
      });
    }
  }

  void _containValidator() {
    if (!_formKey.currentState!.validate() && currentStep == 0) {
      showCustomSnackBar(context, "الرجاء ملئ جميع الحقول بيانات مقدم التقرير");
      return;
    } else if (!_formKey1.currentState!.validate() && currentStep == 1) {
      showCustomSnackBar(
          context, "الرجاء ملئ جميع الحقول المستحضر الطبي المشتبه به");
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
      selectedReportSubmitter = null;
      theActionTaken = null;
      similarReaction = null;
      symptomsAppearOfAnyDevice = null;
      thePatientConditionNow = null;
      chronicDiseases = null;
      takingMedicationChronically = null;
    });
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const ShowReport(),
      ),
      (route) => false,
    );
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('إرسال تقرير')),
      body: isComplete
          ? Container()
          : Directionality(
              textDirection: TextDirection.rtl,
              child: Stepper(
                // type: StepperType.horizontal,
                steps: steps(context),
                currentStep: currentStep,
                onStepContinue: () {
                  onStepContinue();
                },
                onStepCancel: () {
                  if (isFirstStep) {
                  } else {
                    _cancelValidator();
                  }
                },
                //  onStepTapped: (step) => setState(() => currentStep = step),
                controlsBuilder: (context, details) => Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: details.onStepContinue,
                            child: Text(isLastStep ? 'ارسال' : 'التالي')),
                      ),
                      if (!isFirstStep) ...[
                        SizedBox(width: myWidth * .1),
                        Expanded(
                          child: ElevatedButton(
                              onPressed:
                                  isFirstStep ? null : details.onStepCancel,
                              child: const Text('السابق')),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void onStepContinue() {
    bool isStepValid = false;

    if (currentStep == 0) {
      isStepValid = _formKey.currentState?.validate() ?? false;
    } else if (currentStep == 1) {
      isStepValid = _formKey1.currentState?.validate() ?? false;
    } else if (currentStep == 2) {
      isStepValid = _formKey2.currentState?.validate() ?? false;
      if (isStepValid) {
        _createUserAndSendReport();
        return;
      }
    }

    if (isStepValid && currentStep < steps(context).length - 1) {
      setState(() => currentStep += 1);
    } else if (!isStepValid) {
      showCustomSnackBar(context, "الرجاء التحقق من البيانات المدخلة.");
    }
  }

  List<Step> steps(context) => [
        Step(
          state: currentStep > 0 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 0,
          title: const Text('بيانات مقدم التقرير'),
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
                    if (value == null || value.isEmpty && value != 11) {
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
          title: const Text('المستحضر الطبي المشتبه به'),
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
                    const Text('اختار صوره'),
                    photo == null
                        ? InkWell(
                            onTap: () => getImage(),
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              height: MediaQuery.of(context).size.height * .05,
                              width: MediaQuery.of(context).size.width * .25,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: Colors.grey.shade300),
                              child: const Icon(Icons.add),
                            ),
                          )
                        : Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(8),
                                height: MediaQuery.of(context).size.height * .1,
                                width: MediaQuery.of(context).size.width * .25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: Colors.grey.shade300,
                                  image:
                                      DecorationImage(image: FileImage(photo!)),
                                ),
                              ),
                              IconButton(
                                onPressed: () => deleteImage(),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                        keyboardType: TextInputType.number,
                        controller: batchNumberController,
                        hint: "رقم التشغيله",
                        validator: (value) {
                          if ((value == null || value.isEmpty) &&
                              batchNumberPhoto == null) {
                            return 'يرجى إدخال رقم التشغيلة أو اختيار صورة';
                          }
                          return null;
                        }),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('أو اختر صورة لرقم التشغيلة:'),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: _pickBatchNumberImage,
                        ),
                      ],
                    ),
                    if (batchNumberPhoto != null)
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(8),
                            height: MediaQuery.of(context).size.height * .1,
                            width: MediaQuery.of(context).size.width * .25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.grey.shade300,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(batchNumberPhoto!),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                batchNumberPhoto = null;
                              });
                            },
                          ),
                        ],
                      ),
                  ],
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
                ShowDataPicker(
                  dateController: startDateController,
                  text: 'تاريخ بدء اﻻستخدام',
                ),
                const SizedBox(height: 20),
                ShowDataPicker(
                  dateController: endDateController,
                  text: 'تاريخ وقف اﻻستخدام',
                ),
                const SizedBox(height: 20),
                CustomDropdownButton(
                  label: "الاجراء الذي تم اتخازه",
                  hint: "الاجراء الذي تم اتخازه",
                  items: DropdownItems.theActionTaken,
                  selectedItem: theActionTaken,
                  onChanged: (value) {
                    setState(() {
                      theActionTaken = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
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
                      similarReaction = value;
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
          title: const Text('اﻻثار العكسيه المشتبه'),
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
                  label: "الادويه الاخري",
                  hint: "هل تتناول ادويه اخري مع هذا الدواء؟",
                  items: DropdownItems.trueOrFalse,
                  selectedItem: otherMedicines,
                  onChanged: (value) {
                    setState(() {
                      otherMedicines = value;
                    });
                  },
                ),
                if (otherMedicines == "نعم")
                  CustomTextField(
                    hint: 'ما هو الدواء',
                    controller: otherMedicinesController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '';
                      }
                      return null;
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
                if (chronicDiseases == "اخرى")
                  CustomTextField(
                    hint: 'يرجى تحديد',
                    controller: otherChronicDiseaseController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء تحديد الحالة المزمنة';
                      }
                      return null;
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
                const SizedBox(height: 20),
                CustomTextField(
                  hint: 'أضف تعليقك هنا (اختياري)',
                  controller: commentController,
                  validator: (value) {
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ];
}

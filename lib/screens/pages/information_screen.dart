import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:report/screens/auth/report_and_sign_in.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SizedBox(
        height: myHeight,
        width: myWidth,
        // color: Colors.red,
        // margin: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Image.asset(
              'assets/images/logo.jpg',
              width: myWidth * .8,
            ),
            SizedBox(height: myHeight * .05),
            const Text(
              'الإبلاغ عن الآثار الجانبية للمستحضرات والمستلزمات الطبية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
            const SizedBox(
              height: 18,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(19)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'وصف الخدمة --',
                    style: TextStyle(color: Colors.deepOrange, fontSize: 22),
                    textAlign: TextAlign.end,
                  ),
                  Text(
                    'تتيح هذه الخدمة للمواطن إمكانية الإبلاغ عن الآثار الجانبية للأدوية أو المستحضرات الحيوية واللقاحات أو مستحضرات التجميل أو المستلزمات الطبية؛ حيث يقوم فريق مختص من هيئة الدواء متمثلاً في مركز اليقظة الصيدلية المصري التابع للإدارة المركزية للرعاية الصيدلية بتقييم ومتابعة الحالات، ومن ثم اتخاذ الإجراءات الرقابية اللازمة من أجل ضمان مأمونية المستحضرات والمستلزمات الطبية للمريض المصرى.',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.end,
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
                width: MediaQuery.of(context).size.width * .4,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SendReport(),
                          ));
                    },
                    child: const Text('Start')))
          ],
        ),
      ),
    );
  }
}

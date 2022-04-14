import 'dart:developer';
import 'firebase_options.dart';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Ui/HomeScreen.dart';

import 'config.dart';

void main() async {
  log("CONFIG: {apiHost: ${Config.instance.apiHost}, ANDROID_CHANNEL: ${ANDROID_CHANNEL}}");

  await GetStorage.init();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          title: 'Cartoonizer',
          home: MyHomePage(title: 'Cartoonizer'),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: HomeScreen(),
      ),
    );
  }
}

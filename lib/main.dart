import 'dart:developer';
import 'firebase_options.dart';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Ui/HomeScreen.dart';

import 'config.dart';

void main() async {
  log(Config.instance.apiHost);
  await GetStorage.init();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    systemNavigationBarColor: ColorConstant.PrimaryColor,
    statusBarColor: ColorConstant.PrimaryColor,
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
          theme: ThemeData(
            accentColor: ColorConstant.PrimaryColor,
          ),
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
  void initState() {
    // Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //       settings: RouteSettings(name: "/HomeScreen"),
    //       builder: (context) => HomeScreen(),
    //     ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: HomeScreen(),
      ),
    );
  }
}

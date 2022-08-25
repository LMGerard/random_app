import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_app/ad_state.dart';
import 'custom_icons/custom_icons.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'tabs/numbersTab.dart';
import 'tabs/dicesTab.dart';
import 'tabs/listTab.dart';
import 'tabs/cardsTab.dart';
import 'tabs/8ballTab.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initFuture = MobileAds.instance.initialize();
  final adState = AdState(initFuture);
  await GetStorage.init('listTab');
  await GetStorage.init('cardsTab');
  runApp(Provider.value(value: adState, builder: (context, child) => MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentTab = 0;
  BannerAd? banner;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adState = Provider.of<AdState>(context);
    adState.initialization.then((value) {
      setState(() {
        banner = BannerAd(
            size: AdSize.banner,
            adUnitId: adState.bannerAdUnitId,
            request: AdRequest(),
            listener: adState.adListener)
          ..load();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Randomize',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              onTap: (tabIndex) {
                if (tabIndex == currentTab) return;
                FocusScope.of(context).requestFocus(FocusNode());
                currentTab = tabIndex;
              },
              tabs: [
                Tab(icon: Icon(Icons.looks_one)),
                Tab(icon: Icon(Icons.format_list_bulleted)), 
                Tab(icon: Icon(CustomIcons.dice)),
                Tab(icon: Icon(CustomIcons.spades)),
                Tab(icon: Icon(Icons.sports_volleyball))
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  children: [
                    NumbersTab(
                      title: 'Randomize',
                    ),
                    ListTab(),
                    DicesTab(),
                    CardsTab(),
                    EightBallTab()
                  ],
                ),
              ),
              SizedBox(height: 10),
              if (banner == null)
                SizedBox(height: 50)
              else
                Container(height: 50, child: AdWidget(ad: banner!))
            ],
          ),
        ),
      ),
    );
  }
}

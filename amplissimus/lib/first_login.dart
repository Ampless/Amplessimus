import 'package:Amplissimus/main.dart';
import 'package:Amplissimus/values.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class FirstLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        builder: (context, child) {
          return ScrollConfiguration(behavior: MyBehavior(), child: child);
        },
        title: AmpStrings.appTitle,
        theme: ThemeData(
          primarySwatch: AmpColors.primaryBlack,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FirstLoginScreenPage(title: AmpStrings.appTitle, textStyle: TextStyle(
          color: AmpColors.colorForeground, 
          fontSize: 25,
        ),),
      ), 
      onWillPop: () async {
        return new Future(() => false);
      }
    );
  }
}
class FirstLoginScreenPage extends StatefulWidget {
  FirstLoginScreenPage({this.title, this.textStyle});
  final String title;
  final TextStyle textStyle;
  @override
  State<StatefulWidget> createState() {return FirstLoginScreenPageState();}
}
class FirstLoginScreenPageState extends State<FirstLoginScreenPage> with SingleTickerProviderStateMixin {
  TabController tabController;
  String darkAnimName = 'introDark';
  String brightAnimName = 'introBright';

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: tabController,
        children: <Widget> [
          Stack(children: <Widget>[
            Column(children: <Widget>[
              Container(color: AmpColors.blankBlack,),
              Container(color: AmpColors.blankWhite,),
            ]),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: Text('Thema wählen', style: TextStyle(fontSize: 24, color: AmpColors.blankWhite),),
                centerTitle: true,
              ),
              body: Center(child: Column(children: <Widget>[
                  Flexible(child: InkWell(child: FlareActor(
                    'assets/anims/white_dark_mode_select.flr',
                    fit: BoxFit.contain,
                    animation: darkAnimName,
                    callback: (value) {
                      if(value == 'idleDark2') setState(() => darkAnimName = 'idleDark');
                      else if(value == 'idleDark') setState(() => darkAnimName = 'idleDark2');
                      else setState(() => darkAnimName = 'idleDark');
                    },
                  ), onTap: () {},),),
                  Flexible(child: FlareActor(
                    'assets/anims/white_dark_mode_select.flr',
                    fit: BoxFit.contain,
                    animation: brightAnimName,
                    callback: (value) {
                      if(value == 'idleBright2') setState(() => brightAnimName = 'idleBright');
                      else if(value == 'idleBright') setState(() => brightAnimName = 'idleBright2');
                      else setState(() => brightAnimName = 'idleBright');
                    },
                  ),),
                ]
              )),
            ),
          ],),
          Stack(children: <Widget>[
            AnimatedContainer(duration: Duration(milliseconds: 150), color: AmpColors.colorBackground,),
            Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: Text('${AmpStrings.appTitle}', style: TextStyle(fontSize: 24, color: AmpColors.colorForeground),),
                centerTitle: true,
              ),
            ),
          ],),
          Stack(children: <Widget>[
            AnimatedContainer(duration: Duration(milliseconds: 150), color: AmpColors.colorBackground,),
            Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: Text('${AmpStrings.appTitle}', style: TextStyle(fontSize: 30, color: AmpColors.colorForeground),),
                centerTitle: true,
              ),
            ),
          ],),
          Stack(children: <Widget>[
            AnimatedContainer(duration: Duration(milliseconds: 150), color: AmpColors.colorBackground,),
            Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                centerTitle: true,
              ),
            ),
          ],),
        ]
      )
    );
  }

}
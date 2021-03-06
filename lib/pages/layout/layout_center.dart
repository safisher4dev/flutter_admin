import 'package:cry/cry_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin/common/routes.dart';
import 'package:flutter_admin/enum/MenuDisplayType.dart';
import 'package:flutter_admin/models/tab_page.dart';
import 'package:flutter_admin/pages/common/keep_alive_wrapper.dart';
import 'package:flutter_admin/pages/layout/layout_controller.dart';
import 'package:flutter_admin/utils/utils.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart';

class LayoutCenter extends StatefulWidget {
  LayoutCenter({Key key, this.initPage}) : super(key: key);
  final TabPage initPage;

  @override
  LayoutCenterState createState() => LayoutCenterState();
}

class LayoutCenterState extends State<LayoutCenter> with TickerProviderStateMixin {
  Container content = Container();
  List<Widget> pages;
  LayoutController layoutController = Get.find();

  @override
  void initState() {
    if (widget.initPage != null) {
      WidgetsBinding.instance.addPostFrameCallback((c) {
        Utils.openTab(widget.initPage);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = layoutController.tabController;
    var openedTabPageList = layoutController.openedTabPageList;
    var length = openedTabPageList.length;
    if (length == 0) {
      return Container();
    }
    int index = openedTabPageList.indexWhere((note) => note.id == layoutController.currentOpenedTabPageId);
    pages = openedTabPageList.map((TabPage tabPage) {
      var page = tabPage.url != null ? layoutRoutesData[tabPage.url] ?? Container() : tabPage.widget ?? Container();
      return KeepAliveWrapper(child: page);
    }).toList();

    int tabIndex = tabController?.index ?? 0;
    int initialIndex = tabIndex > length - 1 ? length - 1 : tabIndex;
    tabController?.dispose();
    tabController = TabController(vsync: this, length: pages.length, initialIndex: initialIndex);
    layoutController.tabController = tabController;
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        layoutController.updateCurrentOpendMenuId(openedTabPageList[tabController.index].id);
      }
    });

    TabBar tabBar = TabBar(
      controller: tabController,
      isScrollable: true,
      indicator: const UnderlineTabIndicator(),
      tabs: openedTabPageList.map<Tab>((TabPage tabPage) {
        var tabContent = Row(
          children: <Widget>[
            Text(Utils.isLocalEn(context) ? tabPage.nameEn ?? '' : tabPage.name ?? ''),
            SizedBox(width: 3),
            InkWell(
              child: Icon(Icons.close, size: 10),
              onTap: () => Utils.closeTab(tabPage),
            ),
          ],
        );
        return Tab(
          child: CryMenu(
            child: tabContent,
            onSelected: (v) {
              switch (v) {
                case TabMenuOption.closeAll:
                  Utils.closeAllTab();
                  break;
                case TabMenuOption.closeOthers:
                  Utils.closeOtherTab(tabPage);
                  break;
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<TabMenuOption>>[
              PopupMenuItem(
                value: TabMenuOption.closeAll,
                child: ListTile(
                  title: Text('Close All'),
                ),
              ),
              PopupMenuItem(
                value: TabMenuOption.closeOthers,
                child: ListTile(
                  title: Text('Close Others'),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );

    content = Container(
      child: Expanded(
        child: TabBarView(
          controller: tabController,
          children: pages,
        ),
      ),
    );

    tabController.animateTo(index);
    var result = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: tabBar,
                  decoration: BoxDecoration(
                    color: context.theme.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        offset: Offset(2.0, 2.0),
                        blurRadius: 4.0,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          content,
        ],
      ),
    );
    return result;
  }
}

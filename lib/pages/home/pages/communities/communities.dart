import 'dart:async';
import 'package:Okuna/models/categories_list.dart';
import 'package:Okuna/models/category.dart';
import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/pages/home/lib/poppable_page_controller.dart';
import 'package:Okuna/pages/home/pages/communities/widgets/category_tab.dart';
import 'package:Okuna/pages/home/pages/communities/widgets/my_communities/my_communities.dart';
import 'package:Okuna/pages/home/pages/communities/widgets/trending_communities.dart';
import 'package:Okuna/pages/home/pages/communities/widgets/user_avatar_tab.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/modal_service.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/theme.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/alerts/button_alert.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/icon_button.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/tabs/image_tab.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pigment/pigment.dart';

class OBMainCommunitiesPage extends StatefulWidget {
  final OBCommunitiesPageController? controller;

  const OBMainCommunitiesPage({Key? key, this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OBMainCommunitiesPageState();
  }
}

class OBMainCommunitiesPageState extends State<OBMainCommunitiesPage>
    with TickerProviderStateMixin {
  late UserService _userService;
  late ToastService _toastService;
  late ThemeService _themeService;
  late LocalizationService _localizationService;
  late ThemeValueParserService _themeValueParserService;
  late ModalService _modalService;
  late NavigationService _navigationService;

  late List<Category> _categories;
  TabController? _tabController;

  late ScrollController _myCommunitiesScrollController;
  late ScrollController _allTrendingCommnunitiesScrollController;

  late List<ScrollController> _categoriesScrollControllers;

  late bool _needsBootstrap;

  late bool _refreshInProgress;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null)
      widget.controller!.attach(context: context, state: this);
    _needsBootstrap = true;
    _refreshInProgress = false;
    _categories = [];
    _categoriesScrollControllers = [];
    _tabController = _makeTabController();
    _myCommunitiesScrollController = ScrollController();
    _allTrendingCommnunitiesScrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _toastService = openbookProvider.toastService;
      _themeService = openbookProvider.themeService;
      _themeValueParserService = openbookProvider.themeValueParserService;
      _modalService = openbookProvider.modalService;
      _localizationService = openbookProvider.localizationService;
      _navigationService = openbookProvider.navigationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return CupertinoPageScaffold(
        navigationBar: OBThemedNavigationBar(
            title: _localizationService.community__communities_title,
            trailing: OBIconButton(
              OBIcons.add,
              themeColor: OBIconThemeColor.primaryAccent,
              onPressed: _onWantsToCreateCommunity,
            )),
        child: OBPrimaryColorContainer(
            child: _categories.isEmpty && !_refreshInProgress
                ? _buildNoCommunities()
                : _buildCommunities()));
  }

  Widget _buildNoCommunities() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OBButtonAlert(
          text: _localizationService.community__communities_no_category_found,
          onPressed: _refreshCategories,
          buttonText: _localizationService.community__communities_refresh_text,
          buttonIcon: OBIcons.refresh,
          assetImage: 'assets/images/stickers/perplexed-owl.png',
          isLoading: _refreshInProgress,
        )
      ],
    );
  }

  Widget _buildCommunities() {
    return Column(
      children: <Widget>[
        _buildTabBar(),
        Expanded(
          child: TabBarView(
              controller: _tabController,
              children: _buildTabBarViews()),
        )
      ],
    );
  }

  Widget _buildTabBar() {
    OBTheme theme = _themeService.getActiveTheme();

    Gradient themeGradient =
        _themeValueParserService.parseGradient(theme.primaryAccentColor);

    Color tabIndicatorColor = themeGradient.colors[0];

    Color tabLabelColor =
        _themeValueParserService.parseColor(theme.primaryTextColor);

    return TabBar(
      controller: _tabController,
      tabs: _buildTabs(),
      labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      isScrollable: true,
      indicatorColor: tabIndicatorColor,
      labelColor: tabLabelColor,
    );
  }

  List<Widget> _buildTabs() {
    User loggedInUser = _userService.getLoggedInUser()!;

    List<Widget> tabs = [
      OBUserAvatarTab(
        user: loggedInUser,
      ),
      OBImageTab(
        text: _localizationService.community__communities_all_text,
        color: Pigment.fromString('#2d2d2d'),
        textColor: Pigment.fromString('#ffffff'),
        imageProvider:
            const AssetImage('assets/images/categories/category_all-min.png'),
      ),
    ];

    List<Widget> categoriesTabs = _categories.map((Category category) {
      return OBCategoryTab(
        category: category,
      );
    }).toList();

    tabs.addAll(categoriesTabs);

    return tabs;
  }

  List<Widget> _buildTabBarViews() {
    List<Widget> tabBarViews = [
      OBMyCommunities(
        scrollController: _myCommunitiesScrollController,
      ),
      OBTrendingCommunities(
        scrollController: _allTrendingCommnunitiesScrollController,
      )
    ];

    _categoriesScrollControllers = [];

    List<Widget> categoriesTabBarViews = _categories.map((Category category) {
      ScrollController scrollController = ScrollController();
      _categoriesScrollControllers.add(scrollController);
      return OBTrendingCommunities(
        category: category,
        scrollController: scrollController,
      );
    }).toList();

    tabBarViews.addAll(categoriesTabBarViews);
    return tabBarViews;
  }

  void _bootstrap() {
    _refreshCategories();
  }

  Future<void> _refreshCategories() async {
    _setRefreshInProgress(true);
    try {
      CategoriesList categoriesList = await _userService.getCategories();
      _setCategories(categoriesList.categories ?? []);
    } catch (error) {
      _onError(error);
    } finally {
      _setRefreshInProgress(false);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.error__unknown_error, context: context);
    } else {
      _toastService.error(message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setCategories(List<Category> categories) {
    setState(() {
      _categories = categories;
      _tabController = _makeTabController();
    });
  }

  void scrollToTop() {
    int currentIndex = _tabController!.index;
    ScrollController currentTabScrollController;

    if (currentIndex == 0) {
      currentTabScrollController = _myCommunitiesScrollController;
    } else if (currentIndex == 1) {
      currentTabScrollController = _allTrendingCommnunitiesScrollController;
    } else {
      // It's a category scroll controller
      currentTabScrollController =
          _categoriesScrollControllers[currentIndex - 2];
    }

    if (currentTabScrollController.hasClients) {
      currentTabScrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  TabController _makeTabController() {
    int initialIndex = _tabController != null ? _tabController!.index : 0;

    TabController controller = TabController(
        length: _categories.length + 2,
        vsync: this,
        initialIndex: initialIndex);
    return controller;
  }

  void _onWantsToCreateCommunity() async {
    Community? createdCommunity =
        await _modalService.openCreateCommunity(context: context);
    if (createdCommunity != null) {
      _navigationService.navigateToCommunity(
          community: createdCommunity, context: context);
    }
  }

  void _setRefreshInProgress(bool refreshInProgress) {
    setState(() {
      _refreshInProgress = refreshInProgress;
    });
  }
}

class OBCommunitiesPageController extends PoppablePageController {
  OBMainCommunitiesPageState? _state;

  void attach(
      {required BuildContext context, OBMainCommunitiesPageState? state}) {
    super.attach(context: context);
    _state = state;
  }

  void scrollToTop() {
    _state?.scrollToTop();
  }
}

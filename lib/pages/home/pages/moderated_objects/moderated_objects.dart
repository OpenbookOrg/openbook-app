import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/moderation/moderated_object.dart';
import 'package:Okuna/models/moderation/moderated_object_list.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/widgets/moderated_object/moderated_object.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/widgets/no_moderated_objects.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/modal_service.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/badges/badge.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/icon_button.dart';
import 'package:Okuna/widgets/load_more.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/tiles/loading_indicator_tile.dart';
import 'package:Okuna/widgets/tiles/retry_tile.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBModeratedObjectsPage extends StatefulWidget {
  final Community? community;

  const OBModeratedObjectsPage({Key? key, this.community}) : super(key: key);

  @override
  OBModeratedObjectsPageState createState() {
    return OBModeratedObjectsPageState();
  }
}

class OBModeratedObjectsPageState extends State<OBModeratedObjectsPage> {
  static int itemsLoadMoreCount = 10;

  late OBModeratedObjectsPageController _controller;

  Community? _community;
  late OBModeratedObjectsFilters _filters;
  late ScrollController _scrollController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late List<ModeratedObject> _moderatedObjects;

  late UserService _userService;
  late ToastService _toastService;
  late ModalService _modalService;
  late LocalizationService _localizationService;

  CancelableOperation? _loadMoreOperation;
  CancelableOperation? _refreshModeratedObjectsOperation;

  late bool _needsBootstrap;
  late bool _moreModeratedObjectsToLoad;
  late bool _refreshModeratedObjectsInProgress;

  @override
  void initState() {
    super.initState();
    _community = widget.community;
    _filters = OBModeratedObjectsFilters.makeDefault(
        isGlobalModeration: widget.community == null);
    _controller = OBModeratedObjectsPageController(state: this);
    _scrollController = ScrollController();
    _moderatedObjects = [];
    _needsBootstrap = true;
    _moreModeratedObjectsToLoad = true;
    _refreshModeratedObjectsInProgress = true;
  }

  @override
  void dispose() {
    super.dispose();
    if (_loadMoreOperation != null) _loadMoreOperation!.cancel();
    if (_refreshModeratedObjectsOperation != null)
      _refreshModeratedObjectsOperation!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _toastService = openbookProvider.toastService;
      _modalService = openbookProvider.modalService;
      _localizationService = openbookProvider.localizationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return CupertinoPageScaffold(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        navigationBar: OBThemedNavigationBar(
          title: widget.community != null
              ? _localizationService.moderation__community_moderated_objects
              : _localizationService.moderation__globally_moderated_objects,
          trailing: _buildFiltersButton(),
        ),
        child: OBPrimaryColorContainer(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                    key: _refreshIndicatorKey,
                    child: LoadMore(
                        whenEmptyLoad: false,
                        isFinish: !_moreModeratedObjectsToLoad,
                        delegate: OBModeratedObjectsPageLoadMoreDelegate(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(0),
                          itemCount: _moderatedObjects.length + 1,
                          itemBuilder: _buildModeratedObject,
                        ),
                        onLoadMore: _loadMoreModeratedObjects),
                    onRefresh: _refreshModeratedObjects),
              )
            ],
          ),
        ));
  }

  Widget _buildModeratedObject(BuildContext context, int index) {
    if (index == 0) {
      Widget moderatedObjectItem;

      if (_moderatedObjects.isEmpty && !_refreshModeratedObjectsInProgress) {
        moderatedObjectItem = OBNoModeratedObjects(
          onWantsToRefreshModeratedObjects: _refresh,
        );
      } else {
        moderatedObjectItem = const SizedBox(
          height: 20,
        );
      }

      return moderatedObjectItem;
    }

    int moderatedObjectIndex = index - 1;

    var moderatedObject = _moderatedObjects[moderatedObjectIndex];

    return OBModeratedObject(
        moderatedObject: moderatedObject,
        community: widget.community,
        key: Key(moderatedObject.id.toString()));
  }

  Widget _buildFiltersButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OBBadge(
          count: _filters.count(),
        ),
        const SizedBox(
          width: 10,
        ),
        OBIconButton(
          OBIcons.filter,
          themeColor: OBIconThemeColor.primaryAccent,
          onPressed: _onWantsToOpenFilters,
        )
      ],
    );
  }

  void _onWantsToOpenFilters() {
    _modalService.openModeratedObjectsFilters(
        context: context, moderatedObjectsPageController: _controller);
  }

  void _bootstrap() {
    Future.delayed(Duration(milliseconds: 100), () {
      _refresh();
    });
  }

  Future<void>? setFilters(OBModeratedObjectsFilters filters) {
    _filters = filters;
    _refresh();
  }

  void scrollToTop() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset == 0) {
        _refresh();
      }

      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  Future<void> _refresh() async {
    _refreshIndicatorKey.currentState?.show();
  }

  Future<void> _refreshModeratedObjects() async {
    _setRefreshModeratedObjectsInProgress(true);
    try {
      if (widget.community == null) {
        _refreshModeratedObjectsOperation = CancelableOperation.fromFuture(
            _userService.getGlobalModeratedObjects(
                count: itemsLoadMoreCount,
                verified: _filters.onlyVerified,
                statuses: _filters.statuses,
                types: _filters.types));
      } else {
        _refreshModeratedObjectsOperation = CancelableOperation.fromFuture(
            _userService.getCommunityModeratedObjects(
                community: widget.community!,
                count: itemsLoadMoreCount,
                verified: _filters.onlyVerified,
                statuses: _filters.statuses,
                types: _filters.types));
      }

      ModeratedObjectsList moderatedObjectList =
          await _refreshModeratedObjectsOperation?.value;
      _setModeratedObjects(moderatedObjectList.moderatedObjects ?? []);
    } catch (error) {
      _onError(error);
    } finally {
      _setRefreshModeratedObjectsInProgress(false);
    }
  }

  Future<bool> _loadMoreModeratedObjects() async {
    if (_loadMoreOperation != null) _loadMoreOperation!.cancel();

    var lastModeratedObjectId;
    if (_moderatedObjects.isNotEmpty) {
      ModeratedObject lastModeratedObject = _moderatedObjects.last;
      lastModeratedObjectId = lastModeratedObject.id;
    }

    try {
      if (widget.community == null) {
        _loadMoreOperation = CancelableOperation.fromFuture(
            _userService.getGlobalModeratedObjects(
                maxId: lastModeratedObjectId,
                count: itemsLoadMoreCount,
                verified: _filters.onlyVerified,
                statuses: _filters.statuses,
                types: _filters.types));
      } else {
        _loadMoreOperation = CancelableOperation.fromFuture(
            _userService.getCommunityModeratedObjects(
                community: _community!,
                maxId: lastModeratedObjectId,
                count: itemsLoadMoreCount,
                verified: _filters.onlyVerified,
                statuses: _filters.statuses,
                types: _filters.types));
      }

      var moreModeratedObjects =
          (await _loadMoreOperation?.value).moderatedObjects;

      if (moreModeratedObjects.length == 0) {
        _setMoreModeratedObjectsToLoad(false);
      } else {
        setState(() {
          _moderatedObjects.addAll(moreModeratedObjects);
        });
      }
      return true;
    } catch (error) {
      _onError(error);
    } finally {
      _loadMoreOperation = null;
    }

    return false;
  }

  void _setMoreModeratedObjectsToLoad(bool moreModeratedObjectsToLoad) {
    setState(() {
      _moreModeratedObjectsToLoad = moreModeratedObjectsToLoad;
    });
  }

  void _setModeratedObjects(List<ModeratedObject> moderatedObjects) {
    setState(() {
      _moderatedObjects = moderatedObjects;
    });
  }

  void _setRefreshModeratedObjectsInProgress(
      bool refreshModeratedObjectsInProgress) {
    setState(() {
      _refreshModeratedObjectsInProgress = refreshModeratedObjectsInProgress;
    });
  }

  OBModeratedObjectsFilters getFilters() {
    return _filters.clone();
  }

  bool hasCommunity() {
    return _community != null;
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.error__unknown_error, context: context);
    } else {
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }
}

class OBModeratedObjectsFilters {
  final List<ModeratedObjectType> types;
  final List<ModeratedObjectStatus> statuses;
  final bool onlyVerified;

  static OBModeratedObjectsFilters makeDefault({required isGlobalModeration}) {
    List<ModeratedObjectType> filterTypes = [
      ModeratedObjectType.postComment,
      ModeratedObjectType.post,
    ];
    List<ModeratedObjectStatus> filterStatuses = [
      ModeratedObjectStatus.pending
    ];

    if (isGlobalModeration) {
      filterTypes.addAll([
        ModeratedObjectType.user,
        ModeratedObjectType.community,
        ModeratedObjectType.hashtag
      ]);
      filterStatuses.addAll(
          [ModeratedObjectStatus.approved, ModeratedObjectStatus.rejected]);
    }

    return OBModeratedObjectsFilters(
        statuses: filterStatuses, types: filterTypes, onlyVerified: false);
  }

  OBModeratedObjectsFilters(
      {required this.types,
      required this.statuses,
      required this.onlyVerified});

  OBModeratedObjectsFilters clone() {
    return OBModeratedObjectsFilters(
        types: types.toList(),
        statuses: statuses.toList(),
        onlyVerified: onlyVerified);
  }

  int count() {
    return statuses.length + types.length + (onlyVerified ? 1 : 0);
  }
}

class OBModeratedObjectsPageController {
  OBModeratedObjectsPageState? state;

  OBModeratedObjectsPageController({this.state});

  void attach({OBModeratedObjectsPageState? state}) {
    state = state;
  }

  Future<void>? setFilters(OBModeratedObjectsFilters filters) async {
    return state?.setFilters(filters);
  }

  OBModeratedObjectsFilters? getFilters() {
    return state?.getFilters();
  }

  void scrollToTop() {
    state?.scrollToTop();
  }

  bool hasCommunity() {
    return state?.hasCommunity() ?? false;
  }
}

class OBModeratedObjectsPageLoadMoreDelegate extends LoadMoreDelegate {
  final VoidCallback? onWantsToRetryLoading;

  const OBModeratedObjectsPageLoadMoreDelegate({this.onWantsToRetryLoading});

  @override
  Widget buildChild(LoadMoreStatus status,
      {LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.chinese}) {
    String text = builder(status);

    if (status == LoadMoreStatus.fail) {
      return OBRetryTile(
        text: 'Tap to retry loading items',
        onWantsToRetry: onWantsToRetryLoading ?? () {},
      );
    }
    if (status == LoadMoreStatus.idle) {
      // No clue why is this even a state.
      return const SizedBox();
    }
    if (status == LoadMoreStatus.loading) {
      return OBLoadingIndicatorTile();
    }
    if (status == LoadMoreStatus.nomore) {
      return const SizedBox();
    }

    return Text(text);
  }
}

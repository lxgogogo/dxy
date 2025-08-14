import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/services/collect_service.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/widget/scroll_to_top_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../model/collect_group_model.dart';
import '../../../model/collect_page_model.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/date_util.dart';
import '../../../utils/event_bus_util.dart';
import '../../../utils/net_request.dart';
import '../../../utils/dialog_util.dart';
import '../../../utils/track_utils.dart';
import '../../../widget/dialog_common.dart';
import '../../../widget/no_data.dart';
import 'mine_collect_item.dart';

class MineCollectView extends StatefulWidget {
  const MineCollectView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MineCollectViewState();
  }
}

class _MineCollectViewState extends State<MineCollectView>
    with SingleTickerProviderStateMixin {
  int pageNum = 1;
  int pageSize = 20;
  bool noMore = false;

  final ScrollController scrollController = ScrollController();

  bool _isMounted = false;
  bool _showFavorite = false;

  bool loaded = false;
  int _selectIndex = 0;

  List<CollectModel> collectList = [];
  List<CollectGroupModel> groupCollectList = [];
  final ScrollController _listController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final RefreshController _refreshController2 =
      RefreshController(initialRefresh: false);
  late final TabController tabController;

  StreamSubscription? eventSub1;
  StreamSubscription? eventSub2;
  StreamSubscription? eventSub3;
  StreamSubscription? eventSub4;

  // TODO: Private Method

  _reqListData({bool showLoading = true}) async {
    int recordsSize = 0;
    try {
      await NetRequest().userFavoriteList(pageNum, pageSize, '',
          showLoading: showLoading, (data) {
        CollectPageModel dataList = CollectPageModel.fromJson(data);
        recordsSize = (dataList.list ?? []).length;
        if (pageNum == 1) {
          collectList.clear();
        }
        collectList.addAll(dataList.list ?? []);
      });
      if (pageNum == 1) {
        _refreshController.refreshCompleted();
        if (recordsSize < pageSize) {
          noMore = true;
          _refreshController.loadNoData();
        } else {
          noMore = false;
          _refreshController.resetNoData();
        }
      } else {
        if (recordsSize < pageSize) {
          noMore = true;
          _refreshController.loadNoData();
        } else {
          noMore = false;
          _refreshController.loadComplete();
        }
      }
    } catch (e) {
      _refreshController.loadFailed();
    } finally {
      loaded = true;
      if (pageNum == 1) {
        if (_listController.hasClients) {
          _listController.jumpTo(0);
        }
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _requestGroupData() async {
    groupCollectList = await CollectService.categoryList();
    _refreshController2.refreshCompleted();
    _refreshController2.loadNoData();
    int favoriteCategory = UserStore.of.user?.userLevel?.favoriteCategory ?? 0;
    _showFavorite = favoriteCategory > groupCollectList.length ? true : false;
    if (favoriteCategory == -1) {
      _showFavorite = true;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _onRefresh() async {
    if (_selectIndex == 0) {
      pageNum = 1;
      _reqListData(showLoading: false);
    } else {
      _requestGroupData();
    }
  }

  void _onLoading() async {
    if (_selectIndex == 0) {
      if (noMore) {
        _refreshController.loadNoData();
        return;
      }
      pageNum++;
      _reqListData(showLoading: false);
    }
  }

  void _selectOnTap(int index) {
    _selectIndex = index;
    if (_selectIndex == 0) {
      if (collectList.isEmpty) {
        pageNum = 1;
        _reqListData(showLoading: false);
      } else {
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      if (groupCollectList.isEmpty) {
        _requestGroupData();
      } else {
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  // Todo: Life Cycle

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    _isMounted = true;
    _reqListData();
    _requestGroupData();

    eventSub1 = EventBusUtil.of.on<EventRefreshComments>().listen((event) {
      _onRefresh();
    });
    eventSub2 = EventBusUtil.of.on<EventLoginSuccess>().listen((event) {
      _onRefresh();
    });
    eventSub3 = EventBusUtil.of.on<EventRefreshName>().listen((event) {
      _requestGroupData();
    });
    eventSub4 = EventBusUtil.of.on<EventRefreshCollect>().listen((event) {
      int relId = event.id;
      collectList.removeWhere((item) => relId > 0 && item.relId == relId);
      if (_isMounted) {
        setState(() {});
      }
      _requestGroupData();
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    eventSub1?.cancel();
    eventSub2?.cancel();
    eventSub3?.cancel();
    eventSub4?.cancel();
    _listController.dispose(); // 释放资源
    tabController.dispose();
    _refreshController.dispose();
    _refreshController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 0.w, right: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: SizedBox(
                height: 40.w,
                child: TabBar(
                    controller: tabController,
                    tabs: ['全部收藏', '收藏分类'].map((e) => Tab(text: e)).toList(),
                    isScrollable: true,
                    indicator: null,
                    indicatorColor: Colors.transparent,
                    enableFeedback: false,
                    tabAlignment: TabAlignment.start,
                    overlayColor: WidgetStateProperty.resolveWith<Color>((_) {
                      return Colors.transparent;
                    }),
                    dividerHeight: 0,
                    labelStyle: TextStyle(
                      color: ColorStyle.c333333,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: TextStyle(
                      color: AppTheme.color_999999,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.normal,
                    ),
                    onTap: _selectOnTap),
              )),
              if (_showFavorite)
                GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.createCollect,
                        arguments: {'create': true})?.then((value) {
                      _requestGroupData();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(5.w),
                    color: Colors.transparent,
                    child: Image.asset(
                      Assets.images.iconCollectAdd.path,
                      width: 20.w,
                      height: 20.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                SizedBox(width: 30.w)
            ],
          ),
        ),
        SizedBox(height: 5.w),
        Expanded(
            child: TabBarView(
          controller: tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(2, (index) {
            if (index == 0) {
              return _buildCollectListWidget();
            } else {
              return _buildGroupWidget();
            }
          }),
        ))
      ],
    );
  }

  Widget _buildCollectListWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        return SlidableAutoCloseBehavior(
          child: SmartRefresher(
                  scrollController: scrollController,
                  enablePullDown: true,
                  enablePullUp: true,
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: loaded && collectList.isEmpty
                      ? const Center(child: NoDataView())
                      : ListView.builder(
                          itemBuilder: (c, i) {
                            return Slidable(
                                groupTag: '1-list',
                                key: ValueKey('${collectList[i].id}'),
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  extentRatio: 42 / maxWidth,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await showDialog(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (context) => CommonDialog(
                                            title: '删除收藏',
                                            content: '确定要删除这个收藏吗？',
                                            confirmText: '确认',
                                            onConfirm: () {
                                              Navigator.of(context).pop();
                                              NetRequest().favoriteDelete(
                                                  collectList[i].id, (data) {
                                                if (_isMounted) {
                                                  DialogUtil.showToast('删除成功');
                                                  collectList.removeAt(i);
                                                  setState(() {});
                                                  _requestGroupData();
                                                  TrackUtils.trackEvent(
                                                      userLogType: '113007');
                                                }
                                              });
                                            },
                                          ),
                                        );
                                      },
                                      child: SvgPicture.asset(
                                        'assets/svg/icon_delete.svg',
                                        width: 22,
                                        height: 22,
                                      ),
                                    ),
                                  ],
                                ),
                                child: MyCollectItem(item: collectList[i]));
                          },
                          itemCount: collectList.length))
              .scrollToTopWrapper(
            bottom: 30.w,
            scrollController,
          ),
        );
      },
    );
  }

  Widget _buildGroupWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SlidableAutoCloseBehavior(
          child: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  scrollController: _listController,
                  controller: _refreshController2,
                  onRefresh: _onRefresh,
                  child: loaded && groupCollectList.isEmpty
                      ? const Center(child: NoDataView(text: '暂无分类',))
                      : ListView.builder(
                          itemBuilder: (c, i) {
                            return _buildGroupItemWidget(i);
                          },
                          itemCount: groupCollectList.length))
              .scrollToTopWrapper(bottom: 30.w,_listController),
        );
      },
    );
  }

  Widget _buildGroupItemWidget(int index) {
    final model = groupCollectList[index];
    String dateStr = '';
    if (model.createdat != null) {
      dateStr = '${DateUtil.formatDateAlias3(
        model.createdat!.millisecondsSinceEpoch,
        hasHM: false,
      )}创建';
    }
    return GestureDetector(
        onTap: () {
          Get.toNamed(Routes.collectList,
              arguments: {'name': model.name ?? '', 'id': model.id ?? 0});
        },
        child: Container(
            margin:
                EdgeInsets.only(left: 16.w, right: 16.w, bottom: 7.w, top: 5.w),
            padding: EdgeInsets.symmetric(vertical: 16.w, horizontal: 12.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.w)),
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(0, 0),
                      color: '#0050FF'.hexColor.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 0),
                ],
                color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      model.name ?? '',
                      style: TextStyle(
                          fontSize: 16.w, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 26.w)
                  ],
                ),
                SizedBox(height: 10.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${model.count ?? 0}条内容',
                      style: TextStyle(
                          fontSize: 10.w,
                          color: ColorStyle.c333333.withOpacity(0.5)),
                    ),
                    Text(
                      dateStr,
                      style: TextStyle(
                          fontSize: 10.w,
                          color: ColorStyle.c333333.withOpacity(0.5)),
                    ),
                  ],
                )
              ],
            )));
  }
}

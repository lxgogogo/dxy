import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../model/collect_page_model.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/event_bus_util.dart';
import '../../../utils/net_request.dart';
import '../../../utils/toast_utils.dart';
import '../../../widget/common_tab_widget.dart';
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

class _MineCollectViewState extends State<MineCollectView> {
  int pageNum = 1;
  int pageSize = 20;
  bool noMore = false;
  bool _isMounted = false;

  bool loaded = false;
  int _selectIndex = 0;

  List<CollectModel> collectList = [];
  final ScrollController _listController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  StreamSubscription? eventSub1;
  StreamSubscription? eventSub2;

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
      setState(() {});
    }
  }

  void _onRefresh() async {
    pageNum = 1;
    _reqListData(showLoading: false);
  }

  void _onLoading() async {
    if (noMore) {
      _refreshController.loadNoData();
      return;
    }
    pageNum++;
    _reqListData(showLoading: false);
  }

  void _selectOnTap(int index) {
    _selectIndex = index;
    if (mounted) {
      setState(() {});
    }
  }

  // Todo: Life Cycle

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _reqListData();

    eventSub1 = EventBusUtil.of.on<EventRefreshPage>().listen((event) {
      _onRefresh();
    });
    eventSub2 = EventBusUtil.of.on<EventLoginSuccess>().listen((event) {
      _onRefresh();
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    eventSub1?.cancel();
    eventSub2?.cancel();
    _listController.dispose(); // 释放资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 12.w, right: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonTabWidget(selectOnTap: _selectOnTap),
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.createCollect);
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
            ],
          ),
        ),
        SizedBox(height: 5.w),
        Expanded(child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            return SlidableAutoCloseBehavior(
              child: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: loaded && collectList.isEmpty
                      ? const Center(child: NoDataView())
                      : _selectIndex == 0
                          ? ListView.builder(
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
                                              builder: (context) =>
                                                  CommonDialog(
                                                title: '删除收藏',
                                                content: '确定要删除这个收藏吗？',
                                                confirmText: '确认删除',
                                                onConfirm: () {
                                                  Navigator.of(context).pop();
                                                  NetRequest().favoriteDelete(
                                                      collectList[i].id,
                                                      (data) {
                                                    if (_isMounted) {
                                                      ToastUtils.showToast(
                                                          '删除成功');
                                                      collectList.removeAt(i);
                                                      setState(() {});
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
                              itemCount: collectList.length)
                          : ListView.builder(
                              itemBuilder: (c, i) {
                                return _buildGroupItemWidget(i);
                              },
                              itemCount: collectList.length)),
            );
          },
        ))
      ],
    );
  }

  Widget _buildGroupItemWidget(int index) {
    return Container(
        margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 7.w, top: 5.w),
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
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  '#FFFFFF'.hexColor,
                  '#FFFFFF'.hexColor.withOpacity(0.5)
                ],
                stops: const [
                  0,
                  1
                ])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '王者归来的视频',
                  style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                    onTap: () {},
                    child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.all(5.w),
                      child: Image.asset(
                        Assets.images.iconCollectMore.path,
                        width: 16.w,
                        height: 16.w,
                        fit: BoxFit.cover,
                      ),
                    ))
              ],
            ),
            SizedBox(height: 5.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '26条内容',
                  style: TextStyle(
                      fontSize: 12.w,
                      fontWeight: FontWeight.w600,
                      color: '#333333'.hexColor),
                ),
                Text(
                  '2024.11.25创建',
                  style: TextStyle(
                      fontSize: 12.w,
                      fontWeight: FontWeight.w600,
                      color: '#333333'.hexColor),
                ),
              ],
            )
          ],
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecommendedVideosWidget extends StatelessWidget {
  final List<VideoItem> videos;
  final Function(VideoItem)? onVideoTap;
  final double? height;
  final EdgeInsets? padding;

  const RecommendedVideosWidget({
    super.key,
    required this.videos,
    this.onVideoTap,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return const SizedBox();
    }

    // 限制最多3个视频
    final displayVideos = videos.take(3).toList();
    final videoCount = displayVideos.length;

    return Container(
      padding: padding ?? EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '推荐视频',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: List.generate(videoCount, (index) {
              final video = displayVideos[index];
              return Expanded(
                child: _buildVideoItem(video, index, videoCount),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoItem(VideoItem video, int index, int totalCount) {
    return Container(
      margin: EdgeInsets.only(
        right: index < totalCount - 1 ? 8.w : 0,
      ),
      child: GestureDetector(
        onTap: () => onVideoTap?.call(video),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频封面
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Stack(
                    children: [
                      // 视频封面图片
                      if (video.coverUrl != null)
                        Image.network(
                          video.coverUrl!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.video_library,
                                color: Colors.grey[600],
                                size: 32.w,
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.video_library,
                            color: Colors.grey[600],
                            size: 32.w,
                          ),
                        ),
                      
                      // 播放按钮
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 20.w,
                          ),
                        ),
                      ),
                      
                      // 视频时长
                      if (video.duration != null)
                        Positioned(
                          bottom: 8.h,
                          right: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              _formatDuration(video.duration!),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 8.h),
            
            // 视频标题
            Text(
              video.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            
            SizedBox(height: 4.h),
            
            // 视频信息
            Row(
              children: [
                // 播放次数
                if (video.playCount != null) ...[
                  Icon(
                    Icons.play_circle_outline,
                    size: 12.w,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    _formatPlayCount(video.playCount!),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                
                const Spacer(),
                
                // 点赞数
                if (video.likeCount != null) ...[
                  Icon(
                    Icons.favorite_border,
                    size: 12.w,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    _formatCount(video.likeCount!),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatPlayCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    return count.toString();
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}w';
    }
    return count.toString();
  }
}

// 视频数据模型
class VideoItem {
  final String id;
  final String title;
  final String? coverUrl;
  final Duration? duration;
  final int? playCount;
  final int? likeCount;
  final String? videoUrl;

  VideoItem({
    required this.id,
    required this.title,
    this.coverUrl,
    this.duration,
    this.playCount,
    this.likeCount,
    this.videoUrl,
  });
}

 
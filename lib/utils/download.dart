import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:live_photo_maker/live_photo_maker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'dart:io';

import 'package:share_plus/share_plus.dart';

class DownloadUtils {
  // 图片分享
  static void onShareImg(String imgUrl) async {
    try {
      SmartDialog.showLoading();
      var response = await Request()
          .get(imgUrl, options: Options(responseType: ResponseType.bytes));
      final temp = await getTemporaryDirectory();
      SmartDialog.dismiss();
      String imgName =
          "plpl_pic_${DateTime.now().toString().split('-').join()}.jpg";
      var path = '${temp.path}/$imgName';
      File(path).writeAsBytesSync(response.data);

      Rect? sharePositionOrigin;
      if (await Utils.isIpad()) {
        sharePositionOrigin = Rect.fromLTWH(0, 0, Get.width, Get.height / 2);
      }

      Share.shareXFiles(
        [XFile(path)],
        subject: imgUrl,
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }

  // 获取存储权限
  static Future<bool> requestStoragePer(BuildContext context) async {
    await Permission.storage.request();
    PermissionStatus status = await Permission.storage.status;
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      if (!context.mounted) return false;
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('提示'),
            content: const Text('存储权限未授权'),
            actions: [
              TextButton(
                onPressed: () async {
                  openAppSettings();
                },
                child: const Text('去授权'),
              )
            ],
          );
        },
      );
      return false;
    } else {
      return true;
    }
  }

  // 获取相册权限
  static Future<bool> requestPhotoPer() async {
    await Permission.photos.request();
    PermissionStatus status = await Permission.photos.status;
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      // SmartDialog.show(
      //   useSystem: true,
      //   animationType: SmartAnimationType.centerFade_otherSlide,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: const Text('提示'),
      //       content: const Text('相册权限未授权'),
      //       actions: [
      //         TextButton(
      //           onPressed: () async {
      //             openAppSettings();
      //           },
      //           child: const Text('去授权'),
      //         )
      //       ],
      //     );
      //   },
      // );
      return false;
    } else {
      return true;
    }
  }

  static Future<bool> checkPermissionDependOnSdkInt(
      BuildContext context) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        if (!context.mounted) return false;
        return await requestStoragePer(context);
      } else {
        return await requestPhotoPer();
      }
    }
    return await requestStoragePer(context);
  }

  static Future downloadLivePhoto({
    required BuildContext context,
    required String url,
    required String liveUrl,
    required int width,
    required int height,
  }) async {
    try {
      if (!await checkPermissionDependOnSdkInt(context)) {
        return;
      }
      SmartDialog.showLoading(msg: '正在下载');

      String tmpPath = (await getTemporaryDirectory()).path;
      String time = DateTime.now()
          .toString()
          .replaceAll(' ', '_')
          .replaceAll(':', '-')
          .split('.')
          .first;
      late String imageName =
          "cover_$time.${url.split('.').lastOrNull ?? 'jpg'}";
      late String imagePath = '$tmpPath/$imageName';
      String videoName =
          "video_$time.${liveUrl.split('.').lastOrNull ?? 'mp4'}";
      String videoPath = '$tmpPath/$videoName';

      await Request.dio.download(liveUrl, videoPath);

      if (Platform.isIOS) {
        await Request.dio.download(url, imagePath);
        SmartDialog.showLoading(msg: '正在保存');
        bool success = await LivePhotoMaker.create(
          coverImage: imagePath,
          imagePath: null,
          voicePath: videoPath,
          width: width,
          height: height,
        );
        SmartDialog.dismiss();
        if (success) {
          SmartDialog.showToast(' Live Photo 已保存 ');
        } else {
          SmartDialog.showToast('保存失败');
        }
      } else {
        SmartDialog.showLoading(msg: '正在保存');
        final SaveResult result = await SaverGallery.saveFile(
          filePath: videoPath,
          fileName: videoName,
          androidRelativePath: "Pictures/PiliPlus",
          skipIfExists: false,
        );
        SmartDialog.dismiss();
        if (result.isSuccess) {
          SmartDialog.showToast(' 已保存 ');
        } else {
          SmartDialog.showToast('保存失败，${result.errorMessage}');
        }
      }

      return true;
    } catch (err) {
      SmartDialog.dismiss();
      SmartDialog.showToast(err.toString());
      return false;
    }
  }

  static Future downloadImg(
    BuildContext context,
    List<String> imgList, {
    String imgType = 'cover',
  }) async {
    if (!await checkPermissionDependOnSdkInt(context)) return;
    final cancelToken = CancelToken();
    SmartDialog.showLoading(
      msg: '正在下载原图',
      clickMaskDismiss: true,
      onDismiss: () {
        cancelToken.cancel();
      },
    );
    try {
      final isAndroid = Platform.isAndroid;
      final tempPath = (await getTemporaryDirectory()).path;
      final futures = imgList.map((url) async {
        var name = Utils.getFileName(url);
        var filePath = '$tempPath/$name';

        var response = await Request().downloadFile(
          url.http2https,
          filePath,
          cancelToken: cancelToken,
        );

        if (isAndroid) {
          if (response.statusCode == 200) {
            await SaverGallery.saveFile(
              filePath: filePath,
              fileName: name,
              androidRelativePath: "Pictures/PiliPlus",
              skipIfExists: false,
            );
          }
        }
        return {
          'filePath': filePath,
          'name': name,
          'statusCode': response.statusCode,
        };
      });
      final result = await Future.wait(futures, eagerError: true);
      if (!isAndroid) {
        for (Map res in result) {
          if (res['statusCode'] == 200) {
            await SaverGallery.saveFile(
              filePath: res['filePath'],
              fileName: res['name'],
              androidRelativePath: "Pictures/PiliPlus",
              skipIfExists: false,
            );
          }
        }
      }
      if (cancelToken.isCancelled) {
        SmartDialog.showToast('已取消下载');
        return false;
      } else {
        SmartDialog.showToast('图片已保存');
      }
      return true;
    } catch (e) {
      if (cancelToken.isCancelled) {
        SmartDialog.showToast('已取消下载');
      } else {
        SmartDialog.showToast(e.toString());
      }
      return false;
    } finally {
      SmartDialog.dismiss(status: SmartStatus.loading);
    }
  }
}

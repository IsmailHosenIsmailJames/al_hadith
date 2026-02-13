import 'package:dio/dio.dart';

class DownloadService {
  final Dio _dio = Dio();

  Future<void> downloadFile({
    required String url,
    required String savePath,
    required Function(double progress) onProgress,
    required CancelToken cancelToken,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
        cancelToken: cancelToken,
      );
    } catch (e) {
      if (CancelToken.isCancel(e as DioException)) {
        rethrow;
      }
      throw Exception('Failed to download file: $e');
    }
  }
}

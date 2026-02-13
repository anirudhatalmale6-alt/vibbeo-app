class ConvertToNetwork {
  static int maxConvertTime = 0;
  static Future<String> convert(String filePath) async {
    return filePath;
    // try {
    //   final url = await onConverting(filePath);
    //   final response = await http.get(Uri.parse(url));
    //
    //   if (response.statusCode == 200) {
    //     maxConvertTime = 0;
    //     // AppSettings.showLog("Converted Url => $url");
    //     return url;
    //   } else {
    //     if (maxConvertTime < 25) {
    //       maxConvertTime++;
    //       // AppSettings.showLog("Converting Image Failed $maxConvertTime Time !!!");
    //       return await convert(filePath);
    //     } else {
    //       maxConvertTime = 0;
    //       // AppSettings.showLog("Converting Function Exit !!!");
    //       return "";
    //     }
    //   }
    // } catch (e) {
    //   if (maxConvertTime < 25) {
    //     maxConvertTime++;
    //     // AppSettings.showLog("Converting Image Error => Some Thing Went Wrong !!!");
    //     return await convert(filePath);
    //   } else {
    //     maxConvertTime = 0;
    //     // AppSettings.showLog("Converting Function Exit !!!");
    //     return "";
    //   }
    // }
  }

  // static Future<String> onConverting(String path) async {
  //   try {
  //     const endpoint = "https://codderlab.blr1.digitaloceanspaces.com";
  //     String objPath = path.replaceAll("https://codderlab.blr1.digitaloceanspaces.com/", "");
  //
  //     const bucketName = "codderlab";
  //     final objectKey = objPath; // Replace with the actual object key
  //     const accessKeyId = "DO00W6HQVBUR4T8FFXAL";
  //     const secretKey = "1IIaXFh6Znyz1Ryu87lZXOZckV4m5jXlzOZzUrIShT4";
  //
  //     int expirationTimestamp = DateTime.now().add(const Duration(hours: 1)).toUtc().millisecondsSinceEpoch ~/ 1000;
  //     final expirationInSeconds = expirationTimestamp;
  //
  //     final String stringToSign = "GET\n\n\n$expirationInSeconds\n/$bucketName/$objectKey";
  //     final signature = _generateSignature(secretKey, stringToSign);
  //
  //     final userImages =
  //         "$endpoint/$objectKey?AWSAccessKeyId=$accessKeyId&Expires=$expirationInSeconds&Signature=$signature";
  //
  //     return userImages;
  //   } catch (e) {
  //     AppSettings.showLog("Image Covert Time Error $e");
  //     throw "Image Error";
  //   }
  // }
  //
  // static _generateSignature(String secretKey, String stringToSign) {
  //   final key = utf8.encode(secretKey);
  //   final bytes = utf8.encode(stringToSign);
  //   final hmacSha1 = Hmac(sha1, key);
  //   final digest = hmacSha1.convert(bytes);
  //   return base64Encode(digest.bytes);
  // }

  // static Future<String> normalVideo(String filePath) async {
  //   AppSettings.showLog("Large Video Converting.....");
  //   try {
  //     final url = await onConverting(filePath);
  //
  //     final VideoPlayerController controller = VideoPlayerController.networkUrl(Uri.parse(url));
  //     await controller.initialize();
  //
  //     if (controller.value.isInitialized) {
  //       maxConvertTime = 0;
  //       // AppSettings.showLog("Converted Url => $url");
  //       return url;
  //     } else {
  //       if (maxConvertTime < 25) {
  //         maxConvertTime++;
  //         // AppSettings.showLog("Converting Image Failed $maxConvertTime Time !!!");
  //         return await convert(filePath);
  //       } else {
  //         maxConvertTime = 0;
  //         // AppSettings.showLog("Converting Function Exit !!!");
  //         return "";
  //       }
  //     }
  //   } catch (e) {
  //     if (maxConvertTime < 25) {
  //       maxConvertTime++;
  //       // AppSettings.showLog("Converting Image Error => Some Thing Went Wrong !!!");
  //       return await convert(filePath);
  //     } else {
  //       maxConvertTime = 0;
  //       // AppSettings.showLog("Converting Function Exit !!!");
  //       return "";
  //     }
  //   }
  // }
}

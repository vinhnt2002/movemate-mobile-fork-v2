import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate/utils/commons/widgets/widgets_common_export.dart';
import 'package:movemate/utils/constants/asset_constant.dart';
import 'package:uni_links/uni_links.dart';
import 'package:movemate/configs/routes/app_router.dart';

final paymentResultProvider = StateProvider<bool?>((ref) => null);

Future<void> initUniLinks(BuildContext context, WidgetRef ref) async {
  try {
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      handleDeepLink(initialLink, ref);
    }
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        handleDeepLink(uri.toString(), ref);
      }
    }, onError: (err) {
      print('Error processing deep link: $err');

      showSnackBar(
        context: context,
        content: "Không truy cập được deep link",
        icon: AssetsConstants.iconError,
        backgroundColor: Colors.red,
        textColor: AssetsConstants.whiteColor,
      );
    });
  } on PlatformException {
    print('Failed to get initial link.');
    showSnackBar(
      context: context,
      content: "Không lấy được deep link",
      icon: AssetsConstants.iconError,
      backgroundColor: Colors.red,
      textColor: AssetsConstants.whiteColor,
    );
  }
}

// void handleDeepLink(String link, WidgetRef ref) {
//   print('Received deep link: $link');

//   if (link.startsWith('movemate://payment-result')) {
//     final uri = Uri.parse(link);
//     final isSuccess = uri.queryParameters['isSuccess'] == 'true';

//     ref.read(paymentResultProvider.notifier).state = isSuccess;
//     ref
//         .read(appRouterProvider)
//         .push(TransactionResultScreenRoute(isSuccess: isSuccess));
//   }
// }

void handleDeepLink(String link, WidgetRef ref) {
  print('Received deep link: $link');

  if (link.startsWith('movemate://payment-result')) {
    final uri = Uri.parse(link);
    final isSuccess = uri.queryParameters['isSuccess'] == 'true';
    final bookingId = uri.queryParameters['bookingId'];
    final allUri = uri.queryParameters;
    ref.read(paymentResultProvider.notifier).state = isSuccess;

    // Điều hướng tới TransactionResultScreen và truyền bookingId
    ref.read(appRouterProvider).push(TransactionResultScreenRoute(
          isSuccess: isSuccess,
          bookingId: bookingId ?? '',
          allUri: allUri.toString(),
        ));
  }
}

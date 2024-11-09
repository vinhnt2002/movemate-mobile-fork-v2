import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate/features/booking/domain/entities/sub_service_entity.dart';
import 'package:movemate/features/booking/presentation/screens/controller/service_package_controller.dart';
import 'package:movemate/features/booking/presentation/widgets/booking_screen_2th/service_trailing_widget.dart';
import 'package:movemate/features/booking/presentation/providers/booking_provider.dart';
import 'package:movemate/utils/constants/asset_constant.dart';

class SubServiceTile extends ConsumerWidget {
  final SubServiceEntity subService;

  const SubServiceTile({super.key, required this.subService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingNotifier = ref.read(bookingProvider.notifier);
    final bookingState = ref.watch(bookingProvider);

    final currentSubService = bookingState.selectedSubServices.firstWhere(
      (s) => s.id == subService.id,
      orElse: () => subService.copyWith(quantity: 0),
    );

    final int quantity = currentSubService.quantity ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subService.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2D3142),
                                height: 1.2,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subService.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ServiceTrailingWidget(
                        quantity: quantity,
                        addService: !subService.isQuantity,
                        quantityMax: subService.quantityMax,
                        onQuantityChanged: (newQuantity) async {
                          bookingNotifier.updateSubServiceQuantity(
                              subService, newQuantity);
                          bookingNotifier.calculateAndUpdateTotalPrice();

                          // Gọi submitBooking và lấy kết quả
                          final bookingResponse = await ref
                              .read(servicePackageControllerProvider.notifier)
                              .postValuationBooking(
                                context: context,
                              );

                          // bookingNotifier.calculateAndUpdateTotalPrice();
                          if (bookingResponse != null) {
                            try {
                              // Chuyển đổi BookingResponseEntity thành Booking
                              final bookingtotal = bookingResponse.total;
                              final bookingdeposit = bookingResponse.deposit;
                              bookingNotifier
                                  .updateBookingResponse(bookingResponse);
                              print(
                                  'tuan bookingEntity  total : $bookingtotal');
                              print(
                                  'tuan bookingEntity  deposit : $bookingdeposit');
                              print(
                                  'tuan bookingResponse: ${bookingResponse.bookingDetails.toString()}');
                              print(
                                  'tuan bookingResponse: ${bookingResponse.feeDetails.toString()}');

                              // Xóa bookingState sau khi đã đăng ký thành công
                              // bookingNotifier.reset();
                            } catch (e) {
                              // Xử lý ngoại lệ nếu chuyển đổi thất bại

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã xảy ra lỗi: $e')),
                              );
                            }
                          } else {
                            // Xử lý khi bookingResponse là null
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Đặt hàng thất bại. Vui lòng thử lại.')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  if (subService.isQuantity && subService.quantityMax! > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AssetsConstants.primaryDark.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

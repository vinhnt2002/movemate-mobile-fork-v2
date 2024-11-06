import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:movemate/configs/routes/app_router.dart';
import 'package:movemate/features/booking/presentation/providers/booking_provider.dart';
import 'package:movemate/features/home/presentation/widgets/service_selector/balance_indicator.dart';
import 'package:movemate/features/home/presentation/widgets/service_selector/location_field.dart';
import 'package:movemate/features/home/presentation/widgets/service_selector/date_time_section.dart';
import 'package:movemate/features/home/presentation/widgets/service_selector/confirmation_button.dart';
import 'package:movemate/features/home/domain/entities/location_model_entities.dart';
import 'package:movemate/features/home/presentation/screens/location_selection_screen.dart';
import 'package:movemate/utils/constants/asset_constant.dart';

class ServiceSelector extends HookConsumerWidget {
  const ServiceSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingProvider);
    final bookingNotifier = ref.read(bookingProvider.notifier);

    // State for showing validation errors
    final showErrors = useState(false);

    // State for invalid datetime error
    final isDateTimeInvalid = useState(false);

    // Controllers
    final dateController = useTextEditingController();

    // FocusNodes for fields
    final pickUpFocusNode = useFocusNode();
    final dropOffFocusNode = useFocusNode();
    final dateFocusNode = useFocusNode();

    // Helper Methods
    String formatDateTime(DateTime dateTime) {
      return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    void validateDateTime() {
      if (bookingState.bookingDate != null) {
        isDateTimeInvalid.value =
            bookingState.bookingDate!.isBefore(DateTime.now());
      } else {
        isDateTimeInvalid.value =
            true; // Đánh dấu là không hợp lệ nếu chưa chọn ngày giờ
      }
    }

    void navigateToLocationSelectionScreen() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LocationSelectionScreen(),
        ),
      );
    }

    Future<DateTime?> selectDate(DateTime? initialDate) async {
      final now = DateTime.now();

      // Default time is current time + 1 hour
      final defaultTime = TimeOfDay(
          hour: (now.hour + 1) % 24, // Ensure hour does not exceed 24
          minute: now.minute);

      // Last selectable date is 30 days from now
      final lastDate = now.add(const Duration(days: 30));

      // Show date picker with a 30-day range
      final selectedDate = await showDatePicker(
        context: context,
        initialDate: initialDate ?? now,
        firstDate: now,
        lastDate: lastDate,
        selectableDayPredicate: (DateTime date) {
          // Allow selection within 30 days
          return date.difference(now).inDays <= 30;
        },
      );
      if (selectedDate != null) {
        // Show time picker with default time
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: initialDate != null
              ? TimeOfDay(hour: initialDate.hour, minute: initialDate.minute)
              : defaultTime,
        );

        if (selectedTime != null) {
          final selectedDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );

          return selectedDateTime;
        }
      }
      return null;
    }

    // Effects

    // Validate datetime whenever bookingDate changes
    useEffect(() {
      validateDateTime();
      return null;
    }, [bookingState.bookingDate]);

    // Update dateController text whenever bookingDate changes
    useEffect(() {
      if (bookingState.bookingDate != null) {
        dateController.text = formatDateTime(bookingState.bookingDate!);
      } else {
        dateController.text = 'Chọn ngày - giờ';
      }
      return null;
    }, [bookingState.bookingDate]);

    // Listener to hide errors when all fields are valid
    useEffect(() {
      void listener() {
        if (showErrors.value) {
          final isPickUpValid = bookingState.pickUpLocation != null;
          final isDropOffValid = bookingState.dropOffLocation != null;
          final isDateValid =
              bookingState.bookingDate != null && !isDateTimeInvalid.value;

          if (isPickUpValid && isDropOffValid && isDateValid) {
            showErrors.value = false;
          }
        }
      }

      // Add listeners to bookingState changes
      listener();

      return null;
    }, [
      bookingState.pickUpLocation,
      bookingState.dropOffLocation,
      bookingState.bookingDate,
      isDateTimeInvalid.value
    ]);

    // Add listeners to focus nodes to hide errors when focus is lost and data is valid
    useEffect(() {
      void onFocusChange() {
        if (!pickUpFocusNode.hasFocus &&
            !dropOffFocusNode.hasFocus &&
            !dateFocusNode.hasFocus) {
          final isPickUpValid = bookingState.pickUpLocation != null;
          final isDropOffValid = bookingState.dropOffLocation != null;
          final isDateValid =
              bookingState.bookingDate != null && !isDateTimeInvalid.value;

          if (isPickUpValid && isDropOffValid && isDateValid) {
            showErrors.value = false;
          }
        }
      }

      pickUpFocusNode.addListener(onFocusChange);
      dropOffFocusNode.addListener(onFocusChange);
      dateFocusNode.addListener(onFocusChange);

      return () {
        pickUpFocusNode.removeListener(onFocusChange);
        dropOffFocusNode.removeListener(onFocusChange);
        dateFocusNode.removeListener(onFocusChange);
      };
    }, [
      bookingState.pickUpLocation,
      bookingState.dropOffLocation,
      bookingState.bookingDate,
      isDateTimeInvalid.value
    ]);

    return Card(
      color: AssetsConstants.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.only(top: 100),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Prevent overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BalanceIndicator(),
              const SizedBox(height: 16),

              // LocationField for Pick-Up Location
              LocationField(
                title: 'Địa điểm bắt đầu',
                location: bookingState.pickUpLocation,
                onTap: () {
                  bookingNotifier.toggleSelectingPickUp(true);
                  navigateToLocationSelectionScreen();
                },
                hasError:
                    showErrors.value && bookingState.pickUpLocation == null,
                errorMessage: 'Vui lòng chọn điểm bắt đầu',
                onClear: () {
                  print('Clear button for Pick-Up Location tapped');
                  bookingNotifier.updatePickUpLocation(null);
                },
              ),
              const SizedBox(height: 16),

              // LocationField for Drop-Off Location
              LocationField(
                title: 'Địa điểm kết thúc',
                location: bookingState.dropOffLocation,
                onTap: () {
                  bookingNotifier.toggleSelectingPickUp(false);
                  navigateToLocationSelectionScreen();
                },
                hasError:
                    showErrors.value && bookingState.dropOffLocation == null,
                errorMessage: 'Vui lòng chọn điểm kết thúc',
                onClear: () {
                  print('Clear button for Drop-Off Location tapped');
                  bookingNotifier.updateDropOffLocation(null);
                },
              ),
              const SizedBox(height: 16),

              // DateTimeSection for Booking Date and Time
              DateTimeSection(
                controller: dateController,
                showErrors: showErrors.value,
                isDateTimeInvalid: isDateTimeInvalid.value,
                onTap: () async {
                  final selectedDate =
                      await selectDate(bookingState.bookingDate);
                  if (selectedDate != null) {
                    bookingNotifier.updateBookingDate(selectedDate);
                  }
                },
                onClear: () {
                  // Khi nhấn nút "x", đặt lại bookingDate thành null
                  bookingNotifier.updateBookingDate(null);
                },
                focusNode: dateFocusNode, // Pass the focus node
              ),
              const SizedBox(height: 16),

              // ConfirmationButton to proceed
              ConfirmationButton(
                onPressed: () {
                  showErrors.value = true; // Hiển thị các thông báo lỗi

                  // Kiểm tra tính hợp lệ của các trường
                  final isPickUpValid = bookingState.pickUpLocation != null;
                  final isDropOffValid = bookingState.dropOffLocation != null;
                  final isDateValid = bookingState.bookingDate != null &&
                      !isDateTimeInvalid.value;
                  final isDateSelected =
                      dateController.text != 'Chọn ngày - giờ';

                  if (isPickUpValid &&
                      isDropOffValid &&
                      isDateValid &&
                      isDateSelected) {
                    // Nếu tất cả các trường hợp lệ, chuyển trang
                    context.router.push(const BookingScreenRoute());

                    // In thông tin chi tiết (tùy chọn)
                    print(
                        "Pick-up location: ${bookingState.pickUpLocation?.address} ");
                    print(
                        "Drop-off location: ${bookingState.dropOffLocation?.address} ");
                    print(
                        "Drop-off location latitude: ${bookingState.dropOffLocation?.latitude} ");
                    print(
                        "Drop-off location longitude: ${bookingState.dropOffLocation?.longitude} ");
                    print(
                        "Booking date: ${formatDateTime(bookingState.bookingDate!)} ");
                    print("isDateTimeInvalid: ${!isDateTimeInvalid.value} ");
                  } else {
                    // Nếu có trường không hợp lệ, không làm gì (thông báo lỗi đã được hiển thị)
                    print("Vui lòng điền đầy đủ thông tin trước khi tiếp tục.");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

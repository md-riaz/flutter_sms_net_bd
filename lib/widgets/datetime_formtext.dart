import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms_net_bd/widgets/form_text.dart';

class DateTimeFormText extends StatefulWidget {
  const DateTimeFormText({Key? key}) : super(key: key);

  @override
  State<DateTimeFormText> createState() => _DateTimeFormTextState();
}

class _DateTimeFormTextState extends State<DateTimeFormText> {
  final TextEditingController dateTimeController = TextEditingController();

  dateTimePickerWidget(BuildContext context) {
    return () {
      showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 10),
      ).then((date) {
        if (date != null) {
          showTimePicker(
            context: context,
            initialTime: TimeOfDay(
              hour: DateTime.now().hour,
              minute: DateTime.now().minute + 10,
            ),
          ).then((time) {
            if (time != null) {
              final dateTime = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );

              setState(() {
                // format dateTime as 09/08/2022 09:00 AM
                dateTimeController.text =
                    '${DateFormat('dd/MM/yyyy').format(dateTime)} at ${DateFormat('hh:mm a').format(dateTime)}';
              });
            }
          });
        }
      });
    };
  }

  @override
  void dispose() {
    dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormText(
      label: 'Schedule Date',
      controller: dateTimeController,
      bordered: true,
      suffixIcon: const Icon(Icons.calendar_today),
      readOnly: true,
      onTap: dateTimePickerWidget(context),
    );
  }
}

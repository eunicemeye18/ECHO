import 'package:echo_work/constants/const.dart';
import 'package:echo_work/widgets/custom_circle_progress_indicator.dart';
import 'package:flutter/material.dart';

class ConfirmDialogWidget extends StatefulWidget {
  const ConfirmDialogWidget({
    super.key,
    required this.title,
    this.validActionText,
    required this.onPressed,
    this.content,
    this.subtitle,
    this.cancelActionText,
    required this.isLoading,
  });
  final String title;
  final String? subtitle;
  final String? validActionText;
  final String? cancelActionText;
  final Future<void> Function() onPressed;
  final Widget? content;
  final bool isLoading;

  @override
  State<ConfirmDialogWidget> createState() => _ConfirmDialogWidgetState();
}

class _ConfirmDialogWidgetState extends State<ConfirmDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(
        10,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      content: SizedBox(
        width: Const.screenWidth(context) * 0.75,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                // textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              widget.subtitle != null
                  ? Text(
                      widget.subtitle!,
                      style: Theme.of(context).textTheme.displayMedium,
                    )
                  : const SizedBox(),
              SizedBox(height: 20),
              widget.content != null ? widget.content! : const SizedBox(),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      widget.cancelActionText == null
                          ? "Annuler"
                          : widget.cancelActionText!,
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium!
                          .copyWith(color: Color(0xFF707070)),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        await widget.onPressed();
                      },
                      child: widget.isLoading
                          ? ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                              child: CustomCircleProgressIndicator(),
                            )
                          : Text(
                              widget.validActionText == null
                                  ? "Valider"
                                  : widget.validActionText!,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

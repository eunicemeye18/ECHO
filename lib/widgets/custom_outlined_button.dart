import 'package:echo_work/widgets/custom_circle_progress_indicator.dart';
import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    super.key,
    this.onPressed,
    this.label,
    this.isLoading,
    this.borderRadius,
    this.backgroudColor,
    this.textStyle,
    this.prefixIcon,
    this.borderColor,
  });

  final Function()? onPressed;
  final String? label;
  final bool? isLoading;
  final BorderRadiusGeometry? borderRadius;
  final TextStyle? textStyle;
  final Color? backgroudColor;
  final Icon? prefixIcon;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: prefixIcon,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color:borderColor?? Colors.black.withValues(alpha: 0.2)),
                  backgroundColor:
                      backgroudColor ?? Colors.black.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: borderRadius ?? BorderRadius.circular(8),
                  ),
                ),
                onPressed: onPressed,
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (isLoading != null && isLoading == true)
                        ? CustomCircleProgressIndicator()
                        : Text(
                            label ?? "",
                            style: textStyle ??
                                Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:clone_whatsapp_base_code/widgets/custom_circle_progress_indicator.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    this.onPressed,
    this.label,
    this.isLoading,
    this.borderRadius,
    this.backgroudColor,
    this.textStyle,
  });

  final Function()? onPressed;
  final String? label;
  final bool? isLoading;
  final BorderRadiusGeometry? borderRadius;
  final TextStyle? textStyle;
  final Color? backgroudColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
          backgroundColor:
              backgroudColor ?? Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(25),
          ),
        ),
        onPressed: isLoading != null && isLoading == true ? null : onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label ?? "",
              style: textStyle ??
                  Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white),
            ),
            (isLoading != null && isLoading == true)
                ? const SizedBox(width: 10)
                : const SizedBox(),
            (isLoading != null && isLoading == true)
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CustomCircleProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

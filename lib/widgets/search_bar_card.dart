import 'package:flutter/material.dart';

class SearchBarCard extends StatefulWidget {
  const SearchBarCard({
    super.key,
    this.hintText,
    required this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.prefixIcon,
    this.autofocus,
    this.maskSearchIcon = false,
    this.textAlign,
    this.textStyle,
    this.maxLength,
  });
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final bool? autofocus;
  final bool? maskSearchIcon;
  final TextAlign? textAlign;
  final TextStyle? textStyle;
  final int? maxLength;

  @override
  State<SearchBarCard> createState() => _SearchBarCardState();
}

class _SearchBarCardState extends State<SearchBarCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        cursorColor: Colors.black.withValues(alpha: 0.5),
        autofocus: widget.autofocus ?? false,
        focusNode: widget.focusNode,
        onSubmitted: widget.onSubmitted,
        onChanged: widget.onChanged,
        textAlign: widget.textAlign ?? TextAlign.start,
        maxLength: widget.maxLength,
        style: widget.textStyle ?? Theme.of(context).textTheme.displayMedium,
        decoration: InputDecoration(
          counterText: "",
          prefixIcon: widget.prefixIcon,
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          filled: true,
          fillColor: Colors.grey.withValues(alpha: 0.1),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          hintStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                color: Colors.black.withValues(alpha: 0.3),
              ),
          hintText: widget.hintText,
          suffixIcon: widget.maskSearchIcon!
              ? null
              : Icon(
                  Icons.search,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
      ),
    );
  }
}

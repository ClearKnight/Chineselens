import 'package:flutter/material.dart';
import 'package:chinese_lens/config/constants.dart';

enum ButtonType { primary, secondary, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final double width;
  final IconData? icon;
  final double height;

  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.width = double.infinity,
    this.icon,
    this.height = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (type) {
      case ButtonType.primary:
        return _buildElevatedButton(theme);
      case ButtonType.secondary:
        return _buildOutlinedButton(theme);
      case ButtonType.text:
        return _buildTextButton(theme);
    }
  }

  Widget _buildElevatedButton(ThemeData theme) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiConstants.buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: UiConstants.paddingM,
          ),
        ),
        child: _buildButtonContent(theme.colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildOutlinedButton(ThemeData theme) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiConstants.buttonRadius),
          ),
          side: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: UiConstants.paddingM,
          ),
        ),
        child: _buildButtonContent(theme.colorScheme.primary),
      ),
    );
  }

  Widget _buildTextButton(ThemeData theme) {
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            vertical: UiConstants.paddingM,
          ),
        ),
        child: _buildButtonContent(theme.colorScheme.primary),
      ),
    );
  }

  Widget _buildButtonContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: color,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: UiConstants.paddingS),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

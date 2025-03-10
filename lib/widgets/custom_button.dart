// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
  text,
  error,
  success,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final bool disabled;
  final double? width;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.disabled = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? (fullWidth ? double.infinity : null),
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (variant) {
      case ButtonVariant.primary:
        return _buildElevatedButton();
      case ButtonVariant.secondary:
        return _buildSecondaryButton();
      case ButtonVariant.outline:
        return _buildOutlinedButton();
      case ButtonVariant.text:
        return _buildTextButton();
      case ButtonVariant.error:
        return _buildErrorButton();
      case ButtonVariant.success:
        return _buildSuccessButton();
    }
  }

  Widget _buildElevatedButton() {
    return ElevatedButton(
      onPressed: disabled || isLoading ? null : onPressed,
      style: _getElevatedStyle(),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSecondaryButton() {
    return ElevatedButton(
      onPressed: disabled || isLoading ? null : onPressed,
      style: _getSecondaryStyle(),
      child: _buildButtonContent(textColor: AppTheme.primaryBlue),
    );
  }

  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: disabled || isLoading ? null : onPressed,
      style: _getOutlinedStyle(),
      child: _buildButtonContent(textColor: AppTheme.primaryBlue),
    );
  }

  Widget _buildTextButton() {
    return TextButton(
      onPressed: disabled || isLoading ? null : onPressed,
      style: _getTextButtonStyle(),
      child: _buildButtonContent(textColor: AppTheme.primaryBlue),
    );
  }

  Widget _buildErrorButton() {
    return ElevatedButton(
      onPressed: disabled || isLoading ? null : onPressed,
      style: _getErrorStyle(),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSuccessButton() {
    return ElevatedButton(
      onPressed: disabled || isLoading ? null : onPressed,
      style: _getSuccessStyle(),
      child: _buildButtonContent(),
    );
  }

  ButtonStyle _getElevatedStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryBlue,
      disabledBackgroundColor: Colors.grey[300],
      foregroundColor: Colors.white,
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: _getBorderRadius(),
      ),
    );
  }

  ButtonStyle _getSecondaryStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
      disabledBackgroundColor: Colors.grey[100],
      foregroundColor: AppTheme.primaryBlue,
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: _getBorderRadius(),
      ),
      elevation: 0,
    );
  }

  ButtonStyle _getOutlinedStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppTheme.primaryBlue,
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: _getBorderRadius(),
      ),
      side: BorderSide(
        color: disabled ? Colors.grey[300]! : AppTheme.primaryBlue,
      ),
    );
  }

  ButtonStyle _getTextButtonStyle() {
    return TextButton.styleFrom(
      foregroundColor: AppTheme.primaryBlue,
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: _getBorderRadius(),
      ),
    );
  }

  ButtonStyle _getErrorStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.accentRed,
      disabledBackgroundColor: Colors.grey[300],
      foregroundColor: Colors.white,
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: _getBorderRadius(),
      ),
    );
  }

  ButtonStyle _getSuccessStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.accentGreen,
      disabledBackgroundColor: Colors.grey[300],
      foregroundColor: Colors.white,
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: _getBorderRadius(),
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  BorderRadius _getBorderRadius() {
    switch (size) {
      case ButtonSize.small:
        return BorderRadius.circular(8);
      case ButtonSize.medium:
        return BorderRadius.circular(12);
      case ButtonSize.large:
        return BorderRadius.circular(16);
    }
  }

  Widget _buildButtonContent({Color? textColor}) {
    if (isLoading) {
      return SizedBox(
        height: _getLoaderSize(),
        width: _getLoaderSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            textColor ?? Colors.white,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _getIconSize(),
            color: textColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: _getButtonTextStyle(textColor),
          ),
        ],
      );
    }

    return Text(
      text,
      style: _getButtonTextStyle(textColor),
    );
  }

  double _getLoaderSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  TextStyle _getButtonTextStyle(Color? color) {
    final baseStyle = TextStyle(
      color: color,
      fontWeight: FontWeight.w500,
    );

    switch (size) {
      case ButtonSize.small:
        return baseStyle.copyWith(fontSize: 12);
      case ButtonSize.medium:
        return baseStyle.copyWith(fontSize: 14);
      case ButtonSize.large:
        return baseStyle.copyWith(fontSize: 16);
    }
  }
}

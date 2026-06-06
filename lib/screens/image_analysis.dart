import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mynextmeal/features/meals/image_analysis_controller.dart';
import '../common/spacing_styles.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';
import '../utils/helpers/helper_functions.dart';
import 'camera_screen.dart';
import 'food_analysis_results.dart';

class ImageAnalysis extends StatelessWidget {
  const ImageAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final controller = Get.put(ImageAnalysisController());
    final surface = dark ? AppColors.darkContainer : AppColors.white;

    return Scaffold(
      backgroundColor:
          dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Log a meal'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How would you like to add your meal?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(
                    child: _EntryPointCard(
                      dark: dark,
                      surface: surface,
                      iconAsset: 'assets/icons/photo_camera_secondary.svg',
                      label: 'Camera',
                      subtitle: 'Snap a photo',
                      onTap: () async {
                        final cameras = await availableCameras();
                        Get.to(() => CameraScreen(camera: cameras.first));
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: _EntryPointCard(
                      dark: dark,
                      surface: surface,
                      iconAsset:
                          'assets/icons/add_photo_alternate_secondary.svg',
                      label: 'Gallery',
                      subtitle: 'Upload a photo',
                      onTap: () async {
                        final imageChosen = await controller.pickImage();
                        if (imageChosen) {
                          Get.to(() => const FoodAnalysisResults());
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(dark ? 0.3 : 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          'Tips for best results',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    _TipRow(
                      dark: dark,
                      text: 'Center the dish and fill the frame',
                    ),
                    _TipRow(
                      dark: dark,
                      text: 'Use good lighting — avoid heavy shadows',
                    ),
                    _TipRow(
                      dark: dark,
                      text: 'Review and correct AI results before saving',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryPointCard extends StatelessWidget {
  const _EntryPointCard({
    required this.dark,
    required this.surface,
    required this.iconAsset,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final bool dark;
  final Color surface;
  final String iconAsset;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      elevation: 2,
      shadowColor: AppColors.darkerGrey.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        child: Container(
          height: 160,
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
            border: Border.all(
              color: AppColors.primary.withOpacity(dark ? 0.35 : 0.25),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.primary,
                ),
                child: SvgPicture.asset(iconAsset, height: 32),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppSizes.fontSizeLg,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark ? AppColors.darkGrey : AppColors.darkerGrey,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.dark, required this.text});

  final bool dark;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(
              Icons.circle,
              size: 6,
              color: dark ? AppColors.apricotCream400 : AppColors.apricotCream600,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

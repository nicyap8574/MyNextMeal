import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mynextmeal/common/spacing_styles.dart';
import 'package:mynextmeal/features/user/user_controller.dart';
import 'package:mynextmeal/utils/constants/sizes.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/user/user_profile_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/helpers/helper_functions.dart';
import '../utils/popups/loaders.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  static const String eatingDisorderSupportUrl =
      'https://www.nationaleatingdisorders.org/help-support/contact-helpline';

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late final UserProfileController _profileController;

  Set<int> _selectedDietOptions = {};
  Set<int> _selectedDietaryFocus = {};
  List<String> _dietaryRestrictions = [];

  bool _mealRemindersEnabled = true;
  bool _breakfastReminder = true;
  bool _lunchReminder = true;
  bool _dinnerReminder = true;

  bool _isLoading = true;
  bool _isExporting = false;

  static const List<String> _dietOptions = [
    'Halal',
    'Vegetarian',
    'Vegan',
    'Keto',
  ];

  static const List<String> _dietaryFocus = [
    'Type-2 Diabetes',
    'High Cholesterol',
    'Weight Loss',
    'Muscle Gain',
    'General Health',
  ];

  static const List<String> _commonRestrictions = [
    'Gluten',
    'Dairy',
    'Nuts',
    'Shellfish',
    'Soy',
    'Eggs',
  ];

  @override
  void initState() {
    super.initState();
    _profileController = Get.find<UserProfileController>();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _profileController.getUserDetails();

    if (!mounted) return;

    if (data != null) {
      final diet = List<dynamic>.from(data['dietOptions'] ?? []);
      final focus = List<dynamic>.from(data['dietaryFocus'] ?? []);
      final restrictions =
          List<String>.from(data['dietaryRestrictions'] ?? []);

      setState(() {
        _selectedDietOptions = diet
            .map((item) => _dietOptions.indexOf(item.toString()))
            .where((index) => index >= 0)
            .toSet();
        _selectedDietaryFocus = focus
            .map((item) => _dietaryFocus.indexOf(item.toString()))
            .where((index) => index >= 0)
            .toSet();
        _dietaryRestrictions = restrictions;
        _mealRemindersEnabled = data['mealRemindersEnabled'] as bool? ?? true;
        _breakfastReminder = data['breakfastReminder'] as bool? ?? true;
        _lunchReminder = data['lunchReminder'] as bool? ?? true;
        _dinnerReminder = data['dinnerReminder'] as bool? ?? true;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  List<String> get _activeDietLabels => _selectedDietOptions
      .map((index) => _dietOptions[index])
      .toList();

  List<String> get _activeFocusLabels => _selectedDietaryFocus
      .map((index) => _dietaryFocus[index])
      .toList();

  bool get _hasActiveGoals =>
      _activeDietLabels.isNotEmpty || _activeFocusLabels.isNotEmpty;

  Future<void> _persistNotificationPrefs() async {
    await _profileController.saveNotificationPrefs(
      context: context,
      mealRemindersEnabled: _mealRemindersEnabled,
      breakfastReminder: _breakfastReminder,
      lunchReminder: _lunchReminder,
      dinnerReminder: _dinnerReminder,
    );
  }

  Future<void> _openGoalsEditor() async {
    final draftDiet = Set<int>.from(_selectedDietOptions);
    final draftFocus = Set<int>.from(_selectedDietaryFocus);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final dark = AppHelperFunctions.isDarkMode(context);
            final surface =
                dark ? AppColors.apricotCream900 : AppColors.white;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSizes.cardRadiusLg),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.defaultSpace,
                    AppSizes.md,
                    AppSizes.defaultSpace,
                    AppSizes.defaultSpace,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.spaceBtwItems),
                      Text(
                        'Edit dietary goals',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        'Choose what applies to you right now.',
                        style: TextStyle(
                          color: dark
                              ? AppColors.apricotCream200
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spaceBtwItems),
                      _EditorChipGroup(
                        title: 'Diet style',
                        labels: _dietOptions,
                        selected: draftDiet,
                        onToggle: (index) {
                          setSheetState(() {
                            if (draftDiet.contains(index)) {
                              draftDiet.remove(index);
                            } else {
                              draftDiet.add(index);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: AppSizes.spaceBtwItems),
                      _EditorChipGroup(
                        title: 'Health focus',
                        labels: _dietaryFocus,
                        selected: draftFocus,
                        onToggle: (index) {
                          setSheetState(() {
                            if (draftFocus.contains(index)) {
                              draftFocus.remove(index);
                            } else {
                              draftFocus.add(index);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: AppSizes.spaceBtwSections),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final diet = draftDiet
                                .map((i) => _dietOptions[i])
                                .toList();
                            final focus = draftFocus
                                .map((i) => _dietaryFocus[i])
                                .toList();

                            await _profileController.saveChanges(
                              context: context,
                              selectedDietOptions: diet,
                              selectedDietaryFocus: focus,
                            );

                            if (!mounted) return;
                            setState(() {
                              _selectedDietOptions = draftDiet;
                              _selectedDietaryFocus = draftFocus;
                            });
                            Navigator.pop(sheetContext);
                          },
                          child: const Text('Save goals'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);

    final json = await _profileController.exportUserData();

    if (!mounted) return;
    setState(() => _isExporting = false);

    if (json == null) {
      AppLoaders.showSnackBar(
        context,
        'Export failed. Check your connection and try again.',
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Your data export'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(
                json,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: json));
                if (dialogContext.mounted) {
                  AppLoaders.showSnackBar(
                    dialogContext,
                    'Copied to clipboard',
                  );
                }
              },
              child: const Text('Copy'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openSupportLink() async {
    final uri = Uri.parse(UserProfile.eatingDisorderSupportUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        AppLoaders.showSnackBar(context, 'Could not open link.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final user = Get.find<UserController>().user.value;
    final displayName =
        user.username.isNotEmpty ? user.username : 'Your profile';
    final displayEmail =
        user.email.isNotEmpty ? user.email : 'No email on file';
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: AppSpacingStyle.paddingWithAppBarHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileHeader(
              dark: dark,
              initial: initial,
              displayName: displayName,
              displayEmail: displayEmail,
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),
            _ProfileSectionCard(
              dark: dark,
              icon: Icons.flag_outlined,
              title: 'Active dietary goals',
              subtitle: 'What we use to tailor meal suggestions',
              trailing: TextButton.icon(
                onPressed: _openGoalsEditor,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              child: _hasActiveGoals
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_activeDietLabels.isNotEmpty) ...[
                          _GoalGroupLabel(label: 'Diet style', dark: dark),
                          const SizedBox(height: AppSizes.sm),
                          _ActiveGoalChips(labels: _activeDietLabels, dark: dark),
                        ],
                        if (_activeFocusLabels.isNotEmpty) ...[
                          if (_activeDietLabels.isNotEmpty)
                            const SizedBox(height: AppSizes.spaceBtwItems),
                          _GoalGroupLabel(label: 'Health focus', dark: dark),
                          const SizedBox(height: AppSizes.sm),
                          _ActiveGoalChips(labels: _activeFocusLabels, dark: dark),
                        ],
                      ],
                    )
                  : _EmptyGoalsPrompt(
                      dark: dark,
                      onAdd: _openGoalsEditor,
                    ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            _ProfileSectionCard(
              dark: dark,
              icon: Icons.notifications_outlined,
              title: 'Meal reminders',
              subtitle: 'Gentle nudges to log meals you want to track',
              child: Column(
                children: [
                  _PreferenceSwitch(
                    dark: dark,
                    title: 'Enable meal reminders',
                    subtitle: 'Turn off anytime',
                    value: _mealRemindersEnabled,
                    onChanged: (value) async {
                      setState(() => _mealRemindersEnabled = value);
                      await _persistNotificationPrefs();
                    },
                  ),
                  if (_mealRemindersEnabled) ...[
                    const Divider(height: AppSizes.spaceBtwItems),
                    _PreferenceSwitch(
                      dark: dark,
                      title: 'Breakfast',
                      subtitle: 'Morning check-in',
                      value: _breakfastReminder,
                      onChanged: (value) async {
                        setState(() => _breakfastReminder = value);
                        await _persistNotificationPrefs();
                      },
                    ),
                    _PreferenceSwitch(
                      dark: dark,
                      title: 'Lunch',
                      subtitle: 'Midday check-in',
                      value: _lunchReminder,
                      onChanged: (value) async {
                        setState(() => _lunchReminder = value);
                        await _persistNotificationPrefs();
                      },
                    ),
                    _PreferenceSwitch(
                      dark: dark,
                      title: 'Dinner',
                      subtitle: 'Evening check-in',
                      value: _dinnerReminder,
                      onChanged: (value) async {
                        setState(() => _dinnerReminder = value);
                        await _persistNotificationPrefs();
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            _RestrictionsSection(
              dark: dark,
              restrictions: _dietaryRestrictions,
              commonRestrictions: _commonRestrictions,
              onChanged: (updated) async {
                setState(() => _dietaryRestrictions = updated);
                await _profileController.saveDietaryRestrictions(
                  context: context,
                  restrictions: updated,
                );
              },
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            _ProfileSectionCard(
              dark: dark,
              icon: Icons.download_outlined,
              title: 'Export your data',
              subtitle: 'Download a copy of your profile and meal history',
              child: OutlinedButton.icon(
                onPressed: _isExporting ? null : _exportData,
                icon: _isExporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.ios_share_outlined),
                label: Text(_isExporting ? 'Preparing export…' : 'Export data'),
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),
            _SupportResourcesCard(
              dark: dark,
              onTap: _openSupportLink,
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.find<UserController>().signOut(),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      dark ? AppColors.apricotCream200 : AppColors.apricotCream800,
                  side: BorderSide(
                    color: dark
                        ? AppColors.apricotCream700
                        : AppColors.apricotCream300,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                ),
                child: const Text('Sign out'),
              ),
            ),
            const SizedBox(height: AppSizes.defaultSpace),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.dark,
    required this.initial,
    required this.displayName,
    required this.displayEmail,
  });

  final bool dark;
  final String initial;
  final String displayName;
  final String displayEmail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [AppColors.apricotCream900, AppColors.apricotCream800]
              : [AppColors.apricotCream100, AppColors.apricotCream50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkerGrey.withOpacity(dark ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor:
                dark ? AppColors.apricotCream700 : AppColors.apricotCream400,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  displayEmail,
                  style: TextStyle(
                    color: dark
                        ? AppColors.apricotCream200
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({
    required this.dark,
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final bool dark;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: dark ? AppColors.apricotCream900.withOpacity(0.6) : AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? AppColors.apricotCream800 : AppColors.apricotCream100,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkerGrey.withOpacity(dark ? 0.15 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: dark ? AppColors.apricotCream300 : AppColors.apricotCream600,
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: AppSizes.fontSizeSm,
                          color: dark
                              ? AppColors.apricotCream200
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
          child,
        ],
      ),
    );
  }
}

class _GoalGroupLabel extends StatelessWidget {
  const _GoalGroupLabel({required this.label, required this.dark});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: AppSizes.fontSizeSm,
        fontWeight: FontWeight.w600,
        color: dark ? AppColors.apricotCream300 : AppColors.apricotCream700,
      ),
    );
  }
}

class _ActiveGoalChips extends StatelessWidget {
  const _ActiveGoalChips({required this.labels, required this.dark});

  final List<String> labels;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: labels
          .map(
            (label) => Chip(
              label: Text(label),
              backgroundColor: dark
                  ? AppColors.apricotCream800
                  : AppColors.apricotCream100,
              side: BorderSide(
                color: dark
                    ? AppColors.apricotCream600
                    : AppColors.apricotCream200,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _EmptyGoalsPrompt extends StatelessWidget {
  const _EmptyGoalsPrompt({required this.dark, required this.onAdd});

  final bool dark;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: dark
            ? AppColors.apricotCream950.withOpacity(0.5)
            : AppColors.apricotCream50,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
      ),
      child: Column(
        children: [
          Text(
            'No goals set yet',
            style: TextStyle(
              color: dark ? AppColors.apricotCream200 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          TextButton(
            onPressed: onAdd,
            child: const Text('Add dietary goals'),
          ),
        ],
      ),
    );
  }
}

class _EditorChipGroup extends StatelessWidget {
  const _EditorChipGroup({
    required this.title,
    required this.labels,
    required this.selected,
    required this.onToggle,
  });

  final String title;
  final List<String> labels;
  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: List.generate(labels.length, (index) {
            final isSelected = selected.contains(index);
            return FilterChip(
              label: Text(labels[index]),
              selected: isSelected,
              onSelected: (_) => onToggle(index),
            );
          }),
        ),
      ],
    );
  }
}

class _PreferenceSwitch extends StatelessWidget {
  const _PreferenceSwitch({
    required this.dark,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final bool dark;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: AppSizes.fontSizeSm,
          color:
              dark ? AppColors.apricotCream300 : AppColors.textSecondary,
        ),
      ),
      value: value,
      activeColor: AppColors.apricotCream500,
      onChanged: onChanged,
    );
  }
}

class _RestrictionsSection extends StatefulWidget {
  const _RestrictionsSection({
    required this.dark,
    required this.restrictions,
    required this.commonRestrictions,
    required this.onChanged,
  });

  final bool dark;
  final List<String> restrictions;
  final List<String> commonRestrictions;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_RestrictionsSection> createState() => _RestrictionsSectionState();
}

class _RestrictionsSectionState extends State<_RestrictionsSection> {
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _addRestriction(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    if (widget.restrictions
        .any((r) => r.toLowerCase() == trimmed.toLowerCase())) {
      return;
    }
    widget.onChanged([...widget.restrictions, trimmed]);
    _inputController.clear();
  }

  void _removeRestriction(String value) {
    widget.onChanged(
      widget.restrictions.where((r) => r != value).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileSectionCard(
      dark: widget.dark,
      icon: Icons.no_food_outlined,
      title: 'Dietary restrictions',
      subtitle: 'Allergies and ingredients to avoid in recommendations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.restrictions.isNotEmpty) ...[
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: widget.restrictions
                  .map(
                    (item) => InputChip(
                      label: Text(item),
                      onDeleted: () => _removeRestriction(item),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
          ],
          Text(
            'Quick add',
            style: TextStyle(
              fontSize: AppSizes.fontSizeSm,
              fontWeight: FontWeight.w600,
              color: widget.dark
                  ? AppColors.apricotCream300
                  : AppColors.apricotCream700,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: widget.commonRestrictions.map((item) {
              final alreadyAdded = widget.restrictions
                  .any((r) => r.toLowerCase() == item.toLowerCase());
              return ActionChip(
                label: Text(item),
                onPressed: alreadyAdded ? null : () => _addRestriction(item),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    hintText: 'Add a restriction',
                    filled: true,
                    fillColor: widget.dark
                        ? AppColors.apricotCream950.withOpacity(0.4)
                        : AppColors.apricotCream50,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.inputFieldRadius),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: _addRestriction,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              IconButton.filled(
                onPressed: () => _addRestriction(_inputController.text),
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.apricotCream500,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportResourcesCard extends StatelessWidget {
  const _SupportResourcesCard({
    required this.dark,
    required this.onTap,
  });

  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: dark ? AppColors.celadon900.withOpacity(0.35) : AppColors.celadon50,
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.favorite_outline,
                color: dark ? AppColors.celadon300 : AppColors.celadon600,
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Support & wellbeing',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'If food or body image feels overwhelming, confidential help is available. '
                      'You are not alone.',
                      style: TextStyle(
                        height: 1.4,
                        color: dark
                            ? AppColors.celadon100
                            : AppColors.celadon800,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      'Find eating disorder support resources',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        color: dark
                            ? AppColors.celadon200
                            : AppColors.celadon700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new,
                size: 20,
                color: dark ? AppColors.celadon300 : AppColors.celadon600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:chatapp/core/design/app_shadows.dart';
import 'package:chatapp/core/design/app_spacing.dart';
import 'package:chatapp/core/widgets/app_surface_card.dart';

Future<bool?> showChatImageSendPreviewSheet(
  BuildContext context, {
  required File file,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final theme = Theme.of(context);

      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AppSurfaceCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          radius: 28,
          boxShadow: AppShadows.lg,
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Preview image', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(
                  file,
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Send image'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

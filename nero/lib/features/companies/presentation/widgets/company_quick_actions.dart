import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../shared/models/company_model.dart';
import '../../../tasks/presentation/pages/task_form_page_v2.dart';
import '../pages/meeting_form_page.dart';
import '../pages/company_checklists_page.dart';
import '../pages/company_timeline_page.dart';

class CompanyQuickActions extends StatelessWidget {
  final CompanyModel company;

  const CompanyQuickActions({
    super.key,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        runSpacing: 16,
        spacing: 12,
        children: [
          _buildCircularAction(
            icon: Icons.task_alt,
            label: 'Nova\nTarefa',
            color: AppColors.primary,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TaskFormPageV2(
                    initialCompanyId: company.id,
                  ),
                ),
              );
            },
          ),
          _buildCircularAction(
            icon: Icons.event,
            label: 'Agendar\nReunião',
            color: const Color(0xFF9C27B0),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MeetingFormPage(
                    initialCompanyId: company.id,
                  ),
                ),
              );
            },
          ),
          _buildCircularAction(
            icon: Icons.checklist,
            label: 'Checklist',
            color: AppColors.priorityLow,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CompanyChecklistsPage(
                    company: company,
                  ),
                ),
              );
            },
          ),
          _buildCircularAction(
            icon: Icons.timeline,
            label: 'Timeline',
            color: AppColors.aiAccent,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CompanyTimelinePage(
                    company: company,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircularAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _CircularActionButton(
      icon: icon,
      label: label,
      color: color,
      onTap: onTap,
    );
  }
}

class _CircularActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CircularActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_CircularActionButton> createState() => _CircularActionButtonState();
}

class _CircularActionButtonState extends State<_CircularActionButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: SizedBox(
          width: 70,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: isDark ? AppColors.darkText : const Color(0xFF1C1C1C),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

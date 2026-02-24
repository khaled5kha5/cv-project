import 'package:cv_project1/providers/cv_builder_provider.dart';
import 'package:cv_project1/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const double sectionGap = 20;

// Sidebar width scales with available space but never too wide/narrow
double _sidebarWidth(double totalWidth) =>
    (totalWidth * 0.30).clamp(140.0, 220.0);

// ─── Theme Extension ──────────────────────────────────────────────────────────

extension _CvTheme on BuildContext {
  ColorScheme get cs        => Theme.of(this).colorScheme;
  Color get cvSurface       => cs.surface;
  Color get cvBackground    => Theme.of(this).scaffoldBackgroundColor;
  Color get cvBorder        => Theme.of(this).dividerColor;
  Color get cvTextPrimary   => cs.onSurface;
  Color get cvTextMuted     => Theme.of(this).textTheme.bodyMedium!.color!;
  Color get cvAccent        => AppTheme.accent;
  Color get cvSidebar       => isDark ? AppTheme.darkSurface2 : AppTheme.primary;
  Color get cvCardElevated  => isDark ? AppTheme.darkSurface2 : AppTheme.surface;
  bool  get isDark          => Theme.of(this).brightness == Brightness.dark;
}

// ─── Shared Section Widgets ───────────────────────────────────────────────────

Widget sectionSummary(CvBuilderProvider cv, BuildContext ctx) =>
    _section('Summary', cv.cv?.summary, ctx);

Widget sectionExperience(CvBuilderProvider cv, BuildContext ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Experience', ctx),
        ...cv.experienceList.map((e) => _timelineItem(e.position, e.company, ctx)),
      ],
    );

Widget sectionEducation(CvBuilderProvider cv, BuildContext ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Education', ctx),
        ...cv.educationList.map((e) => _timelineItem(e.degree, e.university, ctx)),
      ],
    );

Widget sectionProjects(CvBuilderProvider cv, BuildContext ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Projects', ctx),
        ...cv.projectList.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 5, right: 10),
                  decoration: BoxDecoration(
                      color: ctx.cvAccent, shape: BoxShape.circle),
                ),
                // FIX: Expanded prevents horizontal overflow
                Expanded(
                  child: Text(
                    p.title,
                    style: TextStyle(
                        fontSize: 13, height: 1.5, color: ctx.cvTextPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

Widget sectionSkills(CvBuilderProvider cv, BuildContext ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Skills', ctx),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: cv.skillList.map((s) => _skillBadge(s.name, ctx)).toList(),
        ),
      ],
    );

// ─── Classic Layout ───────────────────────────────────────────────────────────

class ClassicLayout extends StatelessWidget {
  const ClassicLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final cv          = context.watch<CvBuilderProvider>();
    final accentColor = cv.selectedColorScheme?.primary ?? context.cvAccent;

    // FIX: LayoutBuilder reads the real available width — no hardcoded 900
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        // Padding scales down on narrow screens
        final pad = w < 400 ? 20.0 : 32.0;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.cvSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.cvBorder),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(context.isDark ? 0.15 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Accent top bar
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _classicHeader(cv, context),
                    const SizedBox(height: 20),
                    Divider(color: context.cvBorder, thickness: 1),
                    const SizedBox(height: sectionGap),
                    sectionSummary(cv, context),
                    if (cv.cv?.summary?.isNotEmpty == true)
                      const SizedBox(height: sectionGap),
                    sectionExperience(cv, context),
                    if (cv.experienceList.isNotEmpty)
                      const SizedBox(height: sectionGap),
                    sectionEducation(cv, context),
                    if (cv.educationList.isNotEmpty)
                      const SizedBox(height: sectionGap),
                    sectionProjects(cv, context),
                    if (cv.projectList.isNotEmpty)
                      const SizedBox(height: sectionGap),
                    sectionSkills(cv, context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Modern Layout ────────────────────────────────────────────────────────────

class ModernLayout extends StatelessWidget {
  const ModernLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final cv          = context.watch<CvBuilderProvider>();
    final accentColor = cv.selectedColorScheme?.primary ?? context.cvAccent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalW   = constraints.maxWidth;
        final sidebarW = _sidebarWidth(totalW);
        // FIX: on very narrow screens (< 320) collapse to single-column
        final isNarrow = totalW < 320;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.cvSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.cvBorder),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(context.isDark ? 0.15 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isNarrow
                ? _modernNarrow(cv, accentColor, context)
                : _modernWide(cv, accentColor, sidebarW, context),
          ),
        );
      },
    );
  }

  Widget _modernWide(CvBuilderProvider cv, Color accentColor,
      double sidebarW, BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Sidebar ──────────────────────────────
          SizedBox(
            width: sidebarW,
            child: Container(
              color: cv.selectedColorScheme?.primary ?? context.cvSidebar,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profileImage(cv, radius: 36),
                  const SizedBox(height: 16),
                  // FIX: text in sidebar must not overflow — use softWrap + overflow
                  Text(
                    cv.cv?.fullname ?? '',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    cv.cv?.role ?? '',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.55)),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 20),
                  _sidebarSection('Contact', _sidebarContact(cv)),
                  const SizedBox(height: 16),
                  _sidebarSection('Skills', _sidebarSkills(cv)),
                  const SizedBox(height: 16),
                  _sidebarSection('Education', _sidebarEducation(cv)),
                ],
              ),
            ),
          ),

          // ── Main content ─────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _modernRightHeader(cv, accentColor, context),
                  const SizedBox(height: sectionGap),
                  _themedCard(sectionSummary(cv, context), context),
                  const SizedBox(height: 12),
                  _themedCard(sectionExperience(cv, context), context),
                  const SizedBox(height: 12),
                  _themedCard(sectionProjects(cv, context), context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Single-column fallback for very narrow screens
  Widget _modernNarrow(
      CvBuilderProvider cv, Color accentColor, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compact header bar
        Container(
          width: double.infinity,
          color: context.cvSidebar,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              profileImage(cv, radius: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cv.cv?.fullname ?? '',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                        overflow: TextOverflow.ellipsis),
                    Text(cv.cv?.role ?? '',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.6)),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _themedCard(sectionSummary(cv, context), context),
              const SizedBox(height: 10),
              _themedCard(sectionExperience(cv, context), context),
              const SizedBox(height: 10),
              _themedCard(sectionEducation(cv, context), context),
              const SizedBox(height: 10),
              _themedCard(sectionProjects(cv, context), context),
              const SizedBox(height: 10),
              _themedCard(sectionSkills(cv, context), context),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Creative Layout ──────────────────────────────────────────────────────────

class CreativeLayout extends StatelessWidget {
  const CreativeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final cv          = context.watch<CvBuilderProvider>();
    final accentColor = cv.selectedColorScheme?.primary ?? context.cvAccent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w        = constraints.maxWidth;
        final pad      = w < 400 ? 16.0 : 24.0;
        // FIX: only show 2-column grid if enough width
        final twoCol   = w > 480;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.cvBackground,
            borderRadius: BorderRadius.circular(16),
            border: context.isDark
                ? Border.all(color: context.cvBorder)
                : null,
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(context.isDark ? 0.12 : 0.06),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _creativeHeader(cv, accentColor),
              Padding(
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _themedCard(sectionSummary(cv, context), context),
                    const SizedBox(height: 12),
                    // FIX: 2-col only when wide enough
                    if (twoCol)
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                                child: _themedCard(
                                    sectionExperience(cv, context), context)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _themedCard(
                                    sectionEducation(cv, context), context)),
                          ],
                        ),
                      )
                    else ...[
                      _themedCard(sectionExperience(cv, context), context),
                      const SizedBox(height: 12),
                      _themedCard(sectionEducation(cv, context), context),
                    ],
                    const SizedBox(height: 12),
                    _themedCard(sectionProjects(cv, context), context),
                    const SizedBox(height: 12),
                    _themedCard(sectionSkills(cv, context), context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Headers ─────────────────────────────────────────────────────────────────

Widget _classicHeader(CvBuilderProvider cv, BuildContext ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FIX: all header text uses softWrap and never overflows
        Text(
          cv.cv?.fullname ?? '',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: ctx.cvTextPrimary),
          softWrap: true,
        ),
        const SizedBox(height: 3),
        Text(
          cv.cv?.role ?? '',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ctx.cvAccent,
              letterSpacing: 0.5),
          softWrap: true,
        ),
        const SizedBox(height: 10),
        // FIX: Wrap instead of Row so contact info wraps on narrow screens
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            _contactChip(Icons.email_outlined, cv.cv?.email ?? '', ctx),
            _contactChip(Icons.phone_outlined, cv.cv?.phone ?? '', ctx),
          ],
        ),
      ],
    );

Widget _contactChip(IconData icon, String text, BuildContext ctx) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: ctx.cvTextMuted),
        const SizedBox(width: 5),
        // FIX: ConstrainedBox prevents individual chip from overflowing
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: ctx.cvTextMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

Widget _modernRightHeader(
    CvBuilderProvider cv, Color accentColor, BuildContext ctx) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cv.cv?.fullname ?? '',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: ctx.cvTextPrimary),
          softWrap: true,
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Container(
              width: 20,
              height: 3,
              decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                cv.cv?.role ?? '',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                    letterSpacing: 0.5),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );

Widget _creativeHeader(CvBuilderProvider cv, Color accentColor) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          profileImage(cv, radius: 36, borderColor: Colors.white),
          const SizedBox(width: 16),
          // FIX: Expanded is critical — prevents header text overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cv.cv?.fullname ?? '',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3),
                  softWrap: true,
                ),
                const SizedBox(height: 3),
                Text(
                  cv.cv?.role ?? '',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _headerChip(Icons.email_outlined, cv.cv?.email ?? ''),
                    _headerChip(Icons.phone_outlined, cv.cv?.phone ?? ''),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

// ─── Sidebar ──────────────────────────────────────────────────────────────────

Widget _sidebarSection(String label, Widget content) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white38,
                letterSpacing: 1.6)),
        const SizedBox(height: 6),
        Divider(
            color: Colors.white.withOpacity(0.12), thickness: 1, height: 1),
        const SizedBox(height: 10),
        content,
      ],
    );

Widget _sidebarContact(CvBuilderProvider cv) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sidebarRow(Icons.email_outlined, cv.cv?.email ?? ''),
        const SizedBox(height: 6),
        _sidebarRow(Icons.phone_outlined, cv.cv?.phone ?? ''),
      ],
    );

Widget _sidebarRow(IconData icon, String text) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white38, size: 13),
        const SizedBox(width: 6),
        // FIX: Expanded + softWrap prevents sidebar text overflow
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 11, color: Colors.white60, height: 1.4),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );

Widget _sidebarSkills(CvBuilderProvider cv) => Wrap(
      spacing: 5,
      runSpacing: 5,
      children: cv.skillList.map((s) => _sidebarBadge(s.name)).toList(),
    );

Widget _sidebarBadge(String label) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500)),
    );

Widget _sidebarEducation(CvBuilderProvider cv) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cv.educationList
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.degree,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                        softWrap: true),
                    const SizedBox(height: 1),
                    Text(e.university,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white54),
                        softWrap: true),
                  ],
                ),
              ))
          .toList(),
    );

// ─── Card ─────────────────────────────────────────────────────────────────────

Widget _themedCard(Widget child, BuildContext ctx) => Container(
      width: double.infinity,  // FIX: explicit full-width prevents card from sizing to content
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ctx.cvCardElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ctx.cvBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(ctx.isDark ? 0.2 : 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

// ─── Section Title ────────────────────────────────────────────────────────────

Widget _sectionTitle(String text, BuildContext ctx) => Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 2),
      child: Row(
        children: [
          Text(text.toUpperCase(),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: ctx.cvTextMuted)),
          const SizedBox(width: 10),
          Expanded(
              child:
                  Divider(color: ctx.cvBorder, thickness: 1, height: 1)),
        ],
      ),
    );

Widget _section(String titleText, String? content, BuildContext ctx) {
  if (content == null || content.isEmpty) return const SizedBox();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle(titleText, ctx),
      // FIX: text always wraps, never overflows
      Text(content,
          style: TextStyle(
              fontSize: 13, height: 1.6, color: ctx.cvTextMuted),
          softWrap: true),
    ],
  );
}

// ─── Timeline Item ────────────────────────────────────────────────────────────

Widget _timelineItem(String primary, String secondary, BuildContext ctx) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + line
          Column(
            children: [
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(top: 4),
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: ctx.cvAccent),
              ),
              Container(width: 1, height: 28, color: ctx.cvBorder),
            ],
          ),
          const SizedBox(width: 12),
          // FIX: Expanded is required — prevents overflow in both columns
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(primary,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ctx.cvTextPrimary),
                    softWrap: true),
                const SizedBox(height: 2),
                Text(secondary,
                    style: TextStyle(fontSize: 12, color: ctx.cvTextMuted),
                    softWrap: true),
              ],
            ),
          ),
        ],
      ),
    );

// ─── Skill Badge ──────────────────────────────────────────────────────────────

Widget _skillBadge(String label, BuildContext ctx) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ctx.isDark
            ? Colors.white.withOpacity(0.07)
            : AppTheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ctx.cvBorder),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: ctx.cvTextPrimary)),
    );

// ─── Chips ────────────────────────────────────────────────────────────────────

Widget _headerChip(IconData icon, String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white70),
          const SizedBox(width: 4),
          // FIX: constrained so chip never blows out the header row
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(text,
                style:
                    const TextStyle(fontSize: 11, color: Colors.white),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );

// ─── Profile Image ────────────────────────────────────────────────────────────

Widget profileImage(
  CvBuilderProvider cv, {
  double radius = 40,
  Color? borderColor,
}) {
  final url = cv.profileImageUrl;
  if (url == null || url.isEmpty) return const SizedBox();
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            Border.all(color: borderColor ?? AppTheme.border, width: 2.5),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(url),
      ),
    ),
  );
}

// ─── Build Layout ─────────────────────────────────────────────────────────────

Widget buildLayout(CvBuilderProvider cv) {
  switch (cv.styleTemplate) {
    case 'modern':
      return const ModernLayout();
    case 'creative':
      return const CreativeLayout();
    case 'classic':
    default:
      return const ClassicLayout();
  }
}

// ─── Template Selector ────────────────────────────────────────────────────────

Widget templateSelector(CvBuilderProvider cv, BuildContext ctx) => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cv.styleTemplates.map((styleName) {
        final isSelected = cv.styleTemplate == styleName;
        return GestureDetector(
          onTap: () => cv.setStyleTemplate(styleName),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? (ctx.isDark ? ctx.cvAccent : AppTheme.primary)
                  : ctx.cvSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? (ctx.isDark ? ctx.cvAccent : AppTheme.primary)
                    : ctx.cvBorder,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: ctx.cvAccent.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [],
            ),
            child: Text(
              styleName.toUpperCase(),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: isSelected ? Colors.white : ctx.cvTextMuted),
            ),
          ),
        );
      }).toList(),
    );

// ─── Color Selector ───────────────────────────────────────────────────────────

Widget colorSelector(CvBuilderProvider cv) => Wrap(
      spacing: 10,
      runSpacing: 10,
      children: cv.colorSchemes.map((scheme) {
        final isSelected =
            cv.selectedColorScheme?.primary.value == scheme.primary.value;
        return GestureDetector(
          onTap: () => cv.setSelectedColorScheme(scheme),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary
                      .withOpacity(isSelected ? 0.55 : 0.2),
                  blurRadius: isSelected ? 10 : 4,
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );

// ─── CV Paper Wrapper ─────────────────────────────────────────────────────────

// FIX: removed fixed width container — child fills available width naturally.
// Caller (preview tab / preview screen) already provides the right constraints.
Widget cvPaper(Widget child, BuildContext ctx) => Container(
      color: ctx.cvBackground,
      padding: const EdgeInsets.all(16),
      child: child,
    );
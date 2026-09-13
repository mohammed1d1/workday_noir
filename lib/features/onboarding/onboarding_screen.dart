import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/noir_theme.dart';

/// Three short, premium onboarding screens shown only on first launch.
/// Skippable at any point, since the app itself is simple enough that
/// forcing the user through it adds no value.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final Future<void> Function() onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  static const List<_OnboardingPage> _pages = <_OnboardingPage>[
    _OnboardingPage(
      eyebrow: 'WORKDAY NOIR',
      headline: 'Track your workdays.\nNothing more.',
    ),
    _OnboardingPage(
      eyebrow: 'ONE QUESTION',
      headline: 'Did you work today?',
    ),
    _OnboardingPage(
      eyebrow: 'YES OR NO',
      headline: 'Your history is saved\nautomatically.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _pages.length - 1) {
      unawaited(widget.onComplete());
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _page == _pages.length - 1;

    return Scaffold(
      backgroundColor: NoirColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: widget.onComplete,
                  child: Text('Skip', style: NoirTypography.secondary),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int i) => setState(() => _page = i),
                itemBuilder: (BuildContext context, int index) {
                  final _OnboardingPage page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          page.eyebrow,
                          textAlign: TextAlign.center,
                          style: NoirTypography.caption.copyWith(
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.headline,
                          textAlign: TextAlign.center,
                          style: NoirTypography.largeTitle,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40, top: 16),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(_pages.length, (int i) {
                      final bool active = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? NoirColors.textPrimary
                              : NoirColors.textTertiary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 220,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: NoirColors.surfaceRaised,
                        foregroundColor: NoirColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _next,
                      child: Text(
                        isLast ? 'Get Started' : 'Continue',
                        style: NoirTypography.button,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({required this.eyebrow, required this.headline});

  final String eyebrow;
  final String headline;
}

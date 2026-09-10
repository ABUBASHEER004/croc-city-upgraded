import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../onboarding/data/onboarding_data.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {

  final PageController controller = PageController();

  int currentPage = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void nextPage() {
    if (currentPage < onboardingItems.length - 1) {
      controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          PageView.builder(
            controller: controller,
            itemCount: onboardingItems.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPage(
                item: onboardingItems[index],
              );
            },
          ),

          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: List.generate(
                onboardingItems.length,
                (index) => PageIndicator(
                  active: currentPage == index,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: nextPage,
                child: Text(
                  currentPage ==
                          onboardingItems.length - 1
                      ? "Get Started"
                      : "Next",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
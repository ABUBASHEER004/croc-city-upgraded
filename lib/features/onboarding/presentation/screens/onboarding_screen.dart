import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/page_indicator.dart';
import '../../../onboarding/data/onboarding_data.dart';

class OnboardingScreen extends StatefulWidget { const OnboardingScreen({super.key}); @override State<OnboardingScreen> createState()=>_OnboardingScreenState(); }
class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller=PageController(); int currentPage=0;
  @override void dispose(){controller.dispose();super.dispose();}
  void nextPage(){if(currentPage<onboardingItems.length-1){controller.nextPage(duration:const Duration(milliseconds:450),curve:Curves.easeOutCubic);}else{context.go('/login');}}
  @override Widget build(BuildContext context)=>Scaffold(body:Stack(children:[PageView.builder(controller:controller,itemCount:onboardingItems.length,onPageChanged:(i)=>setState(()=>currentPage=i),itemBuilder:(c,i)=>OnboardingPage(item:onboardingItems[i])),Positioned(top:56,right:20,child:TextButton(onPressed:()=>context.go('/login'),child:const Text('Skip'))),Positioned(bottom:112,left:0,right:0,child:Row(mainAxisAlignment:MainAxisAlignment.center,children:List.generate(onboardingItems.length,(i)=>PageIndicator(active:currentPage==i)))),Positioned(bottom:38,left:20,right:20,child:SizedBox(height:56,child:ElevatedButton.icon(onPressed:nextPage,icon:Icon(currentPage==onboardingItems.length-1?Icons.rocket_launch_rounded:Icons.arrow_forward_rounded),label:Text(currentPage==onboardingItems.length-1?'Enter Academy':'Continue'))))]));
}

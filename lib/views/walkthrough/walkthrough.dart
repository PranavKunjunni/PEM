import 'package:flutter/material.dart';
import 'package:pem/views/login_screen/login_screen.dart';
import 'package:pem/widgets/buttons.dart';

class Walkthrough extends StatefulWidget {
  const Walkthrough({super.key});

  @override
  State<Walkthrough> createState() => _WalkthroughState();
}

class _WalkthroughState extends State<Walkthrough> {
  final PageController _controller = PageController();

  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "title": "Privacy by Default, With Zero Ads or Hidden Tracking",
      "subtitle": "No ads. No trackers. No third-party analytics."
    },
    {
      "title": "Insights That Help You Spend Better Without Complexity",
      "subtitle": "See category-wise spending, recent activity."
    },
    {
      "title": "Local-First Tracking That Stays Fully On Your Device",
      "subtitle": "Your finances stay on your phone."
    },
  ];

  void nextPage() {
    if (currentPage < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/walkthrough.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(.35),
            ),
          ),
          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (value) {
              setState(() {
                currentPage = value;
              });
            },
            itemBuilder: (context, index) {
              return SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      50,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            pages.length,
                            (dotIndex) => AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 250),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              width: currentPage == dotIndex ? 20 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: currentPage == dotIndex
                                    ? Colors.white
                                    : Colors.white54,
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          pages[index]["title"]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          pages[index]["subtitle"]!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Row(
                          children: [
                            if (currentPage > 0)
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    _controller.previousPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                            if (currentPage > 0)
                              const SizedBox(width: 12),

                            Expanded(
                              child: Button(
                                text: currentPage == pages.length - 1
                                    ? "Get Started"
                                    : "Next",
                                onPressed: nextPage,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
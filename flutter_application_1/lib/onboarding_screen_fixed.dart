import 'package:flutter/material.dart';
import 'login_page.dart';

class OnboardingScreenFinal extends StatelessWidget {
  const OnboardingScreenFinal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A), // Dark black
              Color(0xFF3E2723), // Deep brown
              Color(0xFF4A3426), // Construction brown
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                
                // Main Heading Section
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Equipment Heading
                    Text(
                      'Equipment',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35), // Bright orange
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    // Booking Sorted Subtitle
                    Text(
                      'Booking Sorted',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.2,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Subtitle
                    Text(
                      'Get quotes for your equipment hiring',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFB0BEC5), // Light grey
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(flex: 1),
                
                // Construction Hazard Stripes
                SizedBox(
                  height: 60,
                  child: Stack(
                    children: [
                      // Orange stripes
                      Positioned(
                        top: 10,
                        left: 20,
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: 30,
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 30,
                        left: 40,
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 3),
                
                // Center Content with Machine Icons
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Construction Equipment Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Wheel Loader
                          _buildEquipmentImage('wheel_loader.png', 'Wheel Loader'),
                          
                          // Excavator
                          _buildEquipmentImage('excavator.png', 'Excavator'),
                          
                          // Backhoe Loader
                          _buildEquipmentImage('backhoe_loader.png', 'Backhoe'),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Carousel Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDot(true), // Active dot
                          _buildDot(false),
                          _buildDot(false),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Get Started Button
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFF6B35) : const Color(0xFF4A3426),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildEquipmentImage(String imagePath, String label) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              // Soft orange glow
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Equipment Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/$imagePath',
                    width: 100,
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A3426),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.construction,
                          size: 40,
                          color: Color(0xFF3E2723),
                        ),
                      );
                    }
                  )
                ),
                
                // Equipment label
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3E2723),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFFF6B35),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

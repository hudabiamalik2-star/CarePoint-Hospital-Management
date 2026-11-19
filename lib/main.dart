import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const HospitalApp());

class HospitalApp extends StatefulWidget {
  const HospitalApp({super.key});

  @override
  State<HospitalApp> createState() => _HospitalAppState();
}

class _HospitalAppState extends State<HospitalApp> {
  bool dark = false;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CarePoint Hospital',
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF167D8D),
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF42B8C5),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: SplashScreen(onTheme: () => setState(() => dark = !dark)),
      );
}

class SplashScreen extends StatefulWidget {
  final VoidCallback onTheme;

  const SplashScreen({super.key, required this.onTheme});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(onTheme: widget.onTheme),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF126B78), Color(0xFF20A6A8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_hospital_rounded,
                  color: Colors.white, size: 82),
              SizedBox(height: 18),
              Text(
                'CarePoint Hospital',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Smart care. Better management.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      );
} 
class LoginScreen extends StatefulWidget {
  final VoidCallback onTheme;

  const LoginScreen({super.key, required this.onTheme});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String role = 'Admin';

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', true);
    await prefs.setString('userRole', role);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          role: role,
          onTheme: widget.onTheme,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.local_hospital,
                    size: 75,
                    color: Color(0xFF167D8D),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'CarePoint Hospital',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome! Please sign in',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(
                      labelText: 'Select Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: ['Admin', 'Doctor', 'Receptionist']
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => role = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: login,
                    child: const Padding(
                      padding: EdgeInsets.all(13),
                      child: Text('LOGIN'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: widget.onTheme,
                    child: const Text('Toggle Light / Dark Mode'),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Demo app: enter any email and password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class HomeScreen extends StatefulWidget {
  final String role;
  final VoidCallback onTheme;

  const HomeScreen({
    super.key,
    required this.role,
    required this.onTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<String> patients = [
    'Ali Ahmed',
    'Sara Khan',
    'Ahmed Raza',
  ];

  final List<String> doctors = [
    'Dr. Ahmed - Cardiologist',
    'Dr. Sara - Dentist',
    'Dr. Bilal - Neurologist',
  ];

  final List<String> appointments = [
    'Ali Ahmed - Dr. Ahmed - Pending',
    'Sara Khan - Dr. Sara - Confirmed',
  ];

  final List<String> invoices = [
    'Ali Ahmed - Rs. 2,000 - Paid',
    'Sara Khan - Rs. 1,500 - Unpaid',
  ];

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', false);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(onTheme: widget.onTheme),
      ),
      (route) => false,
    );
  }

  void addItem(List<String> list, String title) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $title name/details',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => list.add(controller.text.trim()));
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget dashboard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            'Welcome, ${widget.role}!',
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text('Hospital overview'),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              statCard('Patients', patients.length, Icons.people),
              statCard('Doctors', doctors.length, Icons.medical_services),
              statCard('Appointments', appointments.length, Icons.event),
              statCard('Invoices', invoices.length, Icons.receipt_long),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Quick Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manage Patients'),
              subtitle: const Text('Add and view patient records'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => setState(() => selectedIndex = 1),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Manage Appointments'),
              subtitle: const Text('View appointment records'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => setState(() => selectedIndex = 3),
            ),
          ),
        ],
      ),
    );
  }

  Widget statCard(String title, int count, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: const Color(0xFF167D8D)),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget recordPage(
    String title,
    List<String> records,
    IconData icon,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => addItem(records, title),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: records.isEmpty
              ? const Center(child: Text('No records available'))
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) => Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    child: ListTile(
                      leading: Icon(icon),
                      title: Text(records[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() => records.removeAt(index));
                        },
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      dashboard(),
      recordPage('Patients', patients, Icons.people),
      recordPage('Doctors', doctors, Icons.medical_services),
      recordPage('Appointments', appointments, Icons.event),
      recordPage('Billing', invoices, Icons.receipt_long),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CarePoint Hospital'),
        actions: [
          IconButton(
            onPressed: widget.onTheme,
            icon: const Icon(Icons.dark_mode_outlined),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Patients',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services),
            label: 'Doctors',
          ),
          NavigationDestination(
            icon: Icon(Icons.event),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Billing',
          ),
        ],
      ),
    );
  }
}
class ProfileScreen extends StatelessWidget {
  final String role;

  const ProfileScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 45,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 15),
            Text(
              role,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('CarePoint Hospital User'),
          ],
        ),
      ),
    );
  }
}

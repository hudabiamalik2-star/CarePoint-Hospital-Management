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
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF167D8D)), useMaterial3: true),
    darkTheme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF42B8C5), brightness: Brightness.dark), useMaterial3: true),
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
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen(onTheme: widget.onTheme)));
    });
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF126B78), Color(0xFF20A6A8)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.local_hospital_rounded, color: Colors.white, size: 82),
        SizedBox(height: 18),
        Text('CarePoint Hospital', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Smart care. Better management.', style: TextStyle(color: Colors.white70, fontSize: 14)),
        SizedBox(height: 32),
        CircularProgressIndicator(color: Colors.white),
      ]),
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
  final email = TextEditingController(text: 'admin@carepoint.com');
  final password = TextEditingController(text: '123456');
  String role = 'Admin';
  bool remember = true;
  bool busy = false;

  Future<void> login() async {
    setState(() => busy = true);
    final prefs = await SharedPreferences.getInstance();
    if (remember) {
      await prefs.setBool('loggedIn', true);
      await prefs.setString('role', role);
      await prefs.setString('email', email.text.trim());
    }
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(role: role, onTheme: widget.onTheme)));
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Icon(Icons.local_hospital_rounded, size: 64, color: Color(0xFF168493)),
        const SizedBox(height: 12),
        Text('Welcome back', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Sign in to your hospital workspace', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor)),
        const SizedBox(height: 28),
        TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder())),
        const SizedBox(height: 14),
        TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder())),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(value: role, decoration: const InputDecoration(labelText: 'Login as', border: OutlineInputBorder()), items: ['Admin','Doctor','Receptionist'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(), onChanged: (v) => setState(() => role = v ?? 'Admin')),
        CheckboxListTile(contentPadding: EdgeInsets.zero, value: remember, onChanged: (v) => setState(() => remember = v ?? true), title: const Text('Remember my session')),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: busy ? null : login, icon: const Icon(Icons.login), label: Padding(padding: const EdgeInsets.all(13), child: Text(busy ? 'Please wait...' : 'Sign in'))),
        const SizedBox(height: 14),
        const Text('Demo access: admin@carepoint.com  |  Password: 123456', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
      ])),
    )),
  );
}

class HomeScreen extends StatefulWidget {
  final String role;
  final VoidCallback onTheme;
  const HomeScreen({super.key, required this.role, required this.onTheme});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  bool loading = true;
  final List<Map<String,dynamic>> patients = [];
  final List<Map<String,dynamic>> doctors = [];
  final List<Map<String,dynamic>> appointments = [];
  final List<Map<String,dynamic>> invoices = [];

  @override
  void initState() { super.initState(); loadData(); }
  Future<void> loadData() async {
    final p = await SharedPreferences.getInstance();
    patients.addAll(_read(p, 'patients', [
      {'id':1,'name':'Ayesha Khan','age':'28','phone':'03001234567','condition':'General checkup'},
      {'id':2,'name':'Ali Raza','age':'42','phone':'03011234567','condition':'Follow-up'},
      {'id':3,'name':'Sara Ahmed','age':'35','phone':'03121234567','condition':'Dental care'},
    ]));
    doctors.addAll(_read(p, 'doctors', [
      {'id':1,'name':'Dr. Hina Malik','specialty':'Cardiology','available':true},
      {'id':2,'name':'Dr. Usman Ali','specialty':'Neurology','available':true},
      {'id':3,'name':'Dr. Sana Noor','specialty':'Dentistry','available':false},
    ]));
    appointments.addAll(_read(p, 'appointments', [
      {'id':1,'patient':'Ayesha Khan','doctor':'Dr. Hina Malik','date':'2026-11-19','time':'10:00 AM','status':'Confirmed'},
      {'id':2,'patient':'Ali Raza','doctor':'Dr. Usman Ali','date':'2026-11-20','time':'11:30 AM','status':'Pending'},
    ]));
    invoices.addAll(_read(p, 'invoices', [
      {'id':1,'patient':'Ayesha Khan','amount':'2500','status':'Paid'},
      {'id':2,'patient':'Ali Raza','amount':'1800','status':'Unpaid'},
    ]));
    if (mounted) setState(() => loading = false);
  }
  List<Map<String,dynamic>> _read(SharedPreferences p, String key, List<Map<String,dynamic>> fallback) {
    final raw = p.getString(key);
    if (raw == null) return fallback;
    try { return List<Map<String,dynamic>>.from((jsonDecode(raw) as List).map((e) => Map<String,dynamic>.from(e))); } catch (_) { return fallback; }
  }
  Future<void> saveData() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('patients', jsonEncode(patients));
    await p.setString('doctors', jsonEncode(doctors));
    await p.setString('appointments', jsonEncode(appointments));
    await p.setString('invoices', jsonEncode(invoices));
  }
  void refresh() { setState(() {}); saveData(); }
  int get pending => appointments.where((a) => a['status'] == 'Pending').length;
  @override
  Widget build(BuildContext context) {
    final pages = [
      dashboard(),
      patientPage(),
      doctorPage(),
      appointmentPage(),
      billingPage(),
      profilePage(),
    ];
    final titles = ['Dashboard','Patients','Doctors','Appointments','Billing','Profile'];
    return Scaffold(
      appBar: AppBar(title: Text(titles[tab], style: const TextStyle(fontWeight: FontWeight.bold)), actions: [
        IconButton(tooltip: 'Toggle theme', onPressed: widget.onTheme, icon: const Icon(Icons.dark_mode_outlined)),
        const SizedBox(width: 6),
      ]),
      body: loading ? const Center(child: CircularProgressIndicator()) : IndexedStack(index: tab, children: pages),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Patients'),
        NavigationDestination(icon: Icon(Icons.medical_services_outlined), selectedIcon: Icon(Icons.medical_services), label: 'Doctors'),
        NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Visits'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Billing'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ]),
    );
  }

  Widget dashboard() => ListView(padding: const EdgeInsets.all(16), children: [
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Color(0xFF126B78), Color(0xFF20A6A8)])), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Good day!', style: TextStyle(color: Colors.white70)),
      SizedBox(height: 5),
      Text('Hospital overview', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
      SizedBox(height: 5),
      Text('Manage daily operations in one place.', style: TextStyle(color: Colors.white70)),
    ])),
    const SizedBox(height: 16),
    GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.65, children: [
      statCard('Patients', '${patients.length}', Icons.people_alt_outlined, Colors.blue),
      statCard('Doctors', '${doctors.length}', Icons.medical_services_outlined, Colors.teal),
      statCard('Appointments', '${appointments.length}', Icons.calendar_month_outlined, Colors.deepPurple),
      statCard('Revenue', 'PKR ${invoices.where((i)=>i['status']=='Paid').fold<int>(0,(s,i)=>s+(int.tryParse('${i['amount']}')??0))}', Icons.payments_outlined, Colors.orange),
    ]),
    const SizedBox(height: 18),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Appointment activity', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        chartBar('Mon', 0.42), chartBar('Tue', 0.72), chartBar('Wed', 0.55), chartBar('Thu', 0.9), chartBar('Fri', 0.64), chartBar('Sat', 0.35),
      ]),
      const SizedBox(height: 8),
      Text('Illustrative sample activity (local demo data)', style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
    ]))),
    const SizedBox(height: 12),
    Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.pending_actions)), title: const Text('Pending appointments'), trailing: Text('$pending', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), subtitle: const Text('Require confirmation'))),
  ]);
  Widget statCard(String title, String value, IconData icon, Color color) => Card(child: Padding(padding: const EdgeInsets.all(13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Icon(icon, color: color), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)), Text(title, style: TextStyle(color: Theme.of(context).hintColor)),
  ])));
  Widget chartBar(String label, double v) => Column(children: [
    Container(width: 24, height: 95*v, decoration: BoxDecoration(color: const Color(0xFF20A6A8), borderRadius: BorderRadius.circular(7))),
    const SizedBox(height: 6), Text(label, style: const TextStyle(fontSize: 11)),
  ]);

  Widget patientPage() => DataPage(
    title: 'Patient records', empty: 'No patients found', addLabel: 'Add patient',
    items: patients,
    searchText: (m) => '${m['name']} ${m['phone']} ${m['condition']}',
    subtitle: (m) => 'Age ${m['age']} • ${m['phone']} • ${m['condition']}',
    icon: Icons.person,
    onAdd: () => editDialog('Add patient', ['Name','Age','Phone','Condition'], (v) { patients.add({'id':DateTime.now().millisecondsSinceEpoch,'name':v[0],'age':v[1],'phone':v[2],'condition':v[3]}); refresh(); }),
    onEdit: (m) => editDialog('Edit patient', ['Name','Age','Phone','Condition'], (v) { m['name']=v[0];m['age']=v[1];m['phone']=v[2];m['condition']=v[3];refresh(); }, initial: [m['name'],m['age'],m['phone'],m['condition']]),
    onDelete: (m) { patients.remove(m); refresh(); },
  );

  Widget doctorPage() => DataPage(
    title: 'Medical team', empty: 'No doctors found', addLabel: 'Add doctor',
    items: doctors,
    searchText: (m) => '${m['name']} ${m['specialty']}',
    subtitle: (m) => '${m['specialty']} • ${m['available']==true ? 'Available' : 'Unavailable'}',
    icon: Icons.medical_services,
    trailing: (m) => Switch(value: m['available']==true, onChanged: (v) { m['available']=v; refresh(); }),
    onAdd: () => editDialog('Add doctor', ['Name','Specialization'], (v) { doctors.add({'id':DateTime.now().millisecondsSinceEpoch,'name':v[0],'specialty':v[1],'available':true}); refresh(); }),
    onEdit: (m) => editDialog('Edit doctor', ['Name','Specialization'], (v) { m['name']=v[0];m['specialty']=v[1];refresh(); }, initial: [m['name'],m['specialty']]),
    onDelete: (m) { doctors.remove(m); refresh(); },
  );

  Widget appointmentPage() => DataPage(
    title: 'Appointments', empty: 'No appointments scheduled', addLabel: 'Book appointment',
    items: appointments,
    searchText: (m) => '${m['patient']} ${m['doctor']} ${m['status']}',
    subtitle: (m) => '${m['doctor']} • ${m['date']} at ${m['time']}',
    icon: Icons.event_available,
    trailing: (m) => PopupMenuButton<String>(onSelected: (v) { m['status']=v; refresh(); }, itemBuilder: (_) => ['Pending','Confirmed','Completed','Cancelled'].map((s)=>PopupMenuItem(value:s, child:Text(s))).toList(), child: Padding(padding: const EdgeInsets.all(8), child: Chip(label: Text('${m['status']}')))),
    onAdd: () => editDialog('Book appointment', ['Patient name','Doctor name','Date (YYYY-MM-DD)','Time'], (v) { appointments.add({'id':DateTime.now().millisecondsSinceEpoch,'patient':v[0],'doctor':v[1],'date':v[2],'time':v[3],'status':'Pending'}); refresh(); }),
    onEdit: (m) => editDialog('Reschedule appointment', ['Patient name','Doctor name','Date (YYYY-MM-DD)','Time'], (v) { m['patient']=v[0];m['doctor']=v[1];m['date']=v[2];m['time']=v[3];refresh(); }, initial: [m['patient'],m['doctor'],m['date'],m['time']]),
    onDelete: (m) { appointments.remove(m); refresh(); },
  );

  Widget billingPage() => DataPage(
    title: 'Invoices', empty: 'No invoices created', addLabel: 'Create invoice',
    items: invoices,
    searchText: (m) => '${m['patient']} ${m['status']}',
    subtitle: (m) => 'PKR ${m['amount']} • ${m['status']}',
    icon: Icons.receipt_long,
    trailing: (m) => PopupMenuButton<String>(onSelected: (v) { m['status']=v; refresh(); }, itemBuilder: (_) => ['Paid','Unpaid'].map((s)=>PopupMenuItem(value:s, child:Text(s))).toList(), child: Padding(padding: const EdgeInsets.all(8), child: Chip(label: Text('${m['status']}')))),
    onAdd: () => editDialog('Create invoice', ['Patient name','Amount (PKR)'], (v) { invoices.add({'id':DateTime.now().millisecondsSinceEpoch,'patient':v[0],'amount':v[1],'status':'Unpaid'}); refresh(); }),
    onEdit: (m) => editDialog('Edit invoice', ['Patient name','Amount (PKR)'], (v) { m['patient']=v[0];m['amount']=v[1];refresh(); }, initial: [m['patient'],m['amount']]),
    onDelete: (m) { invoices.remove(m); refresh(); },
  );

  Widget profilePage() => ListView(padding: const EdgeInsets.all(16), children: [
    const SizedBox(height: 20),
    const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 42)),
    const SizedBox(height: 12),
    Text(widget.role, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
    const Text('CarePoint Hospital staff account', textAlign: TextAlign.center),
    const SizedBox(height: 24),
    Card(child: Column(children: [
      const ListTile(leading: Icon(Icons.account_circle_outlined), title: Text('Profile'), subtitle: Text('Demo staff profile')),
      const Divider(height: 1),
      ListTile(leading: const Icon(Icons.dark_mode_outlined), title: const Text('Dark mode'), trailing: IconButton(onPressed: widget.onTheme, icon: const Icon(Icons.toggle_on))),
      const Divider(height: 1),
      const ListTile(leading: Icon(Icons.storage_outlined), title: Text('Data storage'), subtitle: Text('Saved locally on this device using SharedPreferences')),
    ])),
    const SizedBox(height: 18),
    OutlinedButton.icon(onPressed: logout, icon: const Icon(Icons.logout), label: const Text('Log out')),
    const SizedBox(height: 12),
    Text('CarePoint Hospital • Internship demo • Uses fictional sample records only', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
  ]);

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('loggedIn', false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginScreen(onTheme: widget.onTheme)), (_) => false);
  }

  Future<void> editDialog(String title, List<String> labels, void Function(List<String>) save, {List<String>? initial}) async {
    final ctrls = labels.asMap().entries.map((e) => TextEditingController(text: initial != null && e.key < initial.length ? initial[e.key] : '')).toList();
    await showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: List.generate(labels.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: ctrls[i], decoration: InputDecoration(labelText: labels[i], border: const OutlineInputBorder()))))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          final values = ctrls.map((c)=>c.text.trim()).toList();
          if (values.any((v)=>v.isEmpty)) return;
          save(values); Navigator.pop(ctx);
        }, child: const Text('Save')),
      ],
    ));
    for (final c in ctrls) { c.dispose(); }
  }
}

class DataPage extends StatefulWidget {
  final String title, empty, addLabel;
  final List<Map<String,dynamic>> items;
  final String Function(Map<String,dynamic>) searchText, subtitle;
  final IconData icon;
  final Widget Function(Map<String,dynamic>)? trailing;
  final VoidCallback onAdd;
  final void Function(Map<String,dynamic>) onEdit, onDelete;
  const DataPage({super.key, required this.title, required this.empty, required this.addLabel, required this.items, required this.searchText, required this.subtitle, required this.icon, required this.onAdd, required this.onEdit, required this.onDelete, this.trailing});
  @override
  State<DataPage> createState() => _DataPageState();
}
class _DataPageState extends State<DataPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((m)=>widget.searchText(m).toLowerCase().contains(query.toLowerCase())).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 8), child: TextField(onChanged: (v)=>setState(()=>query=v), decoration: InputDecoration(hintText: 'Search ${widget.title.toLowerCase()}...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), filled: true))),
      Expanded(child: filtered.isEmpty ? Center(child: Text(widget.empty)) : ListView.separated(padding: const EdgeInsets.all(12), itemCount: filtered.length, separatorBuilder: (_,__)=>const SizedBox(height: 8), itemBuilder: (_,i) {
        final m = filtered[i];
        return Card(child: ListTile(
          leading: CircleAvatar(child: Icon(widget.icon)),
          title: Text('${m['name'] ?? m['patient'] ?? 'Record'}', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(widget.subtitle(m)),
          trailing: widget.trailing != null ? widget.trailing!(m) : PopupMenuButton<String>(onSelected: (v) { if (v=='edit') widget.onEdit(m); if (v=='delete') widget.onDelete(m); }, itemBuilder: (_) => const [PopupMenuItem(value:'edit',child:Text('Edit')),PopupMenuItem(value:'delete',child:Text('Delete'))]),
        ));
      })),
      Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 14), child: SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: widget.onAdd, icon: const Icon(Icons.add), label: Text(widget.addLabel)))),
    ]);
  }
}

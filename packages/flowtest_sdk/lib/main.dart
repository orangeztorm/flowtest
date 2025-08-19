import 'package:flutter/material.dart';
import 'dart:convert';
import 'recorder/run_on_next_launch.dart';
import 'runner/flow_replayer.dart';
import 'models/test_flow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check for pending replay on app start
  await _maybeAutoReplay();

  runApp(const FlowTestDemoApp());
}

/// Check if there's a pending flow replay and execute it
Future<void> _maybeAutoReplay() async {
  try {
    final pending = await getPendingReplay();
    if (pending == null) return;

    // Store the pending replay data to be used after the app is built
    _pendingReplayData = pending;
  } catch (e) {
    debugPrint('Auto-replay setup failed: $e');
  }
}

// Global variable to store pending replay data
Map<String, dynamic>? _pendingReplayData;

class FlowTestDemoApp extends StatelessWidget {
  const FlowTestDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowTest SDK Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: DemoHomePage(pendingReplay: _pendingReplayData),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  final Map<String, dynamic>? pendingReplay;

  const DemoHomePage({super.key, this.pendingReplay});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  int _counter = 0;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _handlePendingReplay();
  }

  void _handlePendingReplay() {
    if (widget.pendingReplay != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final flow = TestFlow.fromJson(
            jsonDecode(widget.pendingReplay!['json']),
          );
          final speed = widget.pendingReplay!['speed'] as double;

          // Show a snackbar to indicate auto-replay is starting
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Auto-replaying flow: ${flow.flowId}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );

          await FlowReplayer(rootContext: context, speed: speed).replay(flow);
        } catch (e) {
          debugPrint('Auto-replay failed: $e');
        }
      });
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _simulateLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoggedIn = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful!')));
    }
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _counter = 0;
    });
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('FlowTest SDK Demo'),
        actions: [
          if (_isLoggedIn)
            IconButton(
              key: const Key('logout_button'),
              onPressed: _logout,
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: _isLoggedIn ? _buildLoggedInView() : _buildLoginView(),
      floatingActionButton: _isLoggedIn
          ? FloatingActionButton(
              key: const Key('increment_button'),
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildLoginView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.blue),
            const SizedBox(height: 32),
            const Text(
              'FlowTest SDK Demo Login',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextFormField(
              key: const Key('email_field'),
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter an email';
                }
                if (!value!.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('password_field'),
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a password';
                }
                if (value!.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('login_button'),
              onPressed: _simulateLogin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text('Login'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tip: Use any email and password (6+ chars) to login',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 100, color: Colors.green),
          const SizedBox(height: 24),
          const Text(
            'Welcome!',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Logged in as: ${_emailController.text}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          const Text('You have pushed the button this many times:'),
          Text(
            '$_counter',
            key: const Key('counter_text'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 32),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(height: 8),
                  Text(
                    'FlowTest SDK Recording',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'In debug mode, use the blue record button to capture your interactions as test flows!',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

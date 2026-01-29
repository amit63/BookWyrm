import 'package:bookwyrm/homescreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ppzmtudsdomvgeuhgetb.supabase.co',
    anonKey: 'sb_publishable_uyBmsJsIg9KWzuhVgLZ78w_osLrqgc6',
  );

  runApp(const BookWyrmApp());
}

class BookWyrmApp extends StatelessWidget {
  const BookWyrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Check for an existing session to auto-login
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BookWyrm',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color.fromARGB(255, 9, 53, 10),
      ),
      home: session != null ? const HomeScreen() : const BookWyrmLogin(),
    );
  }
}

class BookWyrmLogin extends StatefulWidget {
  const BookWyrmLogin({super.key});

  @override
  State<BookWyrmLogin> createState() => _BookWyrmLoginState();
}

class _BookWyrmLoginState extends State<BookWyrmLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // 3. Centralized SignIn Method
  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError("An unexpected error occurred.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 4. Centralized SignUp Method
  Future<void> _handleSignUp() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        _showError("Account created! Check your email for verification.");
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          // Added to prevent keyboard overflow
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const Icon(
                Icons.auto_stories,
                size: 80,
                color: Color.fromARGB(255, 9, 53, 10),
              ),
              const SizedBox(height: 16),
              const Text(
                "BookWyrm",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text("Read more, read curious, read together."),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleLogin, // Linked directly to the logic
                    child: const Text("Login"),
                  ),
                ),
                TextButton(
                  onPressed: _handleSignUp, // Added signup button
                  child: const Text("Create a BookWyrm Account"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

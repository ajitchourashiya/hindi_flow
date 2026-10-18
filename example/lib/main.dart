import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hindi_flow/hindi_flow.dart';

void main() => runApp(const HindiFlowExampleApp());

const _apiUrl = 'https://hindiflow-api.contact-internchoice.workers.dev';
const _ink = Color(0xFF20243A);
const _purple = Color(0xFF6254D9);
const _page = Color(0xFFF6F7FC);

class HindiFlowExampleApp extends StatelessWidget {
  const HindiFlowExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'HindiFlow Studio',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: _page,
          colorScheme: ColorScheme.fromSeed(seedColor: _purple),
          fontFamily: 'Roboto',
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF7F8FC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE7E9F2))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _purple, width: 1.5)),
          ),
        ),
        home: const TranslatorScreen(),
      );
}

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});
  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final _input = TextEditingController(text: 'How are you my friend?');
  String _api = _apiUrl;
  String? _translation;
  String? _error;
  bool _loading = false;
  bool _initialized = false;
  bool _showApiSettings = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await HindiFlow.initialize(baseUrl: _api.trim());
      if (!mounted) return;
      setState(() {
        _initialized = true;
        _error = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API connected successfully')));
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    }
  }

  String _friendlyError(Object e) =>
      e.toString().replaceFirst('Exception: ', '');

  Future<void> _translate() async {
    if (_input.text.trim().isEmpty) {
      setState(() {
        _error = 'Please enter some English text first.';
        _translation = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _translation = null;
    });
    try {
      await HindiFlow.initialize(baseUrl: _api.trim());
      final result =
          await HindiFlow.translate(_input.text.trim(), useCache: false);
      if (mounted)
        setState(() {
          _initialized = true;
          _translation = result;
        });
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _useSample(String value) {
    setState(() {
      _input.text = value;
      _translation = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              children: [
                Row(children: [
                  Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                          color: _purple,
                          borderRadius: BorderRadius.circular(15)),
                      child: const Icon(Icons.translate_rounded,
                          color: Colors.white, size: 26)),
                  const SizedBox(width: 12),
                  const Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('HindiFlow',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _ink)),
                        Text('Translation Studio',
                            style: TextStyle(
                                color: Color(0xFF7C8198), fontSize: 13))
                      ])),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 8),
                      decoration: BoxDecoration(
                          color: _initialized
                              ? const Color(0xFFE7F8EF)
                              : const Color(0xFFEDEBFF),
                          borderRadius: BorderRadius.circular(30)),
                      child: Row(children: [
                        Icon(
                            _initialized
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            size: 15,
                            color: _initialized
                                ? const Color(0xFF188451)
                                : _purple),
                        const SizedBox(width: 6),
                        Text(_initialized ? 'Connected' : 'Ready to connect',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _initialized
                                    ? const Color(0xFF188451)
                                    : _purple))
                      ])),
                ]),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF6557DE), Color(0xFF8A69E8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(26)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .16),
                                borderRadius: BorderRadius.circular(30)),
                            child: const Text('ENGLISH  →  HINDI',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1))),
                        const SizedBox(height: 16),
                        const Text('Say it in Hindi.',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                height: 1.1,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text('Translate everyday text with your HindiFlow API.',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: .16),
                                fontSize: 14)),
                        const SizedBox(height: 18),
                        Row(children: [
                          const Icon(Icons.cloud_done_outlined,
                              color: Colors.white70, size: 17),
                          const SizedBox(width: 7),
                          Expanded(
                              child: Text(_api,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11),
                                  overflow: TextOverflow.ellipsis)),
                          IconButton(
                              tooltip: 'API settings',
                              onPressed: () => setState(
                                  () => _showApiSettings = !_showApiSettings),
                              icon: const Icon(Icons.tune_rounded,
                                  color: Colors.white))
                        ]),
                      ]),
                ),
                if (_showApiSettings) ...[
                  const SizedBox(height: 14),
                  _panel(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Text('API endpoint',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, color: _ink)),
                        const SizedBox(height: 10),
                        TextFormField(
                            initialValue: _api,
                            keyboardType: TextInputType.url,
                            onChanged: (v) => _api = v,
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.link_rounded),
                                hintText: 'https://your-api.example.com')),
                        const SizedBox(height: 10),
                        SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                                onPressed: _initialize,
                                icon: const Icon(Icons.wifi_tethering_rounded),
                                label: const Text('Connect API')))
                      ])),
                ],
                const SizedBox(height: 18),
                _panel(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Row(children: [
                        Icon(Icons.edit_note_rounded, color: _purple),
                        SizedBox(width: 8),
                        Text('Your text',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: _ink))
                      ]),
                      const SizedBox(height: 14),
                      TextField(
                          controller: _input,
                          minLines: 4,
                          maxLines: 7,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                              hintText: 'Type something in English...')),
                      const SizedBox(height: 14),
                      const Text('TRY A SAMPLE',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: Color(0xFF858AA0))),
                      const SizedBox(height: 9),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        _sample('How are you my friend?',
                            () => _useSample('How are you my friend?')),
                        _sample('Welcome to HindiFlow!',
                            () => _useSample('Welcome to HindiFlow!')),
                        _sample(
                            'Good morning', () => _useSample('Good morning')),
                      ]),
                      const SizedBox(height: 18),
                      SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                              onPressed: _loading ? null : _translate,
                              icon: _loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.auto_awesome_rounded),
                              label: Text(
                                  _loading
                                      ? 'Translating…'
                                      : 'Translate to Hindi',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15)),
                              style: FilledButton.styleFrom(
                                  backgroundColor: _purple,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15))))),
                    ])),
                if (_translation != null) ...[
                  const SizedBox(height: 16),
                  _panel(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF188451)),
                          const SizedBox(width: 8),
                          const Expanded(
                              child: Text('Hindi translation',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: _ink))),
                          IconButton(
                              tooltip: 'Copy translation',
                              onPressed: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: _translation!));
                                if (mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Translation copied')));
                              },
                              icon: const Icon(Icons.copy_rounded,
                                  color: _purple))
                        ]),
                        const SizedBox(height: 12),
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF4F2FF),
                                borderRadius: BorderRadius.circular(17)),
                            child: SelectableText(_translation!,
                                style: const TextStyle(
                                    fontSize: 25,
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                    color: _ink))),
                        const SizedBox(height: 12),
                        const Text('Powered by your HindiFlow API',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF858AA0)))
                      ])),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFEEEE),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFD4D4))),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: Color(0xFFB42318)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: SelectableText(_error!,
                                    style: const TextStyle(
                                        color: Color(0xFF8B1E18))))
                          ])),
                ],
                const SizedBox(height: 16),
                _panel(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Row(children: [
                        Icon(Icons.widgets_outlined, color: _purple),
                        SizedBox(width: 8),
                        Text('Flutter widget preview',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, color: _ink))
                      ]),
                      const SizedBox(height: 8),
                      const Text(
                          'Use HindiText anywhere in your app to translate a string asynchronously.',
                          style: TextStyle(
                              color: Color(0xFF777D92), height: 1.45)),
                      const SizedBox(height: 12),
                      if (_initialized)
                        const HindiText('Welcome to HindiFlow!',
                            placeholder: 'Translating widget…',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _ink))
                      else
                        const Text(
                            'Connect the API or translate once to enable the widget preview.',
                            style: TextStyle(
                                color: Color(0xFF858AA0), fontSize: 13))
                    ])),
                const SizedBox(height: 20),
                const Center(
                    child: Text('Made for developers  •  HindiFlow 0.1.0',
                        style:
                            TextStyle(color: Color(0xFF9A9EB0), fontSize: 11))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _panel({required Widget child}) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE9EAF2)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x080F1735), blurRadius: 18, offset: Offset(0, 5))
          ]),
      child: child);

  Widget _sample(String text, VoidCallback onTap) => ActionChip(
      label: Text(text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      onPressed: onTap,
      backgroundColor: const Color(0xFFF1F0FF),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)));
}

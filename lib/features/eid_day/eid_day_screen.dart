import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../services/audio_service.dart';
import '../../widgets/fireworks.dart';

class EidDayScreen extends ConsumerStatefulWidget {
  const EidDayScreen({super.key});

  @override
  ConsumerState<EidDayScreen> createState() => _EidDayScreenState();
}

class _EidDayScreenState extends ConsumerState<EidDayScreen>
    with TickerProviderStateMixin {
  final AudioService _audio = AudioService();
  bool _audioPlaying = false;
  bool _audioMissing = false;

  late final AnimationController _greetingCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAudio());
  }

  Future<void> _startAudio() async {
    final bool ok = await _audio.playLoop('assets/audio/takbeer.mp3');
    if (!mounted) return;
    setState(() {
      _audioPlaying = ok;
      _audioMissing = !ok;
    });
  }

  Future<void> _toggleAudio() async {
    if (_audioPlaying) {
      await _audio.stop();
      if (mounted) setState(() => _audioPlaying = false);
    } else {
      final bool ok = await _audio.playLoop('assets/audio/takbeer.mp3');
      if (mounted) {
        setState(() {
          _audioPlaying = ok;
          _audioMissing = !ok;
        });
      }
    }
  }

  @override
  void dispose() {
    _audio.stop();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _greetingCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EidColors.darkGreen,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // خلفية متدرّجة عيدية.
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.4,
                colors: <Color>[
                  Color(0xFF0A3D2C),
                  Color(0xFF064E3B),
                  Color(0xFF021A12),
                ],
              ),
            ),
          ),
          // نجوم خفيفة.
          const Positioned.fill(child: _StarsLayer()),
          // ألعاب نارية.
          const Positioned.fill(child: FireworksLayer()),
          // المحتوى.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: EidColors.cream,
                          size: 28,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      IconButton(
                        icon: Icon(
                          _audioPlaying
                              ? Icons.volume_up
                              : Icons.volume_off,
                          color: EidColors.gold,
                          size: 28,
                        ),
                        tooltip: _audioPlaying ? 'إيقاف التكبير' : 'تشغيل التكبير',
                        onPressed: _toggleAudio,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: FadeTransition(
                        opacity: _greetingCtrl,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.7, end: 1).animate(
                            CurvedAnimation(
                              parent: _greetingCtrl,
                              curve: Curves.elasticOut,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.95,
                                  end: 1.08,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _pulseCtrl,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                child: const Text(
                                  '🌙',
                                  style: TextStyle(fontSize: 72),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const _GoldText(
                                'عيد مبارك',
                                fontSize: 56,
                                weight: FontWeight.w900,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: EidColors.gold.withValues(alpha: 0.55),
                                  ),
                                ),
                                child: const Text(
                                  'الله أكبر · الله أكبر · لا إله إلا الله',
                                  style: TextStyle(
                                    color: EidColors.cream,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                EidDateUtils.todayHijri(),
                                style: TextStyle(
                                  color: EidColors.cream.withValues(alpha: 0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_audioMissing)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: EidColors.gold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        children: <Widget>[
                          Icon(
                            Icons.info_outline,
                            color: EidColors.gold,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'لم يُضَف ملف التكبيرات. ضع takbeer.mp3 في '
                              'assets/audio/.',
                              style: TextStyle(
                                color: EidColors.cream,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: EidColors.gold,
                        foregroundColor: EidColors.darkGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      icon: const Icon(Icons.celebration),
                      label: const Text(
                        'تقبّل الله منّا ومنكم',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldText extends StatelessWidget {
  const _GoldText(this.text, {required this.fontSize, required this.weight});
  final String text;
  final double fontSize;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect rect) => const LinearGradient(
        colors: <Color>[
          Color(0xFFFFE082),
          EidColors.gold,
          Color(0xFFB8860B),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: Colors.white,
          height: 1.1,
          shadows: const <Shadow>[
            Shadow(
              color: Colors.black54,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarsLayer extends StatelessWidget {
  const _StarsLayer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StarsPainter());
  }
}

class _StarsPainter extends CustomPainter {
  static final List<Offset> _stars = List<Offset>.generate(
    60,
    (int i) => Offset(
      ((i * 37) % 100) / 100,
      ((i * 53) % 100) / 100 * 0.6,
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = EidColors.gold.withValues(alpha: 0.6);
    for (int i = 0; i < _stars.length; i++) {
      final Offset n = _stars[i];
      final double r = (i.isEven ? 1.0 : 1.6);
      canvas.drawCircle(
        Offset(n.dx * size.width, n.dy * size.height),
        r,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) => false;
}

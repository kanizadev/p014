import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:ui'; // Added for ImageFilter

void main() {
  runApp(const ColorPaletteApp());
}

enum ColorSchemeType {
  random,
  monochromatic,
  complementary,
  triadic,
  analogous,
  splitComplementary,
}

class SavedPalette {
  final List<Color> colors;
  final DateTime createdAt;
  final String? name;

  SavedPalette({required this.colors, required this.createdAt, this.name});

  Map<String, dynamic> toJson() {
    return {
      'colors': colors.map((c) => c.toARGB32()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'name': name,
    };
  }

  factory SavedPalette.fromJson(Map<String, dynamic> json) {
    return SavedPalette(
      colors: (json['colors'] as List).map((c) => Color(c)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      name: json['name'],
    );
  }
}

class ColorPaletteApp extends StatelessWidget {
  const ColorPaletteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Color Palette Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF87A96B), // Sage green
          brightness: Brightness.light,
        ),
      ),
      home: const PaletteGeneratorScreen(),
    );
  }
}

class PaletteGeneratorScreen extends StatefulWidget {
  const PaletteGeneratorScreen({super.key});

  @override
  State<PaletteGeneratorScreen> createState() => _PaletteGeneratorScreenState();
}

class _PaletteGeneratorScreenState extends State<PaletteGeneratorScreen>
    with SingleTickerProviderStateMixin {
  List<Color> _currentPalette = [];
  final Random _random = Random();
  ColorSchemeType _schemeType = ColorSchemeType.random;
  Color? _baseColor;
  double _brightness = 0.0;
  double _saturation = 0.0;
  final List<SavedPalette> _savedPalettes = [];
  bool _showAdvancedOptions = false;
  late TabController _tabController;
  String? _copiedText;
  bool _showCopyBox = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generatePalette();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generatePalette() {
    setState(() {
      if (_baseColor != null) {
        _currentPalette = _generateSchemeFromColor(_baseColor!, _schemeType);
      } else {
        _currentPalette = _generateScheme(_schemeType);
      }

      if (_brightness != 0.0 || _saturation != 0.0) {
        _currentPalette = _currentPalette.map((color) {
          return _adjustColor(color, _brightness, _saturation);
        }).toList();
      }
    });
  }

  List<Color> _generateScheme(ColorSchemeType type) {
    final baseHue = _random.nextDouble() * 360;
    final baseSat = 0.5 + _random.nextDouble() * 0.5;
    final baseLight = 0.3 + _random.nextDouble() * 0.4;
    return _generateSchemeFromHSL(baseHue, baseSat, baseLight, type);
  }

  List<Color> _generateSchemeFromColor(Color color, ColorSchemeType type) {
    final hsl = _colorToHSL(color);
    return _generateSchemeFromHSL(hsl[0], hsl[1], hsl[2], type);
  }

  List<Color> _generateSchemeFromHSL(
    double h,
    double s,
    double l,
    ColorSchemeType type,
  ) {
    switch (type) {
      case ColorSchemeType.random:
        return List.generate(5, (_) => _generateRandomColor());
      case ColorSchemeType.monochromatic:
        return List.generate(5, (i) {
          final lightness = (l + (i - 2) * 0.15).clamp(0.1, 0.9);
          return _hslToColor(h, s, lightness);
        });
      case ColorSchemeType.complementary:
        return [
          _hslToColor(h, s, l),
          _hslToColor(h, s, (l + 0.2).clamp(0.0, 1.0)),
          _hslToColor((h + 180) % 360, s, l),
          _hslToColor(h, s, (l - 0.2).clamp(0.0, 1.0)),
          _hslToColor((h + 180) % 360, s, (l + 0.2).clamp(0.0, 1.0)),
        ];
      case ColorSchemeType.triadic:
        return [
          _hslToColor(h, s, l),
          _hslToColor((h + 120) % 360, s, l),
          _hslToColor((h + 240) % 360, s, l),
          _hslToColor(h, s, (l + 0.15).clamp(0.0, 1.0)),
          _hslToColor((h + 120) % 360, s, (l + 0.15).clamp(0.0, 1.0)),
        ];
      case ColorSchemeType.analogous:
        return List.generate(5, (i) {
          final hue = (h + (i - 2) * 30) % 360;
          return _hslToColor(hue, s, l + (i - 2) * 0.1);
        });
      case ColorSchemeType.splitComplementary:
        return [
          _hslToColor(h, s, l),
          _hslToColor((h + 150) % 360, s, l),
          _hslToColor((h + 210) % 360, s, l),
          _hslToColor(h, s, (l + 0.2).clamp(0.0, 1.0)),
          _hslToColor((h + 180) % 360, s, (l + 0.15).clamp(0.0, 1.0)),
        ];
    }
  }

  Color _generateRandomColor() {
    return Color.fromRGBO(
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
      1.0,
    );
  }

  List<double> _colorToHSL(Color color) {
    final r = color.r;
    final g = color.g;
    final b = color.b;

    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);
    final delta = max - min;

    double h = 0.0;
    if (delta != 0) {
      if (max == r) {
        h = ((g - b) / delta) % 6;
      } else if (max == g) {
        h = (b - r) / delta + 2;
      } else {
        h = (r - g) / delta + 4;
      }
    }
    h = (h * 60) % 360;
    if (h < 0) h += 360;

    final l = (max + min) / 2.0;
    final s = delta == 0 ? 0.0 : (delta / (1 - (2 * l - 1).abs())).toDouble();

    return [h, s, l];
  }

  Color _hslToColor(double h, double s, double l) {
    final c = (1 - (2 * l - 1).abs()) * s;
    final x = c * (1 - ((h / 60) % 2 - 1).abs());
    final m = l - c / 2;

    double r = 0, g = 0, b = 0;

    if (h < 60) {
      r = c;
      g = x;
      b = 0;
    } else if (h < 120) {
      r = x;
      g = c;
      b = 0;
    } else if (h < 180) {
      r = 0;
      g = c;
      b = x;
    } else if (h < 240) {
      r = 0;
      g = x;
      b = c;
    } else if (h < 300) {
      r = x;
      g = 0;
      b = c;
    } else {
      r = c;
      g = 0;
      b = x;
    }

    return Color.fromRGBO(
      ((r + m) * 255).round().clamp(0, 255),
      ((g + m) * 255).round().clamp(0, 255),
      ((b + m) * 255).round().clamp(0, 255),
      1.0,
    );
  }

  Color _adjustColor(Color color, double brightness, double saturation) {
    final hsl = _colorToHSL(color);
    var newLight = (hsl[2] + brightness).clamp(0.0, 1.0);
    var newSat = (hsl[1] + saturation).clamp(0.0, 1.0);
    return _hslToColor(hsl[0], newSat, newLight);
  }

  String _colorToHex(Color color) {
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    return '#${(r << 16 | g << 8 | b).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  Color _getContrastColor(Color color) {
    final brightness =
        ((color.r * 255 * 299) +
            (color.g * 255 * 587) +
            (color.b * 255 * 114)) /
        1000;
    return brightness > 128 ? Colors.black : Colors.white;
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      setState(() {
        _copiedText = text;
        _showCopyBox = true;
      });

      // Hide copy box after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showCopyBox = false;
            _copiedText = null;
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Copied to clipboard!'),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _savePalette() {
    setState(() {
      _savedPalettes.insert(
        0,
        SavedPalette(
          colors: List.from(_currentPalette),
          createdAt: DateTime.now(),
        ),
      );
      if (_savedPalettes.length > 20) {
        _savedPalettes.removeLast();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Palette saved!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getSchemeTypeName(ColorSchemeType type) {
    switch (type) {
      case ColorSchemeType.random:
        return 'Random';
      case ColorSchemeType.monochromatic:
        return 'Monochromatic';
      case ColorSchemeType.complementary:
        return 'Complementary';
      case ColorSchemeType.triadic:
        return 'Triadic';
      case ColorSchemeType.analogous:
        return 'Analogous';
      case ColorSchemeType.splitComplementary:
        return 'Split Complementary';
    }
  }

  Widget _buildCopyBox() {
    if (!_showCopyBox || _copiedText == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showCopyBox = false;
            _copiedText = null;
          });
        },
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent tap from propagating to background
              child: AnimatedOpacity(
                opacity: _showCopyBox ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      constraints: BoxConstraints(
                        maxWidth: 600,
                        minWidth: 320,
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                        minHeight: 200,
                      ),
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.95),
                            Colors.white.withValues(alpha: 0.9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: const Color(
                              0xFF87A96B,
                            ).withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green.shade700,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Copied!',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _showCopyBox = false;
                                      _copiedText = null;
                                    });
                                  },
                                  icon: const Icon(Icons.close),
                                  color: Colors.grey.shade700,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(
                                minHeight: 100,
                                maxHeight: 400,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: SelectableText(
                                _copiedText!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                  color: Colors.grey.shade900,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showCopyBox = false;
                                    _copiedText = null;
                                  });
                                },
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Close'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey.shade700,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFE8F5E9), // Light sage green
                  const Color(0xFFC8E6C9), // Medium sage green
                  const Color(0xFFA5D6A7), // Sage green
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Column(
              children: [
                ClipRRect(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(
                            0xFF87A96B,
                          ).withValues(alpha: 0.95), // Sage green
                          const Color(
                            0xFF6B8E4F,
                          ).withValues(alpha: 0.95), // Darker sage green
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF87A96B).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 16.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.palette,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Color Palette Generator',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TabBar(
                            controller: _tabController,
                            indicatorColor: Colors.white,
                            indicatorWeight: 3,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white70,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            tabs: const [
                              Tab(
                                text: 'Generator',
                                icon: Icon(Icons.palette),
                                iconMargin: EdgeInsets.only(bottom: 4),
                              ),
                              Tab(
                                text: 'Saved',
                                icon: Icon(Icons.bookmark),
                                iconMargin: EdgeInsets.only(bottom: 4),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildGeneratorTab(), _buildSavedTab()],
                  ),
                ),
              ],
            ),
          ),
          _buildCopyBox(),
        ],
      ),
    );
  }

  Widget _buildGeneratorTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Color Scheme',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: Icon(
                            _showAdvancedOptions
                                ? Icons.expand_less
                                : Icons.expand_more,
                          ),
                          onPressed: () {
                            setState(() {
                              _showAdvancedOptions = !_showAdvancedOptions;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ColorSchemeType.values.map((type) {
                          final isSelected = _schemeType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: FilterChip(
                              label: Text(
                                _getSchemeTypeName(type),
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFFC8E6C9),
                              checkmarkColor: const Color(0xFF4A5F3A),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _schemeType = type;
                                    _generatePalette();
                                  });
                                }
                              },
                              elevation: isSelected ? 4 : 1,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF87A96B)
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showAdvancedOptions)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Brightness: ${_brightness.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Slider(
                                  value: _brightness,
                                  min: -0.5,
                                  max: 0.5,
                                  onChanged: (value) {
                                    setState(() {
                                      _brightness = value;
                                      _generatePalette();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Saturation: ${_saturation.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Slider(
                                  value: _saturation,
                                  min: -0.5,
                                  max: 0.5,
                                  onChanged: (value) {
                                    setState(() {
                                      _saturation = value;
                                      _generatePalette();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final Color? picked = await showDialog<Color>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Pick Base Color'),
                                    content: Container(
                                      width: 300,
                                      height: 300,
                                      padding: const EdgeInsets.all(8.0),
                                      child: GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 8,
                                              mainAxisSpacing: 4,
                                              crossAxisSpacing: 4,
                                            ),
                                        itemCount: 64,
                                        itemBuilder: (context, index) {
                                          final hue = (index * 5.625) % 360;
                                          final color = _hslToColor(
                                            hue,
                                            1.0,
                                            0.5,
                                          );
                                          return InkWell(
                                            onTap: () =>
                                                Navigator.pop(context, color),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: color,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: _baseColor == color
                                                    ? Border.all(
                                                        color: Colors.white,
                                                        width: 3,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  ),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _baseColor = picked;
                                    _generatePalette();
                                  });
                                }
                              },
                              icon: const Icon(Icons.colorize),
                              label: Text(
                                _baseColor == null
                                    ? 'Pick Base Color'
                                    : 'Base: ${_colorToHex(_baseColor!)}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          if (_baseColor != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _baseColor = null;
                                  _generatePalette();
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              children: _currentPalette.asMap().entries.map((entry) {
                final index = entry.key;
                final color = entry.value;
                final hexCode = _colorToHex(color);
                final contrastColor = _getContrastColor(color);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Material(
                          color: Colors.transparent,
                          elevation: 8,
                          borderRadius: BorderRadius.circular(24),
                          shadowColor: color.withValues(alpha: 0.5),
                          child: InkWell(
                            onTap: () => _copyToClipboard(hexCode),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    color.withValues(alpha: 0.9),
                                    Color.lerp(
                                      color,
                                      Colors.black,
                                      0.1,
                                    )!.withValues(alpha: 0.9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 25,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28.0,
                                  vertical: 20.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Color ${index + 1}',
                                            style: TextStyle(
                                              color: contrastColor.withValues(
                                                alpha: 0.9,
                                              ),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          const SizedBox(height: 6),
                                          Flexible(
                                            child: Text(
                                              hexCode,
                                              style: TextStyle(
                                                color: contrastColor,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.2,
                                                fontFeatures: [
                                                  FontFeature.tabularFigures(),
                                                ],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Flexible(
                                            child: Text(
                                              'RGB(${(color.r * 255).round()}, ${(color.g * 255).round()}, ${(color.b * 255).round()})',
                                              style: TextStyle(
                                                color: contrastColor.withValues(
                                                  alpha: 0.85,
                                                ),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: contrastColor.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: contrastColor.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.copy,
                                        color: contrastColor,
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generatePalette,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Generate'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _savePalette,
                  icon: const Icon(Icons.bookmark_add),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildCopyButton('Copy Hex', Icons.copy_all, () {
                  final allHex = _currentPalette
                      .map((c) => _colorToHex(c))
                      .join(', ');
                  _copyToClipboard(allHex);
                }),
                const SizedBox(width: 8),
                _buildCopyButton('Copy RGB', Icons.code, () {
                  final rgbCodes = _currentPalette
                      .map(
                        (c) =>
                            'rgb(${(c.r * 255).round()}, ${(c.g * 255).round()}, ${(c.b * 255).round()})',
                      )
                      .join(', ');
                  _copyToClipboard(rgbCodes);
                }),
                const SizedBox(width: 8),
                _buildCopyButton('Copy CSS', Icons.style, () {
                  final css = _currentPalette
                      .asMap()
                      .entries
                      .map(
                        (e) =>
                            '  --color-${e.key + 1}: ${_colorToHex(e.value)};',
                      )
                      .join('\n');
                  _copyToClipboard(':root {\n$css\n}');
                }),
                const SizedBox(width: 8),
                _buildCopyButton('Copy JSON', Icons.data_object, () {
                  final json = jsonEncode({
                    'colors': _currentPalette
                        .map((c) => _colorToHex(c))
                        .toList(),
                    'scheme': _getSchemeTypeName(_schemeType),
                  });
                  _copyToClipboard(json);
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCopyButton(String label, IconData icon, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Widget _buildSavedTab() {
    if (_savedPalettes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No saved palettes',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Save palettes from the Generator tab',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 40.0),
      itemCount: _savedPalettes.length,
      itemBuilder: (context, index) {
        final palette = _savedPalettes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                _currentPalette = List.from(palette.colors);
                _tabController.animateTo(0);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Palette ${_savedPalettes.length - index}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() {
                            _savedPalettes.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: palette.colors.map((color) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _copyToClipboard(_colorToHex(color)),
                          child: Container(
                            height: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

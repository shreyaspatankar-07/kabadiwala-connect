import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/ml/edge_material_classifier.dart';
import '../../core/services/location_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/image_preview_dialog.dart';
import '../widgets/speaker_button.dart';

/// Live Camera Screen integrating INT8 Quantized Edge AI Material Classifier.
///
/// Features:
/// - Real-time camera preview feed with viewfinder targeting box.
/// - Asynchronous on-startup TFLite model loading.
/// - Single-touch capture with 224x224 INT8 preprocessing & on-device inference.
/// - Confidence threshold fallback:
///     - Below 0.55: Displays warning:
///       "Low Confidence: Please select item manually from the grid."
///       along with an interactive 10-category manual selection grid.
///     - 0.55 or above: Displays predicted category and confidence percentage.
/// - Vernacular audio feedback (Marathi / Hindi / English).
/// - Full lifecycle pause/resume management.
class MaterialScanScreen extends StatefulWidget {
  const MaterialScanScreen({
    super.key,
    this.classifier,
    this.audioService,
    this.locale = 'mr',
    this.onCategoryConfirmed,
    this.cameraDescription,
  });

  final EdgeMaterialClassifier? classifier;
  final AudioFeedbackService? audioService;
  final String locale;
  final ValueChanged<String>? onCategoryConfirmed;
  final CameraDescription? cameraDescription;

  @override
  State<MaterialScanScreen> createState() => _MaterialScanScreenState();
}

class _MaterialScanScreenState extends State<MaterialScanScreen>
    with WidgetsBindingObserver {
  late EdgeMaterialClassifier _classifier;
  late AudioFeedbackService _audioService;

  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];
  int _selectedCameraIndex = 0;

  bool _isCameraInitializing = true;
  bool _isModelLoading = true;
  bool _isProcessingFrame = false;
  FlashMode _flashMode = FlashMode.off;

  MaterialClassificationResult? _lastResult;
  String? _manuallySelectedCategory;
  Uint8List? _capturedFrameBytes;
  String? _capturedLocationString;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _classifier = widget.classifier ?? EdgeMaterialClassifier();
    _audioService = widget.audioService ?? AudioFeedbackService();
    _isModelLoading = !_classifier.isModelLoaded;

    _initializeServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    if (widget.classifier == null) {
      _classifier.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCameraController(controller.description);
    }
  }

  bool get _isTestEnvironment {
    return WidgetsBinding.instance.runtimeType
        .toString()
        .contains('TestWidgetsFlutterBinding');
  }

  Future<void> _initializeServices() async {
    // 1. Asynchronously load Edge AI model on startup
    unawaited(_loadModelAsync());

    // 2. Initialize Camera Feed
    await _initCamera();
  }

  Future<void> _loadModelAsync() async {
    try {
      if (!_classifier.isModelLoaded) {
        await _classifier.loadModel();
      }
    } catch (e) {
      if (kDebugMode) {
        print('[MaterialScanScreen] Model load error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isModelLoading = false;
        });
      }
    }
  }

  Future<void> _initCamera() async {
    if (_isTestEnvironment && widget.cameraDescription == null) {
      if (mounted) {
        setState(() {
          _isCameraInitializing = false;
        });
      }
      return;
    }
    try {
      if (widget.cameraDescription != null) {
        _availableCameras = [widget.cameraDescription!];
      } else {
        _availableCameras = await availableCameras();
      }

      if (_availableCameras.isNotEmpty) {
        await _initCameraController(_availableCameras[_selectedCameraIndex]);
      } else {
        if (mounted) {
          setState(() {
            _isCameraInitializing = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[MaterialScanScreen] Camera access exception: $e');
      }
      if (mounted) {
        setState(() {
          _isCameraInitializing = false;
        });
      }
    }
  }

  Future<void> _initCameraController(CameraDescription description) async {
    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _cameraController = controller;

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitializing = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('[MaterialScanScreen] Controller initialization error: $e');
      }
      if (mounted) {
        setState(() {
          _isCameraInitializing = false;
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final nextMode = _flashMode == FlashMode.off
          ? FlashMode.torch
          : (_flashMode == FlashMode.torch ? FlashMode.auto : FlashMode.off);
      await _cameraController!.setFlashMode(nextMode);
      setState(() {
        _flashMode = nextMode;
      });
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (_availableCameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _availableCameras.length;
    setState(() {
      _isCameraInitializing = true;
    });
    await _cameraController?.dispose();
    await _initCameraController(_availableCameras[_selectedCameraIndex]);
  }

  /// Captures a frame, preprocesses, quantizes to INT8, runs inference, and updates state.
  Future<void> _captureAndClassifyFrame() async {
    unawaited(HapticService.heavyImpact());

    setState(() {
      _isProcessingFrame = true;
    });

    try {
      Uint8List imageBytes;

      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final XFile file = await _cameraController!.takePicture();
        imageBytes = await file.readAsBytes();
      } else {
        // Fallback synthetic test frame for headless/simulator environments
        imageBytes = _generateSyntheticFrameBytes();
      }

      _capturedFrameBytes = imageBytes;

      // Run INT8 model inference & fetch real device GPS coordinates concurrently
      final futures = await Future.wait([
        _classifier.classifyImage(imageBytes),
        LocationService.getCurrentLocationString(),
      ]);

      final result = futures[0] as MaterialClassificationResult;
      final locationString = futures[1] as String;

      if (mounted) {
        setState(() {
          _lastResult = result;
          _capturedLocationString = locationString;
          _manuallySelectedCategory = result.isLowConfidence ? null : result.category;
          _isProcessingFrame = false;
        });

        // Vernacular audio cues based on confidence
        if (result.isLowConfidence) {
          final warningPrompt = widget.locale == 'hi'
              ? 'कम आत्मविश्वास: कृपया नीचे दी गई सूची से वस्तु चुनें।'
              : (widget.locale == 'en'
                  ? 'Low confidence. Please select item manually from the grid.'
                  : 'कमी अचूकता: कृपया खालील यादीतून वस्तू निवडा.');
          unawaited(_audioService.speakCustomText(warningPrompt, localeOverride: widget.locale));
        } else {
          final catInfo = EdgeMaterialClassifier.categoryMetadata[result.category];
          final catName = catInfo?.getLocalizedName(widget.locale) ?? result.category;
          final successPrompt = widget.locale == 'hi'
              ? 'पहचानी गई वस्तु: $catName, आत्मविश्वास: ${result.confidencePercent}%'
              : (widget.locale == 'en'
                  ? 'Detected item: $catName, Confidence: ${result.confidencePercent}%'
                  : 'ओळखलेली वस्तू: $catName, अचूकता: ${result.confidencePercent}%');
          unawaited(_audioService.speakCustomText(successPrompt, localeOverride: widget.locale));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[MaterialScanScreen] Inference execution failure: $e');
      }
      if (mounted) {
        setState(() {
          _isProcessingFrame = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.locale == 'hi'
                  ? 'फोटो प्रोसेस करने में त्रुटि'
                  : (widget.locale == 'en'
                      ? 'Error processing frame'
                      : 'फोटो तपासताना त्रुटी आली'),
            ),
          ),
        );
      }
    }
  }

  void _resetScan() {
    setState(() {
      _lastResult = null;
      _manuallySelectedCategory = null;
      _capturedFrameBytes = null;
      _capturedLocationString = null;
    });
  }

  void _confirmCategory(String category) {
    widget.onCategoryConfirmed?.call(category);
    Navigator.of(context).pop(category);
  }

  Uint8List _generateSyntheticFrameBytes() {
    // Generate valid minimal 224x224 encoded JPEG frame for simulator / test harness
    final image = img.Image(width: 224, height: 224);
    img.fill(image, color: img.ColorRgb8(120, 150, 180));
    return Uint8List.fromList(img.encodeJpg(image));
  }

  @override
  Widget build(BuildContext context) {
    final bool isReady = !_isCameraInitializing &&
        _cameraController != null &&
        _cameraController!.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Camera Live Feed or Offline Fallback Canvas
            Positioned.fill(
              child: _lastResult != null
                  ? _buildResultBackdrop()
                  : (isReady
                      ? Center(child: CameraPreview(_cameraController!))
                      : _buildNoCameraFallback()),
            ),

            // 2. Viewfinder Overlay (active when no result is shown)
            if (_lastResult == null) _buildViewfinderOverlay(),

            // 3. Top Action Bar (Back, Flash, Audio, Camera Flip)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: _buildTopBar(),
            ),

            // 4. Bottom Controls: Shutter Button or Result Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _lastResult == null
                  ? _buildCaptureControls()
                  : _buildClassificationResultSheet(),
            ),

            // 5. Processing Indicator Overlay
            if (_isProcessingFrame || _isModelLoading)
              Positioned.fill(child: _buildLoadingOverlay()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        IconButton.filledTonal(
          key: const Key('btn_scan_back'),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          style: IconButton.styleFrom(backgroundColor: Colors.black54),
          onPressed: () => Navigator.of(context).maybePop(),
        ),

        Row(
          children: [
            // Flash Mode Toggle
            if (_cameraController != null && _cameraController!.value.isInitialized)
              IconButton.filledTonal(
                key: const Key('btn_scan_flash'),
                icon: Icon(
                  _flashMode == FlashMode.torch
                      ? Icons.flash_on_rounded
                      : (_flashMode == FlashMode.auto
                          ? Icons.flash_auto_rounded
                          : Icons.flash_off_rounded),
                  color: Colors.white,
                ),
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                onPressed: _toggleFlash,
              ),
            const SizedBox(width: 8),

            // Switch Camera
            if (_availableCameras.length > 1)
              IconButton.filledTonal(
                key: const Key('btn_scan_flip'),
                icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                onPressed: _switchCamera,
              ),
            const SizedBox(width: 8),

            // Speaker Button for Low-Literacy Audio Guidance
            SpeakerButton(
              promptKey: 'tabAddLot',
              audioService: _audioService,
              tooltip: 'सूचना ऐका',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewfinderOverlay() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.85), width: 2.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                // Corner Guide Accents
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppTheme.greenGoEarn, width: 4.5),
                        left: BorderSide(color: AppTheme.greenGoEarn, width: 4.5),
                      ),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(22)),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppTheme.greenGoEarn, width: 4.5),
                        right: BorderSide(color: AppTheme.greenGoEarn, width: 4.5),
                      ),
                      borderRadius: BorderRadius.only(topRight: Radius.circular(22)),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppTheme.greenGoEarn, width: 4.5),
                        left: BorderSide(color: AppTheme.greenGoEarn, width: 4.5),
                      ),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(22)),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppTheme.greenGoEarn, width: 4.5),
                        right: BorderSide(color: AppTheme.greenGoEarn, width: 4.5),
                      ),
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(22)),
                    ),
                  ),
                ),
                const Center(
                  child: Icon(Icons.center_focus_weak_rounded, color: Colors.white54, size: 48),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.locale == 'hi'
                  ? 'वस्तु को बॉक्स में रखें (224x224)'
                  : (widget.locale == 'en'
                      ? 'Fit scrap inside target (224x224)'
                      : 'ई-कचरा चौकटीत ठेवा (224x224)'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.9), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Large tactile shutter button
          GestureDetector(
            key: const Key('btn_scan_capture'),
            onTap: _captureAndClassifyFrame,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: AppTheme.greenGoEarn,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.greenGoEarn.withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 38),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.locale == 'hi'
                ? 'स्कैन करने के लिए दबाएं'
                : (widget.locale == 'en' ? 'Tap to Scan' : 'स्कॅन करण्यासाठी दाबा'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationResultSheet() {
    final result = _lastResult!;
    final bool isLowConfidence = result.isLowConfidence;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grab handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Captured frame preview bar with clickable image icon
            _buildScannedImageThumbnailBar(),

            if (isLowConfidence) ...[
              // Fallback Warning UI requirement:
              // Display a warning UI saying "Low Confidence: Please select item manually from the grid."
              _buildLowConfidenceWarningBanner(),
              const SizedBox(height: 16),
              _buildManualSelectionGrid(),
            ] else ...[
              // High Confidence UI requirement:
              // Display the predicted category and confidence percentage
              _buildConfidentPredictionCard(result),
            ],

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('btn_scan_retake'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: const BorderSide(color: AppTheme.borderColor, width: 2),
                    ),
                    onPressed: _resetScan,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      widget.locale == 'hi'
                          ? 'फिर से फोटो लें'
                          : (widget.locale == 'en' ? 'Retake Photo' : 'पुन्हा फोटो काढा'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    key: const Key('btn_scan_confirm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.greenGoEarn,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _manuallySelectedCategory != null
                        ? () => _confirmCategory(_manuallySelectedCategory!)
                        : null,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: Text(
                      widget.locale == 'hi'
                          ? 'पुष्टि करें'
                          : (widget.locale == 'en' ? 'Confirm Item' : 'नक्की करा'),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Clickable thumbnail bar showing the captured image with an image icon to preview.
  Widget _buildScannedImageThumbnailBar() {
    if (_capturedFrameBytes == null) return const SizedBox.shrink();

    final String previewLabel = widget.locale == 'hi'
        ? 'फोटो देखें'
        : (widget.locale == 'en' ? 'View Photo' : 'फोटो पहा');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          // Clickable image thumbnail with zoom icon
          GestureDetector(
            key: const Key('btn_preview_scanned_image'),
            onTap: _showScannedImagePreview,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    _capturedFrameBytes!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.greenGoEarnLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.image_rounded,
                        color: AppTheme.greenGoEarn,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.zoom_in_rounded, size: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.locale == 'hi'
                      ? 'स्कैन की गई फोटो'
                      : (widget.locale == 'en' ? 'Scanned Photo' : 'स्कॅन केलेला फोटो'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${(_capturedFrameBytes!.length / 1024.0).toStringAsFixed(1)} KB • AI स्कॅनिंग',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          // Clickable image icon button
          TextButton.icon(
            key: const Key('btn_preview_scanned_image_icon'),
            onPressed: _showScannedImagePreview,
            icon: const Icon(Icons.image_rounded, size: 20, color: AppTheme.greenGoEarn),
            label: Text(
              previewLabel,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.greenGoEarn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showScannedImagePreview() {
    if (_capturedFrameBytes == null) return;
    ImagePreviewDialog.show(
      context: context,
      imageBytes: _capturedFrameBytes!,
      title: widget.locale == 'hi'
          ? 'स्कैन फोटो पूर्वावलोकन'
          : (widget.locale == 'en' ? 'Scanned Photo Preview' : 'स्कॅन फोटो पूर्वावलोकन'),
      sizeInKb: _capturedFrameBytes!.length / 1024.0,
      locationString: _capturedLocationString,
      locale: widget.locale,
    );
  }

  /// Warning banner required by prompt:
  /// "Low Confidence: Please select item manually from the grid."
  Widget _buildLowConfidenceWarningBanner() {
    return Container(
      key: const Key('warning_low_confidence_banner'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Amber-50
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFD97706),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Low Confidence: Please select item manually from the grid.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFB45309),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.locale == 'hi'
                      ? 'मॉडल को पूरा विश्वास नहीं है (${_lastResult?.confidencePercent ?? 0}% < 55%)। कृपया नीचे से सही श्रेणी चुनें।'
                      : (widget.locale == 'en'
                          ? 'Model confidence is low (${_lastResult?.confidencePercent ?? 0}% < 55%). Choose below.'
                          : 'अचूकता कमी आहे (${_lastResult?.confidencePercent ?? 0}% < 55%). कृपया अचूक प्रकार निवडा.'),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF78350F)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidentPredictionCard(MaterialClassificationResult result) {
    final catInfo = EdgeMaterialClassifier.categoryMetadata[result.category];
    final categoryColor = catInfo?.color ?? AppTheme.greenGoEarn;
    final categoryIcon = catInfo?.icon ?? Icons.category_rounded;
    final localizedName = catInfo?.getLocalizedName(widget.locale) ?? result.category;

    return Container(
      key: const Key('card_confident_prediction'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: categoryColor.withOpacity(0.4), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(categoryIcon, color: Colors.white, size: 34),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppTheme.greenGoEarn, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          widget.locale == 'hi'
                              ? 'सटीक पहचान'
                              : (widget.locale == 'en' ? 'Matched Category' : 'अचूक ओळख'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.greenGoEarn,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.category,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      localizedName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              // Confidence Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: categoryColor, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      '${result.confidencePercent}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: categoryColor,
                      ),
                    ),
                    const Text(
                      'Confidence',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Confidence progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: result.confidence,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
            ),
          ),
        ],
      ),
    );
  }

  /// 10 alphabetically sorted categories manual selection grid.
  Widget _buildManualSelectionGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.locale == 'hi'
              ? 'श्रेणी चुनें (10 श्रेणियां):'
              : (widget.locale == 'en' ? 'Select Category (10 Items):' : 'खालील प्रकारातून निवडा:'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.1,
          ),
          itemCount: EdgeMaterialClassifier.categories.length,
          itemBuilder: (context, index) {
            final catId = EdgeMaterialClassifier.categories[index];
            final info = EdgeMaterialClassifier.categoryMetadata[catId];
            final bool isSelected = _manuallySelectedCategory == catId;
            final categoryColor = info?.color ?? AppTheme.greenGoEarn;

            return InkWell(
              key: Key('grid_category_$catId'),
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                HapticService.selectionClick();
                setState(() {
                  _manuallySelectedCategory = catId;
                });
              },
              child: Container(
                constraints: const BoxConstraints(minHeight: 56), // 56dp per AGENTS.md
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? categoryColor.withOpacity(0.12) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? categoryColor : Colors.grey.shade300,
                    width: isSelected ? 2.5 : 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? categoryColor : categoryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        info?.icon ?? Icons.category_rounded,
                        color: isSelected ? Colors.white : categoryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            catId,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? categoryColor : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            info?.getLocalizedName(widget.locale) ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: categoryColor, size: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResultBackdrop() {
    if (_capturedFrameBytes != null) {
      return Image.memory(
        _capturedFrameBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Container(color: Colors.black87);
  }

  Widget _buildNoCameraFallback() {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              widget.locale == 'hi'
                  ? 'कैमरा उपलब्ध नहीं है (परीक्षण मोड)'
                  : (widget.locale == 'en'
                      ? 'Camera hardware uninitialized (Test Mode)'
                      : 'कॅमेरा उपलब्ध नाही (चाचणी मोड)'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.locale == 'hi'
                  ? 'सैंपल फ्रेम के साथ AI मॉडल का परीक्षण करें'
                  : (widget.locale == 'en'
                      ? 'Run Edge AI classifier using test frame'
                      : 'चाचणी फ्रेम वापरून AI मॉडेल तपासा'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.greenGoEarn),
              const SizedBox(height: 16),
              Text(
                _isModelLoading
                    ? (widget.locale == 'hi'
                        ? 'AI मॉडल लोड हो रहा है...'
                        : (widget.locale == 'en'
                            ? 'Loading TFLite INT8 Model...'
                            : 'AI मॉडेल लोड होत आहे...'))
                    : (widget.locale == 'hi'
                        ? 'AI विश्लेषण चालू आहे...'
                        : (widget.locale == 'en'
                            ? 'Analyzing Frame (224x224 INT8)...'
                            : 'ई-कचऱ्याचे विश्लेषण सुरू आहे...')),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

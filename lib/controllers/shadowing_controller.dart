import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/data/models/shadowing_model.dart';
import '../config/env_config.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
//D:\DemoDACN\wordmaster_dacn\lib\controllers\shadowing_controller.dart
class ShadowingController extends GetxController {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  String get baseUrl => '${EnvConfig.baseUrl}/shadowing';
  
  
  var isLoading = false.obs;
  var error = ''.obs;
  var shadowingList = <ShadowingContent>[].obs;
  var currentContent = Rx<ShadowingContentDetail?>(null);
  
  
  var sttProviderInfo = Rx<STTProviderInfo?>(null);
  
 
  var selectedDifficulty = 'all'.obs;
  var selectedAccent = 'all'.obs;
  var selectedSpeechRate = 'all'.obs;
  
 
  var isPlaying = false.obs;
  var currentPosition = Duration.zero.obs;
  var totalDuration = Duration.zero.obs;
  var playbackSpeed = 1.0.obs;
  
  
  var isRecording = false.obs;
  var recordingPath = ''.obs;
  var isProcessing = false.obs;
  

  var practiceMode = PracticeMode.segment.obs;
  var currentSegmentIndex = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadShadowingContent();
    loadSTTInfo(); //
    _initAudioPlayer();
    _requestPermissions();
  }
  
  @override
  void onClose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.onClose();
  }
  

  
  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }
  

  
  void _initAudioPlayer() {
    _audioPlayer.positionStream.listen((position) {
      currentPosition.value = position;
    });
    
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        totalDuration.value = duration;
      }
    });
    
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });
  }
  
 
  
  Future<void> loadSTTInfo() async {
    try {
      final apiService = Get.find<ApiService>();
      final data = await apiService.getSTTInfo();
      sttProviderInfo.value = STTProviderInfo.fromJson(data);
      
      print(' STT Provider: ${sttProviderInfo.value?.name}');
      print('   Mode: ${sttProviderInfo.value?.mode}');
      print('   Mock: ${sttProviderInfo.value?.isMock}');
    } catch (e) {
      print(' Failed to load STT info: $e');
    }
  }
  

  
  Future<void> loadShadowingContent() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final response = await http.get(
        Uri.parse('$baseUrl?difficulty=${selectedDifficulty.value}&accent=${selectedAccent.value}'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        shadowingList.value = (data['data'] as List)
            .map((json) => ShadowingContent.fromJson(json))
            .toList();
      } else {
        error.value = 'Failed to load content';
      }
    } catch (e) {
      error.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  
  Future<ShadowingContentDetail?> getContentDetail(int id) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        currentContent.value = ShadowingContentDetail.fromJson(data['data']);
        return currentContent.value;
      } else {
        error.value = 'Failed to load content detail';
        return null;
      }
    } catch (e) {
      error.value = 'Error: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }
  

  
  Future<void> playFullAudio(String audioUrl) async {
    try {
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.setSpeed(playbackSpeed.value);
      await _audioPlayer.play();
    } catch (e) {
      error.value = 'Failed to play audio: $e';
    }
  }

  
  Future<void> playSegment(ShadowingSegment segment, String audioUrl) async {
    try {
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.setSpeed(playbackSpeed.value);
      
      await _audioPlayer.seek(Duration(milliseconds: (segment.startTime * 1000).toInt()));
      await _audioPlayer.play();
      
      final segmentDuration = Duration(
        milliseconds: ((segment.endTime - segment.startTime) * 1000).toInt(),
      );
      
      Future.delayed(segmentDuration, () {
        if (isPlaying.value) {
          _audioPlayer.pause();
        }
      });
    } catch (e) {
      error.value = 'Failed to play segment: $e';
    }
  }
  
  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }
  
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }
  
  Future<void> changeSpeed(double speed) async {
    playbackSpeed.value = speed;
    await _audioPlayer.setSpeed(speed);
  }
  
  
  
  Future<void> startRecording() async {
    try {
     
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
      }
      
      if (!status.isGranted) {
        error.value = 'Microphone permission denied';
        return;
      }
      
      // Check if recorder has permission
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/shadowing_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        print('Starting recording to: $path');
        
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );
        
        isRecording.value = true;
        recordingPath.value = path;
        error.value = ''; 
        print('Recording started successfully');
      } else {
        error.value = 'AudioRecorder permission check failed';
      }
    } catch (e) {
      print('Recording error: $e');
      error.value = 'Failed to start recording: $e';
      isRecording.value = false;
    }
  }
  
  Future<String?> stopRecording() async {
    try {
      print('Stopping recording...');
      final path = await _audioRecorder.stop();
      isRecording.value = false;
      
      if (path != null) {
        print('Recording saved to: $path');
        recordingPath.value = path;
        error.value = ''; 
        return path;
      } else {
        print('Recording stopped but no path returned');
        error.value = 'Recording failed - no file created';
        return null;
      }
    } catch (e) {
      print('Stop recording error: $e');
      error.value = 'Failed to stop recording: $e';
      isRecording.value = false;
      return null;
    }
  }
  

  
  Future<SegmentResult?> submitSegmentRecording({
    required int contentId,
    required int segmentId,
    required String audioPath,
  }) async {
    try {
      isProcessing.value = true;
      error.value = '';
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/$contentId/submit-segment'),
      );
      
      final userId = AuthService.instance.userId;
    
      final safeUserId = userId > 0 ? userId : 2;
      request.fields['userId'] = safeUserId.toString();
      request.fields['segmentId'] = segmentId.toString();
      
      request.files.add(await http.MultipartFile.fromPath('audio', audioPath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = SegmentResult.fromJson(data['data']);
        
     
        print(' Result from ${result.provider} STT');
        if (result.isMock == true) {
          print(' Mock mode - simulated result');
        }
        
        return result;
      } else {
        error.value = 'Failed to submit recording';
        return null;
      }
    } catch (e) {
      error.value = 'Error: $e';
      return null;
    } finally {
      isProcessing.value = false;
    }
  }
  

  
  Future<ShadowingResult?> submitFullRecording({
    required int contentId,
    required String audioPath,
  }) async {
    try {
      isProcessing.value = true;
      error.value = '';
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/$contentId/submit-full'),
      );
      
      final userId = AuthService.instance.userId;
     
      final safeUserId = userId > 0 ? userId : 2;
      request.fields['userId'] = safeUserId.toString();
      request.files.add(await http.MultipartFile.fromPath('audio', audioPath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ShadowingResult.fromJson(data['data']);
      } else {
        error.value = 'Failed to submit recording';
        return null;
      }
    } catch (e) {
      error.value = 'Error: $e';
      return null;
    } finally {
      isProcessing.value = false;
    }
  }
  
 
  
  void applyFilters({String? difficulty, String? accent, String? search}) {
    if (difficulty != null) selectedDifficulty.value = difficulty;
    if (accent != null) selectedAccent.value = accent;
    loadShadowingContent();
  }
  
  Future<void> refresh() async {
    await loadShadowingContent();
    await loadSTTInfo();
  }
}

enum PracticeMode { segment, full }
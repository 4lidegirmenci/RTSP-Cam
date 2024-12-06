import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> cameraUrls = [
    "rtsp://admin:Sd2023!*@@188.59.119.126:554/cam/realmonitor?channel=1&subtype=1",
    "rtsp://admin:Sd2023!*@@188.59.119.126:554/cam/realmonitor?channel=2&subtype=0",
    "rtsp://admin:Sd2023!*@@188.59.119.126:554/cam/realmonitor?channel=1&subtype=0",
    "rtsp://admin:Sd2023!*@@188.59.119.126:554/cam/realmonitor?channel=1&subtype=0",
  ];

  List<VlcPlayerController?> _controllers = List<VlcPlayerController?>.filled(4, null);
  int? _selectedCameraIndex;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < cameraUrls.length; i++) {
      _initializeController(i);
    }
  }

  void _initializeController(int index) {
    if (_controllers[index] == null) {
      _controllers[index] = VlcPlayerController.network(
        cameraUrls[index],
        autoPlay: true,
        options: VlcPlayerOptions(),
      );
    } else {
      // Eğer kontrolcü zaten varsa, onu yeniden başlat
      _controllers[index]?.play();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  Widget _buildFullScreenCamera() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height / 2,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_selectedCameraIndex != null) {
              // Seçili kamerayı temizle
              _disposeController(_selectedCameraIndex!);
              _selectedCameraIndex = null;
            }
          });
        },
        child: Container(
          color: Colors.black,
          child: _selectedCameraIndex != null && _controllers[_selectedCameraIndex!] != null
              ? VlcPlayer(
            key: ValueKey('fullscreen_camera_${_selectedCameraIndex!}'),
            controller: _controllers[_selectedCameraIndex!]!,
            aspectRatio: 16 / 9,
            placeholder: Center(child: CircularProgressIndicator()),
          )
              : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }


  void _disposeController(int index) {
    _controllers[index]?.dispose();
    _controllers[index] = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kamera Yayını'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          _buildCameraGrid(),
          if (_selectedCameraIndex != null) _buildFullScreenCamera(),
        ],
      ),
    );
  }

  Widget _buildCameraGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: cameraUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _disposeController(_selectedCameraIndex ?? index); // Dispose of previous selected camera
              _selectedCameraIndex = index;
              _initializeController(index);
            });
          },
          child: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent),
            ),
            child: _controllers[index] != null
                ? VlcPlayer(
              key: ValueKey('camera_$index'),
              controller: _controllers[index]!,
              aspectRatio: 16 / 9,
              placeholder: Center(child: CircularProgressIndicator()),
            )
                : Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Widget buildFullScreenCamera() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height / 2,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _disposeController(_selectedCameraIndex!); // Dispose of full-screen camera
            _selectedCameraIndex = null;
          });
        },
        child: Container(
          color: Colors.black,
          child: _selectedCameraIndex != null && _controllers[_selectedCameraIndex!] != null
              ? VlcPlayer(
            key: ValueKey('fullscreen_camera_${_selectedCameraIndex!}'),
            controller: _controllers[_selectedCameraIndex!]!,
            aspectRatio: 16 / 9,
            placeholder: Center(child: CircularProgressIndicator()),
          )
              : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

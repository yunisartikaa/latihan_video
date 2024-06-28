import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latihan_video/screen_page/video_detail.dart';

class PageLatVideo extends StatefulWidget {
  const PageLatVideo({super.key});

  @override
  State<PageLatVideo> createState() => _PageLatVideoState();
}

class _PageLatVideoState extends State<PageLatVideo> {
  List<Datum> _videoList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVideoData();
  }

  Future<void> _fetchVideoData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.163.97/listvideo/list_video/getVideo.php'));

      if (response.statusCode == 200) {
        final modelVideo = modelVideoFromJson(response.body);
        if (modelVideo.isSuccess && modelVideo.data.isNotEmpty) {
          setState(() {
            _videoList = modelVideo.data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load video data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching video data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video List'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _videoList.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerPage(
                      videoUrl: 'http://192.168.163.97/listvideo/list_video/video_file/${_videoList[index].videoFile}',
                      title: _videoList[index].judulVideo,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  _videoList[index].gambar.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0),
                    ),
                    child: Image.network(
                      'http://192.168.163.97/listvideo/list_video/gambar/${_videoList[index].gambar}',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        bottomLeft: Radius.circular(15.0),
                      ),
                    ),
                    child: Icon(Icons.video_library, size: 50, color: Colors.white),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _videoList[index].judulVideo,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _videoList[index].videoFile,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// To parse this JSON data, do
//
//     final modelVideo = modelVideoFromJson(jsonString);

ModelVideo modelVideoFromJson(String str) => ModelVideo.fromJson(json.decode(str));

String modelVideoToJson(ModelVideo data) => json.encode(data.toJson());

class ModelVideo {
  bool isSuccess;
  String message;
  List<Datum> data;

  ModelVideo({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory ModelVideo.fromJson(Map<String, dynamic> json) => ModelVideo(
    isSuccess: json["isSuccess"],
    message: json["message"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "isSuccess": isSuccess,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  String id;
  String judulVideo;
  String videoFile;
  String gambar;

  Datum({
    required this.id,
    required this.judulVideo,
    required this.videoFile,
    required this.gambar,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    judulVideo: json["judul_video"],
    videoFile: json["video_file"],
    gambar: json["gambar"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "judul_video": judulVideo,
    "video_file": videoFile,
    "gambar": gambar,
  };
}
import 'package:http/http.dart' as http;

Future<String> convertPhoto(img) async {
  try {
    var response = await http.post(
        Uri.parse("https://opencv-natxio.herokuapp.com/opencv"),
        body: {'img': img});

    print(response.body);
    return response.body;
  } catch (e) {
    print("Exception:" + e.toString());
    return '{"fingers": "0"}';
  }
}

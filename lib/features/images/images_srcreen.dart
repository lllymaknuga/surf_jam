import 'package:flutter/material.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({Key? key}) : super(key: key);

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  List<String> images = [];
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop({
              'select': false,
            }),
          ),
          title: const Text('Фотограции'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Кол-во изоображений: ${images.length}',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(33, 33, 33, 1),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                hintText: 'Введите url',
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (images.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Удаление из списка'),
                          content: Image.network(images.last),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Отмена'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  images.remove(images.last);
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Да'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Удалить последнее фото',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Добавдение в список'),
                          content: Image.network(_controller.text),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Отмена'),
                            ),
                            TextButton(
                              onPressed: images.length <= 9
                                  ? () {
                                      setState(() {
                                        images.add(_controller.text);
                                        _controller.text = '';
                                      });
                                      Navigator.pop(context);
                                    }
                                  : null,
                              child: const Text('Добавить'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Добавить фото',
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (images.isNotEmpty) {
                    Navigator.of(context).pop(
                      {
                        'select': true,
                        'images': images,
                      },
                    );
                  } else {
                    Navigator.of(context).pop(
                      {
                        'select': false,
                      },
                    );
                  }
                },
                child: const Text('Перейти к отправке'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Apod {
  final String date;
  final String explanation;
  final String hdurl;
  final String mediaType;
  final String serviceVersion;
  final String title;
  final String url;

  Apod({
    required this.date,
    required this.explanation,
    required this.hdurl,
    required this.mediaType,
    required this.serviceVersion,
    required this.title,
    required this.url,
  });

  factory Apod.fromJson(Map<String, dynamic> json) {
    return Apod(
      date: json['date'],
      explanation: json['explanation'],
      hdurl: json['hdurl'],
      mediaType: json['media_type'],
      serviceVersion: json['service_version'],
      title: json['title'],
      url: json['url'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BrianVasquezParcial03',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Agregamos una fuente personalizada para darle un estilo más elegante
        fontFamily: 'Montserrat',
        // Configuramos el esquema de colores de la aplicación
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: Colors.pinkAccent,
          brightness: Brightness.light,
        ),
        // Configuramos la apariencia de los botones
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.pinkAccent,
            onPrimary: Colors.white,
          ),
        ),
      ),
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {

   late Apod _apod = Apod(
  date: '',
  explanation: '',
  hdurl: 'https://apod.nasa.gov/apod/image/2304/waterspout_mole_960.jpg',
  mediaType: '',
  serviceVersion: '',
  title: '',
  url: '',
  );

 
  

  final _dateController = TextEditingController();

  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse(
        'https://api.nasa.gov/planetary/apod?api_key=pdSCdjWIU487aTNFOU25FewGkc1Y5uHVwu3P0kMt'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

										
      _apod = Apod.fromJson(jsonData);
	   

      setState(() {});
    } else {
      throw Exception("Falla en conectarse");
    }
  }

  void _showNotification(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: Colors.blue.withOpacity(0.7),
      action: SnackBarAction(
        label: 'Cerrar',
        textColor: Colors.white,
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('API NASA BRIAN VASQUEZ'),
      ),
      
      body: Column(
        
        children: [
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              
              controller: _dateController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color.fromARGB(255, 255, 205, 198), 
              labelStyle: TextStyle(color: Color.fromARGB(255, 223, 22, 22)),
                labelText: 'Ingrese la fecha (YYYY-MM-DD)',
              ),
            ),
          ),
          Expanded(
            child: _apod == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(_apod!.title, style: TextStyle(fontSize: 24)),
                      SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                                Image.network(_apod!.hdurl),
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.blue, width: 1),
                                ),
                                child: Text(_apod!.explanation),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          String date = _dateController.text;
                          if (date.isEmpty) {
                            
                            final today = DateTime.now();
                            final randomDate = DateTime.utc(
                              today.year,
                              today.month,
                              Random().nextInt(today.day) + 1,
                             
                            );
                            date =
                                DateFormat('yyyy-MM-dd').format(randomDate);
                                 _showNotification('Imagen aleatoria API NASA');
                          }else
                          {
                             _showNotification('Imagen buscada por fecha by Brian Vasquez');
                          }
                          
                          final url =
                              'https://api.nasa.gov/planetary/apod?api_key=pdSCdjWIU487aTNFOU25FewGkc1Y5uHVwu3P0kMt&date=$date';
                          final response = await http.get(Uri.parse(url));
                          if (response.statusCode == 200) {
                            final jsonData = jsonDecode(response.body);
                            setState(() {
                              _apod = Apod.fromJson(jsonData);
                            });
                          } else {
                            throw Exception("Falla en conectarse");
                          }
                        },
                        
                        child: Text('Ver otra imagen'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
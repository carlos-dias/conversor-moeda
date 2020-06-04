import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const _chave = "";//chave obtida no site hgbrasil
const request = "https://api.hgbrasil.com/finance?key=$_chave";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.orange,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        hintStyle: TextStyle(color: Colors.amber),
      ),
    ),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChange(String texto) {
    if (texto.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(texto);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChange(String texto) {
    if (texto.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(texto);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChange(String texto) {
    if (texto.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(texto);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando"),
              );
            default:
              if (snapshot.hasError)
                return Center(
                  child: Text("Erro"),
                );
              else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        "Dolar: $dolar",
                        style: TextStyle(fontSize: 25.0),
                      ),
                      Text(
                        "Euro: $euro",
                        style: TextStyle(fontSize: 25.0),
                      ),
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                      ),
                      buildTextField(
                          "Real", "R\$", realController, _realChange),
                      Divider(),
                      buildTextField(
                          "Dolar", "US\$", dolarController, _dolarChange),
                      Divider(),
                      buildTextField("Euro", "€", euroController, _euroChange)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
        TextEditingController controller, Function function) =>
    TextField(
      onChanged: function,
      keyboardType: TextInputType.number,
      controller: controller,
      decoration: InputDecoration(
          labelText: label, border: OutlineInputBorder(), prefixText: prefix),
    );

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

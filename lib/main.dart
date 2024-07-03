import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Price List',
      theme: ThemeData(primaryColor: Colors.white),
      home: CryptoList(),
    );
  }
}

class CryptoList extends StatefulWidget {
  @override
  CryptoListState createState() => CryptoListState();
}

class CryptoListState extends State<CryptoList> {
  List _cryptoList = [];
  final _boldStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.white);
  bool _loading = false;
  final List<MaterialColor> _colors = [
    Colors.blue,
    Colors.indigo,
    Colors.lime,
    Colors.teal,
    Colors.cyan
  ];

  Future<void> getCryptoPrices() async {
    print('getting crypto prices');
    String apiURL = "https://api.coinlore.net/api/tickers/";
    setState(() {
      _loading = true;
    });

    try {
      Uri uri = Uri.parse(apiURL);
      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          _cryptoList = jsonDecode(response.body)['data'];
          _loading = false;
          print('Crypto data loaded: $_cryptoList');
        });
      } else {
        throw Exception('Failed to load crypto prices: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        _loading = false;
      });
      print('Error fetching crypto prices: $error');
    }
  }

  String cryptoPrice(Map crypto) {
    int decimals = 2;
    int fac = pow(10, decimals).toInt();
    double d = double.parse(crypto['price_usd']);
    return "\$" + (d = (d * fac).round() / fac).toString();
  }

  Widget _getLeadingWidget(String name, MaterialColor color) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
      ),
      child: Center(
        child: Text(
          name[0],
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  _getMainBody() {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return RefreshIndicator(
        child: _buildCryptoList(),
        onRefresh: getCryptoPrices,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getCryptoPrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Currency', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
        centerTitle: true, // Menempatkan teks judul di tengah
      ),
      backgroundColor: Color(0xff494F55), // Ubah warna latar belakang di sini
      body: _getMainBody(),
    );
  }

  Widget _buildCryptoList() {
    return ListView.builder(
      itemCount: _cryptoList.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        final index = i;
        final MaterialColor color = _colors[index % _colors.length];
        return _buildRow(_cryptoList[index], color);
      },
    );
  }

  Widget _buildRow(Map crypto, MaterialColor color) {
    return Container(
      height: 80.0,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          _getLeadingWidget(crypto['name'], color),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${crypto['name']} (${crypto['symbol']})',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                cryptoPrice(crypto),
                style: _boldStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

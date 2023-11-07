import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class Currency {
  String name;
  double rate;
  double variation;

  Currency({
    required this.name,
    required this.rate,
    required this.variation,
  });
}

class ExchangeRate {
  List<Currency> currencies = [];

  ExchangeRate({
    required this.currencies,
  });
}

class ExchangeRateProvider with ChangeNotifier {
  ExchangeRate _exchangeRate = ExchangeRate(currencies: []);

  ExchangeRate get exchangeRate => _exchangeRate;

  void updateExchangeRate(ExchangeRate newRate) {
    _exchangeRate = newRate;
    notifyListeners();
  }
}

class StocksData {
  List<Currency> stocks = [];

  StocksData({
    required this.stocks,
  });
}

class StocksDataProvider with ChangeNotifier {
  StocksData _stocksData = StocksData(stocks: []);

  StocksData get stocksData => _stocksData;

  void updateStocksData(StocksData newData) {
    _stocksData = newData;
    notifyListeners();
  }
}

class BitcoinData {
  List<Currency> bitcoinPrices = [];

  BitcoinData({
    required this.bitcoinPrices,
  });
}

class BitcoinDataProvider with ChangeNotifier {
  BitcoinData _bitcoinData = BitcoinData(bitcoinPrices: []);

  BitcoinData get bitcoinData => _bitcoinData;

  void updateBitcoinData(BitcoinData newData) {
    _bitcoinData = newData;
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ExchangeRateProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => StocksDataProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => BitcoinDataProvider(),
        ),
      ],
      child: const MaterialApp(
        home: ExchangeRatePage(),
      ),
    ),
  );
}

class ExchangeRatePage extends StatefulWidget {
  const ExchangeRatePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ExchangeRatePageState createState() => _ExchangeRatePageState();
}

class _ExchangeRatePageState extends State<ExchangeRatePage> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
    fetchBitcoinPrices();
  }

  void _changePage(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> fetchExchangeRates() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.hgbrasil.com/finance/quotations?format=json&key=20ef439f',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final currencies = data['results']['currencies'];

        if (currencies != null) {
          ExchangeRate exchangeRate = ExchangeRate(
            currencies: [
              Currency(
                name: 'Dólar',
                rate: currencies['USD']?['buy'] ?? 0.0,
                variation: currencies['USD']?['variation']?.toDouble() ?? 0.0,
              ),
              Currency(
                name: 'Euro',
                rate: currencies['EUR']?['buy'] ?? 0.0,
                variation: currencies['EUR']?['variation']?.toDouble() ?? 0.0,
              ),
              Currency(
                name: 'Peso',
                rate: currencies['ARS']?['buy'] ?? 0.0,
                variation: currencies['ARS']?['variation']?.toDouble() ?? 0.0,
              ),
              Currency(
                name: 'Yen',
                rate: currencies['JPY']?['buy'] ?? 0.0,
                variation: currencies['JPY']?['variation']?.toDouble() ?? 0.0,
              ),
            ],
          );

          // ignore: use_build_context_synchronously
          context.read<ExchangeRateProvider>().updateExchangeRate(exchangeRate);
        }

        if (data['results']['stocks'] != null) {
          StocksData stocksData = StocksData(
            stocks: [
              Currency(
                name: 'Ibovespa',
                rate: data['results']['stocks']['IBOVESPA']['points'] ?? 0.0,
                variation: data['results']['stocks']['IBOVESPA']['variation']?.toDouble() ?? 0.0,
              ),
              Currency(
                name: 'IFIX',
                rate: data['results']['stocks']['IFIX']['points'] ?? 0.0,
                variation: data['results']['stocks']['IFIX']['variation']?.toDouble() ?? 0.0,
              ),
              Currency(
                name: 'Nasdaq',
                rate: data['results']['stocks']['NASDAQ']['points'] ?? 0.0,
                variation: data['results']['stocks']['NASDAQ']['variation']?.toDouble() ?? 0.0,
              ),
              Currency(
                name: 'Dow Jones',
                rate: data['results']['stocks']['DOWJONES']['points'] ?? 0.0,
                variation: data['results']['stocks']['DOWJONES']['variation']?.toDouble() ?? 0.0,
              ),
              Currency(
                name: 'CAC',
                rate: data['results']['stocks']['CAC']['points'] ?? 0.0,
                variation: data['results']['stocks']['CAC']['variation']?.toDouble() ?? 0.0,
              ),
              Currency(
                name: 'Nikkei',
                rate: data['results']['stocks']['NIKKEI']['points'] ?? 0.0,
                variation: data['results']['stocks']['NIKKEI']['variation']?.toDouble() ?? 0.0,
              ),
            ],
          );

          // ignore: use_build_context_synchronously
          context.read<StocksDataProvider>().updateStocksData(stocksData);
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<void> fetchBitcoinPrices() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.hgbrasil.com/finance/quotations?format=json&key=20ef439f',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results']['bitcoin'] != null) {
          final bitcoinData = data['results']['bitcoin'];

          final blockchainPrice = bitcoinData['blockchain_info']['last'];
          final coinbasePrice = bitcoinData['coinbase']['last'];
          final bitstampPrice = bitcoinData['bitstamp']['last'];
          final foxbitPrice = bitcoinData['foxbit']['last'];
          final mercadoBitcoinPrice = bitcoinData['mercadobitcoin']['last'];

          BitcoinData bitcoinPrices = BitcoinData(
            bitcoinPrices: [
              Currency(
                  name: 'Blockchain',
                  rate: blockchainPrice.toDouble(),
                  variation: 0.0),
              Currency(
                  name: 'Coinbase',
                  rate: coinbasePrice.toDouble(),
                  variation: 0.0),
              Currency(
                  name: 'Bitstamp',
                  rate: bitstampPrice.toDouble(),
                  variation: 0.0),
              Currency(
                  name: 'Foxbit', rate: foxbitPrice.toDouble(), variation: 0.0),
              Currency(
                  name: 'Mercado Bitcoin',
                  rate: mercadoBitcoinPrice.toDouble(),
                  variation: 0.0),
            ],
          );

          // ignore: use_build_context_synchronously
          context.read<BitcoinDataProvider>().updateBitcoinData(bitcoinPrices);
        }
      } else {
        throw Exception('Failed to load Bitcoin data');
      }
    } catch (e) {
      throw Exception('Failed to load Bitcoin data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final exchangeRate = context.watch<ExchangeRateProvider>().exchangeRate;
    final stocksData = context.watch<StocksDataProvider>().stocksData;
    final bitcoinData = context.watch<BitcoinDataProvider>().bitcoinData;

    return Scaffold(
  appBar: AppBar(
    title: const Text('Finanças hoje'),
    backgroundColor: const Color(0xFF00441B), // Defina a cor desejada aqui
  ),
      body: _buildTabContent(_currentPage == 0
          ? exchangeRate
          : _currentPage == 1
              ? stocksData
              : bitcoinData),
      bottomNavigationBar: BottomAppBar(
        child: BottomNavigationBar(
          currentIndex: _currentPage,
          onTap: _changePage,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Moedas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Ações',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on),
              label: 'Bitcoin',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(dynamic data) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            _currentPage == 0
                ? 'Moedas'
                : _currentPage == 1
                    ? 'Ações'
                    : 'Bitcoin',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 16),
          if (data is ExchangeRate)
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (var i = 0; i < data.currencies.length; i += 2)
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.currencies[i].name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${data.currencies[i].rate.toStringAsFixed(2)} ${data.currencies[i].variation.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: data.currencies[i].variation >= 0
                                                ? Colors.blue
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (i + 1 < data.currencies.length)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.currencies[i + 1].name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${data.currencies[i + 1].rate.toStringAsFixed(2)} ${data.currencies[i + 1].variation.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: data.currencies[i + 1]
                                                          .variation >=
                                                      0
                                                  ? Colors.blue
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          if (data is StocksData)
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (var stock in data.stocks)
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stock.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${stock.rate.toStringAsFixed(2)} ${stock.variation.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: stock.variation >= 0
                                                ? Colors.blue
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

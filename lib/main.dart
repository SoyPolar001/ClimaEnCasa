import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

void main() => runApp(const ClimaEnCasaApp());

class ClimaEnCasaApp extends StatelessWidget {
  const ClimaEnCasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF176B72);
    return MaterialApp(
      title: 'Clima en Casa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: brand),
        scaffoldBackgroundColor: const Color(0xFFF3F7F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF3F7F6),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE1EAE8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: brand, width: 1.5),
          ),
        ),
      ),
      home: const ClimaHomePage(),
    );
  }
}

class ClimaHomePage extends StatefulWidget {
  const ClimaHomePage({super.key});

  @override
  State<ClimaHomePage> createState() => _ClimaHomePageState();
}

class _ClimaHomePageState extends State<ClimaHomePage> {
  final _searchController = TextEditingController(text: 'Ciudad de México');
  final _service = OpenMeteoService();

  WeatherSnapshot? _weather;
  List<WeatherLocation> _matches = [];
  String? _errorMessage;
  String? _emptyMessage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchCity());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchCity() async {
    final query = _searchController.text.trim();
    if (query.length < 2) {
      setState(() {
        _weather = null;
        _matches = [];
        _emptyMessage = null;
        _errorMessage = 'Escribe al menos dos letras para buscar una ciudad.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _weather = null;
      _matches = [];
      _emptyMessage = null;
      _errorMessage = null;
    });

    try {
      final locations = await _service.findLocations(query);
      if (!mounted) return;
      if (locations.isEmpty) {
        setState(() {
          _loading = false;
          _emptyMessage =
              'No encontramos esa ciudad. Revisa el nombre e intenta de nuevo.';
        });
        return;
      }
      if (locations.length > 1) {
        setState(() {
          _loading = false;
          _matches = locations;
        });
        return;
      }
      await _loadForecast(locations.first);
    } on WeatherApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = error.message;
      });
    }
  }

  Future<void> _loadForecast(WeatherLocation location) async {
    setState(() {
      _loading = true;
      _weather = null;
      _matches = [];
      _emptyMessage = null;
      _errorMessage = null;
    });

    try {
      final weather = await _service.fetchForecast(location);
      if (!mounted) return;
      _searchController.text = location.name;
      setState(() {
        _weather = weather;
        _loading = false;
      });
    } on WeatherApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = error.message;
      });
    }
  }

  Future<void> _refresh() async {
    final location = _weather?.location;
    if (location == null) {
      await _searchCity();
    } else {
      await _loadForecast(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            const Icon(Icons.cloud_outlined, color: Color(0xFF176B72)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clima en Casa',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Pronóstico para tu ciudad',
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: const Color(0xFF71817E)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar clima',
            onPressed: _loading ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchCity(),
                decoration: InputDecoration(
                  hintText: 'Busca una ciudad',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  suffixIcon: IconButton(
                    tooltip: 'Buscar ciudad',
                    onPressed: _loading ? null : _searchCity,
                    icon: const Icon(Icons.search_rounded),
                  ),
                ),
              ),
            ),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Consultando el pronóstico…'),
          ],
        ),
      );
    }

    final error = _errorMessage;
    if (error != null) {
      return _StatusPanel(
        icon: Icons.cloud_off_outlined,
        title: 'No pudimos cargar el clima',
        message: error,
        buttonLabel: 'Intentar de nuevo',
        onPressed: _searchCity,
      );
    }

    final empty = _emptyMessage;
    if (empty != null) {
      return _StatusPanel(
        icon: Icons.location_searching_rounded,
        title: 'No encontramos resultados',
        message: empty,
        buttonLabel: 'Buscar otra vez',
        onPressed: _searchCity,
      );
    }

    if (_matches.isNotEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Text(
            'Elige una ubicación',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Encontramos varias coincidencias para tu búsqueda.',
            style: TextStyle(color: Color(0xFF71817E)),
          ),
          const SizedBox(height: 12),
          for (final location in _matches)
            Card(
              color: Colors.white,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE3EBE9)),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE7F3F1),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF176B72),
                  ),
                ),
                title: Text(
                  location.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(location.subtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _loadForecast(location),
              ),
            ),
        ],
      );
    }

    final weather = _weather;
    if (weather == null) {
      return const _StatusPanel(
        icon: Icons.wb_cloudy_outlined,
        title: 'Busca el clima de una ciudad',
        message: 'Escribe un nombre en el campo superior para consultar el pronóstico.',
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 28),
        children: [
          _CurrentWeatherCard(weather: weather),
          const SizedBox(height: 18),
          Text(
            'Detalles de hoy',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricCard(
                    width: width,
                    icon: Icons.thermostat_rounded,
                    label: 'Sensación',
                    value: _formatTemperature(weather.feelsLike),
                  ),
                  _MetricCard(
                    width: width,
                    icon: Icons.water_drop_outlined,
                    label: 'Humedad',
                    value: _formatPercent(weather.humidity),
                  ),
                  _MetricCard(
                    width: width,
                    icon: Icons.air_rounded,
                    label: 'Viento',
                    value: _formatWind(weather.windSpeed),
                  ),
                  _MetricCard(
                    width: width,
                    icon: Icons.umbrella_outlined,
                    label: 'Prob. de lluvia',
                    value: _formatPercent(weather.todayRainChance),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Próximos 5 días',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                'Actualizado a las ${_formatHour(weather.observedAt)}',
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: const Color(0xFF71817E)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 158,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: weather.days.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) =>
                  _ForecastCard(forecast: weather.days[index], index: index),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Datos de Open-Meteo. El pronóstico puede cambiar durante el día.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF71817E)),
          ),
        ],
      ),
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  const _CurrentWeatherCard({required this.weather});

  final WeatherSnapshot weather;

  @override
  Widget build(BuildContext context) {
    final condition = describeWeather(weather.weatherCode);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF155B69), Color(0xFF258A83)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25155B69),
            blurRadius: 18,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            weather.location.name,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            weather.location.subtitle,
            style: const TextStyle(color: Color(0xFFD3E8E4)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTemperature(weather.temperature),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 62,
                        height: 1,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      condition.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(condition.icon, size: 76, color: const Color(0xFFE3F5ED)),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0x26FFFFFF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'Máx. ${_formatTemperature(weather.todayMax)}   ·   Mín. ${_formatTemperature(weather.todayMin)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3EBE9)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF176B72), size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF71817E),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF233734),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.forecast, required this.index});

  final DailyForecast forecast;
  final int index;

  @override
  Widget build(BuildContext context) {
    final condition = describeWeather(forecast.weatherCode);
    final day = index == 0
        ? 'Hoy'
        : index == 1
        ? 'Mañana'
        : _weekday(forecast.date);
    return Container(
      width: 124,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3EBE9)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(
              color: Color(0xFF52635F),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Icon(condition.icon, color: const Color(0xFF176B72), size: 30),
          Text(
            condition.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF71817E)),
          ),
          Text(
            '${_formatTemperature(forecast.high)} / ${_formatTemperature(forecast.low)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF233734),
            ),
          ),
          Text(
            'Lluvia ${_formatPercent(forecast.rainChance)}',
            style: const TextStyle(fontSize: 10, color: Color(0xFF71817E)),
          ),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F0ED),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: const Color(0xFF176B72), size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF71817E), height: 1.4),
            ),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(buttonLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class OpenMeteoService {
  const OpenMeteoService();

  static const _timeout = Duration(seconds: 14);

  Future<List<WeatherLocation>> findLocations(String query) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '5',
      'language': 'es',
      'format': 'json',
    });
    final data = await _getJson(uri);
    final results = data['results'];
    if (results == null) return [];
    if (results is! List) {
      throw const WeatherApiException(
        'La respuesta de búsqueda no tiene el formato esperado.',
      );
    }
    return results
        .whereType<Map<String, dynamic>>()
        .map(WeatherLocation.fromJson)
        .where((location) => location.name.isNotEmpty)
        .toList();
  }

  Future<WeatherSnapshot> fetchForecast(WeatherLocation location) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': location.latitude.toString(),
      'longitude': location.longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
      'timezone': 'auto',
      'forecast_days': '5',
      'temperature_unit': 'celsius',
      'wind_speed_unit': 'kmh',
    });
    final data = await _getJson(uri);
    final current = _asStringMap(data['current']);
    final daily = _asStringMap(data['daily']);
    if (current == null || daily == null) {
      throw const WeatherApiException(
        'La respuesta del pronóstico está incompleta.',
      );
    }

    final dates = _stringList(daily['time']);
    final codes = daily['weather_code'];
    final highs = daily['temperature_2m_max'];
    final lows = daily['temperature_2m_min'];
    final rainChances = daily['precipitation_probability_max'];
    if (dates.isEmpty || codes is! List || highs is! List || lows is! List) {
      throw const WeatherApiException('La API no devolvió días de pronóstico.');
    }

    final days = <DailyForecast>[];
    for (var index = 0; index < dates.length; index++) {
      final code = _numberAt(codes, index)?.toInt();
      final high = _numberAt(highs, index);
      final low = _numberAt(lows, index);
      if (code == null || high == null || low == null) continue;
      days.add(
        DailyForecast(
          date: dates[index],
          weatherCode: code,
          high: high,
          low: low,
          rainChance: _numberAt(rainChances, index),
        ),
      );
    }
    if (days.isEmpty) {
      throw const WeatherApiException('La API devolvió un pronóstico vacío.');
    }

    return WeatherSnapshot(
      location: location,
      observedAt: current['time']?.toString() ?? '',
      temperature: _numberValue(current['temperature_2m']),
      feelsLike: _numberValue(current['apparent_temperature']),
      humidity: _numberValue(current['relative_humidity_2m']),
      windSpeed: _numberValue(current['wind_speed_10m']),
      weatherCode: _numberValue(current['weather_code'])?.toInt() ?? 0,
      todayMax: days.first.high,
      todayMin: days.first.low,
      todayRainChance: days.first.rainChance,
      days: days,
    );
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      final request = await client.getUrl(uri).timeout(_timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close().timeout(_timeout);
      final body = await utf8.decoder.bind(response).join().timeout(_timeout);

      if (response.statusCode == 429) {
        throw const WeatherApiException(
          'El servicio recibió muchas solicitudes. Espera un momento y vuelve a intentar.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw WeatherApiException(
          'El servicio respondió con el código ${response.statusCode}. Intenta más tarde.',
        );
      }
      if (body.trim().isEmpty) {
        throw const WeatherApiException('El servicio respondió sin datos.');
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const WeatherApiException(
          'La respuesta del servicio no tiene el formato esperado.',
        );
      }
      if (decoded['error'] == true) {
        final reason = decoded['reason']?.toString();
        throw WeatherApiException(
          reason == null || reason.isEmpty
              ? 'La API no pudo completar la solicitud.'
              : reason,
        );
      }
      return decoded;
    } on WeatherApiException {
      rethrow;
    } on TimeoutException {
      throw const WeatherApiException(
        'La conexión tardó demasiado. Revisa tu internet e intenta de nuevo.',
      );
    } on SocketException {
      throw const WeatherApiException(
        'No hay conexión con el servicio. Revisa tu conexión a internet.',
      );
    } on HandshakeException {
      throw const WeatherApiException(
        'No se pudo establecer una conexión segura. Intenta de nuevo más tarde.',
      );
    } on HttpException {
      throw const WeatherApiException(
        'No se pudo completar la solicitud. Revisa tu conexión e intenta de nuevo.',
      );
    } on FormatException {
      throw const WeatherApiException(
        'El servicio devolvió una respuesta que no pudimos leer.',
      );
    } finally {
      client.close(force: true);
    }
  }
}

class WeatherApiException implements Exception {
  const WeatherApiException(this.message);

  final String message;
}

class WeatherLocation {
  const WeatherLocation({
    required this.name,
    required this.area,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String area;
  final String country;
  final double latitude;
  final double longitude;

  String get subtitle =>
      [area, country].where((part) => part.isNotEmpty).join(', ');

  factory WeatherLocation.fromJson(Map<String, dynamic> json) {
    return WeatherLocation(
      name: json['name']?.toString() ?? '',
      area: json['admin1']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      latitude: _numberValue(json['latitude'])?.toDouble() ?? 0,
      longitude: _numberValue(json['longitude'])?.toDouble() ?? 0,
    );
  }
}

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.location,
    required this.observedAt,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.todayMax,
    required this.todayMin,
    required this.todayRainChance,
    required this.days,
  });

  final WeatherLocation location;
  final String observedAt;
  final num? temperature;
  final num? feelsLike;
  final num? humidity;
  final num? windSpeed;
  final int weatherCode;
  final num? todayMax;
  final num? todayMin;
  final num? todayRainChance;
  final List<DailyForecast> days;
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.high,
    required this.low,
    required this.rainChance,
  });

  final String date;
  final int weatherCode;
  final num high;
  final num low;
  final num? rainChance;
}

class WeatherCondition {
  const WeatherCondition(this.label, this.icon);

  final String label;
  final IconData icon;
}

WeatherCondition describeWeather(int code) {
  if (code == 0) {
    return const WeatherCondition('Despejado', Icons.wb_sunny_outlined);
  }
  if (code == 1) {
    return const WeatherCondition(
      'Mayormente despejado',
      Icons.wb_sunny_outlined,
    );
  }
  if (code == 2) {
    return const WeatherCondition(
      'Parcialmente nublado',
      Icons.wb_cloudy_outlined,
    );
  }
  if (code == 3) {
    return const WeatherCondition('Nublado', Icons.cloud_outlined);
  }
  if (code == 45 || code == 48) {
    return const WeatherCondition('Niebla', Icons.cloud_outlined);
  }
  if (code >= 51 && code <= 57) {
    return const WeatherCondition('Llovizna', Icons.water_drop_outlined);
  }
  if (code >= 61 && code <= 67) {
    return const WeatherCondition('Lluvia', Icons.water_drop_outlined);
  }
  if (code >= 71 && code <= 77) {
    return const WeatherCondition('Nieve', Icons.ac_unit_rounded);
  }
  if (code >= 80 && code <= 82) {
    return const WeatherCondition('Chubascos', Icons.water_drop_outlined);
  }
  if (code == 85 || code == 86) {
    return const WeatherCondition('Chubascos de nieve', Icons.ac_unit_rounded);
  }
  if (code >= 95) {
    return const WeatherCondition('Tormenta', Icons.thunderstorm_outlined);
  }
  return const WeatherCondition('Variable', Icons.wb_cloudy_outlined);
}

Map<String, dynamic>? _asStringMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  return null;
}

List<String> _stringList(dynamic value) {
  if (value is! List) return [];
  return value.whereType<String>().toList();
}

num? _numberValue(dynamic value) {
  if (value is num) return value;
  return null;
}

num? _numberAt(dynamic value, int index) {
  if (value is! List || index >= value.length) return null;
  return _numberValue(value[index]);
}

String _formatTemperature(num? value) {
  if (value == null) return 'N/D';
  return '${value.round()}°';
}

String _formatPercent(num? value) {
  if (value == null) return 'N/D';
  return '${value.round()}%';
}

String _formatWind(num? value) {
  if (value == null) return 'N/D';
  return '${value.round()} km/h';
}

String _formatHour(String value) {
  final separator = value.indexOf('T');
  if (separator < 0 || value.length < separator + 6) return '—';
  return value.substring(separator + 1, separator + 6);
}

String _weekday(String date) {
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return date;
  const weekdays = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  return weekdays[parsed.weekday - 1];
}

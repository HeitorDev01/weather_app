import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:weather_app/const.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY, language: Language.PORTUGUESE_BRAZIL);
  // Adicione isso abaixo do Weather Factory
final TextEditingController _searchController = TextEditingController();
List<String> _favoritos = []; // Começa com algumas cidades

void _buscarNovaCidade(String nomeDaCidade) {
  // 1. Avisa o Flutter para mostrar a bolinha de carregamento
  setState(() {
    _weather = null; 
  });

  // 2. Vai na API buscar a cidade digitada
  _wf.currentWeatherByCityName(nomeDaCidade).then((w) {
    setState(() {
      _weather = w; // 3. Atualiza a tela com o clima novo
    });
  }).catchError((e) {
    // Se o usuário digitar uma cidade que não existe, mostramos um aviso!
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Não conseguimos encontrar a cidade: $nomeDaCidade"),
        backgroundColor: Colors.redAccent,
      ),
    );
    // E voltamos para uma cidade padrão para não travar na tela de loading
    _buscarNovaCidade("Rio de Janeiro"); 
  });
}

void _searchWeather(String city) {
  _wf.currentWeatherByCityName(city).then((w) {
    setState(() {
      _weather = w;
    });
  });
}

  Weather? _weather;

  @override
void initState() {
  super.initState();
  print("Iniciando busca de clima...");
  
  _wf.currentWeatherByCityName("Rio de Janeiro").then((w) {
    print("Dados recebidos: ${w.areaName}"); // Verifique se isso aparece
    setState(() {
      _weather = w;
    });
  }).catchError((e) {
    print("ERRO NA API: $e"); // Isso vai te dizer se a API Key é inválida ou se não há internet
  });
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    // Removemos a cor padrão e colocamos o conteúdo dentro de um Container com gradiente
    body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1D3B74), // Azul escuro no topo
            Color(0xFF4A88D9), // Azul vibrante no meio
            Color(0xFF8BC6EC), // Azul claro na base
          ],
        ),
      ),
      child: SafeArea( // Protege contra o "notch" da câmera e barra de status
        child: _buildUI(),
      ),
    ),
  );
}

Widget _buildUI() {
  if (_weather == null) {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }
  return SingleChildScrollView(
    physics: const BouncingScrollPhysics(), // Efeito de rolagem mais suave (estilo iOS)
    child: Column(
      children: [
        const SizedBox(height: 10),
        _searchBar(),
        const SizedBox(height: 30),
        _favoritosList(),
        _locationHeader(),
        _dateTimeInfo(),
        const SizedBox(height: 20),
        _weatherIcon(),
        _currentTemp(),
        const SizedBox(height: 30),
        _sunTimes(),
        const SizedBox(height: 15),
        _extraInfo(),
        const SizedBox(height: 30),
      ],
    ),
  );
}
Widget _locationHeader() {
  bool jaEFavorito = _favoritos.contains(_weather?.areaName);

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        _weather?.areaName ?? "",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      IconButton(
        icon: Icon(
          jaEFavorito ? Icons.star : Icons.star_border,
          color: Colors.yellow,
        ),
        onPressed: () {
          setState(() {
            if (jaEFavorito) {
              _favoritos.remove(_weather?.areaName);
            } else {
              if (_weather?.areaName != null) {
                _favoritos.add(_weather!.areaName!);
              }
            }
          });
        },
      ),
    ],
  );
}

Widget _dateTimeInfo() {
  DateTime now = _weather!.date!; 
  return Column(
    children: [
      Text(
        "${DateFormat("EEEE", "pt_BR").format(now)}, ${DateFormat("d MMM", "pt_BR").format(now)}",
        style: const TextStyle(
          color: Colors.white70, // Branco levemente transparente
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    ],
  );
}

Widget _currentTemp() {
  return Text(
    "${_weather?.temperature?.celsius?.toStringAsFixed(0)}°",
    style: const TextStyle(
      color: Colors.white,
      fontSize: 96, // Temperatura GIGANTE
      fontWeight: FontWeight.w200, // Fonte bem fina (Light)
    ),
  );
}

Widget _weatherIcon() {
  // Pegamos a descrição original (ex: "nuvens dispersas")
  String rawDescription = _weather?.weatherDescription ?? "";
  
  // Transformamos na versão formatada (ex: "Nuvens dispersas")
  String formattedDescription = rawDescription.isNotEmpty 
      ? "${rawDescription[0].toUpperCase()}${rawDescription.substring(1)}" 
      : "";

  return Column(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        height: MediaQuery.sizeOf(context).height * 0.20,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                "https://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"),
          ),
        ),
      ),
      Text(
        formattedDescription, // Usamos a string que criamos acima
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w500, // Um leve negrito fica ótimo aqui
        ),
      ),
    ],
  );
}
Widget _extraInfo() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15), // Transparência
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1), // Borda de "vidro"
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _infoTile("Máxima", "${_weather?.tempMax?.celsius?.toStringAsFixed(0)}°C", Icons.thermostat),
            _infoTile("Mínima", "${_weather?.tempMin?.celsius?.toStringAsFixed(0)}°C", Icons.thermostat_outlined),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: Colors.white30, thickness: 1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _infoTile("Vento", "${_weather?.windSpeed?.toStringAsFixed(0)} m/s", Icons.air),
            _infoTile("Umidade", "${_weather?.humidity?.toStringAsFixed(0)}%", Icons.water_drop_outlined),
          ],
        ),
      ],
    ),
  );
}

// Widget auxiliar para organizar cada bloquinho de informação
Widget _infoTile(String title, String value, IconData icon) {
  return Column(
    children: [
      Icon(icon, color: Colors.white70, size: 24),
      const SizedBox(height: 8),
      Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    ],
  );
}
Widget _searchBar() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Buscar cidade... (ex: Londres, Tokyo)",
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2), 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
      // MUDANÇA PRINCIPAL AQUI:
      onSubmitted: (value) {
        if (value.trim().isNotEmpty) {
          _buscarNovaCidade(value.trim()); // Chama a função buscando o que foi digitado
          _searchController.clear(); // Limpa o texto da barra
        }
      },
    ),
  );
}
  Widget _favoritosList() {
  return SizedBox(
    height: 40,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _favoritos.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => _buscarNovaCidade(_favoritos[index]), // Usa sua função de busca
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                _favoritos[index],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        );
      },
    ),
  );
}

Widget _sunTimes() {
  // Pegamos a hora e formatamos para "HH:mm". Se der algum erro e vier nulo, mostramos "--:--"
  String sunrise = _weather?.sunrise != null 
      ? DateFormat("HH:mm").format(_weather!.sunrise!) 
      : "--:--";
      
  String sunset = _weather?.sunset != null 
      ? DateFormat("HH:mm").format(_weather!.sunset!) 
      : "--:--";

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15), // Transparência acompanhando o outro card
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Reutilizamos o SEU widget auxiliar aqui!
        _infoTile("Nascer do Sol", sunrise, Icons.wb_twilight),
        _infoTile("Pôr do Sol", sunset, Icons.brightness_3),
      ],
    ),
  );
}

}


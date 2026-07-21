import 'package:flutter/material.dart';

void main() {
  runApp(const EncuestaApp());
}

class EncuestaApp extends StatelessWidget {
  const EncuestaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema Electoral Virtual',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0C1B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFE040FB),
          surface: Color(0xFF1D1B2A),
          tertiary: Color(0xFFFFD600),
        ),
      ),
      home: const PantallaRegistro(),
    );
  }
}

// -------------------------------------------------------------
// BASE DE DATOS LOCAL
// -------------------------------------------------------------
class DatosGlobales {
  // Clave exclusiva de administración e identidad
  static const String claveAdmin = "41043074";
  static const String administradora = "Luciana Nicolle Huerta Baños";

  // Registro de votantes
  static Map<String, Map<String, dynamic>> padronElectoral = {
    '71234567': {'nombre': 'Luciana Torres', 'yaVoto': false, 'votoPor': ''},
    '72345678': {'nombre': 'Carlos Mendoza', 'yaVoto': false, 'votoPor': ''},
  };

  // Candidatos Editables
  static List<String> candidatos = [
    'Camila Valenzuela',
    'Roberto Mendoza',
    'Elena Rostova',
    'Voto en Blanco / Nulo',
  ];

  static List<String> partidos = [
    'Alianza Progresista',
    'Movimiento Renovación',
    'Frente Cívico Nacional',
    'Opción de abstención',
  ];

  static List<String> fotos = [
    'https://picsum.photos/id/64/200/200',
    'https://picsum.photos/id/1005/200/200',
    'https://picsum.photos/id/338/200/200',
    'https://picsum.photos/id/1025/200/200',
  ];

  // Registro nominal privado para la administradora
  static List<Map<String, String>> historialVotosNominales = [];

  // Conteo acumulado
  static List<int> conteoVotos = [0, 0, 0, 0];
}

// -------------------------------------------------------------
// PANTALLA 1: INGRESO DEL VOTANTE Y ACCESO A ADMIN
// -------------------------------------------------------------
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _dniController = TextEditingController();

  void _validarEIngresar() {
    if (!_formKey.currentState!.validate()) return;

    String dni = _dniController.text.trim();
    String nombre = _nombreController.text.trim();

    if (DatosGlobales.padronElectoral.containsKey(dni)) {
      bool yaVoto = DatosGlobales.padronElectoral[dni]!['yaVoto'];

      if (yaVoto) {
        _mostrarAlerta(
          '¡Acceso Denegado!',
          'El DNI $dni ($nombre) ya ha registrado su voto previamente.',
          Colors.redAccent,
        );
        return;
      }
    } else {
      DatosGlobales.padronElectoral[dni] = {'nombre': nombre, 'yaVoto': false, 'votoPor': ''};
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaVotacion(nombre: nombre, dni: dni),
      ),
    );
  }

  void _abrirLoginAdmin() {
    final passController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1B2A),
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Color(0xFFFFD600)),
            SizedBox(width: 8),
            Text('Acceso Privado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Administradora: ${DatosGlobales.administradora}',
              style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Clave de Administrador',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
            onPressed: () {
              if (passController.text == DatosGlobales.claveAdmin) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PantallaAdminResultados()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Clave incorrecta. Acceso denegado.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Ingresar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _mostrarAlerta(String titulo, String mensaje, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF261C33),
        title: Text(titulo, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido', style: TextStyle(color: Color(0xFF00E5FF))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline, color: Color(0xFFFFD600)),
            tooltip: 'Acceso Privado (Admin)',
            onPressed: _abrirLoginAdmin,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0C1B), Color(0xFF2A085C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              color: const Color(0xFF1D1B2A),
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.how_to_vote_rounded, size: 70, color: Color(0xFF00E5FF)),
                      const SizedBox(height: 12),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFFE040FB)],
                        ).createShader(bounds),
                        child: const Text(
                          'ELECCIONES VIRTUALES',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Ingresa tus datos para identificarte y votar',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre Completo',
                          prefixIcon: const Icon(Icons.person, color: Color(0xFFE040FB)),
                          filled: true,
                          fillColor: const Color(0xFF120E1F),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v!.trim().isEmpty ? 'Ingresa tu nombre' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dniController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Número de DNI',
                          prefixIcon: const Icon(Icons.badge, color: Color(0xFF00E5FF)),
                          filled: true,
                          fillColor: const Color(0xFF120E1F),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v!.trim().length < 8 ? 'DNI inválido (mín. 8 dígitos)' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _validarEIngresar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE040FB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('INGRESAR A VOTAR', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// PANTALLA 2: CABINA DE VOTACIÓN
// -------------------------------------------------------------
class PantallaVotacion extends StatefulWidget {
  final String nombre;
  final String dni;

  const PantallaVotacion({super.key, required this.nombre, required this.dni});

  @override
  State<PantallaVotacion> createState() => _PantallaVotacionState();
}

class _PantallaVotacionState extends State<PantallaVotacion> {
  int? _seleccionado;

  void _confirmarVoto() {
    if (_seleccionado == null) return;

    String candidatoElegido = DatosGlobales.candidatos[_seleccionado!];

    setState(() {
      DatosGlobales.conteoVotos[_seleccionado!]++;

      DatosGlobales.padronElectoral[widget.dni] = {
        'nombre': widget.nombre,
        'yaVoto': true,
        'votoPor': candidatoElegido,
      };

      DatosGlobales.historialVotosNominales.add({
        'nombre': widget.nombre,
        'dni': widget.dni,
        'votoPor': candidatoElegido,
      });
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1B2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, size: 60, color: Color(0xFF00E5FF)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¡Gracias por tu voto, ${widget.nombre}!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu participación con DNI ${widget.dni} ha sido registrada con éxito.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE040FB)),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Finalizar', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cédula de Votación'),
        backgroundColor: const Color(0xFF1D1B2A),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: const Color(0xFF261C33),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFF00E5FF),
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('DNI: ${widget.dni}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Selecciona tu Candidato:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...List.generate(DatosGlobales.candidatos.length, (index) {
              bool esSeleccionado = _seleccionado == index;

              return GestureDetector(
                onTap: () => setState(() => _seleccionado = index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: esSeleccionado ? const Color(0xFF321A4C) : const Color(0xFF1D1B2A),
                    border: Border.all(
                      color: esSeleccionado ? const Color(0xFF00E5FF) : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: index,
                        groupValue: _seleccionado,
                        activeColor: const Color(0xFF00E5FF),
                        onChanged: (val) => setState(() => _seleccionado = val),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          DatosGlobales.fotos[index],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.person, color: Colors.white54),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DatosGlobales.candidatos[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(DatosGlobales.partidos[index], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _seleccionado != null ? _confirmarVoto : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('EMITIR MI VOTO', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// PANTALLA 3: PANEL EXCLUSIVO PARA LUCIANA (RESULTADOS + EDICIÓN)
// -------------------------------------------------------------
class PantallaAdminResultados extends StatefulWidget {
  const PantallaAdminResultados({super.key});

  @override
  State<PantallaAdminResultados> createState() => _PantallaAdminResultadosState();
}

class _PantallaAdminResultadosState extends State<PantallaAdminResultados> {
  int get _totalVotos => DatosGlobales.conteoVotos.reduce((a, b) => a + b);

  void _abrirEditorCandidatos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaEditarCandidatos()),
    ).then((_) => setState(() {})); // Recargar cambios al volver
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: const Color(0xFF1D1B2A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Administradora
            Card(
              color: const Color(0xFF261C33),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user, color: Color(0xFF00E5FF), size: 36),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sesión de Control', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(
                          DatosGlobales.administradora,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // BOTÓN EXCLUSIVO DE EDICIÓN
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _abrirEditorCandidatos,
                icon: const Icon(Icons.edit_attributes_rounded, color: Colors.black),
                label: const Text('GESTIONAR Y EDITAR CANDIDATOS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Gráfico de Conteo Global
            Card(
              color: const Color(0xFF1D1B2A),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bar_chart, color: Color(0xFFFFD600)),
                        SizedBox(width: 8),
                        Text('Conteo General en Vivo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Total de votos procesados: $_totalVotos', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 16),
                    ...List.generate(DatosGlobales.candidatos.length, (index) {
                      double porcentaje = _totalVotos > 0 ? (DatosGlobales.conteoVotos[index] / _totalVotos) : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DatosGlobales.candidatos[index], style: const TextStyle(fontSize: 12)),
                                Text('${(porcentaje * 100).toStringAsFixed(1)}% (${DatosGlobales.conteoVotos[index]})', style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: porcentaje,
                              color: const Color(0xFFE040FB),
                              backgroundColor: Colors.black26,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Registro Nominal (Quién votó por quién)
            const Text('Registro Nominal de Votantes:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            if (DatosGlobales.historialVotosNominales.isEmpty)
              const Card(
                color: Color(0xFF1D1B2A),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Aún no se han emitido votos.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...DatosGlobales.historialVotosNominales.map((registro) {
                return Card(
                  color: const Color(0xFF1D1B2A),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFFE040FB)),
                    title: Text(registro['nombre']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('DNI: ${registro['dni']}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF321A4C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF00E5FF)),
                      ),
                      child: Text(
                        registro['votoPor']!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// PANTALLA 4: FORMULARIO DE EDICIÓN DE CANDIDATOS (SOLO LUCIANA)
// -------------------------------------------------------------
class PantallaEditarCandidatos extends StatefulWidget {
  const PantallaEditarCandidatos({super.key});

  @override
  State<PantallaEditarCandidatos> createState() => _PantallaEditarCandidatosState();
}

class _PantallaEditarCandidatosState extends State<PantallaEditarCandidatos> {
  void _editarCandidatoDialog(int index) {
    final nombreCtrl = TextEditingController(text: DatosGlobales.candidatos[index]);
    final partidoCtrl = TextEditingController(text: DatosGlobales.partidos[index]);
    final fotoCtrl = TextEditingController(text: DatosGlobales.fotos[index]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1B2A),
        title: Text('Editar Candidato #${index + 1}', style: const TextStyle(color: Color(0xFFFFD600))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del Candidato'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: partidoCtrl,
                decoration: const InputDecoration(labelText: 'Partido / Descripción'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fotoCtrl,
                decoration: const InputDecoration(labelText: 'URL de la foto (Imagen)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
            onPressed: () {
              setState(() {
                DatosGlobales.candidatos[index] = nombreCtrl.text.trim();
                DatosGlobales.partidos[index] = partidoCtrl.text.trim();
                DatosGlobales.fotos[index] = fotoCtrl.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Candidatos'),
        backgroundColor: const Color(0xFF1D1B2A),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: DatosGlobales.candidatos.length,
        itemBuilder: (context, index) {
          return Card(
            color: const Color(0xFF1D1B2A),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  DatosGlobales.fotos[index],
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => Container(
                    width: 45,
                    height: 45,
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.person),
                  ),
                ),
              ),
              title: Text(DatosGlobales.candidatos[index], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(DatosGlobales.partidos[index], style: const TextStyle(color: Colors.grey, fontSize: 12)),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFFFFD600)),
                onPressed: () => _editarCandidatoDialog(index),
              ),
            ),
          );
        },
      ),
    );
  }
}

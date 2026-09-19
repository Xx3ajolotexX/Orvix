import 'package:flutter/material.dart';

/// Asigna un color fijo y consistente a cada materia, para que el
/// estudiante identifique visualmente sus tareas de un vistazo,
/// como si usara marcadores de colores en una agenda física.
class SubjectColors {
  static const List<Color> _palette = [
    Color(0xFFFF6B6B), // coral
    Color(0xFF4ECDC4), // azul cielo
    Color(0xFFFFD166), // amarillo
    Color(0xFF06D6A0), // verde menta
    Color(0xFF7C5CFF), // violeta
    Color(0xFFFF9F1C), // naranja
    Color(0xFFEF476F), // rosa fuerte
    Color(0xFF118AB2), // azul profundo
  ];

  /// Misma materia (mismo texto) siempre devuelve el mismo color,
  /// sin necesidad de guardar el color en la base de datos.
  static Color of(String subject) {
    if (subject.trim().isEmpty) return _palette.last;
    final index = subject.toLowerCase().trim().hashCode.abs() % _palette.length;
    return _palette[index];
  }
}
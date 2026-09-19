// lib/screens/profile_screen.dart
//
// Perfil simple: nombre + avatar (foto local), guardados con
// shared_preferences. No hay login/cuentas — es solo personalización local.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class ProfileScreen extends StatefulWidget {
  final List<Task> tasks;
  const ProfileScreen({super.key, required this.tasks});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  String? _avatarPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text =
        prefs.getString('perfil_nombre') ?? 'Estudiante Orvix';
    _avatarPath = prefs.getString('perfil_avatar_path');
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _guardarNombre() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('perfil_nombre', _nameController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre guardado')),
      );
    }
  }

  Future<void> _elegirFoto() async {
    final picker = ImagePicker();
    try {
      final XFile? imagen = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 80,
      );
      if (imagen == null) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('perfil_avatar_path', imagen.path);
      if (mounted) setState(() => _avatarPath = imagen.path);
    } catch (e) {
      print('[Orvix] Error eligiendo foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la galería')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final total = widget.tasks.length;
    final completadas = widget.tasks.where((t) => t.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: const Color(0xFF7C5CFF),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: GestureDetector(
              onTap: _elegirFoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor:
                        const Color(0xFF7C5CFF).withValues(alpha: 0.15),
                    backgroundImage: _avatarPath != null
                        ? FileImage(File(_avatarPath!))
                        : null,
                    child: _avatarPath == null
                        ? const Icon(Icons.person,
                            size: 56, color: Color(0xFF7C5CFF))
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF7C5CFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Toca la foto para cambiarla',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tu nombre',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _guardarNombre(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _guardarNombre,
              child: const Text('Guardar nombre'),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$total',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Text('Tareas totales'),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$completadas',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Text('Completadas'),
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
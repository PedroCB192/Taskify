import 'package:flutter/material.dart';
import 'package:taskify/features/tasks/models/subtask.dart';

class Task {
  final String id;
  final String nombre;
  final DateTime fecha;
  final TimeOfDay? hora;
  final List<Subtask>? subtareas;
  final String categoriaId;
  final bool completada;
  final bool isSynced; // Para control de sincronización

  Task({
    required this.id,
    required this.nombre,
    required this.fecha,
    this.hora,
    this.subtareas,
    required this.categoriaId,
    this.completada = false,
    this.isSynced = false,
  });
}

// lib/models/archive_model.dart
class Archive {
  final String id;
  final String reference;
  final String description;
  final String location;
  final int dua; // Durée d'utilité administrative en années
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String status; // À conserver, À éliminer, À verser
  final Map<String, dynamic> metadata;
  final DateTime? eliminationDate;
  final DateTime? transferDate;
  final String? notes;

  Archive({
    required this.id,
    required this.reference,
    required this.description,
    required this.location,
    required this.dua,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.status,
    this.metadata = const {},
    this.eliminationDate,
    this.transferDate,
    this.notes,
  });

  factory Archive.fromJson(Map<String, dynamic> json) {
    return Archive(
      id: json['id'],
      reference: json['reference'],
      description: json['description'],
      location: json['location'],
      dua: json['dua'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      createdBy: json['created_by'],
      status: json['status'],
      metadata: json['metadata'] ?? {},
      eliminationDate: json['elimination_date'] != null
          ? DateTime.parse(json['elimination_date'])
          : null,
      transferDate: json['transfer_date'] != null
          ? DateTime.parse(json['transfer_date'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'description': description,
      'location': location,
      'dua': dua,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'status': status,
      'metadata': metadata,
      'elimination_date': eliminationDate?.toIso8601String(),
      'transfer_date': transferDate?.toIso8601String(),
      'notes': notes,
    };
  }

  Archive copyWith({
    String? reference,
    String? description,
    String? location,
    int? dua,
    String? status,
    Map<String, dynamic>? metadata,
    DateTime? eliminationDate,
    DateTime? transferDate,
    String? notes,
  }) {
    return Archive(
      id: id,
      reference: reference ?? this.reference,
      description: description ?? this.description,
      location: location ?? this.location,
      dua: dua ?? this.dua,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      createdBy: createdBy,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      eliminationDate: eliminationDate ?? this.eliminationDate,
      transferDate: transferDate ?? this.transferDate,
      notes: notes ?? this.notes,
    );
  }
}

// lib/models/document_version_model.dart
class DocumentVersion {
  final String id;
  final String documentId;
  final String numeroVersion;
  final String cheminFichier;
  final String nomFichier;
  final int tailleFichier;
  final String? hashMd5;
  final String? bucketPath;
  final String? commentaire;
  final Map<String, dynamic> modifications;
  final DateTime creeLe;
  final String creePar;
  final bool estMajeure;

  DocumentVersion({
    required this.id,
    required this.documentId,
    required this.numeroVersion,
    required this.cheminFichier,
    required this.nomFichier,
    required this.tailleFichier,
    this.hashMd5,
    this.bucketPath,
    this.commentaire,
    this.modifications = const {},
    required this.creeLe,
    required this.creePar,
    this.estMajeure = false,
  });

  factory DocumentVersion.fromJson(Map<String, dynamic> json) {
    return DocumentVersion(
      id: json['id'],
      documentId: json['document_id'],
      numeroVersion: json['numero_version'],
      cheminFichier: json['chemin_fichier'],
      nomFichier: json['nom_fichier'],
      tailleFichier: json['taille_fichier'],
      hashMd5: json['hash_md5'],
      bucketPath: json['bucket_path'],
      commentaire: json['commentaire'],
      modifications: json['modifications'] ?? {},
      creeLe: DateTime.parse(json['cree_le']),
      creePar: json['cree_par'],
      estMajeure: json['est_majeure'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_id': documentId,
      'numero_version': numeroVersion,
      'chemin_fichier': cheminFichier,
      'nom_fichier': nomFichier,
      'taille_fichier': tailleFichier,
      'hash_md5': hashMd5,
      'bucket_path': bucketPath,
      'commentaire': commentaire,
      'modifications': modifications,
      'cree_le': creeLe.toIso8601String(),
      'cree_par': creePar,
      'est_majeure': estMajeure,
    };
  }
}

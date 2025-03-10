// lib/models/document_model.dart
import 'package:flutter/foundation.dart';

enum DocumentType {
  document_administratif,
  rapport,
  note_service,
  correspondance,
  contrat
}

enum DocumentStatus {
  brouillon,
  en_revision,
  a_valider,
  valide,
  a_modifier,
  archive,
  supprime
}

enum AccessLevel { public, interne, confidentiel, secret }

class Document {
  final String id;
  final String reference;
  final String titre;
  final String? description;
  final DocumentType typeDocument;
  final String version;
  final DocumentStatus statut;
  final AccessLevel niveauAcces;

  // Métadonnées du fichier
  final String cheminFichier;
  final String nomFichier;
  final String formatFichier;
  final int tailleFichier;
  final String? hashMd5;
  final String? bucketPath;

  // Classification et localisation
  final String? departement;
  final String? emplacement;
  final List<String>? motsCles;
  final Map<String, dynamic>? tags;

  // Durées de conservation
  final int? dua;
  final DateTime? dateElimination;
  final String? motifConservation;
  final bool alerteElimination;
  final DateTime? dateAlerte;

  // Processus de validation
  final bool necessiteValidation;
  final String? validateurId;
  final DateTime? dateValidation;
  final String? commentaireValidation;
  final Map<String, dynamic>? workflowStatus;

  // Contrôle d'accès
  final String createurId;
  final String? proprietaireId;
  final String? groupeId;
  final List<String>? utilisateursAutorises;
  final List<String>? groupesAutorises;
  final Map<String, dynamic>? restrictionsAcces;

  // Champs de traçabilité
  final DateTime creeLe;
  final DateTime modifieLe;
  final String? creePar;
  final String? modifiePar;
  final DateTime? derniereConsultation;
  final int nombreConsultations;

  // Champs pour l'archivage
  final bool estArchive;
  final DateTime? dateArchivage;
  final String? raisonArchivage;

  Document({
    required this.id,
    required this.reference,
    required this.titre,
    this.description,
    required this.typeDocument,
    required this.version,
    required this.statut,
    required this.niveauAcces,
    required this.cheminFichier,
    required this.nomFichier,
    required this.formatFichier,
    required this.tailleFichier,
    this.hashMd5,
    this.bucketPath,
    this.departement,
    this.emplacement,
    this.motsCles,
    this.tags,
    this.dua,
    this.dateElimination,
    this.motifConservation,
    this.alerteElimination = false,
    this.dateAlerte,
    this.necessiteValidation = true,
    this.validateurId,
    this.dateValidation,
    this.commentaireValidation,
    this.workflowStatus,
    required this.createurId,
    this.proprietaireId,
    this.groupeId,
    this.utilisateursAutorises,
    this.groupesAutorises,
    this.restrictionsAcces,
    required this.creeLe,
    required this.modifieLe,
    this.creePar,
    this.modifiePar,
    this.derniereConsultation,
    this.nombreConsultations = 0,
    this.estArchive = false,
    this.dateArchivage,
    this.raisonArchivage,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      reference: json['reference'],
      titre: json['titre'],
      description: json['description'],
      typeDocument: DocumentType.values.firstWhere(
          (e) => e.toString() == 'DocumentType.${json['type_document']}'),
      version: json['version'],
      statut: DocumentStatus.values.firstWhere(
          (e) => e.toString() == 'DocumentStatus.${json['statut']}'),
      niveauAcces: AccessLevel.values.firstWhere(
          (e) => e.toString() == 'AccessLevel.${json['niveau_acces']}'),
      cheminFichier: json['chemin_fichier'],
      nomFichier: json['nom_fichier'],
      formatFichier: json['format_fichier'],
      tailleFichier: json['taille_fichier'],
      hashMd5: json['hash_md5'],
      bucketPath: json['bucket_path'],
      departement: json['departement'],
      emplacement: json['emplacement'],
      motsCles: json['mots_cles'] != null
          ? List<String>.from(json['mots_cles'])
          : null,
      tags: json['tags'],
      dua: json['dua'],
      dateElimination: json['date_elimination'] != null
          ? DateTime.parse(json['date_elimination'])
          : null,
      motifConservation: json['motif_conservation'],
      alerteElimination: json['alerte_elimination'] ?? false,
      dateAlerte: json['date_alerte'] != null
          ? DateTime.parse(json['date_alerte'])
          : null,
      necessiteValidation: json['necessite_validation'] ?? true,
      validateurId: json['validateur_id'],
      dateValidation: json['date_validation'] != null
          ? DateTime.parse(json['date_validation'])
          : null,
      commentaireValidation: json['commentaire_validation'],
      workflowStatus: json['workflow_status'],
      createurId: json['createur_id'],
      proprietaireId: json['proprietaire_id'],
      groupeId: json['groupe_id'],
      utilisateursAutorises: json['utilisateurs_autorises'] != null
          ? List<String>.from(json['utilisateurs_autorises'])
          : null,
      groupesAutorises: json['groupes_autorises'] != null
          ? List<String>.from(json['groupes_autorises'])
          : null,
      restrictionsAcces: json['restrictions_acces'],
      creeLe: DateTime.parse(json['cree_le']),
      modifieLe: DateTime.parse(json['modifie_le']),
      creePar: json['cree_par'],
      modifiePar: json['modifie_par'],
      derniereConsultation: json['derniere_consultation'] != null
          ? DateTime.parse(json['derniere_consultation'])
          : null,
      nombreConsultations: json['nombre_consultations'] ?? 0,
      estArchive: json['est_archive'] ?? false,
      dateArchivage: json['date_archivage'] != null
          ? DateTime.parse(json['date_archivage'])
          : null,
      raisonArchivage: json['raison_archivage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
      'type_document': typeDocument.toString().split('.').last,
      'niveau_acces': niveauAcces.toString().split('.').last,
      'departement': departement,
      'emplacement': emplacement,
      'mots_cles': motsCles,
      'tags': tags,
      'dua': dua,
      'date_elimination': dateElimination?.toIso8601String(),
      'motif_conservation': motifConservation,
      'alerte_elimination': alerteElimination,
      'necessite_validation': necessiteValidation,
      'validateur_id': validateurId,
      'commentaire_validation': commentaireValidation,
      'workflow_status': workflowStatus,
      'groupe_id': groupeId,
      'utilisateurs_autorises': utilisateursAutorises,
      'groupes_autorises': groupesAutorises,
      'restrictions_acces': restrictionsAcces,
    };
  }
}

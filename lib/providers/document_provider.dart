// lib/providers/document_provider.dart
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/document_model.dart';
import '../models/document_version_model.dart';

class DocumentProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Document> _documents = [];

  List<Document> get documents => _documents;

  Future<void> loadDocuments({
    DocumentType? type,
    AccessLevel? accessLevel,
    String? department,
    DocumentStatus? status,
    String? searchQuery,
  }) async {
    try {
      var query =
          _supabase.from('documents').select().not('statut', 'eq', 'supprime');

      if (type != null) {
        query = query.eq('type_document', type.toString().split('.').last);
      }
      if (accessLevel != null) {
        query =
            query.eq('niveau_acces', accessLevel.toString().split('.').last);
      }
      if (department != null) {
        query = query.eq('departement', department);
      }
      if (status != null) {
        query = query.eq('statut', status.toString().split('.').last);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.textSearch('contenu_indexe', searchQuery);
      }

      final response = await query.order('cree_le', ascending: false);

      _documents = response.map((doc) => Document.fromJson(doc)).toList();
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des documents: $e');
      rethrow;
    }
  }

  Future<bool> createDocument({
    required String title,
    required String description,
    required DocumentType type,
    required String department,
    required AccessLevel accessLevel,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      final hash = md5.convert(fileBytes).toString();
      final fileExtension =
          path.extension(fileName).toLowerCase().replaceAll('.', '');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final bucketPath = 'documents/$timestamp\_$fileName';

      await _supabase.storage.from('documents').uploadBinary(
            bucketPath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: 'application/${fileExtension}',
            ),
          );

      final fileUrl =
          _supabase.storage.from('documents').getPublicUrl(bucketPath);

      await _supabase.from('documents').insert({
        'titre': title,
        'description': description,
        'type_document': type.toString().split('.').last,
        'niveau_acces': accessLevel.toString().split('.').last,
        'departement': department,
        'chemin_fichier': fileUrl,
        'nom_fichier': fileName,
        'format_fichier': fileExtension,
        'taille_fichier': fileBytes.length,
        'hash_md5': hash,
        'bucket_path': bucketPath,
        'createur_id': _supabase.auth.currentUser?.id,
        'cree_par': _supabase.auth.currentUser?.id,
      });

      await loadDocuments();
      return true;
    } catch (e) {
      print('Erreur lors de la création du document: $e');
      rethrow;
    }
  }

  Future<bool> updateDocument({
    required String documentId,
    required Map<String, dynamic> updates,
    Uint8List? newFileBytes,
    String? newFileName,
    String? newFileType,
  }) async {
    try {
      if (newFileBytes != null && newFileName != null) {
        final hash = md5.convert(newFileBytes).toString();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final bucketPath = 'documents/$timestamp\_$newFileName';

        await _supabase.storage.from('documents').uploadBinary(
              bucketPath,
              newFileBytes,
              fileOptions: FileOptions(
                contentType: 'application/${newFileType ?? 'octet-stream'}',
              ),
            );

        final fileUrl =
            _supabase.storage.from('documents').getPublicUrl(bucketPath);

        updates['chemin_fichier'] = fileUrl;
        updates['nom_fichier'] = newFileName;
        updates['format_fichier'] = newFileType;
        updates['taille_fichier'] = newFileBytes.length;
        updates['hash_md5'] = hash;
        updates['bucket_path'] = bucketPath;
      }

      updates['modifie_par'] = _supabase.auth.currentUser?.id;
      updates['modifie_le'] = DateTime.now().toIso8601String();

      await _supabase.from('documents').update(updates).eq('id', documentId);

      await loadDocuments();
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du document: $e');
      rethrow;
    }
  }

  Future<bool> deleteDocument(String documentId) async {
    try {
      // Soft delete
      await _supabase.from('documents').update({
        'statut': 'supprime',
        'modifie_par': _supabase.auth.currentUser?.id,
        'modifie_le': DateTime.now().toIso8601String(),
      }).eq('id', documentId);

      await loadDocuments();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression du document: $e');
      rethrow;
    }
  }

  Future<bool> archiveDocument(String documentId, String reason) async {
    try {
      await _supabase.from('documents').update({
        'est_archive': true,
        'date_archivage': DateTime.now().toIso8601String(),
        'raison_archivage': reason,
        'modifie_par': _supabase.auth.currentUser?.id,
        'modifie_le': DateTime.now().toIso8601String(),
      }).eq('id', documentId);

      await loadDocuments();
      return true;
    } catch (e) {
      print('Erreur lors de l\'archivage du document: $e');
      rethrow;
    }
  }

  Future<bool> validateDocument({
    required String documentId,
    required String validateurId,
    required bool isApproved,
    String? commentaire,
  }) async {
    try {
      await _supabase.from('documents').update({
        'statut': isApproved ? 'valide' : 'a_modifier',
        'validateur_id': validateurId,
        'date_validation': isApproved ? DateTime.now().toIso8601String() : null,
        'commentaire_validation': commentaire,
        'modifie_par': _supabase.auth.currentUser?.id,
        'modifie_le': DateTime.now().toIso8601String(),
      }).eq('id', documentId);

      await loadDocuments();
      return true;
    } catch (e) {
      print('Erreur lors de la validation du document: $e');
      rethrow;
    }
  }

  Future<List<DocumentVersion>> getDocumentVersions(String documentId) async {
    try {
      final response = await _supabase
          .from('versions_documents')
          .select()
          .eq('document_id', documentId)
          .order('cree_le', ascending: false);

      return response
          .map((version) => DocumentVersion.fromJson(version))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des versions: $e');
      rethrow;
    }
  }

  Future<Uint8List?> downloadDocument(String documentId) async {
    try {
      final document = _documents.firstWhere((doc) => doc.id == documentId);

      if (document.bucketPath == null) return null;

      final bytes = await _supabase.storage
          .from('documents')
          .download(document.bucketPath!);

      // Mettre à jour le nombre de consultations
      await _supabase.from('documents').update({
        'nombre_consultations': document.nombreConsultations + 1,
        'derniere_consultation': DateTime.now().toIso8601String(),
      }).eq('id', documentId);

      return bytes;
    } catch (e) {
      print('Erreur lors du téléchargement du document: $e');
      rethrow;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:tapps/models/province_record.dart';
import 'package:tapps/models/province.dart';
import 'dart:async';

class FirebaseException implements Exception {
  final String message;
  final dynamic originalError;

  FirebaseException(this.message, [this.originalError]);

  @override
  String toString() => 'FirebaseException: $message${originalError != null ? '\nOriginal error: $originalError' : ''}';
}

class DamLevelsRecord {
  final double thisWeekLevel;
  final double lastWeekLevel;
  final double lastYearLevel;
  final DateTime timestamp;

  DamLevelsRecord({
    required this.thisWeekLevel,
    required this.lastWeekLevel,
    required this.lastYearLevel,
    required this.timestamp,
  });

  factory DamLevelsRecord.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) {
      throw FirebaseException('Document does not exist');
    }

    try {
      final data = doc.data() as Map<String, dynamic>;
      
      return DamLevelsRecord(
        thisWeekLevel: (data['this_week_level'] ?? 0.0).toDouble(),
        lastWeekLevel: (data['last_week_level'] ?? 0.0).toDouble(),
        lastYearLevel: (data['last_year_level'] ?? 0.0).toDouble(),
        timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      throw FirebaseException('Failed to parse document data', e);
    }
  }
}

class FirebaseService {
  final FirebaseFirestore _firestore;
  static const String _damLevelsCollection = 'Grand_total';
  static const String _damLevelsDocId = 'HvLx0oOi0Uxgik0J7hMy';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  FirebaseService({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<bool> checkConnection() async {
    try {
      // Only enable network, don't terminate or clear persistence
      await _firestore.enableNetwork();
      // Try a simple query to verify connection
      await _firestore.collection(_damLevelsCollection).doc(_damLevelsDocId).get();
      return true;
    } catch (e) {
      debugPrint('❌ Firebase connection check failed: $e');
      return false;
    }
  }

  Stream<T> _withStreamRetry<T>(Stream<T> Function() operation, String operationName) {
    return Stream.multi((controller) async {
      int attempts = 0;
      StreamSubscription<T>? subscription;
      bool hasError = false;

      void retry() async {
        await subscription?.cancel();

        if (attempts >= _maxRetries) {
          controller.addError(FirebaseException('All retry attempts failed for $operationName'));
          await controller.close();
          return;
        }

        if (attempts > 0) {
          debugPrint('⚠️ Attempt $attempts failed for $operationName, retrying...');
          await Future.delayed(_retryDelay * attempts);
        }

        subscription = operation().listen(
          (data) {
            if (!controller.isClosed) controller.add(data);
            hasError = false;
          },
          onError: (error) {
            hasError = true;
            attempts++;
            retry();
          },
          onDone: () {
            if (!hasError && !controller.isClosed) controller.close();
          },
        );
      }

      retry();

      // Clean up subscription when the controller is closed
      controller.onCancel = () {
        subscription?.cancel();
      };
    });
  }

  Stream<DamLevelsRecord> getDamLevels() {
    try {
      return _withStreamRetry(() {
        return _firestore
            .collection(_damLevelsCollection)
            .doc(_damLevelsDocId)
            .snapshots()
            .handleError((error) {
              debugPrint('❌ Error fetching dam levels: $error');
              throw FirebaseException('Failed to fetch dam levels', error);
            })
            .map((snapshot) => DamLevelsRecord.fromFirestore(snapshot));
      }, 'getDamLevels');
    } catch (e) {
      throw FirebaseException('Failed to create dam levels stream', e);
    }
  }

  Stream<ProvinceRecord> getProvinceTotals(String provinceCode) {
    try {
      // Map province codes to their respective document IDs
      final Map<String, String> provinceDocIds = {
        'WC': 'rxpK7cf0ImOZtqJBWndu',  // Western Cape
        'EC': 'HQ4VGbK8VFe8yXZ97fVr',  // Eastern Cape
        'NC': 'tkUmSThRNbxtSGhmtJ2q',  // Northern Cape
        'FS': 'iqSa1Whljfk63r7W5hiT',  // Free State
        'KZN': 'TWRSTXhJkdlK4g1fANlG', // KwaZulu-Natal
        'GP': 'pEF90QvqBNV64hJOhx1S',  // Gauteng
        'MP': 'kG0WBCOI26wF7kxeGw9I',  // Mpumalanga
        'LP': '8cP6petEFKZx8ScGsnF8',  // Limpopo
        'NW': 'hw8PSceWv0Kw2cJ2CdXf',  // North West
      };

      // Validate province code
      if (!provinceDocIds.containsKey(provinceCode)) {
        debugPrint('⚠️ Invalid province code: $provinceCode');
        throw FirebaseException('Invalid province code: $provinceCode. Valid codes are: ${provinceDocIds.keys.join(", ")}');
      }

      final docId = provinceDocIds[provinceCode]!;
      final collectionName = '${provinceCode}Totals';
      
      debugPrint('📊 Fetching data for province: $provinceCode');
      debugPrint('📁 Collection: $collectionName');
      debugPrint('📄 Document ID: $docId');
      
      return _withStreamRetry(() {
        return _firestore
            .collection(collectionName)
            .doc(docId)
            .snapshots()
            .handleError((error) {
              debugPrint('❌ Error fetching province totals for $provinceCode: $error');
              throw FirebaseException('Failed to fetch province totals for $provinceCode', error);
            })
            .map((snapshot) {
              if (!snapshot.exists) {
                debugPrint('⚠️ No data found for province: $provinceCode');
                throw FirebaseException('No data found for province: $provinceCode');
              }
              debugPrint('✅ Successfully fetched data for province: $provinceCode');
              return ProvinceRecord.fromFirestore(snapshot);
            });
      }, 'getProvinceTotals');
    } catch (e) {
      debugPrint('❌ Error in getProvinceTotals for $provinceCode: $e');
      throw FirebaseException('Failed to create province totals stream for $provinceCode', e);
    }
  }

  Stream<List<Map<String, dynamic>>> getProvinceDams(String provinceCode) {
    try {
      // Validate province code first
      if (!provinceCode.contains(RegExp(r'^(WC|EC|NC|FS|KZN|GP|MP|LP|NW)$'))) {
        debugPrint('⚠️ Invalid province code for dams: $provinceCode');
        throw FirebaseException('Invalid province code for dams: $provinceCode');
      }

      final collectionName = '${provinceCode}Dams';
      debugPrint('🌊 Fetching dams for province: $provinceCode');
      debugPrint('📁 Collection: $collectionName');

      return _withStreamRetry(() {
        return _firestore
            .collection(collectionName)
            .snapshots()
            .handleError((error) {
              debugPrint('❌ Error fetching province dams for $provinceCode: $error');
              throw FirebaseException('Failed to fetch province dams for $provinceCode', error);
            })
            .map((snapshot) {
              if (snapshot.docs.isEmpty) {
                debugPrint('ℹ️ No dams found for province: $provinceCode');
              } else {
                debugPrint('✅ Successfully fetched ${snapshot.docs.length} dams for province: $provinceCode');
              }
              return snapshot.docs
                  .map((doc) => {'id': doc.id, ...doc.data()})
                  .toList();
            });
      }, 'getProvinceDams');
    } catch (e) {
      debugPrint('❌ Error in getProvinceDams for $provinceCode: $e');
      throw FirebaseException('Failed to create province dams stream for $provinceCode', e);
    }
  }

  Stream<List<Province>> getProvinces() {
    try {
      return _firestore
          .collection('provinces')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Province.fromFirestore(doc.data()))
              .toList());
    } catch (e) {
      debugPrint('🔴 Error getting provinces: $e');
      rethrow;
    }
  }
}

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final damLevelsStreamProvider = StreamProvider<DamLevelsRecord>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getDamLevels();
});

final provinceTotalsProvider = StreamProvider.family<ProvinceRecord, String>((ref, provinceCode) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getProvinceTotals(provinceCode);
});

final provinceDamsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, provinceCode) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getProvinceDams(provinceCode);
});

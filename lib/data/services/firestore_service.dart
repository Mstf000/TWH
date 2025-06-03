import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveFormData(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    await _db.collection('users').doc(user.uid).collection('forms').add({
      ...data,
      'submitted_at': Timestamp.now(),
    });
  }

  Future<int> getUserFormCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    final snapshot =
        await _db.collection('users').doc(user.uid).collection('forms').get();

    return snapshot.docs.length;
  }

  Future<List<String>> getUserFormNames() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('forms')
        .orderBy('submitted_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['name']?.toString() ?? 'Unnamed')
        .toList();
  }

  Future<List<String>> getUserDealNames() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('forms')
        .orderBy('submitted_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['name'] as String? ?? 'Unnamed Deal')
        .toList();
  }

  Future<List<Map<String, String>>> getUserDealsWithStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('forms')
        .orderBy('submitted_at', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'name': (data['name'] ?? 'Unnamed Deal').toString(),
        'status': (data['deal_status'] ?? 'pending').toString(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getUserDealsWithFullInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('forms')
        .orderBy('submitted_at', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'formId': doc.id,
        'name': data['name'] ?? '',
        'status': data['deal_status'] ?? 'unknown',
        'submitted_at': data['submitted_at']?.toDate(),
      };
    }).toList();
  }

  Future<Map<String, int>> getGlobalDealStats() async {
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    int total = 0;
    int done = 0;
    int pending = 0;
    int noDeal = 0;

    for (var userDoc in usersSnapshot.docs) {
      final formsSnapshot = await userDoc.reference.collection('forms').get();
      for (var doc in formsSnapshot.docs) {
        final status = doc.data()['deal_status'] ?? 'pending';
        total++;
        if (status == 'done')
          done++;
        else if (status == 'no_deal')
          noDeal++;
        else
          pending++;
      }
    }

    return {
      'total': total,
      'done': done,
      'pending': pending,
      'no_deal': noDeal,
    };
  }
}

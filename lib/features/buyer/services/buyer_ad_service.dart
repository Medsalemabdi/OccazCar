import 'package:cloud_firestore/cloud_firestore.dart';

class BuyerAdService {
  final _ads = FirebaseFirestore.instance.collection('ads');

  Stream<QuerySnapshot<Map<String, dynamic>>> getAds() {
    return _ads
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}

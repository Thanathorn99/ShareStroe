import 'package:cloud_firestore/cloud_firestore.dart';
import 'model.dart';

class DatabaseHelper {
  // Reference ไปยัง Collection ของ Firestore
  final CollectionReference collection =
      FirebaseFirestore.instance.collection(Product.collectionName);

  // เพิ่มสินค้าใหม่ลงในฐานข้อมูล Firestore
  Future<DocumentReference> insertProduct(Product product) {
    return collection.add(product.toJson());
  }

  // อัปเดตข้อมูลสินค้าที่มีอยู่
  Future<void> updateProduct(Product product) async {
    return await collection.doc(product.referenceId).update(product.toJson());
  }

  // ลบสินค้าที่มีอยู่ในฐานข้อมูล
  Future<void> deleteProduct(Product product) async {
    return await collection.doc(product.referenceId).delete();
  }
  
 
  // ดึงข้อมูลสินค้าทั้งหมดจากฐานข้อมูล Firestore
  Future<List<Product>> getAllProducts() async {
    QuerySnapshot querySnapshot = await collection.get();
    final List<QueryDocumentSnapshot> docs = querySnapshot.docs;
    return docs
        .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  


  // ดึงข้อมูลสินค้าแบบเรียลไทม์
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }
}

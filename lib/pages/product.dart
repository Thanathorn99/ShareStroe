import 'package:flutter/material.dart';
import '../database/model.dart';
import '../database/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProductListScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const ProductListScreen({Key? key, required this.dbHelper}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];

  // Confirm dialog for deletion
  Future<bool?> _showConfirmDialog(BuildContext context, String message) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จองคิวแม่บ้าน'),
      ),
      body: Column(
        children: [
          // ส่วนของโฆษณา
Container(
  height: 250, // ปรับความสูงของกรอบให้ใหญ่ขึ้น
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: 4, // จำนวนโฆษณาที่จะแสดง (เพราะมี 3 รูป)
    itemBuilder: (context, index) {
      // สร้างเส้นทางของรูปภาพโดยใช้ชื่อไฟล์ที่ถูกต้อง
      String imagePath = 'assets/images/maaban${index + 1}.jpg';

      return Container(
        width: 300, // ปรับความกว้างของกรอบให้ใหญ่ขึ้น
        margin: EdgeInsets.all(16.0), // เพิ่ม margin รอบๆ กรอบ
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0), // เพิ่มความโค้งให้กรอบ
          color: Colors.orange, // สีพื้นหลังของโฆษณา
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0), // เพิ่ม padding รอบๆ ภายในกรอบ
          child: Column(
            children: [
              Expanded(
                flex: 4, // ใช้ flex เพื่อเพิ่มพื้นที่ให้กับรูปภาพ
                child: Image.asset(
                  imagePath, // แสดงรูปภาพจาก assets
                  fit: BoxFit.cover, // จัดการให้รูปภาพครอบคลุมพื้นที่
                ),
              ),
              SizedBox(height: 10), // เพิ่มพื้นที่ระหว่างรูปภาพกับข้อความ
              Expanded(
                flex: 1, // พื้นที่สำหรับข้อความโฆษณา
                child: Text(
                  'โฆษณา ${index + 1}', // ข้อความโฆษณา
                  style: TextStyle(color: Colors.white, fontSize: 22), // ขนาดฟอนต์ใหญ่ขึ้น
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
),



          // ส่วนของข้อมูล
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: widget.dbHelper.getStream(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                products.clear();
                for (var element in snapshot.data!.docs) {
                  var data = element.data() as Map<String, dynamic>;
                  products.add(Product(
                    name: element.get('name'),
                    description: element.get('description'),
                    favorite: element.get('favorite'),
                    referenceId: element.id,
                    contactnumber: data.containsKey('contactnumber')
                        ? data['contactnumber']
                        : '',
                    address: data.containsKey('address') ? data['address'] : '',
                    bookingTime: data.containsKey('bookingTime')
                        ? data['bookingTime']
                        : '',
                  ));
                }

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: UniqueKey(),
                      background: Container(color: Colors.blue),
                      secondaryBackground: Container(
                        color: Colors.red,
                        child: const Icon(Icons.delete),
                        alignment: Alignment.centerRight,
                      ),
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          widget.dbHelper.deleteProduct(products[index]);
                          setState(() {
                            products.removeAt(index);
                          });
                        }
                      },
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          return await _showConfirmDialog(
                              context, 'แน่ใจว่าจะลบการจองนี้?');
                        }
                        return false;
                      },
                      child: Card(
                        elevation: 5,
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(products[index].name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('รายละเอียด: ${products[index].description}'),
                              Text('เบอร์: ${products[index].contactnumber}'),
                              Text('ที่อยู่: ${products[index].address}'),
                              Text('เวลาจอง: ${DateFormat('dd/MM/yyyy HH:mm').format(DateFormat("dd/MM/yyyy h:mm a").parse(products[index].bookingTime))}'),
                            ],
                          ),
                          onTap: () async {
                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailScreen(productdetail: products[index]),
                              ),
                            );
                            setState(() {
                              if (result != null) {
                                products[index].favorite = result;
                                widget.dbHelper.updateProduct(products[index]);
                              }
                            });
                          },
                          onLongPress: () async {
                            await ModalEditProductForm(
                              dbHelper: widget.dbHelper,
                              editedProduct: products[index],
                            ).showModalInputForm(context);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ModalProductForm(dbHelper: widget.dbHelper)
              .showModalInputForm(context);
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key, required this.productdetail}) : super(key: key);

  final Product productdetail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productdetail.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(
                  left: 10, top: 20.0), // Adjust top padding as needed
              child: Text(
                'เรื่องจอง: ${productdetail.name}', // Updated label
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(
                  left: 10, top: 20.0), // Adjust top padding as needed
              child: Text(
                'รายละเอียด: ${productdetail.description}', // Updated label
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(
                  left: 10, top: 20.0), // Adjust top padding as needed
              child: Text(
                'ที่อยู่: ${productdetail.address}', // Updated label
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(
                  left: 10, top: 20.0), // Adjust top padding as needed
              child: Text(
                'เบอร์โทร: ${productdetail.contactnumber}', // Updated label
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(
                left: 10,
                top: 20.0,
              ),
              child: Text(
                'เวลาการจอง: ${productdetail.bookingTime}', // New label for booking time
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(120, 40),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Add spacing at the bottom
          ],
        ),
      ),
    );
  }
}

class ModalProductForm {
  ModalProductForm({Key? key, required this.dbHelper});
  final DatabaseHelper dbHelper;

  String _name = '', _description = '';
  String _address = '';
  String _contactnumber = '';
  final int _favorite = 0;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      _selectedDate = picked;
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      _selectedTime = picked;
    }
  }

  Future<void> showModalInputForm(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เพิ่มการจอง'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(labelText: 'ชื่อ'),
                  onChanged: (value) {
                    _name = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'รายละเอียด'),
                  onChanged: (value) {
                    _description = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'เบอร์โทร'),
                  onChanged: (value) {
                    _contactnumber = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'ที่อยู่'),
                  onChanged: (value) {
                    _address = value;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectDate(context),
                        child: Text(
                          _selectedDate == null
                              ? 'เลือกวันที่'
                              : 'วันที่: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectTime(context),
                        child: Text(
                          _selectedTime == null
                              ? 'เลือกเวลา'
                              : 'เวลา: ${_selectedTime!.format(context)}',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                if (_name.isNotEmpty && _description.isNotEmpty) {
                  dbHelper.insertProduct(Product(
                    name: _name,
                    description: _description,
                    favorite: _favorite,
                    contactnumber: _contactnumber,
                    address: _address,
                    bookingTime:
                        '${DateFormat('dd/MM/yyyy').format(_selectedDate!)} ${_selectedTime!.format(context)}',
                  ));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }
}

class ModalEditProductForm {
  const ModalEditProductForm({Key? key, required this.dbHelper, required this.editedProduct});
  
  final DatabaseHelper dbHelper;
  final Product editedProduct;

  Future<dynamic> showModalInputForm(BuildContext context) {
    return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 500, // Set desired height
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: IconButton(
                  icon: Icon(Icons.close, color: Colors.orange),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: const Center(
                  child: Text(
                    'แก้ไขข้อมูล', // Changed title
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                trailing: TextButton(
                  onPressed: () async {
                    await dbHelper.updateProduct(editedProduct);
                    Navigator.pop(context);
                  },
                  child: const Text('บันทึก', style: TextStyle(color: Colors.orange)), // Save button
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (value) {
                        editedProduct.name = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'ชื่อบริการ (เช่น ทำความสะอาด)',
                        labelText: 'ชื่อบริการ',
                        labelStyle: TextStyle(color: Colors.orange),
                      ),
                    ),
                    TextField(
                      onChanged: (value) {
                        editedProduct.description = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'รายละเอียด (เช่น ทำความสะอาดบ้าน)',
                        labelText: 'รายละเอียด',
                        labelStyle: TextStyle(color: Colors.orange),
                      ),
                    ),
                    TextField(
                      onChanged: (value) {
                        editedProduct.address = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'ที่อยู่',
                        labelText: 'ที่อยู่',
                        labelStyle: TextStyle(color: Colors.orange),
                      ),
                    ),
                    TextField(
                      onChanged: (value) {
                        editedProduct.contactnumber = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'เบอร์โทรศัพท์',
                        labelText: 'เบอร์โทรศัพท์',
                        labelStyle: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



import 'package:flutter/material.dart';

class genBill extends StatefulWidget {
  @override
  _genBillState createState() => _genBillState();
}

class _genBillState extends State<genBill> {
  List<dynamicWidget> dynamicList = [];

  List<String> harga = [];

  List<String> quantity = [];

  double containerHeight = 50;

  addDynamic() {
    setState(() {
      if (quantity.isNotEmpty) {
        quantity = [];
        harga = [];
        dynamicList = [];
      }
      dynamicList.add(dynamicWidget());
      containerHeight += 50;
    });
  }

  submitData() {
    quantity = [];
    harga = [];
    dynamicList
        .forEach((widget) => quantity.add(widget.quantityController.text));
    dynamicList.forEach((widget) => harga.add(widget.hargaController.text));
    setState(() {});
    print(quantity.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            quantity.isEmpty
                ?  SizedBox(
                        height: containerHeight,
                        width: 600,
                        child: ListView.builder(
                          itemCount: dynamicList.length,
                          itemBuilder: (_, index) {
                            return Row(
                              children: [
                                dynamicList[index],
                                Tooltip(
                                  message: "Delete product",
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        dynamicList.removeAt(index);
                                        containerHeight -= 50;
                                      });

                                      // harga.removeAt(index);
                                      // quantity.removeAt(index);
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                )
                              ],
                            );
                          },
                        ))
                : Flexible(
                    flex: 1,
                    child: Card(
                        child: ListView.builder(
                            itemCount: quantity.length,
                            itemBuilder: (_, index) {
                              return Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(left: 10.0),
                                      child: Text(
                                          "${index + 1} : ${quantity[index]}   ${harga[index]}"),
                                    ),
                                    Divider()
                                  ],
                                ),
                              );
                            }))),
            quantity.isEmpty
                ? ElevatedButton(
                    onPressed: submitData,
                    child: Padding(
                        padding: new EdgeInsets.all(16.0),
                        child: new Text('Submit Data')))
                : Container(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: addDynamic, child: Icon(Icons.add)));
  }
}

class dynamicWidget extends StatelessWidget {
  TextEditingController quantityController = new TextEditingController();
  TextEditingController hargaController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 540,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(
              height: 50,
              width: 100,
              child: TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                keyboardType: TextInputType.number,
              )),
          SizedBox(
              height: 50,
              width: 150,
              child: TextFormField(
                controller: hargaController,
                decoration: const InputDecoration(
                  labelText: 'Harga (per barang)',
                ),
                keyboardType: TextInputType.number,
              )),
        ],
      ),
    );
  }
}

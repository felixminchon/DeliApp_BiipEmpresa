import 'package:delivery_app_biip/models/json/appShopItemModel.dart';
import 'package:delivery_app_biip/models/json/appShopModel.dart';
import 'package:delivery_app_biip/pages/item.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app_biip/common/widgets/pleaseWaitWidget.dart';
import 'package:delivery_app_biip/common/apifunctions/requestItemsAPI.dart';
import 'package:getflutter/getflutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';

import 'carrito.dart';

class ItemsPage extends StatefulWidget {
  int _shopId;
  String _shopName;
  Shop shop;

  ItemsPage(this._shopId, this._shopName,this.shop);

  @override
  _ItemsPageState createState() => _ItemsPageState(this._shopId, this._shopName,this.shop);
}

class _ItemsPageState extends State<ItemsPage> {
  int _shopId;
  String _shopName;
  Shop shop;

  _ItemsPageState(this._shopId,this._shopName,this.shop);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PleaseWaitWidget _pleaseWaitWidget = PleaseWaitWidget(key: ObjectKey("pleaseWaitWidget"));

  bool _refresh = true;
  List<Item> _items;
  bool _pleaseWait = false;

  _showSnackBar(String content, {bool error = false}){
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content:
      Text('${error ? "An unexpected error occured: " : ""}${content}'),
    ));
  }

  _showPleaseWait(bool b){
    setState(() {
      _pleaseWait = b;
    });
  }


  _refreshItems(){
    setState(() {
      _refresh = true;
    });
  }

  _navigateToItem(BuildContext context, int itemId, String itemName,Shop shop, Item item){
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => ItemPage(itemId,itemName,shop,item)),
    ).then((result) {
      if((result != null) && (result is bool) && (result == true)){
        _showSnackBar('Shop saved');
        _refreshItems();
      }
    });
  }

  badStatusCode(Response response){
    debugPrint("Bad status code ${response.statusCode} returned from server.");
    debugPrint("Response body ${response.body} returned from server.");
    throw Exception('Bad status code ${response.statusCode} returned from server.');
  }


  _loadItems(BuildContext context){
    _showPleaseWait(true);
    try{
      requestItemsAPI.loadAndParseItems(_shopId).then((response){
        setState(() {
          if(response.statusCode == 200){
            final list = json.decode(response.body);
            var items = list['meals'].map<Item>((json) => Item.fromJson(json)).toList();
            _items = items;
          }else{
            badStatusCode(response);
          }
        });
        _showPleaseWait(false);

      }).catchError((error){
        _showPleaseWait(false);
        _showSnackBar(error.toString(), error: true);
      });
    } catch (e) {
      _showPleaseWait(false);
      _showSnackBar(e.toString(), error: true);
    }
  }
  @override
  Widget build(BuildContext context) {
    if(_refresh){
      _refresh = false;
      _loadItems(context);
    }


    ListView builder = ListView.builder(
        itemCount: _items != null ? _items.length : 0,
        itemBuilder: (context, index) {
          Item item = _items[index];
//          return GFCard(
//            boxFit: BoxFit.cover,
//            image: Image.network(item.image),
//            title: GFListTile(
//                title: Text(item.price.toString()),
//                icon: GFIconButton(
//                  onPressed: null,
//                  icon: Icon(Icons.attach_money),
//                  type: GFButtonType.transparent,
//                )
//            ),
//            content: Text(item.name),
//            buttonBar: GFButtonBar(
//              alignment: WrapAlignment.start,
//              children: <Widget>[
//                GFButton(
//                  icon: Icon(Icons.description),
//                  onPressed: ()  => _navigateToItem(context, item.id, item.name,shop,item),
//                  text: 'View Item',
//                ),
//              ],
//            ),
//          );

          return GFCard(
            boxFit: BoxFit.cover,

            title: GFListTile(
                avatar:GFAvatar(
                    backgroundImage:NetworkImage(shop.logo)
                ),
                title: Text(shop.name),
                icon: GFIconButton(
                  onPressed: null,
                  icon: Icon(Icons.info),
                  type: GFButtonType.transparent,
                )
            ),
            image: Image.network(item.image),
            content:Text(item.name),
            buttonBar: GFButtonBar(
              alignment: WrapAlignment.start,
              children: <Widget>[
                GFButton(
                  onPressed: () => _navigateToItem(context, item.id, item.name,shop,item),
                  text: 'Ver productos',
                  shape: GFButtonShape.pills,
                ),
              ],
            ),
          );


//          return ListTile(
//            title: Text('${item.name}'),
////            subtitle: Text('Price: ${item.price.toString()}'),
//            trailing: Icon(Icons.arrow_right),
//            onTap: () => _navigateToItem(context, item.id, item.name,shop,item),
////            onLongPress: () => _deleteEmployee(context, employee),
//          );


        });
    Widget bodyWidget = _pleaseWait ? Stack(key: ObjectKey("stack"),children: <Widget>[_pleaseWaitWidget, builder],): Stack(key: ObjectKey("stack"),children: [builder]);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("${_shopName}"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              _refreshItems();
            },
          )
        ],
      ),
      body: new Center( child: bodyWidget),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> CarritoPage()));
        },
        tooltip: 'Carrito',
        child: Icon(Icons.shopping_basket),
      ),
    );
  }
}

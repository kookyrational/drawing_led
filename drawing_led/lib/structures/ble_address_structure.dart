
// 日期,時間,名稱,地點
class BLEAddressStructure
{
  String mAddress;

  BLEAddressStructure(this.mAddress);

  BLEAddressStructure.fromMap(Map<String, dynamic> aMap)
  {
    this.mAddress = aMap['address'];
  }

  Map<String, dynamic> toMap()
  {
    return {
      'address': mAddress,
    };
  }
}
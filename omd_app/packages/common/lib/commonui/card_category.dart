import 'custom_tab_bar_widget.dart';

class CardCategory extends TabItem {
  final String subTitle;
  CardCategory({this.subTitle = "", super.title, super.index, super.value});

  @override
  String toString() =>
      "{'title': $title, 'value': $value, 'index': $index, 'subTitle': $subTitle}";
}

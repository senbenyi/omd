enum MgBottomTabbarType {
  //首页和抖音是一个tab，只是有些app叫首页，有些叫抖音
  home("首页"),
  ticktok("抖音"),
  video("视频"),
  comic("漫画"),
  community("社区"),
  tiyu("世界杯"),
  mine("我的"),
  tianyashequ("吃瓜");

  final String name;
  const MgBottomTabbarType(this.name);
}

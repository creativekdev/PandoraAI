class Crop{
  // List<List<int>> ratios = [[2, 3, 20, 30], [3,2,30,20], [3,4,22,30],[4,3,30,22],[1,1,30,30]];
  List<double> ratios = [1,1,2/3,3/4,9/16];
  bool isPortrait = false;
  List<String> titles = ["Original", "Square", "2:3", "3:4", "9:16"];
  int selectedID = 0;
  // double aspectRatio = 2 / 3;
}
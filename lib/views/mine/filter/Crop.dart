class Crop{
  // List<List<int>> ratios = [[2, 3, 20, 30], [3,2,30,20], [3,4,22,30],[4,3,30,22],[1,1,30,30]];
  List<List<double>> ratios = [[1,1,3.0/2,4.0/3,16.0/9],[1,1,2.0/3,3.0/4,9.0/16]];

  int isPortrait = 0;
  List<List<String>> titles = [["Original", "Square", "3:2", "4:3", "16:9"],["Original", "Square", "2:3", "3:4", "9:16"]];
  int selectedID = 0;
  // double aspectRatio = 2 / 3;
}
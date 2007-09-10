REQUIRE Point	~pi/lib/wincon/graph.f
REQUIRE _TEXT	~pi/lib/wincon/text.f

0xFF0000 Color
0 0 length height 10 10 RRect
0x00FF00 Color
3 3 length 3 - height 3 - 10 10 RRect
0x0000FF Color
6 6 length 6 - height 6 - 10 10 RRect
S" disketa.bmp" 10 10 Image
0x00FFFF ColorText
10 30 S" Это дискета" Print
ConRefresh

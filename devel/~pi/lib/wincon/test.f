REQUIRE Point	~pi/lib/wincon/graph.f

S" disketa.bmp" 10 70 Image
S" yes.bmp" 30 70 Image
S" Anim.ico" 150 50 Icon
10 10 Point
10 10 50 20 20 RSquare
0x000000FF Color
0x00FF0000 Background
20 20 50 20 20 RSquare
0x0000FF00 Color
50 50 100 70 Line
10 10 Draw
0x0000FF00 Background
100 10 100 170 115 15 180 70 Sector
ConRefresh

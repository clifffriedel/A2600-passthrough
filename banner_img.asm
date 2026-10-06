
 ; *** if you want to modify the bitmap color on the fly, just dim a
 ; *** variable in bB called "bmp_banner_1_color", and use it to set the
 ; *** color.

 ;*** this is the height of the displayed data
bmp_banner_1_window = 14

 ;*** this is the height of the bitmap data
bmp_banner_1_height = 14

 ifnconst bmp_banner_1_color
bmp_banner_1_color
 endif
	.byte $0f

   if >. != >[.+(6*bmp_banner_1_height)]
      align 256
   endif

bmp_banner_1_00

	BYTE %00000000
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000011
	BYTE %00000111
	BYTE %00000011
	BYTE %00000011
	BYTE %00000010
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000



   if >. != >[.+(6*bmp_banner_1_height)]
      align 256
   endif

bmp_banner_1_01

	BYTE %00000000
	BYTE %11110111
	BYTE %00110110
	BYTE %00110110
	BYTE %00110110
	BYTE %00110110
	BYTE %10111100
	BYTE %00110000
	BYTE %00111100
	BYTE %00110110
	BYTE %00110110
	BYTE %00110110
	BYTE %00110110
	BYTE %01111100

   if >. != >[.+(6*bmp_banner_1_height)]
      align 256
   endif

bmp_banner_1_02

	BYTE %00000000
	BYTE %11110011
	BYTE %01100110
	BYTE %01100110
	BYTE %01100110
	BYTE %01101110
	BYTE %11111011
	BYTE %00000000
	BYTE %01111111
	BYTE %11011010
	BYTE %01011001
	BYTE %00111011
	BYTE %11011011
	BYTE %01110001




   if >. != >[.+(6*bmp_banner_1_height)]
      align 256
   endif

bmp_banner_1_03

	BYTE %00000000
	BYTE %10001111
	BYTE %11011011
	BYTE %11011011
	BYTE %11011011
	BYTE %11011011
	BYTE %10111011
	BYTE %00000000
	BYTE %10011100
	BYTE %11010110
	BYTE %11001110
	BYTE %10011100
	BYTE %01011010
	BYTE %11001110



   if >. != >[.+(6*bmp_banner_1_height)]
      align 256
   endif

bmp_banner_1_04

	BYTE %00111100
	BYTE %01000010
	BYTE %01111100
	BYTE %00110000
	BYTE %00101100
	BYTE %01101100
	BYTE %00111110
	BYTE %01000000
	BYTE %01100000
	BYTE %00110000
	BYTE %00111110
	BYTE %00110000
	BYTE %01100000
	BYTE %01000000


   if >. != >[.+(6*bmp_banner_1_height)]
      align 256
   endif

bmp_banner_1_05
	BYTE %00000000
	BYTE %11011000
	BYTE %11011000
	BYTE %11011000
	BYTE %11011000
	BYTE %11011000
	BYTE %11110000
	BYTE %11000000
	BYTE %11000000
	BYTE %10000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000
	BYTE %00000000


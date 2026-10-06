 rem Generated 8/18/2010 10:21:08 PM by Visual bB Version 1.0.0.550
 rem *******************************************
 rem * Passthrough 2600                         *
 rem * A simple but fun game                   *
 rem * By Cliff Friedel                               *
 rem * Custom Minikernel by Reveng      *
 rem * Version 1.0.0	                               *
 rem *                                                      *
 rem * 8/30.2010                                     *
 rem *******************************************

 set tv ntsc
 
 include div_mul.asm
 include banner_mk.asm
 set smartbranching on

 dim sc1=score
 dim sc2=score+1
 dim sc3=score+2

 gosub title

main_loop
 if switchreset then reboot
 scorecolor = 14
 if h=0 then COLUP0=$C0 else COLUP0=c 
 if i > 0 then COLUP0=i
 if x{0} then COLUP1=$C6  else COLUP1=$44
 if l=1 then gosub level1
 if l=2 then gosub level2
 if l=3 then gosub level3
 if l=4 then gosub level4
 if l=5 then gosub level5
 if l=6 then gosub level6
 if l=7 then gosub level7
 if l=8 then gosub level8
 if l=9 then gosub level9
 if l=10 then gosub level10
 if l>10 then goto gameover
 if n>0 then gosub makenoise
 gosub powerups
 if sc1=$00 && sc2=$00 && sc3=$00 then goto gameover
 gosub moveplayer
 if g<>0 then COLUPF = 0 else COLUPF=c
 drawscreen
 if joy0fire && f=0 then gosub checkplayercol
 if f > 0 then f=f+1 : if f > 10 then f=0
 if g > 0 then g=g+1 : if g > 200 then g=0
 if h > 0 then h=h+1 : if h > 200 then h=0
 if i > 0 then i=i+1 : if i > 200 then i=0
 if e > 0 then e=e+1 : if e > 200 then e=0
 if y > 0 then y=y+1 : if y =200 then y=1 : w=w+1
 if w > 1 then y=0 : w=0
 if e=0 && l<11 then score = score - 100
 goto main_loop

moveplayer
 if  l > 1 then m=m+1
 if m > l then m = 0
 if l <= 1 || l<>m then SingleStep
 if p = 1 then player0x = player0x + (l/2)
 if p = 0 then player0x = player0x - (l/2)
SingleStep
 if p = 1 then player0x = player0x + 1
 if p = 0 then player0x = player0x - 1
 if player0x < 140 then Negchange 
   p = 0
   player0x = 140
Negchange
 if player0x > 16 then Poschange
    p = 1
    player0x = 16
Poschange
 return

powerups
 rem if there is no powerup on the board, pick one using the random number generator
 if y<>0  then PowerupPicked
 x = (rand&7)+1
 y=1
100 z=rand : rem I am using a line number here so I can call back to it if the number is out of bounds
 if z < 30 || z > 130 then goto 100 : rem this should put the ships closer to the screen 
 player1x = z 
110 z=(rand&15) : rem I am using a line number here so I can call back to it if the number is out of bounds
 if z < 1 || z > 11 then goto 110 : rem this should put the ships closer to the screen
 z=z*8 
 player1y = z 
 COLUPF=c
 drawscreen
PowerupPicked
 if !collision(player0,player1) then EndCollision
 rem x =1 Score+100000
 if x<>1 then SkipOne
 if sc1 < $89 && sc2 < $99 then score=score+100000 else score =999900
 n=3
SkipOne
 rem x =2 Score-100000
 if x<>2 then SkipTwo
 score=score-100000
 if sc1 < $09 && sc2 < $99 then goto gameover
 n=1
SkipTwo
 rem x =3 Player moves up three rows
 if x<>3 then SkipThree
 player0y = player0y - 24
 gosub moveplayer
 n=3
SkipThree
 rem x =4 move player back; call backtostart
 if x<>4 then SkipFour
 gosub backtostart
 n=1
SkipFour
 rem x=5 temporary invincibility
 if x<>5 then SkipFive
 i=1
 n=3 
SkipFive
 rem x =6 make the player disappear for a short time
 if x<>6 then SkipSix
 h=1
 n=1 
SkipSix
 rem will stop the score from decreasing for a short time
 if x<>7 then SkipSeven
 e=1
 n=3
SkipSeven
 rem x =8 playfield will disappear for a short itme
 if x<>8 then SkipEight
 g=1
 n=1
SkipEight
 gosub removepowerup
EndCollision
 return

removepowerup
 player1x=0
 player1y=0
 x=0
 y=0
 return


checkplayercol
 if collision(player0,playfield) && i=0 then gosub backtostart else player0y = player0y - 8
 if player0y >= 8 then NewLevel
 l=l+1
 n=2
 if sc1<$79 && sc2<$99 then score = score + 200000 else score =999900
 player0x = 76
 player0y = 88
 gosub removepowerup
NewLevel 
 f=1 
 return

backtostart
 if i <>0 then Invincible 
 if switchleftb then BeginnerSettings 
 player0x = 76
 player0y = 88
 if sc1<$05 then l=11 else score = score - 50000 
BeginnerSettings
 if !switchleftb then CommonSettings
 player0x = 76
 player0y = player0y + 24
 if player0y > 88 then player0y = 88
 if sc1<=$02 && sc2<=$49 then l=11 :  n=1 : return
 if sc1<=$01 && sc2<=$99 then l=11 :  n=1 : return
 score = score - 25000
CommonSettings
 n=1
Invincible
 return
 
makenoise
 if n<>1 then Sound2
   if s >= 1 then Sound2
     r = r+1
     if r > 30 then s=s+1
     AUDV0=7 : AUDC0=14 : AUDF0 = 14
     COLUP0=$C0
     if r > 30 then r = 1
     if g<>0 then COLUPF = 0 else COLUPF=c
     drawscreen
     goto makenoise
Sound2
  if n<>2 then Sound3 
   if s >= 3 then Sound3
     if r =1 then s=s+1
     if r <=1 then r = 31
     r = r-1
     AUDV0=7 : AUDC0=12 : AUDF0 = r
     COLUP0=$C0
     if g<>0 then COLUPF = 0 else COLUPF=c
     drawscreen
     goto makenoise
Sound3
  if n<>3 then Sound4 
   if s >= 2 then Sound4
     if r =1 then s=s+1
     if r <= 1 then r = 31
     r = r-1
     AUDV0=7 : AUDC0=7 : AUDF0 =r
     COLUP0=$C0
     if g<>0 then COLUPF = 0 else COLUPF=c
     drawscreen
     goto makenoise
Sound4
 AUDV0 = 0
 s = 0
 r = 1
 n = 0
 return

level1
 playfield:
 XXXXXXXXXXXXXXX...XXXXXXXXXXXXXX
 XXXXXXXXXXXXXXX...XXXXXXXXXXXXXX
 XXXXXXXXXXXXXXX...XXXXXXXXXXXXXX
 XXXXXXXXXXXXXX....XXXXXXXXXXXXXX
 XXXXXXXXXXXXXX....XXXXXXXXXXXXXX
 XXXXXXXXXXXXX......XXXXXXXXXXXXX
 XXXXXXXXXXXX........XXXXXXXXXXXX
 XXXXXXXXXXX..........XXXXXXXXXXX
 XXXXXXX.................XXXXXXXX
 XXXXX......................XXXXX
 XX............................XX
end
 c=$2E
 return

level2
 playfield:
 XXXXXXXXXXXXX...XXXXXXXXXXXXXXXX
 XXXXXXXXXXXX.....XXXXXXXXXXXXXXX
 XXXXXXXXX..........XXXXXXXXXXXXX
 XXXXXXXXX...XXXX...XXXXXXXXXXXXX
 XXXXXXXXX...XXXX...XXXXXXXXXXXXX
 XXXXXXXXX..........XXXXXXXXXXXXX
 XXXXXXXXX..........XXXXXXXXXXXXX
 XXXXXXXXXXX......XXXXXXXXXXXXXXX
 XXXXXXXXXXX......XXXXXXXXXXXXXXX
 XXXXXXXXXXX.....XXXXXXXXXXXXXXXX
 XXXXXXXXX.....XXXXXXXXXXXXXXXXXX
end
 c=$8E
 return

level3
 playfield:
 XXXXXXXXXX...X....X...XXXXXXXXXX
 XXXXXXXXXX...X....X...XXXXXXXXXX
 XXXXXXXXXX...X....X...XXXXXXXXXX
 XXXXXXXXXX...X....X...XXXXXXXXXX
 XXXXXXXXXX...X....X...XXXXXXXXXX
 XXXXXXXXXX...X....X...XXXXXXXXXX
 XXXXXXXXXX...X....X...XXXXXXXXXX
 XXXXXXXXX...XX....XX...XXXXXXXXX
 XXXXXXX....XXX....XXX....XXXXXXX
 XXXX.....XXXXX....XXXXX.....XXXX
 ......XXXXXXXX....XXXXXXXX......
end
 c=$6E
 return

level4
 playfield:
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXX...
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXX...
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXX...
 XXXXXXXXXXXXXXXXXXXXXXXXXXXX...X
 XXXXXXXXXXXXXXXXXXXXXXXXXXX...XX
 XXXXXXXXXXXXXXXXXXXXXXXXX...XXXX
 XXXXXXXXXXXXXXXXXXXXXXX...XXXXXX
 XXXXXXXXXXXXXXXXXXXX...XXXXXXXXX
 XXXXXXXXXXXXXXXXX...XXXXXXXXXXXX
 XXXXXXXXXXXX.....XXXXXXXXXXXXXXX
 XXXXXX......XXXXXXXXXXXXXXXXXXXX
end
 c=$BE
 return

level5
 playfield:
 XXXXXXXXXXXXXX...XXXXXXXXXXXXXXX
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXX...
 XXXXXXXXXXXXXXXXX...XXXXXXXXXXXX
 XXXXXXXXXXXXXXXXXXXXXXXX...XXXXX
 XXXXXXXXXXX...XXXXXXXXXXXXXXXXXX
 XXXX...XXXXXXXXXXXXXXXXXXXXXXXXX
 XXXXXXXXXXXXXXXXXXXX...XXXXXXXXX
 XXXXXXXXXXXXXXXXXXXXXXXXXXX...XX
 XXXXXXX...XXXXXXXXXXXXXXXXXXXXXX
 ...XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 XXXXXXXXXXXXXX...XXXXXXXXXXXXXXX
end
 c=$DA
 return

level6
 playfield:
 XXXXXXXXXXXXXXX...XXXXXXXXXXXXXX
 XXXXXXXXXXXXXXX...XXXXXXXXXXXXXX
 XXXXXXXXXXXXXXX...XXXXXXXXXXXXXX
 XXXXXXXXXXXXXXX...XXXXXXXXXXXXXX
 ................................
 ...............XXX..............
 ..............XXXXX.............
 X..............XXX.............X
 XXX...........XXXXX..........XXX
 XXXXXX.....XXXXXXXXXX.....XXXXXX
 ...XXXXXXXXXXXXXXXXXXXXXXXXXX...
end
 c=$FE
 return

level7
 playfield:
 XXXXXXXXXX......................
 XXXXXXXXXX......................
 XXXXXXXXXXXXXXXXXXXXXXXXXX....XX
 XXXXXXXXXXXXXXXXXXXXXXXX....XXXX
 XXXXXXXXXXXXXXXXXXXXXX....XXXXXX
 XXXXXXXXXXXXXXXXXXXX....XXXXXXXX
 XXXXXXXXXXXXXXXXXX....XXXXXXXXXX
 XXXXXXXXXXXXXXXX....XXXXXXXXXXXX
 XXXXXXXXXXXXXX....XXXXXXXXXXXXXX
 XXXXXXXXXXXXXX....XXXXXXXXXXXXXX
 XXXXXXXXXXXXXX....XXXXXXXXXXXXXX
end
 c=$0C
 return

level8
 playfield:
 XXXXXXXXXX....................XX
 XXXXXXX...XXXXXXXXXXXXXX......XX
 XXXX...XXXXXXXXXXXXXX...XXX...XX
 X...XXXXXXXXXXXXXX...XXXXXX...XX
 ..................XXXXXXXXX...XX
 .XXXXXXXXXXXXXXXX.XXXXXXXXX...XX
 .XXXXXXXXXXXXXXXX.XXXXXXXXX...XX
 .XXXXXXXXXXXXXXXX.XXXXXX...XXXXX
 .XXXXXXXXXXXXXXXX.XXX...XXXXXXXX
 .XXXXXXXXXXXXXXXX....XXXXXXXXXXX
 ..................XXXXXXXXXXXXXX
end
 c=$3E
 return

level9
 playfield:
 .........X...XXXXXXXXXXXXXXXX...
 XXX...XXXX...XXXXXXXXXXXXXXXX...
 XXX...XXXXXXX...XXXXXXXXXX...XXX
 XXX...XXXXXXXXXX...XXXX...XXXXXX
 XXX...XXXXXXXXXXXXX....XXXXXXXXX
 XXX...XXXXXXXXXXXXX....XXXXXXXXX
 XXX...XXXXXXXXXXXXX....XXXXXXXXX
 XXX...XXXXXXXXXX...XXXX...XXXXXX
 XXX...XXXXXXX...XXXXXXXXXX...XXX
 XXX...XXXX...XXXXXXXXXXXXXXXX...
 .........X...XXXXXXXXXXXXXXXX...
end
 c=$1C
 return

level10
 playfield:
 XXXXXXXXXXX...XXX...XXXXXXXXXXXX
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXX...
 X...XXXXXXXXXXXXXXXXXXXXXXXXXXXX
 XXXXXXXXXXXXXXXXXXXXXXXXXX...XXX
 XXXX...XXXXXXXXXXXXXXXXXXXXXXXXX
 XXXXXXXXXXXXXXXXXXXXXXX...XXXXXX
 XXXXXXXX...XXXXXXXXXXXXXXXXXXXXX
 XXXXXXXXXXXXXXXXXXXX...XXXXXXXXX
 XXXXXXXXXXX...XXXXXXXXXXXXXXXXXX
 XXXXXXXXXXXXXXXXX...XXXXXXXXXXXX
 XXXXXXXXXXXXXX...XXXXXXXXXXXXXXX
end
 c=$8E
 return

joywait
 COLUPF=c
 drawscreen
 b=b+1 : if b>50 then b=50 : if b=50 && joy0fire then b=0 : f=1 : return
 goto joywait
 return

gameover
 score=0
 player0x = 0
 player0y = 0
 player1x = 0
 player1y = 0
 c=68
 playfield:
 .XXXX...X...X...X.XXXXX.........
 X......X.X..XX.XX.X.............
 X.XXX.XXXXX.X.X.X.XXXX..........
 X...X.X...X.X...X.X.............
 .XXX..X...X.X...X.XXXXX.........
 ................................
 ......XXX..X...X.XXXXX.XXXX.....
 .....X...X.X...X.X.....X...X....
 .....X...X.X...X.XXXX..XXXX.....
 .....X...X..X.X..X.....X...X....
 ......XXX....X...XXXXX.X...X....
end
 COLUBK = 64
 COLUPF = c
 drawscreen
 if switchreset then reboot
 goto gameover

title
 player0x = 20
 player0y = 77
 rem this vairable is used to count frames for the game over screen.
 a = 1
 rem this variable gives the current playfield color.  This is used to change the player to invisible should they receive that powerup.
 c = 30
 rem this variable will set the duration of stopping the score (powerup)
 e = 0
 rem this variable sets the level, which in turn sets the playfield.
 l = 1
 rem This variable tells the program whether the button has been fired and sets a delay so that it won't repeat over and over
 f = 0
 rem this variable sets whether the playfield is visible or not and times it (powerup effect)
 g = 0 
 rem this variable sets whether the player is visible or not. (powerup effect)
 h = 0
 rem this variable sets invincibility for a short time.
 i = 0
 rem This variable tells the moveplayer subroutine whether to move the player positively or negatively. 1 is positive (right), 0 is negative (left).
 p = 1
 rem This variable sets the move rate for the player.  A higher number means the player will move faster.
 m = 0
 rem set the beginning score at 999990.  We are going to have it countdown from there.
 score = 999900
 rem this variable is the sound counter for the number of loops.
 s = 0
 rem this variable is for the volume counter.
 v = 0
 rem this variable is for the frequency counter.
 r = 0
 rem this variable says whether to make noise and what type.
 n = 0
 rem this lets the powerup stay out longer
 w = 0
 rem powerup variable go to powerup to see what this value can be.  Starts at 0
 x = 0
 rem powerup variable to determine whether a powerup is on the board.
 y = 0
 rem powerup location variable
 z = 0
  scorecolor = 14
 playfield:
 XXXXXXX...XXXXXXXXXXXXXXXXXXXXXX
 XXXXXX.XXX.XXXXXXXXXXXXXXXXXXXXX
 XXXXXXXX..XX....XXXXXXXXXXXXXXXX
 XXXXXXX.XXX.XXXXXXXXXXXXXXXXXXXX
 XXXXXX.........XX...XXXXXXXXXXXX
 XXXXXXXXXXX.XXX..XXX.XXXXXXXXXXX
 XXXXXXXXXXXX...X.XXX.X...XXXXXXX
 XXXXXXXXXXXXXXXX.XXX..XXX.XXXXXX
 XXXXXXXXXXXXXXXXX...X.XXX.XXXXXX
 XXXXXXXXXXXXXXXXXXXXX.XXX.XXXXXX
 XXXXXXXXXXXXXXXXXXXXXX...XXXXXXX
end
 COLUBK = 00
 COLUPF = c
 drawscreen
 gosub joywait
 player0:
 %00000000
 %11000110
 %01111100
 %00111000
 %00010000
 %00010000
 %00010000
 %00010000
end
 player1:
 %01111110
 %10111101
 %11000011
 %11011011
 %11011011
 %11000011
 %10111101
 %01111110
end
 player0x=76
 player0y=88
 goto main_loop
 return

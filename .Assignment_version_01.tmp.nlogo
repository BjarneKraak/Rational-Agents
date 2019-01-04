;there are three breeds of turtles: enemies, friends and robots
breed [enemies enemy]
breed [robots robot]
breed [friends friend]

robots-own
[
  damage ;robots gets damaged by meeting enemies, it heals by meeting friends
  energy ;robots loses energy by moving, it gains energy by entering a power station
  orientation ;orientation of robot: 0 is up, 90 if right etc
  xcor-goal ;x coordinate of goal, which can be the real goal or a power station
  ycor-goal ;y coordinate of goal, which can be the real goal or a power station
]

to setup ;runs once when button is pressed
  clear-all ;clear field
  setup-patches ;creat all pathces needed
  setup-turtles ;create all turtles aka enemies, friends and the robot
  reset-ticks ; let time begin
  user-message "The field is set-up" ; give user a message
end

to go ; runs continiously when button is pressed
  move-turtles ;move all turtles
  meet-enemies ;check if the robot meets enemies
  meet-friends ;check if the roboto meets friends
  check-for-power-stations ;check if robot is on a power station
  check-for-goal ;check if the robot reached the goal
  check-death ;check if the robot should 'die'
  tick ; let time pass
end

to setup-turtles ;create all turtles and give them their properties
  create-enemies number-of-enemies  ;create as many enemies as specified by the user
  [
    set color orange ; make the enemies orange
    setxy random-xcor random-ycor ;place all enemies on random coordinates
  ]

  create-robots 1 ;create one robot
  [
    set color grey ;make the robot grey
    set size robot-size ;give the robot the size specified by the user
    set damage initial-damage ;give the robot the initial damage specified by the user
    setxy x-start y-start ;place the robot at the coordinates specified by the user
    set energy initial-energy ;give the robot its initial energy specified by the user
  ]

  create-friends number-of-friends ;create as many friends as specified by the user
  [
    set color yellow  ;make friends yellow
    setxy random-xcor random-ycor ;place all enemies on random coordinates
  ]
  ;give all breeds their shape:
  set-default-shape  enemies "face sad"
  set-default-shape friends "face happy"
  set-default-shape robots "robot"

end

to setup-patches ;setup all patches
  ask patches [set pcolor black] ; general patches are black
  ask n-of number-of-obstacles patches [set pcolor red] ; slider sets amount of obstacles randomly distributed with red color
  ask n-of number-of-power-stations patches [set pcolor green] ; slider sets amount of power stations randomly distributed with green color
  ask patch x-goal y-goal  [set pcolor white] ; create a target with a white color
end

to move-turtles ;move all turtles with separate functions
  move-enemies
  move-friends
  move-robots
end

to meet-enemies
  ask robots[
    let person one-of enemies-here ;check if there are enemies on location of robot
    if person != nobody [ ;if theres at least one enemy
      set damage damage + loss-from-enemies; increase the damage of robot by amount specified by user
    ]
  ]
end

to meet-friends
  ask robots[
    let person one-of friends-here ;check if there are friends on location of robot
    if person != nobody [ ; if there's at least one friend
      set damage damage - gain-from-friends; decrease the damage of robot by amount specified by user
      if damage < 0 [ ; make sure the damage can not get below zero
        set damage 0
      ]
    ]
  ]
end

to check-for-power-stations
  ask robots[
    if pcolor = green [ ;check if robot is on power station
      set energy energy + gain-from-power-station ;increase energy level by amount specified by user
      if energy > 100 ;make sure the energy level can not get greater than 100
      [
        set energy 100
      ]
    ]
  ]
end

to check-for-goal
  ask robots[
    if pcolor = white [ ;check if the robot is on the goal
      user-message "The robot arrived at the goal" ;tell the user the robot is on the goal
      stop
    ]
  ]
end

to lose-energy
  ask robots [
    set energy energy - 1; robots lose energy by moving
  ]
end

to check-death ;a robot can 'die' in two ways, by getting to damaged or by having no energy left
  ask robots [
    if damage >= maximum-damage [ ;if damage is greater than amount specified by user, the robot dies
      user-message "Robot is too damaged: it died" ;send message to user
      die
    ]
    if energy <=  0 [ ;if the energy gets below 1, the robot can't move any more
      user-message "Robot has no energy left: it died" ;send message to user
      die
    ]
  ]
end

to move-enemies
  ask enemies
  [
    right random 360 ;turn a random direction
    let temp one-of [1 2 3] ;get a number (1 2 or 3)
    forward temp ; move that amount forard
    if pcolor = red ;check if enemy moved on top of obstacle
    [ ;if moved on top of obstacle, move back
      right 180 ;turn 180 degrees
      forward temp ; go back
      right 180 ; turn to normal orientation
    ]
  ]
end

to move-friends
  ask friends
  [
    right random 360 ;turn a random direction
    forward 1 ;move one step forward
    if pcolor = red [ ;if moved on top of obstacle, move back
      right 180 ;turn 180 degrees
      forward 1 ; go back
      right 180 ; turn to normal pos
    ]
  ]
end

to move-robots
  ask robots [
    ifelse pcolor = green and energy < 100 ;check if robot is on a power station and the energy level is below 100
    [ ]; wait and get fueled
    [move-to-goal] ; otherwise move to the goal specified at the moment
  ]

end

to move-to-goal
  set-goal ;set goal depending on energy level

  move-and-find-orientation ; move 1 forward and find orientation
  avoid-obstacles ;avoid obstacles:
  lose-energy ;lose energy by moving

  ;find angle to come to the goal specified
  let dif-x2 xcor-goal - xcor
  let dif-y2 ycor-goal - ycor
  let angle atan dif-x2 dif-y2

  rotate-to-orientation angle ;rotate robot towards the goal
end

to set-goal
  ifelse energy > 50 ;if energy level is higher than 50
  [;goal is real goal
    set xcor-goal  x-goal
    set ycor-goal  y-goal
  ]
  [;if energy level is below 50, search for nearby powerstations and set that as the goal
    ask patches in-radius 3 with [pcolor = green] ; find powerstations within a radius of 3 patches
    [ ;save coordinates of power station
      let x-temp pxcor
      let y-temp pycor
      ask robots
      [ ;send goal coordinates to coordinates of power station found, if any
        set xcor-goal x-temp
        set ycor-goal y-temp
      ]
    ]
  ]
end

to rotate-to-orientation [wanted-orientation] ;rotate to angle wanted, depending on current orientation
  ask robots [
    right wanted-orientation - orientation ;turn
    set orientation wanted-orientation ;save new orientation
  ]
end

to avoid-obstacles
  if pcolor = red [ ;if moved on top of obstacle
    right 180 ;turn 180 degrees
    forward 1 ; go back
    right 180 ; turn to normal pos
    let temp one-of [90 90 45 180 270 300 14] ; choose a random angle, random to make sure it does not get stuck in a loop
    right temp ; turn the random angle
    forward 1 ;move forward
    set orientation orientation + temp ; save new orientation
    avoid-obstacles ;make sure robot is not again on a obstacle, if it is do it again
  ]
end

to move-and-find-orientation
  ;save coordinates
  let last-x xcor
  let last-y ycor
  forward 1 ;move 1 forward
  ;save new coordinates
  let new-x xcor
  let new-y ycor
  ;calculate the difference
  let dif-x new-x - last-x
  let dif-y new-y - last-y
  ;calculate orientation and save it
  if dif-x > 0 [set orientation atan dif-x dif-y ]
end
@#$#@#$#@
GRAPHICS-WINDOW
482
15
1061
595
-1
-1
11.2
1
10
1
1
1
0
0
0
1
-25
25
-25
25
1
1
1
ticks
30.0

BUTTON
17
44
83
77
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
89
44
152
77
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
20
87
151
120
number-of-enemies
number-of-enemies
0
150
50.0
1
1
NIL
HORIZONTAL

SLIDER
157
88
279
121
number-of-friends
number-of-friends
0
150
50.0
1
1
NIL
HORIZONTAL

SLIDER
21
134
152
167
number-of-power-stations
number-of-power-stations
0
100
60.0
1
1
NIL
HORIZONTAL

SLIDER
158
132
278
165
number-of-obstacles
number-of-obstacles
0
400
120.0
1
1
NIL
HORIZONTAL

SLIDER
23
181
153
214
initial-energy
initial-energy
0
100
40.0
1
1
NIL
HORIZONTAL

SLIDER
23
232
150
265
initial-damage
initial-damage
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
157
231
288
264
maximum-damage
maximum-damage
0
50
20.0
1
1
NIL
HORIZONTAL

SLIDER
158
46
280
79
robot-size
robot-size
2
15
2.0
1
1
NIL
HORIZONTAL

INPUTBOX
289
47
349
107
x-start
20.0
1
0
Number

INPUTBOX
289
118
354
178
y-start
20.0
1
0
Number

INPUTBOX
290
192
353
252
x-goal
-20.0
1
0
Number

INPUTBOX
292
269
350
329
y-goal
-20.0
1
0
Number

PLOT
22
348
280
468
Damage
Time
Damage
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Damage" 1.0 0 -16777216 true "" "ask robots [ plot damage ]"
"Maximum" 1.0 0 -7500403 true "" "plot maximum-damage"

PLOT
21
472
281
592
Energy
Time
Energy
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Energy" 1.0 0 -2674135 true "" "ask robots [plot energy]"

SLIDER
166
181
281
214
gain-from-power-station
gain-from-power-station
1
40
40.0
1
1
NIL
HORIZONTAL

SLIDER
20
277
152
310
gain-from-friends
gain-from-friends
1
20
1.0
1
1
NIL
HORIZONTAL

SLIDER
163
279
287
312
loss-from-enemies
loss-from-enemies
1
20
17.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This is a model which describes a basic survivel algorithm. There is one robot who is our main character. This robot is somewhere and it needs to go somewhere else, the goal. The goal is marked by a white tile. The robot both knows its position and the location of the goal is provided as well at any time.

The robots purpose is to make it to the goal. The robot cannot move through obstacles - marked in red - and thus have to move around them. 

Moreover, with every step the robot takes, it loses energy. If there is no energy left at all, the robot cannot move anymore and 'dies'. Luckily, there are some powerstations - in green - to add energy to the robot.

Furthermore, the area is inhibited by friends and enemies. The robot gets damaged if it meets an enemy, and recovers from meeting friends. If the robot gets to damaged, it 'dies' as well. Friends have a happy face, enemies look sad.

## HOW IT WORKS

Both the enemies and friends move in a random way, the friends with one step at a time and the enemies with 1, 2 or 3 steps at a time. Thus, on aver

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

robot
false
0
Rectangle -7500403 true true 120 15 180 60
Rectangle -7500403 true true 90 60 210 165
Rectangle -7500403 true true 120 165 135 240
Rectangle -7500403 true true 165 165 180 240
Rectangle -7500403 true true 75 75 90 135
Rectangle -7500403 true true 210 75 225 135

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

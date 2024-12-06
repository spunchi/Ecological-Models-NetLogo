globals [J N2 empty-patch-random K1 K2]
breed [species1 a-species1]
breed [species2 a-species2]
turtles-own [species]
patches-own [random-number]

to setup
  clear-all
  set J (w1 + 1) * (w1 + 1)
  resize-world 0 w1 0 w1
  set N2 J - N1
  set K1 N1
  set K2 J - N1
  while [K1 > 0] [
    set empty-patch-random one-of patches with [count turtles-here = 0]
    create-species1 1 [
      setxy [pxcor] of empty-patch-random [pycor] of empty-patch-random
      set species 1
      set size 1
      set shape "circle"
      set color orange
    ]
    set K1 K1 - 1
  ]
  while [K2 > 0] [
    set empty-patch-random one-of patches with [count turtles-here = 0]
    create-species2 1 [
      setxy [pxcor] of empty-patch-random [pycor] of empty-patch-random
      set species 2
      set size 1
      set shape "circle"
      set color blue
    ]
    set K2 K2 - 1
  ]
  reset-ticks
end

to go
  species1-die
  species2-die
  ask turtles [species-birth]
  update-plots
  tick
end

to species1-die
  ask species1 [
    let count-neighbors-species1 count species2-on neighbors
    if (count-neighbors-species1 > HND-sp2) [
      die
    ]
  ]
end

to species2-die
  ask species2 [
    let count-neighbors-species2 count species1-on neighbors
    if (count-neighbors-species2 > HND-sp1) [
      die
    ]
  ]
end

to species-birth
  let empty-patches count patches with [count turtles-here = 0]
  if (empty-patches > 0) [
    set empty-patch-random one-of patches with [count turtles-here = 0]
    ask empty-patch-random [
      let species1-count count species1-on neighbors
      let species2-count count species2-on neighbors
      if (species1-count < HND-sp1) [
        ask one-of species1 [
          hatch 1
          setxy [pxcor] of empty-patch-random [pycor] of empty-patch-random
        ]
      ]
      if (species2-count < HND-sp2) [
        ask one-of species2 [
          hatch 1
          setxy [pxcor] of empty-patch-random [pycor] of empty-patch-random
        ]
      ]
    ]
  ]
end


; Copyright 2023l Sareena, B. & Ruwan Punchi-Manage.
; * Corresponding Email: spunchi@sci.pdn.ac.lk
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
207
10
999
803
-1
-1
16.0
1
10
1
1
1
0
1
1
1
0
48
0
48
0
0
1
ticks
30.0

BUTTON
0
10
63
43
NIL
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
71
10
134
43
NIL
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
0
95
172
128
N1
N1
0
J
749.0
1
1
NIL
HORIZONTAL

MONITOR
0
221
57
266
N1
count species1
17
1
11

MONITOR
64
221
121
266
N2
count species2
17
1
11

PLOT
1047
10
1514
395
Abundance of Trees
NIL
NIL
0.0
10.0
0.0
2000.0
true
true
"" ""
PENS
"Species-1" 1.0 0 -817084 true "" "plot N1"
"Species-2" 1.0 0 -13345367 true "" "plot N2"

MONITOR
127
221
184
266
J
count turtles
17
1
11

SLIDER
0
53
172
86
w1
w1
0
100
48.0
1
1
NIL
HORIZONTAL

SLIDER
0
135
172
168
HND-sp1
HND-sp1
0
8
3.0
1
1
NIL
HORIZONTAL

SLIDER
0
177
172
210
HND-sp2
HND-sp2
0
8
3.0
1
1
NIL
HORIZONTAL

MONITOR
4
284
102
329
Empty Patches
count patches with [count turtles-here = 0]
17
1
11

PLOT
1048
418
1517
667
Empty Patches
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count patches with [count turtles-here = 0]"

@#$#@#$#@
## WHAT IS IT?

It is assumed that two species cannot coexist in the same environment (Gauss 1932). The competition among two species out compete one of the species and only one species survive in the long run. If two species are equally competitive then stochastic drift determines the species abundances, the stochastic drift caused community to reach monodominance. However, we have seen two species managed to coexist in the same environment. It is assumed that ecological processes such as heterospecific negative density dependence (HNND) can maintain the species richness at local spatial scales (_i.e._ tree neighborhood). This model illustrates the HNND (interspecific competition) in sessile organisms (_e.g._ trees).

## HOW IT WORKS

The model has two species (sp<sub>1</sub> and sp<sub>2</sub>). The initial abundance of the species are _N_<sub>1</sub> and _N_<sub>2</sub>. The community has a size _J_. Each patch contains maximum one individual. Initially, community is saturated. Therefore, initial abundance of the species-2 is, _N_<sub>2</sub> = _J_ - _N_<sub>1</sub>. Two species placed in the community randomly at the beginning. Each time a tree is selected (a focal tree). If the number of heterospecifics around the focal tree in its neighborhood (_i.e._ surrounding eight patches) exceeds a certain number (HND-sp) then the focal tree dies due to intense HNND, otherwise focal tree is survived. This process creates empty patches in the community. These empty patches will be filled by the individuals from one of the species. However, the filling process should not violate the above rule that we mentioned (_i.e._ The number of heterospecifics, in the surrounding eight patches, should not exceeds the threshold value. If it exceeds the threshold value vacant site cannot be filled and should remained empty).  

## HOW TO USE IT

The model has four parameters.

1. **Community size:**  _J_ = (w<sub>1</sub> + 1)<sup>2</sup>.

2. **Initial abundance of species:** 1 (_N_<sub>1</sub>). HND-sp<sub>1</sub> is the maximum number of conspecifics that can be allowed in the eight neigboring patches for a stable community. 
Note: For example if HND-sp1 is equals to 5 then focal species-1 has 6, 7, or 8 heterospecific neighbors then the focal species-1 has to die.
 
3. **Heterospecific density on focal species-1:** (HND-sp<sub>1</sub>).

4. **Heterospecific density on focal species-2:** (HND-sp<sub>2</sub>). 

The other parameter _K_, controls the stochastic drift, set to be 0. For more details about the parameter _K_ refer the section "extending the model".

## THINGS TO NOTICE

Stong HNND leave many vacant sites.


## THINGS TO TRY

Reduce the threshold values (i.e. reduce HND-sp1 or HND-sp2 or both) to see the number of vacant sites increases.

One of the assumptions in neutral model is that "functional equivalence". Model becomes a neutral model when the HND-sp1 and HND-sp2 are equal.

## EXTENDING THE MODEL

The model is extended by incorperating stochastic death process. Certain number of trees die (_K_) randomly in each time step. Maximum number of deaths per time step is equal to _J_ - 1. When _K_ = J the model becomes a non-overlapping genrations model.

## NETLOGO FEATURES


## RELATED MODELS

Gause, G.F. (1932). "Experimental studies on the struggle for existence: 1. Mixed population of two species of yeast". _Journal of Experimental Biology_, **9**: 389–402.


## CREDITS AND REFERENCES

* Sareena, B. & Punchi-Manage, R. (2023l).  NetLogo Interspecific Competition Model.
https://modelingcommons.org/browse/one_model/7275

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
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
NetLogo 6.3.0
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

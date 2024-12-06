extensions [table csv]
globals [index meta-sp meta-time meta-a0  meta-j2 meta-a meta-set2 extinct-species number-of-meta-trees a initial-meta-richness random-number2 number time num j x-cor y-cor N richness a0 n-speciation local-set local-di-set local-off-set set-species-who-di set-species-who-off sp hist-frq rel-hist-frq s local-set0 remove-set richness-counts species-who-di di-locx di-locy species-who-off set1-species-who-off meta-set effective-meta-cmmunity-size number-of-local-trees item-x meta-set-new meta-sp-count sp-count j1 i1 k1 j2 i2 k2 meta-richness-counts meta-richness local-richness-counts local-richness hist-frq-meta rel-hist-frq-meta hist-frq-local rel-hist-frq-local]
breed [meta-trees meta-tree]
breed [trees tree]
meta-trees-own [meta-species n-speciation-no]
trees-own [species h]
circles-own []
breed [circles a-circle]
patches-own[elevation]
;extensions [ r ]


to setup2
  clear-all
  set a JL
  set sp 0
  set JL (w2 + 1) * (w2 + 1)
  resize-world 0 w2 0 w2
  species-gen2
  set extinct-species 0
  set hist-frq-local sort-by > map count table:values table:group-agents trees [ species ]
  set rel-hist-frq-local map [ i -> i / JL ] hist-frq-local
  reset-ticks
end

to species-gen2
  set k2 -1
  while [k2 < w2 ] [
    set k2 k2 + 1
    set i2 -1
    while [i2 < w2] [
      set i2 i2 + 1
      create-trees 1 [
        set h s + 1
        setxy k2 i2
        set shape "circle"
        set size 1
        set num random-float 1
        set j2 j2 + 1
        if-else (num < (theta2 / (theta2 + j2 - 1 ))) [
          set species (sp + 1)
          set sp sp + 1
          set color 5 * species + 2
        ]
        [
          set species [species] of one-of other trees
          set sp sp
          set color 5 * species + 2
        ]
      ]
    ]
  ]
  set local-richness sp
end

to go2
  count-down
  forest-die-regenerate3
  set hist-frq-local sort-by > map count table:values table:group-agents trees [ species ]
  set rel-hist-frq-local map [ i -> i / JL ] hist-frq-local
  update-plot2
  plot-genetic-tree-Local-Community
  update-plots
  tick
end

to count-down
  set time time + 1
end

to forest-die-regenerate3
  set N count trees
  count-down
  set remove-set []
  set local-richness-counts map count table:values table:group-agents trees [ species ]
  set local-richness length local-richness-counts
  repeat D [ask one-of trees [
    set species species
    let species0 species
    set number-of-local-trees count trees with [species = species0]
    if (number-of-local-trees = 1) [
      set extinct-species extinct-species + 1
    ]
    set di-locx xcor
    set di-locy ycor
    die
    ]
    let random-number3 random-float 1
    if-else (immigration-rate < random-number3) [
      ; let random-patch one-of patches with [turtles-here = false]
      ask one-of trees [
        hatch 1
        set h  a
        setxy di-locx di-locy
        ;[pxcor] of random-patch [pycor] of random-patch
      ]
    ]
    [
      create-trees 1 [
        set sp sp + 1
        set species sp
        set h  a
        set shape "circle"
        set size 1
        let random-patch one-of patches with [turtles-here = false]
        setxy di-locx di-locy
        ;[pxcor] of random-patch [pycor] of random-patch
      ]
    ]
  ]
end

to update-plot2
  set-current-plot "Species Abundance Distribution Local Community"
  set n 1
  while [n <= sp] [
    create-temporary-plot-pen (word n)
    set-current-plot-pen (word n)
    set-plot-pen-color 5 * n + 4
    plotxy ticks count trees with [species = n]
    set n n + 1
    plot-pen-down
  ]
end


to plot-genetic-tree-Local-Community
  set sp-count 0
  set-current-plot "Generic-Tree Local Community"
  while [sp-count <= sp] [
    create-temporary-plot-pen (word sp-count)
    set-current-plot-pen (word sp-count)
    set-plot-pen-color 5 * sp-count + 4
    let N-sp count (trees with [species = sp-count])
    if (N-sp > 0) [
      plotxy ticks sp-count
      plot-pen-down
    ]
    set sp-count sp-count + 1
  ]
end


; Copyright 2023 Ruwan Punchi-Manage.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
369
10
766
408
-1
-1
13.42
1
10
1
1
1
0
0
0
1
0
28
0
28
0
0
1
ticks
30.0

BUTTON
0
10
66
43
NIL
setup2
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
73
10
139
44
NIL
go2
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
0
233
276
278
Total number of deaths in the local community
D * ticks
17
1
11

MONITOR
0
336
310
381
Number of temporal extinct species in the local community
extinct-species
17
1
11

PLOT
1190
415
1572
729
Number of extinct species
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
"default" 1.0 0 -16777216 true "" "plotxy ticks extinct-species"

SLIDER
0
52
172
85
JL
JL
0
10000
841.0
1
1
NIL
HORIZONTAL

SLIDER
0
87
172
120
w2
w2
1
50
28.0
1
1
NIL
HORIZONTAL

SLIDER
0
121
172
154
theta2
theta2
0
100
17.0
1
1
NIL
HORIZONTAL

SLIDER
0
194
172
227
immigration-rate
immigration-rate
0
1
0.0
0.01
1
NIL
HORIZONTAL

PLOT
786
10
1184
408
Generic-Tree Local Community
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

PLOT
1192
10
1573
408
Local Community Species Richness
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
"default" 1.0 0 -16777216 true "" "plotxy ticks local-richness"

PLOT
785
413
1182
727
Species Abundance Distribution Local Community
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

PLOT
1580
415
1928
728
Relative Species Abundance Local Community
NIL
NIL
0.0
10.0
0.0
0.5
true
false
"" "plot-pen-reset\nforeach (reverse sort rel-hist-frq-local) plot"
PENS
"default" 1.0 1 -16777216 true "" ""

PLOT
1582
10
1926
408
Species Abundance Distribution of Local-Community
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" "plot-pen-reset\n;let counts map count table:values table:group-agents trees [ species ]\n;foreach (reverse sort counts) plot\nforeach (reverse sort hist-frq-local) plot"
PENS
"default" 1.0 1 -16777216 true "" ""

MONITOR
2
284
276
329
Local community species richness
local-richness
17
1
11

SLIDER
0
157
173
190
D
D
0
50
9.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

"The model is essentially a dynamic version of MacArthur's "broken stick" hypothesis, and is based on a nonequilibrium interpretation of community organization. Suppose that forests are saturated with trees, each of which individually controls a unit of canopy space in the forest and resists invasion by other trees until it is damaged or killed. Let the forest be saturated when it has K individual trees, regardless of species. Now suppose that the forest is disturbed by a wind storm landslide, or the like, and some trees are killed. Let D trees be killed, and assume that this mortality is randomly distributed across species, with the expectation that the losses of each species are strictly proportional to its current relative abundance. Next let D new trees grow up, exactly replacing the D "vacancies" in the canopy created by the disturbance, so that the community is restored to its predisturbance saturation until the next disturbance comes along. Let the expected proportion of the replacement trees contributed by each species be given by the proportional abundance of the species in the community after the disturbance. Finally, repeat this cycle of disturbance and resaturation over and over again. In the absence of immigration of new species into the community, or of the recolonization of species formerly present but lost through local extinction, this simple stochastic model leads in the long run to complete dominance by one species. in the short run, however, the model leads to lognormal relative abundance patterns, and to geometric patterns in the intermediate run. The magnitude of the disturbance mortality, D, relative to community size, K, controls the rate at which the species diversity is reduced by local extinction: the larger D is relative to K, the shorter the time until extinction of any given species, and the faster the relative abundance patterns assume an approximately geometric distribution. (Hubbell, 1979)" 
## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

Hubbell, S. P. (1979). Tree Dispersion, Abundance, and Diversity in a Tropical Dry Forest: That tropical trees are clumped, not spaced, alters conceptions of the organization and dynamics. _Science_, **203**(4387), 1299–1309. 

Hubbell, S. P. (1997). A unified theory of biogeography and relative species abundance and its application to tropical rain forests and coral reefs. _Coral Reefs_ **16**:S9–S21.

Hubbell, S. P. (2001). _The Unified Neutral Theory of Biodiversity and Biogeography_. Princeton, NJ: Princeton University Press.


## CREDITS AND REFERENCES

* Punchi-Manage, R. (2023k).  NetLogo Hubbell's (1979) Neutral Model. http://modelingcommons.org/browse/one_model/7262
https://ccl.northwestern.edu/netlogo/models/community/Hubbell%201979%20Model

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
<experiments>
  <experiment name="meta-community" repetitions="4" runMetricsEveryStep="true">
    <setup>setup2</setup>
    <go>go2</go>
    <timeLimit steps="500"/>
    <metric>count turtles</metric>
    <metric>n-speciation</metric>
    <enumeratedValueSet variable="theta2">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="w2">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sp-random">
      <value value="64"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="w">
      <value value="49"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="theta">
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="JL">
      <value value="2601"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="immigration-rate">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="JM">
      <value value="2500"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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

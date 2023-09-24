extensions [table csv]
globals [meta-sp extinct-species n-speciation spi local-s K1 i1 K2 i2 hist-frq-local rel-hist-frq-local local-richness local-richness-counts count-dead-trees immigrant-trees count-new-trees n crowding conspecifics di-locx di-locy neighbor-patch JL1]
breed [meta-trees meta-tree]
breed [trees tree]
meta-trees-own [species]
trees-own [species h]
patches-own [occupied]
circles-own []
breed [circles a-circle]

to setup2
  clear-all
  set meta-sp 0
  set JMS (w1 + 1) * (w1 + 1)
  resize-world 0 (w1 + w2 + 20) 0 (w1 + w2 + 20)
  ;set hist-frq-meta sort-by > map count table:values table:group-agents meta-trees [ meta-species ]
  ;set rel-hist-frq-meta map [ i -> i / JM ] hist-frq-meta
  set extinct-species 0
  set n-speciation 0
  set JL initial-local-richness * Ni
  set K (w2 + 1) * (w2 + 1)
  set w2 w2
  set n 0
  set di-locx 0
  set di-locy max-pycor
  ask patches with [pycor <= max-pycor AND pycor >= w1 + 20 AND pxcor >= 0 AND pxcor <= w2] [
    set pcolor gray
    set occupied 0 ]
  species-generator-1
  species-generator-4
  set hist-frq-local sort-by > map count table:values table:group-agents turtles with [ycor >= w1 + 20] [species]
  set rel-hist-frq-local map [ i -> i / JL ] hist-frq-local
  set local-richness local-s
  set count-dead-trees 0
  set immigrant-trees 0
  set count-new-trees 0
  create-channel
  reset-ticks
end

to species-generator-1
  set k1 -1
  while [k1 < w1 ] [
    set k1 k1 + 1
    set i1 -1
    while [i1 < w1 ] [
      set i1 i1 + 1
      create-meta-trees 1 [
        let random-patch one-of patches with [pycor <= w1 AND pycor >= 0 AND pxcor >= 0 AND pxcor <= w1 AND occupied = 0]
        setxy [pxcor] of random-patch [pycor] of random-patch
        set shape "circle"
        set size 1
        set species (meta-sp + 1)
        set meta-sp meta-sp + 1
        set color species
        ask patch-here [set occupied 1]
      ]
    ]
  ]
end

to species-generator-4
  set k2 1
  while [k2 <= initial-local-richness] [
    set k2 k2 + 1
    set i2 max-pxcor + 1
    set local-s local-s + 1
    repeat Ni [
      let random-patch one-of patches with [pycor <= max-pycor AND pycor >= w1 + 20 AND pxcor >= 0 AND pxcor <= w2 AND occupied = 0]
      create-trees 1 [
        set i2 i2 - 1
        set shape "circle"
        set size 1
        set species local-s
        setxy [pxcor] of random-patch [pycor] of random-patch
        set color local-s
        ask patch-here [set occupied 1]
        ]
      ]
    ]
end

to go2
  test-capacity
  death-rates
  birth-rates
  immigration
  set JL1 count turtles-on patches with [pycor <= max-pycor AND pycor >= w1 + 20 AND pxcor >= 0 AND pxcor <= w2]
  set hist-frq-local sort-by > map count table:values table:group-agents turtles with [pycor > w1 + 20] [ species ]
  set rel-hist-frq-local map [ i -> i / JL1 ] hist-frq-local
  set local-richness-counts map count table:values table:group-agents turtles with [pycor >= w1 + 20] [species ]
  set local-richness length local-richness-counts
  update-plots
  tick
end

to immigration
  let random-number3 random-float 1
  if (immigration-rate > random-number3) [
      replace-previous-immigrant
      move-immigrant
      immigration-through-channel
    ask one-of meta-trees [
      hatch 1
      let random-patch one-of patches with [pycor <= max-pycor AND pycor >= w1 + 20 AND pxcor >= 0 AND pxcor <= w2 AND occupied = 0]
      setxy [pxcor] of random-patch [pycor] of random-patch
      ask patch-here [set occupied 1]
    ]
    set immigrant-trees immigrant-trees + 1
  ]
end

to birth-rates
 let random-number1 random-float 1
    if (b > random-number1) [
      set count-new-trees count-new-trees + 1
    ask one-of turtles with [ycor >= w1 + 20] [
        hatch 1
        let random-patch one-of patches with [pycor <= max-pycor AND pycor >= w1 + 20 AND pxcor >= 0 AND pxcor <= w2 AND occupied = 0]
        setxy [pxcor] of random-patch [pycor] of random-patch
        ask patch-here [set occupied 1]
        ]
      ]
end

to death-rates
 let random-number2 random-float 1
  if (d > random-number2) [
    ask one-of turtles with [ycor >= w1 + 20] [
      set di-locx xcor
      set di-locy ycor
      die]
    set count-dead-trees count-dead-trees + 1
  ]
end

to create-channel
  ask patches [
    if (pxcor > w2 / 2 AND pxcor < ((w2 / 2) + 2) AND pycor > w1 AND pycor < w1 + 20) [
      set pcolor gray
    ]
  ]
end

to immigration-through-channel
  create-circles 1 [
    set color ticks
    set heading 0
    set size 1
    setxy ((w2 + 2) / 2) (w1 + 1)
   ]
end

to move-immigrant
  ask circles [ fd 4]
end

to replace-previous-immigrant
  ask circles with [ycor > (w1 + 13) ] [die]
end

to update-plot2
set-current-plot "Species Abundance Distribution Local Community"
set n 1
while [n <= meta-sp] [
create-temporary-plot-pen (word n)
set-current-plot-pen (word n)
set-plot-pen-color 5 * n + 4
plotxy ticks count trees with [ycor >= w1 + 20 AND species = n]
set n n + 1
plot-pen-down
]
end

to test-capacity
  if (count turtles with [ycor >= w1 + 20] > K - 5) [
    ask one-of turtles with [ycor >= w1 + 20] [die]
    ]
  ask patches [
    if (count turtles-here > 0) [
      set occupied 1
    ]
    if (count turtles-here = 0) [
      set occupied 0
    ]
  ]
end

; Copyright 2023e Ruwan Punchi-Manage.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
295
10
1504
1220
-1
-1
13.2
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
90
0
90
0
0
1
ticks
30.0

BUTTON
0
13
66
46
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
0
50
66
84
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

SLIDER
73
13
245
46
JMS
JMS
0
1600
2025.0
1
1
NIL
HORIZONTAL

MONITOR
0
665
264
710
Number of temporal extinct species in the local community
extinct-species
17
1
11

SLIDER
0
173
172
206
JL
JL
0
10000
437.0
1
1
NIL
HORIZONTAL

SLIDER
0
208
172
241
w2
w2
1
200
26.0
1
1
NIL
HORIZONTAL

SLIDER
1
248
173
281
immigration-rate
immigration-rate
0
1
0.33
0.01
1
NIL
HORIZONTAL

PLOT
1512
257
1965
553
Relative Species Abundance Distribution
NIL
NIL
0.0
10.0
0.0
0.02
true
false
"" "plot-pen-reset\nforeach (reverse sort rel-hist-frq-local) plot"
PENS
"pen-0" 1.0 1 -7500403 true "" ""

SLIDER
74
51
246
84
w1
w1
0
200
44.0
1
1
NIL
HORIZONTAL

PLOT
1778
14
2054
253
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
2061
13
2387
252
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
0
614
202
659
Local community species richness
local-richness
17
1
11

SLIDER
0
135
172
168
initial-local-richness
initial-local-richness
0
100
23.0
1
1
NIL
HORIZONTAL

SLIDER
1
288
173
321
K
K
0
100000
729.0
1
1
NIL
HORIZONTAL

SLIDER
1
325
173
358
b
b
0
1
0.0
0.001
1
NIL
HORIZONTAL

SLIDER
1
367
173
400
d
d
0
1
0.0
0.001
1
NIL
HORIZONTAL

MONITOR
2
407
145
452
Local Community trees
count turtles with [pycor >= w1 + 20]
17
1
11

MONITOR
0
455
211
500
Total dead trees from t = 0 to t = t
count-dead-trees
17
1
11

MONITOR
0
508
211
553
Immigrant-trees from t = 0 to t = t
immigrant-trees
17
1
11

MONITOR
0
558
180
603
New Births from t = 0 to t = t
count-new-trees
17
1
11

PLOT
1512
10
1766
250
Local Community Size
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
"default" 1.0 0 -16777216 true "" "plot JL1"

SLIDER
0
98
173
131
Ni
Ni
0
100
19.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

Neutral models refer to communities of ecological similar species in which individuals compete with one another and do not describe trophic interactions (Bell, 2001). Here I developed the NetLogo model that used in Bell's (2000) paper. Bell (2000) describes the properties of a very simple neutral model. It represents macro-ecological patterns of a community of functionally identical species. He used the term "neutral" to mean that individuals possess the same properties, regardless of species membership; thus, individuals of different species are indistinguishable (Bell, 2000).

Bell (2000) assumed followings:

1. Species of community terms) is drawn from a external regional pool of _JMS_ species. 

2. The community initially consists of _N_<sub>i</sub> individuals of each species (Bell, 2000). 


Bell (2000) assumed the following dynamics in his model.

1. **Immigration:** A single individual is added to the community from each species in the pool with probability _m_.

2. **Birth:** Each individual gives rise to a single offspring with probability _b_.

3. **Death:** Each adult individual dies with probability _d_.

4. **Density regulation:** If the community exceeds its capacity of _K_ individuals, excess individuals are removed at random, each individual having the same probability of being removed, until the community is reduced to exactly _K_ individuals before the next cycle is begun. 

**Note:** "It is individuals that are culled, and that all species are treated alike, so that each species is on average culled in proportion to its relative abundance alone. Species do not differ in their sensitivity to density, and there are no implicit or explicit interactions among species (Bell, 2000)".

The model is different from Hubbell's model becaused Bell (2000) used a species pool where each species has equal chance, not individuals, to immigrate.


## HOW IT WORKS

There are two sets of turtles. Trees and meta-species. Trees and meta-trees own property called "species". Patches have a property called "occupied". If a tree or meta-tree occupied the local community then patch is 'occupied'. When a patch is vacant patch is 'unoccupied'. Initial abundances of species are set to N<sub>i</sub>.

## HOW TO USE IT

### Sliders

1. **JMS:** Species present in the regional species pool. It is equal to size of the regional pool. _JMS_= _(w1 + 1)_<sup>2</sup>. The JMS slider automatically changes when w1 changes.

2. **w1:** It is used to decides the JMS.

3. **Ni:** Initial abundances of species (all the populations have equal sizes).

4. **initial-local-richness:** This decides the inital species richness of the local community.

5. **JL:** This is the initial local community size. Initial local community size (_JL_) is also a automatically change.  Initial abundances of species are set to _Ni_. Therefore, initial abundance of the community is equal to 100 times initial-local-richness.

6. **w2:** This decides the size of the local community, the maximum capacity. (_w2 + 1_)<sup>2</sup>.

7. **m:** It is the rate of immigration of species from the regional pool.

8. **K:** Automatic slider. It is the maximum capacity community can hold. Also called carrying capacity.

9. K = (_w2 + 1_)<sup>2</sup>.

10. **b:** It is the birth rate of individuals.

11. **d:** It is the death rate of individuals.

## THINGS TO NOTICE

The model can then be used to describe the relationship of diversity and abundance to the six parameters of the model: pool size _JMS_ species, size of the initial species populations (N<sub>i</sub> individuals), community capacity _K_ individuals, immigration rate _m_ per species per cycle, birth rate _b_, and death rate _d_ per individual per cycle. It can then be determined whether the patterns exhibited by natural populations differ systematically from those generated by a finite stochastic birth-death-immigration process.

### Outputs

1. **Local Community Trees:** Number of trees or meta-trees in the local community

2. **Total dead trees from t = 0 to t = t:** Total number of deaths happened in the local community.

3. **Immigrant-trees from t = 0 to t = t:** Total number of immigrations happened in the local community.

4. **New Births from t = 0 to t = t:** Total number of births happened in the local community.

5. **Local community species richness:** Species richness of the local community.

6. **Number of temporal extinct species in the local community:** Total number of temporal extinctions happened in the local community.

### Plots

1. **Local Community Size:** Abundance of the local community.

2. **Local Community Species Richness:** Number of species in the local community.

3. **Species Abundance Distribution of Local-Community:** Species abundance distribution of the local community.

4. **Relative Species Abundance Distribution:** Relative species abundance distribution of the local community. 
 
 


## THINGS TO TRY
 
Change the sliders (_i.e._ b for birth rate, d for death rate, and m for immigration rates, initial-species-richness for initial species richness). Use slider w1 to change the regional species richness (JMS) and slider w2 to chnage the carrying capacity (K)).
See how community species richness and community species abundance vary.


## EXTENDING THE MODEL


## NETLOGO FEATURES


## RELATED MODELS

Bell, G. (2000). The Distribution of Abundance in Neutral Communities. _The American Naturalist_, **155** (5), pp. 606-617.

Bell, G. (2001). Neutral Macroecology. _Science_, **293**(5539), 2413–2418.




## CREDITS AND REFERENCES

* Punchi-Manage, R. (2023e).  NetLogo Bell's (2000) Model. http://netlogo/models/Bell-2000-Model.

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

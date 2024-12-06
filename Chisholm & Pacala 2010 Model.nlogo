extensions [table csv]
globals [index meta-sp meta-time meta-a0  meta-j2 meta-a meta-set2 extinct-species number-of-meta-trees a initial-meta-richness random-number2 number time num j x-cor y-cor N richness a0 n-speciation local-set local-di-set local-off-set set-species-who-di set-species-who-off sp hist-frq rel-hist-frq s local-set0 remove-set richness-counts species-who-di di-locx di-locy species-who-off set1-species-who-off meta-set effective-meta-cmmunity-size number-of-local-trees item-x meta-set-new meta-sp-count sp-count j1 i1 k1 j2 i2 k2 meta-richness-counts meta-richness local-richness-counts local-richness hist-frq-meta rel-hist-frq-meta hist-frq-local rel-hist-frq-local habitat hist-frq-meta0 rel-hist-frq-meta0 hist-frq-local0 rel-hist-frq-local0 extinct-species-meta]
breed [meta-trees meta-tree]
breed [trees tree]
meta-trees-own [meta-species n-speciation-no]
trees-own [species h]
circles-own []
breed [circles a-circle]
patches-own[elevation niche]

to setup2
  clear-all
  set meta-richness-counts map count table:values table:group-agents meta-trees [ meta-species ]
  set meta-richness length meta-richness-counts
  set n-speciation 0
  set meta-set[]
  set meta-sp 0
  set JM (w1 + 1) * (w1 + 1)
  resize-world 0 (w1 + w2 + 20) 0 (w1 + w2 + 20)
  if (Hubbell-2001-Wright-Fisher? = true) [
    set speciation-rate theta / (2 * JM)
    set effective-meta-cmmunity-size JM]
  if (Moran? = true) [
    set speciation-rate theta / JM
    set effective-meta-cmmunity-size JM ^ 2 / 2]
  if (Etinne-Alonso-Hubbell?) [
    set speciation-rate theta / (theta + JM - 1)
    set effective-meta-cmmunity-size JM * (JM - 1) / 2]
  if (file-exists? "parent-species-speciation-species-time.csv")
  [
    carefully
    [file-delete "parent-species-speciation-species-time.csv"]
    [print error-message]
  ]
  file-open "parent-species-speciation-species-time.csv"
  file-close
  if (file-exists? "Meta-Community-extinction-species-time.csv")
  [
    carefully
    [file-delete "Meta-Community-extinction-species-time.csv"]
    [print error-message]
  ]
  file-open "Meta-Community-extinction-species-time.csv"
  file-close
  species-gen1
  ask patches with [count meta-trees-here > 0] [
    set niche 1 + random K
    set pcolor 5 * niche
  ]
  set hist-frq-meta sort-by > map count table:values table:group-agents meta-trees [ meta-species ]
  set rel-hist-frq-meta map [ i -> i / JM ] hist-frq-meta
  set hist-frq-meta0 sort-by > map count table:values table:group-agents meta-trees-on patches with [niche = 1 AND count meta-trees-here > 0] [ meta-species ]
  set rel-hist-frq-meta0 map [ i -> i / count patches with [niche = 1 AND count meta-trees-here > 0] ] hist-frq-meta0
  set meta-time 0
  set meta-a0 1
  set n-speciation 0
  set extinct-species-meta 0
  set meta-j2 2
  set meta-a JM
  set a JL
  set sp 0
  set JL (w2 + 1) * (w2 + 1)
  if (Immigration-number? = True) [
    set theta2 immigration-rate * JL / (1 - immigration-rate) ]
  species-gen2
  ask patches with [count trees-here > 0] [
    set niche 1 + random K
    set pcolor 5 * niche
  ]
  set extinct-species 0
  set hist-frq-local sort-by > map count table:values table:group-agents trees [ species ]
  set rel-hist-frq-local map [ i -> i / JL ] hist-frq-local
  set hist-frq-local0 sort-by > map count table:values table:group-agents trees-on patches with [niche = 1 AND count trees-here > 0] [ species ]
  set rel-hist-frq-local0 map [ i -> i / count patches with [niche = 1 AND count trees-here > 0] ] hist-frq-local0
  if (file-exists? "Local-Extinction-Species-Extinction-Time.csv")
  [
    carefully
    [file-delete "Local-Extinction-Species-Extinction-Time.csv"]
    [print error-message]
  ]
  file-open "Local-Extinction-Species-Extinction-Time.csv"
  file-close
  create-channel
  reset-ticks
end

to species-gen1
  set k1 -1
  while [k1 < w1 ] [
    set k1 k1 + 1
    set i1 -1
    while [i1 < w1 ] [
      set i1 i1 + 1
      create-meta-trees 1 [
        setxy k1 i1
        set shape "circle"
        set size 1
        set num random-float 1
        set j1 j1 + 1
        if-else (num < (theta / (theta + j1 - 1 ))) [
          set meta-sp meta-sp + 1
          set meta-species meta-sp
          set color 0.5 * meta-species
        ]
        [
          set meta-species [meta-species] of one-of other meta-trees
          set meta-sp meta-sp
          set color 0.5 * meta-species
        ]
        file-open "Metacommunityset.csv"
        file-print (meta-species)
        file-close
      ]
    ]
  ]
  set initial-meta-richness meta-sp
end

to species-gen2
  set k2 -1
  while [k2 < w2 ] [
    set k2 k2 + 1
    set i2 max-pxcor + 1
    while [i2 <= max-pxcor + 1 AND i2 >= max-pxcor - w2 + 1] [
      set i2 i2 - 1
      create-trees 1 [
        set h s + 1
        setxy k2 i2
        set shape "circle"
        set size 1
        set num random-float 1
        set j2 j2 + 1
        if-else (num < (theta2 / (theta2 + j2 - 1 ))) [
          set sp sp + 1
          set species sp
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
  forest-die-regenerate2
  count-down
  speciation
  set hist-frq-meta sort-by > map count table:values table:group-agents meta-trees [ meta-species ]
  set rel-hist-frq-meta map [ i -> i / JM ] hist-frq-meta
  set hist-frq-meta0 sort-by > map count table:values table:group-agents meta-trees-on patches with [niche = 1 AND count meta-trees-here > 0] [ meta-species ]
  set rel-hist-frq-meta0 map [ i -> i / count patches with [niche = 1 AND count meta-trees-here > 0] ] hist-frq-meta0
  update-plots
  if (graphic? = true) [
    plot-genetic-tree-Meta-Community
    update-plot1
    update-plot4
  ]
  forest-die-regenerate3
  set hist-frq-local sort-by > map count table:values table:group-agents trees [ species ]
  set rel-hist-frq-local map [ i -> i / JL ] hist-frq-local
  set hist-frq-local0 sort-by > map count table:values table:group-agents trees-on patches with [niche = 1 AND count trees-here > 0] [ species ]
  set rel-hist-frq-local0 map [ i -> i / count patches with [niche = 1 AND count trees-here > 0] ] hist-frq-local0
  if (graphic? = true) [
    plot-genetic-tree-Local-Community
    update-plot2
    update-plot3
  ]
  update-plots
  tick
end

to forest-die-regenerate2
  set N count meta-trees
  set meta-richness-counts map count table:values table:group-agents meta-trees [ meta-species ]
  set meta-richness length meta-richness-counts
  ask one-of meta-trees [
    set x-cor xcor
    set y-cor ycor
    set habitat [niche] of patch x-cor y-cor
    set meta-species meta-species
    let meta-species0 meta-species
    set number-of-meta-trees count meta-trees with [meta-species = meta-species0]
    if (number-of-meta-trees = 1)[
      set extinct-species-meta extinct-species-meta + 1
      file-open "Meta-Community-extinction-species-time.csv"
      file-write (meta-species)
      file-write (ticks)
      file-print ""
      file-close
    ]
    die
  ]
  set random-number2 random-float 1
  if (random-number2 > speciation-rate)[
    ask one-of meta-trees-on patches with [niche = habitat] [
      hatch 1
      setxy x-cor y-cor
    ]
  ]
end

to count-down
  set time time + 1
end

to speciation
  if  (random-number2 <= speciation-rate) [
    set n-speciation n-speciation + 1
    set meta-sp meta-sp + 1
    ask one-of meta-trees [
      let parent-of-speciation meta-species
      hatch 1
      set n-speciation-no n-speciation
      set meta-j2 meta-j2 + 1
      set meta-species meta-sp
      set color  0.5 * (a0 + 1 + meta-j2)
      setxy x-cor y-cor
      file-open "parent-species-speciation-species-time.csv"
      file-write (parent-of-speciation)
      file-write (meta-species)
      file-write (ticks)
      file-print ""
      file-close
    ]
  ]
end

to forest-die-regenerate3
  set N count trees
  count-down
  set remove-set []
  set local-richness-counts map count table:values table:group-agents trees [species]
  set local-richness length local-richness-counts
  repeat D [ask one-of trees [
    set species species
    let species0 species
    set number-of-local-trees count trees with [species = species0]
    if (number-of-local-trees = 1)[
      set extinct-species extinct-species + 1
      file-open "Local-Extinction-Species-Extinction-Time.csv"
      file-write (species0)
      file-write (ticks)
      file-print ""
      file-close
    ]
    set di-locx xcor
    set di-locy ycor
    set habitat [niche] of patch x-cor y-cor
    die
    ]
    let random-number3 random-float 1
    if-else (immigration-rate < random-number3) [
      ask one-of trees-on patches with [niche = habitat] [
        hatch 1
        set h  a
        setxy di-locx di-locy
      ]
    ]
    [
      replace-previous-immigrant
      move-immigrant
      immigration-through-channel
      create-trees 1 [
        set species one-of [meta-species] of meta-trees
        set h  a
        set shape "circle"
        set size 1
        setxy di-locx di-locy
      ]
    ]
  ]
end

to update-plot1
  set-current-plot "Species Abundance Distribution Meta Community"
  set n 1
  while [n <= meta-sp] [
    create-temporary-plot-pen (word n)
    set-current-plot-pen (word n)
    set-plot-pen-color 5 * n + 4
    plotxy ticks count meta-trees with [meta-species = n]
    set n n + 1
    plot-pen-down
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

to plot-genetic-tree-Meta-Community
  set meta-sp-count 0
  set-current-plot "Generic-Tree Meta Community"
  while [meta-sp-count <= meta-sp] [
    create-temporary-plot-pen (word meta-sp-count)
    set-current-plot-pen (word meta-sp-count)
    set-plot-pen-color 5 * meta-sp-count + 4
    let N-sp count (meta-trees with [meta-species = meta-sp-count])
    if (N-sp > 0) [
      plotxy ticks meta-sp-count
      plot-pen-down
    ]
    set meta-sp-count meta-sp-count + 1
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

to update-plot3
  set-current-plot "Relative species abundance of niches in local community"
  let n2 1
  clear-plot
  while [n2 <= K] [
    create-temporary-plot-pen (word "habitat " n2)
    set-current-plot-pen (word "habitat " n2)
    set-plot-pen-color 5 * n2 + 4
    set-plot-pen-mode 0
    set hist-frq-local0 sort-by > map count table:values table:group-agents trees-on patches with [niche = n2 AND count trees-here > 0] [ species ]
    set rel-hist-frq-local0 map [ i -> i / count patches with [niche = n2 AND count trees-here > 0] ] hist-frq-local0
    foreach (reverse sort rel-hist-frq-local0) plot
    set n2 n2 + 1
    plot-pen-down
  ]
end

to update-plot4
  set-current-plot "Relative species abundance of niches in meta-community"
  let n3 1
  clear-plot
  while [n3 <= K] [
    create-temporary-plot-pen (word "habitat " n3)
    set-current-plot-pen (word "habitat " n3)
    set-plot-pen-color 5 * n3 + 4
    set-plot-pen-mode 0
    set hist-frq-meta0 sort-by > map count table:values table:group-agents trees-on patches with [niche = n3 AND count trees-here > 0] [ species ]
    set rel-hist-frq-meta0 map [ i -> i / count patches with [niche = n3 AND count trees-here > 0] ] hist-frq-meta0
    foreach (reverse sort rel-hist-frq-meta0) plot
    set n3 n3 + 1
    plot-pen-down
  ]
end

; Copyright 2023 Ruwan Punchi-Manage.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
441
15
2247
1822
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
133
0
133
0
0
1
ticks
30.0

BUTTON
14
10
80
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
14
50
80
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
90
10
262
43
JM
JM
0
1600
9604.0
1
1
NIL
HORIZONTAL

MONITOR
9
403
259
448
Total number of deaths in the local community)
ticks
17
1
11

PLOT
1723
279
1938
574
Species Abundance Distribution Meta Community
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

MONITOR
10
352
279
397
Speciation events happened in the meta-community
n-speciation
17
1
11

MONITOR
9
451
283
496
Meta community species richness at time t = 0
initial-meta-richness
17
1
11

MONITOR
9
506
281
551
Meta community species richness at time t = t
meta-richness
17
1
11

PLOT
1694
16
2102
260
Meta Community Species Richness
NIL
NIL
0.0
10.0
890.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy ticks meta-richness"

PLOT
1180
585
1423
827
Relative Species Abundance Meta Community
NIL
NIL
0.0
100.0
0.0
0.2
true
false
"" "plot-pen-reset\nforeach (reverse sort rel-hist-frq-meta) plot"
PENS
"default" 1.0 1 -16777216 true "" ""

PLOT
1426
585
1726
827
Species Abundance Distribution of Meta-Community
NIL
NIL
0.0
100.0
0.0
10.0
true
false
"" "plot-pen-reset\n;let counts map count table:values table:group-agents trees [ species ]\n;foreach (reverse sort counts) plot\nforeach (reverse sort hist-frq-meta) plot"
PENS
"default" 1.0 1 -16777216 true "" ""

MONITOR
11
301
142
346
Meta community size
JM
17
1
11

SLIDER
14
87
186
120
theta
theta
0
100
41.0
1
1
NIL
HORIZONTAL

PLOT
1179
16
1691
259
Total Speciation event happens in the community
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Speciations" 1.0 0 -14070903 true "" "plotxy ticks n-speciation"
"Extinctions" 1.0 0 -5298144 true "" "plotxy ticks extinct-species-meta"

SLIDER
14
133
232
166
speciation-rate
speciation-rate
0
1
0.00426905456059975
0.0001
1
NIL
HORIZONTAL

SWITCH
117
177
321
210
Hubbell-2001-Wright-Fisher?
Hubbell-2001-Wright-Fisher?
1
1
-1000

MONITOR
9
728
319
773
Number of temporal extinct species in the local community
extinct-species
17
1
11

PLOT
2193
278
2644
575
Number of temprary extinct species in local community
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
936
65
1108
98
JL
JL
0
10000
289.0
1
1
NIL
HORIZONTAL

SLIDER
936
100
1108
133
w2
w2
1
50
16.0
1
1
NIL
HORIZONTAL

SLIDER
936
138
1108
171
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
936
175
1108
208
immigration-rate
immigration-rate
0
1
0.78
0.01
1
NIL
HORIZONTAL

SLIDER
11
257
183
290
equilibrium-run
equilibrium-run
0
10000
892.0
1
1
NIL
HORIZONTAL

SWITCH
11
176
114
209
Moran?
Moran?
0
1
-1000

SWITCH
12
217
186
250
Etinne-Alonso-Hubbell?
Etinne-Alonso-Hubbell?
1
1
-1000

MONITOR
9
607
189
652
Effective-meta-cmmunity-size
effective-meta-cmmunity-size
17
1
11

SWITCH
936
31
1109
64
immigration-number?
immigration-number?
1
1
-1000

PLOT
1438
278
1714
574
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

MONITOR
9
557
353
602
Number of species appeared in the meta community t = 0 to t = t
meta-sp
17
1
11

PLOT
1178
279
1434
574
Generic-Tree Meta Community
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

SLIDER
92
53
264
86
w1
w1
0
200
97.0
1
1
NIL
HORIZONTAL

PLOT
2112
15
2398
257
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
1945
279
2190
574
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
2040
584
2474
826
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
1731
584
2034
826
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
11
664
213
709
Local community species richness
local-richness
17
1
11

SLIDER
189
88
341
121
D
D
0
50
10.0
1
1
NIL
HORIZONTAL

SLIDER
154
301
326
334
K
K
0
20
4.0
1
1
NIL
HORIZONTAL

PLOT
1179
831
1612
1119
Meta-Community Niche 1 Dynamics
NIL
NIL
0.0
10.0
0.0
0.1
true
false
"" "plot-pen-reset\nforeach (reverse sort rel-hist-frq-meta0) plot"
PENS
"pen-0" 1.0 1 -7500403 true "" ""

PLOT
1616
832
2030
1123
Local Community Niche 1 Dynamics
NIL
NIL
0.0
10.0
0.0
0.2
true
false
"" "plot-pen-reset\nforeach (reverse sort rel-hist-frq-local0) plot"
PENS
"pen-0" 1.0 1 -7500403 true "" ""

SWITCH
212
230
315
263
graphic?
graphic?
0
1
-1000

PLOT
2044
831
2617
1125
Relative species abundance of niches in local community
NIL
NIL
0.0
10.0
0.0
0.2
true
true
"" ""
PENS

PLOT
1770
1128
2614
1380
Relative species abundance of niches in meta-community
NIL
NIL
0.0
10.0
0.0
0.2
true
true
"" ""
PENS

@#$#@#$#@
## WHAT IS IT?

According to Gauss competitive exclusion principle (Gauss, 1932) two species cannot exist in a same environment. However, thousands of species found coexists in tropical forests. 
This model is a simulation model for the Chisholm and Pacala (2010) analytical model. Chisholm and Pacala (2010) relaxed one of the fundamental neutral assumptions that all species in the community interact in the same zero-sum game and derive a high-diversity approximation for the metacommunity SAD under the new model. 



This model used to explains the two macro-ecological patterns species abundance distribution (SAD) and species area relationship (SAR). The model consists of two parts.

### Meta-community
Meta-community (size _J_<sub>M</sub>) is very large compared to local community (size _J_<sub>L</sub>). Meta-community is saturated. That is there is no vacant sites (space). This is one of the main assumptions of neutral theroy. Meta-community has demographic fluctuations (stochastic drift). Trees dies and rebirth every time step. It has also mechanisam called speciation. Speciation allows new species to appear. When a tree dies the vacant space is occupied by offsprings of a randomly selected individual or from a new species (speciation is a rare event. Probability of happening that event is very very small). Number of species in the meta community depends on the fundemental bio-diversity number (_θ_) and the meta-community size (_J_<sub>M</sub>). Species are generated at the beginning using the Hubbell's (2001) species generating flow chart (pg. 291). Each species has _J_<sub>i</sub> number of individuals.

Chisholm and Pacala (2010) divided the metacommunity into _K_ niches and allowed each niche to operate according to its own neutral dynamics, independently of the other _K_ − 1 niches. He assigned each patch in the metacommunity to a niche and assumed that a vacant location is always captured by an individual with a matching niche. He retained the other neutral assumptions: immigration rate (_m_), the speciation rate (_ν_), and the density of individuals per unit area (_ρ_) are constant across niches.
 
### Local community
Local community has demographic fluctuations (death and birth of trees). Local community is saturated. That is there is no vacant sites (space). This is one of the main assumptions of neutral theroy. Original version of the Hubbell's neutral model assumes single death in each time steps. When a tree dies randomly the vacant space is occupied by a offspring of a randomly selected individual. This randomly selected individual is either from a local community or meta-community. If its from meta-community then offspring immigrates from meta-community to local community to occupy the vacant site. If there is no immigration local community undergoes mono-dominance (all the sites occupied by one species). Therefore to maintain the species diversity immigration is necessary. Local community has _S_ number of species. Species are generated at the beginning using the Hubbell's (2001) species generating flow chart (pg. 291). Number of species in the local community depends on the fundemental bio-diversity number (_θ_<sub>2</sub>) and the local community size (_J_<sub>L</sub>). Each species has _J_<sub>i</sub> number of individuals.

Chisholm and Pacala (2010) assumed that the scale of observation is large enough that the relative sizes of niches in the local community are the same as in the metacommunity (_J_<sub>i</sub> = _β_<sub>i</sub>._J_). He assigned each patch in the local community to a niche and assumed that a vacant location is always captured by an individual with a matching niche. He retained the other neutral assumptions: immigration rate (_m_), the speciation rate (_ν_), and the density of individuals per unit area (_ρ_) are constant across niches.
 
## HOW IT WORKS

Each agent has a property called 'species'. Each patch has a property called 'niche'. Species have different colors. Niches  have different colors also. When an agent dies, an offspring with a matching niche is randomly selected occupied that empty space. Only one agent exists in a patch.

**(1) Meta-community:** When an agent dies, the vacant space is occupied by offsprings  with a matching niche is randomly selected or from a new type of agent (probailities are 1-_v_ and _v_ respectively).
 
**(2) Local community:** When an agent dies, randomly the vacant space is occupied by a offspring  with a matching niche is randomly selected. This randomly selected agent is either from a local community or meta-community (probabilites are 1-_m_ and _m_ respectively). If its from meta-community then offspring agent immigrates from meta-community to local community to occupy the vacant site.

## HOW TO USE IT

### Sliders
1. **w1:** Used to  change meta-community size. _J_<sub>M </sub> = (w1+1)<sup>2</sup>
2. **w2:**  Used to change the local community size. _J_<sub>L</sub> = (w2+1)<sup>2</sup>
3. **θ:** Fundamental biodiversity numbers  used for meta-community.
4. **_θ_<sub>2</sub>:** Fundamental biodiversity numbers  used for local-community.
5. **Immigration:** Used to control the immigration rate (0-1).
6. **D:** Used to defines the number of death per each time step in the local community. Hubbell's (2001) original model _D_ = 1. Here it can takes any value from 1 to JL.
7. **speciation-initiation-rate:** Defines the speciation rate in the Hubbell's (2001) model. Hubbell used Wright-Fisher equation to define the point mutation speciation. In this model it has additional three additional switches (off-on) that used to set the speciation rates according to either Hubbell (2001) or Moran or Etinne-Alonso-Hubbell.
8. **tau-protracted:** Hubbell (2001) used only point mutation (instant specitation). However, this model has an slider called tau-protracted to shift from Hubbell's (2001)  point mutation to  Rosindell et al. protracted speciation. When tau-protracted is 0 it is Hubbell's instant point speciation, else it is protracted speciaiton (Rosindell et al. 2010).
9. **Equilibrium-run:** Use to decide the number of runs before stop the process.
10. **K:** Number of niches in meta-community and local community.

### Switches
1. **graphic?:** switch is used to switch on-off graphics. Off graphics? speeds the process.
2. **Moran?:** θ = _J_<sup>2</sup><sub>M</sub>. _v_
3. **Etienne-Alonso-Hubbell?:** θ = _J_<sub>M</sub>.(_J_<sub>M</sub>-1). _v_
4. **Hubbell-200-Wright-Fisher?:** θ = 2._J_<sub>M</sub>. _v_
5. **immigration-number?:** If switch is 'on' then θ<sub>2</sub> = _m_._J_<sub>L</sub> / (1 - _m_)

## THINGS TO NOTICE

### Monitor:
1. **Meta-community size:** Shows the meta-community.
2. **Protracted Speciation events happened in the meta-community:** Shows number of protrated species in the community.
3. **Point-mutations:** Shows number of point mutations.
4. **Total number of deaths in the local community:** Shows total number of deaths in the local community. Equals to number of ticks in netlogo.
5. **Meta-community species richness at time _t_ = 0:** Shows initial species richness in the meta-community.
6. **Meta-community species richness at time _t_ = t:** Shows the current species richness in the meta-community.
7. **Number of species appeared in the meta-community _t_ = 0 to _t_ = t:** Total number of new species appeared in the meta-community.
8. **Effective-meta-community size:** See Etienne and Alonso (2007).
9. **JL:** Current local community size.
10. **JM:** Current meta-community size.
11. **Number of temporal extinct species in the meta-community:** Number of species temporally extinct from local community. Temporal extinction happens only if immigration rate is non-zero. Otherwise it is shows number permenant extinct species.

### Plots:
1. **Total speciation events happen in the meta-community:** Cumulative function of speciations over time.
2. **Meta-community species richness:** Number of meta-community species presents over time.
3. **Local community species richness:** Number of local community species presents over time. 
4. **Incipient species in the meta-community:** "During the transition period of a lineage undergoing protracted speciation, the individuals of this lineage are interpreted as an incipient species (Rosindell et al., 2010)"
5. **Generic-tree meta-community:** Similar to meta-community pylogenetic tree that also includes extinct lineages.
6. **Generic-tree local community:** Similar to local-community pylogenetic tree that also includes extinct lineages.
7. **Species Abundance Distribution meta-community:** Meta-community species abundance fluctuations.
8. **Species Abundance Distribution local community:** Local-community species abundance fluctuations.
9. **Number of extinct species from local-community:** Cumulative distribution of temporaly extinct species from local-community.
10. **Relative Species Abundance Meta Community:** Species abundance (_J_) / Meta-community size (_J_<sub>M</sub>).
11. **Species Abundance Distribution of Meta-Community:** Number of individuals from each species in the meta-community sorted.
12. **Number of extinct species from meta-community:** Cumulative distribution of permenantly extinct species from meta-community.
13. **Relative Species Abundance Local Community:** Species abundance (_J_) / Local-community size (_J_<sub>L</sub>).
14. **Species Abundance Distribution of Local-Community:** Number of individuals from each species in the local community sorted.
15. **Relative species abundance distribution of niche in local community:** Relative abundance of species in each habitats in local community.
16. **Relative species abundance of niches in meta-community:**  Relative abundance of species in each habitats in meta-community.
## THINGS TO TRY

* Move sliders w1 and w2 to change the meta and local community size.
* Move sliders theta and theta2 to change the fundamental Biodiversity number for meta and local community.
* Move slider immigration-rate to change the immigration rate (0-1).
* speciation-initiation-rate is determine by one of the swithces (Moran, Hubbell-2001-Wright-Fisher, Etienne-Alonso-Hubbell) usually. Off three swiches to change the speciation-initiation-rate user defines values.

## EXTENDING THE MODEL


## NETLOGO FEATURES


## RELATED MODELS

Gause, G.F. (1932). "Experimental studies on the struggle for existence: 1. Mixed population of two species of yeast". _Journal of Experimental Biology_, **9**: 389–402.

Moran, P.A.P. (1958). Random processes in genetics. _Proceedings of the Cambridge Philosophical Society_, **54**: 28 60-71.

Ewens, W.J. (1972). The sampling theory of selectively neutral alleles. _Theoretical Population Biology_, **3**: 87-112.

Kimura, M. (1983). _The Neutral Theory of Molecular Evolution_. Cambridge, UK: Cambridge University Press.

Hubbell, S. P. (1979). Tree Dispersion, Abundance, and Diversity in a Tropical Dry Forest: That tropical trees are clumped, not spaced, alters conceptions of the organization and dynamics. _Science_, **203**(4387), 1299–1309. 

Hubbell, S. P. (1997). A unified theory of biogeography and relative species abundance and its application to tropical rain forests and coral reefs. _Coral Reefs_ **16**:S9–S21.

Hubbell, S. P. (2001). _The Unified Neutral Theory of Biodiversity and Biogeography_. Princeton, NJ: Princeton University Press.

Etienne, R. S., & Alonso, D. (2007). Neutral Community Theory: How Stochasticity and Dispersal-Limitation Can Explain Species Coexistence. _Journal of Statistical Physics_, **128**(1–2), 485–510.

Rosindell, J., Cornell, S. J., Hubbell, S. P., & Etienne, R. S. (2010). Protracted speciation revitalizes the neutral theory of biodiversity. _Ecology Letters_, **13**(6), 716-727.

Chisholm, R. A., & Pacala, S. W. (2010). Niche and neutral models predict asymptotically equivalent species abundance distributions in high-diversity ecological communities. _Proceedings of the National Academy of Sciences_, **107**(36), 15821–15825. 
 




## CREDITS AND REFERENCES

For the model itself:

* Punchi-Manage, R. (2023c).  NetLogo Chisholm and Pacala (2010) Niche Based Neutral Model. http://netlogo/models/NetLogo-Chisholm-and-Pacala-(2010)-Niche-Based-Neutral-Model.

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

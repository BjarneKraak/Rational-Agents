globals [ max-sheep ]  ; don't let sheep population grow too large
; Sheep and wolves are both breeds of turtle.
breed [ sheep a-sheep ]  ; sheep is its own plural, so we use "a-sheep" as the singular.
breed [ wolves wolf ]
turtles-own [ energy ]       ; both wolves and sheep have energy
patches-own [ countdown ]

to setup
  clear-all
  ifelse netlogo-web? [set max-sheep 10000] [set max-sheep 30000]

  ; Check model-version switch
  ; if we're not modeling grass, then the sheep don't need to eat to survive
  ; otherwise the grass's state of growth and growing logic need to be set up
  ifelse model-version = "sheep-wolves-grass" [
    ask patches [
      set pcolor one-of [ green brown ]
      ifelse pcolor = green
        [ set countdown grass-regrowth-time ]
      [ set countdown random grass-regrowth-time ] ; initialize grass regrowth clocks randomly for brown patches
    ]
  ]
  [
    ask patches [ set pcolor green ]
  ]

  create-sheep initial-number-sheep  ; create the sheep, then initialize their variables
  [
    set shape  "sheep"
    set color white
    set size 1.5  ; easier to see
    set label-color blue - 2
    set energy random (2 * sheep-gain-from-food)
    setxy random-xcor random-ycor
  ]

  create-wolves initial-number-wolves  ; create the wolves, then initialize their variables
  [
    set shape "wolf"
    set color black
    set size 2  ; easier to see
    set energy random (2 * wolf-gain-from-food)
    setxy random-xcor random-ycor
  ]
  display-labels
  reset-ticks
end

to go
  ; stop the simulation of no wolves or sheep
  if not any? turtles [ stop ]
  ; stop the model if there are no wolves and the number of sheep gets very large
  if not any? wolves and count sheep > max-sheep [ user-message "The sheep have inherited the earth" stop ]
  ask sheep [
    move
    if model-version = "sheep-wolves-grass" [ ; in this version, sheep eat grass, grass grows and it costs sheep energy to move
      set energy energy - 1  ; deduct energy for sheep only if running sheep-wolf-grass model version
      eat-grass  ; sheep eat grass only if running sheep-wolf-grass model version
      death ; sheep die from starvation only if running sheep-wolf-grass model version
    ]
    reproduce-sheep  ; sheep reproduce at random rate governed by slider
  ]
  ask wolves [
    move
    set energy energy - 1  ; wolves lose energy as they move
    eat-sheep ; wolves eat a sheep on their patch
    death ; wolves die if our of energy
    reproduce-wolves ; wolves reproduce at random rate governed by slider
  ]
  if model-version = "sheep-wolves-grass" [ ask patches [ grow-grass ] ]
  ; set grass count patches with [pcolor = green]
  tick
  display-labels
end

to move  ; turtle procedure
  rt random 50
  lt random 50
  fd 1
end

to eat-grass  ; sheep procedure
  ; sheep eat grass, turn the patch brown
  if pcolor = green [
    set pcolor brown
    set energy energy + sheep-gain-from-food  ; sheep gain energy by eating
  ]
end

to reproduce-sheep  ; sheep procedure
  if random-float 100 < sheep-reproduce [  ; throw "dice" to see if you will reproduce
    set energy (energy / 2)                ; divide energy between parent and offspring
    hatch 1 [ rt random-float 360 fd 1 ]   ; hatch an offspring and move it forward 1 step
  ]
end

to reproduce-wolves  ; wolf procedure
  if random-float 100 < wolf-reproduce [  ; throw "dice" to see if you will reproduce
    set energy (energy / 2)               ; divide energy between parent and offspring
    hatch 1 [ rt random-float 360 fd 1 ]  ; hatch an offspring and move it forward 1 step
  ]
end

to eat-sheep  ; wolf procedure
  let prey one-of sheep-here                    ; grab a random sheep
  if prey != nobody  [                          ; did we get one?  if so,
    ask prey [ die ]                            ; kill it, and...
    set energy energy + wolf-gain-from-food     ; get energy from eating
  ]
end

to death  ; turtle procedure (i.e. both wolf nd sheep procedure)
  ; when energy dips below zero, die
  if energy < 0 [ die ]
end

to grow-grass  ; patch procedure
  ; countdown on brown patches: if reach 0, grow some grass
  if pcolor = brown [
    ifelse countdown <= 0
      [ set pcolor green
        set countdown grass-regrowth-time ]
      [ set countdown countdown - 1 ]
  ]
end

to-report grass
  ifelse model-version = "sheep-wolves-grass" [
    report patches with [pcolor = green]
  ]
  [ report 0 ]
end


to display-labels
  ask turtles [ set label "" ]
  if show-energy? [
    ask wolves [ set label round energy ]
    if model-version = "sheep-wolves-grass" [ ask sheep [ set label round energy ] ]
  ]
end


; Copyright 1997 Uri Wilensky.
; See Info tab for full copyright and license.

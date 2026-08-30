;!#

;; ============================================================
;; GIMP SCRIPT-FU β€” PALLET DRAWING
;;
;; Rotated pallet reference size:
;;   0.80 m x 1.20 m
;;   270 px x 405 px
;;
;; EXISTING FIVE PLANKS (ROTATED 90 DEGREES)
;;   Original horizontal planks are now vertical.
;;
;; THREE NEW PERPENDICULAR PLANKS
;;   Full pallet width, placed at the top, middle, and bottom.
;;   Each plank is 14 cm thick = 47 px.
;;
;; The spaces between the original planks are WHITE and transparent
;; to the wood, matching the white background.
;;
;; No floating-point coordinate values are used.
;; ============================================================


;; ============================================================
;; CONFIGURATION
;; ============================================================

(define IMAGE-WIDTH 1080)
(define IMAGE-HEIGHT 1080)

(define BASE-WIDTH 1080)
(define BASE-HEIGHT 1080)

;; Pallet size after 90-degree rotation
(define PALLET-WIDTH 270)
(define PALLET-HEIGHT 405)

;; Original plank dimensions, rotated:
;; original 14 cm x 9 cm planks become 47 px x 30 px in plan.
(define PLANK-1-WIDTH 47)
(define PLANK-2-WIDTH 30)
(define PLANK-3-WIDTH 47)
(define PLANK-4-WIDTH 30)
(define PLANK-5-WIDTH 47)

;; Three new perpendicular planks
;; EXACT DIMENSION: 14 cm = 47 px thickness.
;; This is the dimension perpendicular to the plank's long direction.
(define CROSS-PLANK-THICKNESS-14CM 47)

;; Total original-plank width = 201 px.
;; Remaining white space across pallet width = 69 px.
;;
;; Four equal-ish gaps:
;;   GAP-1 = 17 px
;;   GAP-2 = 17 px
;;   GAP-3 = 17 px
;;   GAP-4 = 18 px
;;
;; 47 + 17 + 30 + 17 + 47 + 17 + 30 + 18 + 47 = 270 px

(define GAP-1 17)
(define GAP-2 17)
(define GAP-3 17)
(define GAP-4 18)

;; Three cross-planks:
;; Each is EXACTLY 47 px thick (14 cm).
;;   top    = 0..47
;;   middle = 179..226
;;   bottom = 358..405
(define CROSS-TOP-Y 0)
(define CROSS-MIDDLE-Y 179)
(define CROSS-BOTTOM-Y 358)


;; ============================================================
;; CENTER PALLET IN IMAGE
;; ============================================================

(define PALLET-X
  (/ (- BASE-WIDTH PALLET-WIDTH) 2))

(define PALLET-Y
  (/ (- BASE-HEIGHT PALLET-HEIGHT) 2))


;; ============================================================
;; COLORS
;; ============================================================

;; Light wood fill
(define WOOD-R 196)
(define WOOD-G 145)
(define WOOD-B 85)

;; Dark wood for outlines
(define WOOD-LINE-R 96)
(define WOOD-LINE-G 62)
(define WOOD-LINE-B 30)

;; Background
(define BG-R 255)
(define BG-G 255)
(define BG-B 255)


;; ============================================================
;; LINE WIDTH
;; ============================================================

(define BASE-LINE-WIDTH 6)


;; ============================================================
;; SCALE FUNCTIONS
;; ============================================================

(define (scale-x)
  (/ IMAGE-WIDTH BASE-WIDTH))

(define (scale-y)
  (/ IMAGE-HEIGHT BASE-HEIGHT))

(define (scale-uniform)
  (min (scale-x) (scale-y)))

(define (px x)
  (* x (scale-x)))

(define (py y)
  (* y (scale-y)))

(define (psize value)
  (* value (scale-uniform)))


;; ============================================================
;; COLOR HELPERS
;; ============================================================

(define (make-color r g b)
  (list r g b))

(define (color-r c)
  (list-ref c 0))

(define (color-g c)
  (list-ref c 1))

(define (color-b c)
  (list-ref c 2))


;; ============================================================
;; DRAW FILLED RECTANGLE
;; ============================================================

(define (draw-rectangle-filled drawable image x y width height color)

  (gimp-context-set-foreground
    (list
      (color-r color)
      (color-g color)
      (color-b color)))

  (gimp-image-select-rectangle
    image
    CHANNEL-OP-REPLACE
    (px x)
    (py y)
    (px width)
    (py height))

  (gimp-drawable-edit-fill
    drawable
    FILL-FOREGROUND)

  (gimp-selection-none image))


;; ============================================================
;; DRAW STRAIGHT LINE
;; ============================================================

(define (draw-straight-line drawable x1 y1 x2 y2 width color)

  (gimp-context-set-foreground
    (list
      (color-r color)
      (color-g color)
      (color-b color)))

  (let*
    ((stroke
      (vector
        (px x1)
        (py y1)
        (px x2)
        (py y2))))

    (gimp-context-set-brush-size
      (psize width))

    (gimp-paintbrush-default
      drawable
      stroke)))


;; ============================================================
;; DRAW PALLET BASE
;;
;; Full pallet area starts white. Wood is only drawn where planks
;; exist, leaving the original gaps white.
;; ============================================================

(define (draw-pallet-base drawable image)

  (draw-rectangle-filled
    drawable
    image
    PALLET-X
    PALLET-Y
    PALLET-WIDTH
    PALLET-HEIGHT
    (make-color BG-R BG-G BG-B)))


;; ============================================================
;; DRAW FIVE ORIGINAL PLANKS β€” NOW VERTICAL
;; ============================================================

(define (draw-vertical-planks drawable image)

  (let*
    ((x1 PALLET-X)

     ;; Plank 1
     (x2
      (+ x1 PLANK-1-WIDTH))

     ;; White gap 1
     (x3
      (+ x2 GAP-1))

     ;; Plank 2
     (x4
      (+ x3 PLANK-2-WIDTH))

     ;; White gap 2
     (x5
      (+ x4 GAP-2))

     ;; Plank 3
     (x6
      (+ x5 PLANK-3-WIDTH))

     ;; White gap 3
     (x7
      (+ x6 GAP-3))

     ;; Plank 4
     (x8
      (+ x7 PLANK-4-WIDTH))

     ;; White gap 4
     (x9
      (+ x8 GAP-4))

     ;; Plank 5
     (x10
      (+ x9 PLANK-5-WIDTH))

     (wood
      (make-color WOOD-R WOOD-G WOOD-B)))

    ;; Plank 1 β€” 47 px wide
    (draw-rectangle-filled
      drawable
      image
      x1
      PALLET-Y
      PLANK-1-WIDTH
      PALLET-HEIGHT
      wood)

    ;; Plank 2 β€” 30 px wide
    (draw-rectangle-filled
      drawable
      image
      x3
      PALLET-Y
      PLANK-2-WIDTH
      PALLET-HEIGHT
      wood)

    ;; Plank 3 β€” 47 px wide
    (draw-rectangle-filled
      drawable
      image
      x5
      PALLET-Y
      PLANK-3-WIDTH
      PALLET-HEIGHT
      wood)

    ;; Plank 4 β€” 30 px wide
    (draw-rectangle-filled
      drawable
      image
      x7
      PALLET-Y
      PLANK-4-WIDTH
      PALLET-HEIGHT
      wood)

    ;; Plank 5 β€” 47 px wide
    (draw-rectangle-filled
      drawable
      image
      x9
      PALLET-Y
      PLANK-5-WIDTH
      PALLET-HEIGHT
      wood)))


;; ============================================================
;; DRAW THREE NEW PERPENDICULAR PLANKS
;;
;; These run across the full pallet width.
;; They are drawn after the vertical planks so they visibly sit
;; across them. Their thickness is exactly 14 cm (47 px).
;; ============================================================

(define (draw-cross-planks drawable image)

  (let
    ((wood
      (make-color WOOD-R WOOD-G WOOD-B)))

    ;; Top cross-plank
    (draw-rectangle-filled
      drawable
      image
      PALLET-X
      (+ PALLET-Y CROSS-TOP-Y)
      PALLET-WIDTH
      CROSS-PLANK-THICKNESS-14CM
      wood)

    ;; Middle cross-plank
    (draw-rectangle-filled
      drawable
      image
      PALLET-X
      (+ PALLET-Y CROSS-MIDDLE-Y)
      PALLET-WIDTH
      CROSS-PLANK-THICKNESS-14CM
      wood)

    ;; Bottom cross-plank
    (draw-rectangle-filled
      drawable
      image
      PALLET-X
      (+ PALLET-Y CROSS-BOTTOM-Y)
      PALLET-WIDTH
      CROSS-PLANK-THICKNESS-14CM
      wood)))


;; ============================================================
;; DRAW OUTLINES FOR THE FIVE VERTICAL PLANKS
;; ============================================================

(define (draw-vertical-plank-outlines drawable)

  (let*
    ((c
      (make-color
        WOOD-LINE-R
        WOOD-LINE-G
        WOOD-LINE-B))

     (x1 PALLET-X)

     (x2
      (+ x1 PLANK-1-WIDTH))

     (x3
      (+ x2 GAP-1))

     (x4
      (+ x3 PLANK-2-WIDTH))

     (x5
      (+ x4 GAP-2))

     (x6
      (+ x5 PLANK-3-WIDTH))

     (x7
      (+ x6 GAP-3))

     (x8
      (+ x7 PLANK-4-WIDTH))

     (x9
      (+ x8 GAP-4))

     (x10
      (+ x9 PLANK-5-WIDTH)))

    ;; Vertical boundary lines for each of the 5 original planks
    (draw-straight-line
      drawable
      x1 PALLET-Y
      x1 (+ PALLET-Y PALLET-HEIGHT)
      BASE-LINE-WIDTH c)

    (draw-straight-line
      drawable
      x2 PALLET-Y
      x2 (+ PALLET-Y PALLET-HEIGHT)
      BASE-LINE-WIDTH c)

    (draw-straight-line
      drawable
      x3 PALLET-Y
      x3 (+ PALLET-Y PALLET-HEIGHT)
      BASE-LINE-WIDTH c)

    (draw-straight-line
      drawable
      x4 PALLET-Y
      x4 (+ PALLET-Y PALLET-HEIGHT)
      BASE-LINE-WIDTH c)

    (draw-straight-line
      drawable
      x5 PALLET-Y
      x5 (+ PALLET-Y PALLET-HEIGHT)
      BASE-LINE-WIDTH c)

    (draw-straight-line
      drawable
      x6 PALLET-Y
      x6 (+ PALLET-Y PALLET-HEIGHT)
      BASE-LINE-WIDTH c)

    (draw-straight-line
      drawable
      x7 PALLET-Y
      x7 (+ PALLET-Y PALLET-HEIGHT)
      BASE-LINE-WIDTH c)

    (draw-straight-line
      drawable
      x8 PALLET-Y
      x8 (+ PALLET-Y PALLET-HEIGHT)
      BASE-LINE-WIDTH c)

    (draw-straight-line
      drawable
      x9 PALLET-Y
      x9 (+ PALLET-Y PALLET-HEIGHT)
      BASE-LINE-WIDTH c)

    (draw-straight-line
      drawable
      x10 PALLET-Y
      x10 (+ PALLET-Y PALLET-HEIGHT)
      BASE-LINE-WIDTH c)))


;; ============================================================
;; DRAW OUTLINES FOR THE THREE NEW CROSS-PLANKS
;; ============================================================

(define (draw-cross-plank-outlines drawable)

  (let
    ((c
      (make-color
        WOOD-LINE-R
        WOOD-LINE-G
        WOOD-LINE-B)))

    ;; Top cross-plank
    (draw-straight-line
      drawable
      PALLET-X
      (+ PALLET-Y CROSS-TOP-Y)
      (+ PALLET-X PALLET-WIDTH)
      (+ PALLET-Y CROSS-TOP-Y)
      BASE-LINE-WIDTH
      c)

    (draw-straight-line
      drawable
      PALLET-X
      (+ PALLET-Y CROSS-TOP-Y CROSS-PLANK-THICKNESS-14CM)
      (+ PALLET-X PALLET-WIDTH)
      (+ PALLET-Y CROSS-TOP-Y CROSS-PLANK-THICKNESS-14CM)
      BASE-LINE-WIDTH
      c)

    ;; Middle cross-plank
    (draw-straight-line
      drawable
      PALLET-X
      (+ PALLET-Y CROSS-MIDDLE-Y)
      (+ PALLET-X PALLET-WIDTH)
      (+ PALLET-Y CROSS-MIDDLE-Y)
      BASE-LINE-WIDTH
      c)

    (draw-straight-line
      drawable
      PALLET-X
      (+ PALLET-Y CROSS-MIDDLE-Y CROSS-PLANK-THICKNESS-14CM)
      (+ PALLET-X PALLET-WIDTH)
      (+ PALLET-Y CROSS-MIDDLE-Y CROSS-PLANK-THICKNESS-14CM)
      BASE-LINE-WIDTH
      c)

    ;; Bottom cross-plank
    (draw-straight-line
      drawable
      PALLET-X
      (+ PALLET-Y CROSS-BOTTOM-Y)
      (+ PALLET-X PALLET-WIDTH)
      (+ PALLET-Y CROSS-BOTTOM-Y)
      BASE-LINE-WIDTH
      c)

    (draw-straight-line
      drawable
      PALLET-X
      (+ PALLET-Y CROSS-BOTTOM-Y CROSS-PLANK-THICKNESS-14CM)
      (+ PALLET-X PALLET-WIDTH)
      (+ PALLET-Y CROSS-BOTTOM-Y CROSS-PLANK-THICKNESS-14CM)
      BASE-LINE-WIDTH
      c)))


;; ============================================================
;; DRAW PALLET OUTER BOUNDARY
;; ============================================================

(define (draw-pallet-outer-outline drawable)

  (let
    ((c
      (make-color
        WOOD-LINE-R
        WOOD-LINE-G
        WOOD-LINE-B)))

    ;; Top edge
    (draw-straight-line
      drawable
      PALLET-X PALLET-Y
      (+ PALLET-X PALLET-WIDTH) PALLET-Y
      BASE-LINE-WIDTH c)

    ;; Bottom edge
    (draw-straight-line
      drawable
      PALLET-X (+ PALLET-Y PALLET-HEIGHT)
      (+ PALLET-X PALLET-WIDTH) (+ PALLET-Y PALLET-HEIGHT)
      BASE-LINE-WIDTH c)

    ;; Left edge
    (draw-straight-line
      drawable
      PALLET-X PALLET-Y
      PALLET-X (+ PALLET-Y PALLET-HEIGHT)
      BASE-LINE-WIDTH c)

    ;; Right edge
    (draw-straight-line
      drawable
      (+ PALLET-X PALLET-WIDTH) PALLET-Y
      (+ PALLET-X PALLET-WIDTH) (+ PALLET-Y PALLET-HEIGHT)
      BASE-LINE-WIDTH c)))


;; ============================================================
;; MAIN
;; ============================================================

(define (script-fu-draw-pallet)

  (script-fu-use-v3)

  (let*
    ((image
      (gimp-image-new
        IMAGE-WIDTH
        IMAGE-HEIGHT
        RGB))

     (layer
      (gimp-layer-new
        image
        "Wooden Pallet"
        IMAGE-WIDTH
        IMAGE-HEIGHT
        RGBA-IMAGE
        100
        LAYER-MODE-NORMAL)))

    ;; Add layer
    (gimp-image-insert-layer
      image
      layer
      0
      0)

    ;; Start with white background
    (gimp-drawable-fill
      layer
      FILL-WHITE)

    ;; Reset GIMP context
    (gimp-context-set-defaults)
    (gimp-context-set-default-colors)

    ;; White pallet area
    (draw-pallet-base
      layer
      image)

    ;; Five original planks, rotated 90 degrees
    (draw-vertical-planks
      layer
      image)

    ;; Three new perpendicular planks:
    ;; top, middle, bottom
    (draw-cross-planks
      layer
      image)

    ;; Outlines for original vertical planks
    (draw-vertical-plank-outlines
      layer)

    ;; Outlines for new cross-planks
    (draw-cross-plank-outlines
      layer)

    ;; Outer pallet boundary
    (draw-pallet-outer-outline
      layer)

    ;; Display finished image
    (gimp-display-new
      image)))


;; ============================================================
;; RUN
;; ============================================================

(script-fu-draw-pallet)

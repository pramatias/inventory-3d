#!/usr/bin/env gimp-script-fu-interpreter-3.0
;!#

;; ============================================================
;; GIMP SCRIPT-FU — PALLET DRAWING
;;
;; Pallet reference size:
;;   1.20 m x 0.80 m
;;   405 px x 270 px
;;
;; FIVE HORIZONTAL PLANKS
;;
;; Plank dimensions:
;;   1st = 14 cm = 47 px
;;   2nd =  9 cm = 30 px
;;   3rd = 14 cm = 47 px
;;   4th =  9 cm = 30 px
;;   5th = 14 cm = 47 px
;;
;; The spaces between the planks are WHITE and transparent
;; to the wood, matching the white background.
;;
;; No floating-point numbers are used.
;; ============================================================


;; ============================================================
;; CONFIGURATION
;; ============================================================

(define IMAGE-WIDTH 1080)
(define IMAGE-HEIGHT 1080)

(define BASE-WIDTH 1080)
(define BASE-HEIGHT 1080)

;; Pallet size
(define PALLET-WIDTH 405)
(define PALLET-HEIGHT 270)

;; Plank heights
;; 14 cm ≈ 47 px
;;  9 cm ≈ 30 px
(define PLANK-1-HEIGHT 47)
(define PLANK-2-HEIGHT 30)
(define PLANK-3-HEIGHT 47)
(define PLANK-4-HEIGHT 30)
(define PLANK-5-HEIGHT 47)

;; Total plank height = 201 px
;; Pallet height = 270 px
;; Remaining white space = 69 px
;;
;; We use four equal-ish gaps:
;;   GAP-1 = 17 px
;;   GAP-2 = 17 px
;;   GAP-3 = 17 px
;;   GAP-4 = 18 px
;;
;; This gives:
;;   47 + 17 + 30 + 17 + 47 + 17 + 30 + 18 + 47
;;   = 270 px

(define GAP-1 17)
(define GAP-2 17)
(define GAP-3 17)
(define GAP-4 18)


;; Center pallet in image.
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
;; This creates the full white background first.
;; The wood is then drawn only where the planks exist.
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
;; DRAW FIVE SEPARATE HORIZONTAL PLANKS
;;
;; IMPORTANT:
;; The white gaps between planks remain untouched.
;; ============================================================

(define (draw-horizontal-planks drawable image)

  (let*
    ;; Starting Y coordinate
    ((y1
      PALLET-Y)

     ;; Plank 1
     (y2
      (+ y1 PLANK-1-HEIGHT))

     ;; White gap 1
     (y3
      (+ y2 GAP-1))

     ;; Plank 2
     (y4
      (+ y3 PLANK-2-HEIGHT))

     ;; White gap 2
     (y5
      (+ y4 GAP-2))

     ;; Plank 3
     (y6
      (+ y5 PLANK-3-HEIGHT))

     ;; White gap 3
     (y7
      (+ y6 GAP-3))

     ;; Plank 4
     (y8
      (+ y7 PLANK-4-HEIGHT))

     ;; White gap 4
     (y9
      (+ y8 GAP-4))

     ;; Plank 5
     (y10
      (+ y9 PLANK-5-HEIGHT))

     (wood
      (make-color WOOD-R WOOD-G WOOD-B)))

    ;; --------------------------------------------------------
    ;; PLANK 1 — 14 cm / 47 px
    ;; --------------------------------------------------------

    (draw-rectangle-filled
      drawable
      image
      PALLET-X
      y1
      PALLET-WIDTH
      PLANK-1-HEIGHT
      wood)

    ;; --------------------------------------------------------
    ;; PLANK 2 — 9 cm / 30 px
    ;; --------------------------------------------------------

    (draw-rectangle-filled
      drawable
      image
      PALLET-X
      y3
      PALLET-WIDTH
      PLANK-2-HEIGHT
      wood)

    ;; --------------------------------------------------------
    ;; PLANK 3 — 14 cm / 47 px
    ;; --------------------------------------------------------

    (draw-rectangle-filled
      drawable
      image
      PALLET-X
      y5
      PALLET-WIDTH
      PLANK-3-HEIGHT
      wood)

    ;; --------------------------------------------------------
    ;; PLANK 4 — 9 cm / 30 px
    ;; --------------------------------------------------------

    (draw-rectangle-filled
      drawable
      image
      PALLET-X
      y7
      PALLET-WIDTH
      PLANK-4-HEIGHT
      wood)

    ;; --------------------------------------------------------
    ;; PLANK 5 — 14 cm / 47 px
    ;; --------------------------------------------------------

    (draw-rectangle-filled
      drawable
      image
      PALLET-X
      y9
      PALLET-WIDTH
      PLANK-5-HEIGHT
      wood)))


;; ============================================================
;; DRAW EACH PLANK OUTLINE
;;
;; Each plank gets its own outline.
;; The white spaces remain completely white.
;; ============================================================

(define (draw-horizontal-plank-outlines drawable)

  (let*
    ((c
      (make-color
        WOOD-LINE-R
        WOOD-LINE-G
        WOOD-LINE-B))

     (y1
      PALLET-Y)

     (y2
      (+ y1 PLANK-1-HEIGHT))

     (y3
      (+ y2 GAP-1))

     (y4
      (+ y3 PLANK-2-HEIGHT))

     (y5
      (+ y4 GAP-2))

     (y6
      (+ y5 PLANK-3-HEIGHT))

     (y7
      (+ y6 GAP-3))

     (y8
      (+ y7 PLANK-4-HEIGHT))

     (y9
      (+ y8 GAP-4))

     (y10
      (+ y9 PLANK-5-HEIGHT)))


    ;; ========================================================
    ;; PLANK 1 OUTLINE
    ;; ========================================================

    ;; Top
    (draw-straight-line
      drawable
      PALLET-X y1
      (+ PALLET-X PALLET-WIDTH) y1
      BASE-LINE-WIDTH c)

    ;; Bottom
    (draw-straight-line
      drawable
      PALLET-X y2
      (+ PALLET-X PALLET-WIDTH) y2
      BASE-LINE-WIDTH c)


    ;; ========================================================
    ;; PLANK 2 OUTLINE
    ;; ========================================================

    ;; Top
    (draw-straight-line
      drawable
      PALLET-X y3
      (+ PALLET-X PALLET-WIDTH) y3
      BASE-LINE-WIDTH c)

    ;; Bottom
    (draw-straight-line
      drawable
      PALLET-X y4
      (+ PALLET-X PALLET-WIDTH) y4
      BASE-LINE-WIDTH c)


    ;; ========================================================
    ;; PLANK 3 OUTLINE
    ;; ========================================================

    ;; Top
    (draw-straight-line
      drawable
      PALLET-X y5
      (+ PALLET-X PALLET-WIDTH) y5
      BASE-LINE-WIDTH c)

    ;; Bottom
    (draw-straight-line
      drawable
      PALLET-X y6
      (+ PALLET-X PALLET-WIDTH) y6
      BASE-LINE-WIDTH c)


    ;; ========================================================
    ;; PLANK 4 OUTLINE
    ;; ========================================================

    ;; Top
    (draw-straight-line
      drawable
      PALLET-X y7
      (+ PALLET-X PALLET-WIDTH) y7
      BASE-LINE-WIDTH c)

    ;; Bottom
    (draw-straight-line
      drawable
      PALLET-X y8
      (+ PALLET-X PALLET-WIDTH) y8
      BASE-LINE-WIDTH c)


    ;; ========================================================
    ;; PLANK 5 OUTLINE
    ;; ========================================================

    ;; Top
    (draw-straight-line
      drawable
      PALLET-X y9
      (+ PALLET-X PALLET-WIDTH) y9
      BASE-LINE-WIDTH c)

    ;; Bottom
    (draw-straight-line
      drawable
      PALLET-X y10
      (+ PALLET-X PALLET-WIDTH) y10
      BASE-LINE-WIDTH c)))


;; ============================================================
;; DRAW PALLET SIDE BOUNDARIES
;;
;; Only the outer left and right edges are drawn.
;; ============================================================

(define (draw-pallet-side-outline drawable)

  (let*
    ((c
      (make-color
        WOOD-LINE-R
        WOOD-LINE-G
        WOOD-LINE-B))

     (top
      PALLET-Y)

     (bottom
      (+ PALLET-Y PALLET-HEIGHT)))


    ;; Left edge
    (draw-straight-line
      drawable
      PALLET-X
      top
      PALLET-X
      bottom
      BASE-LINE-WIDTH
      c)

    ;; Right edge
    (draw-straight-line
      drawable
      (+ PALLET-X PALLET-WIDTH)
      top
      (+ PALLET-X PALLET-WIDTH)
      bottom
      BASE-LINE-WIDTH
      c)))


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

    ;; Five separate wooden planks
    (draw-horizontal-planks
      layer
      image)

    ;; Individual plank outlines
    (draw-horizontal-plank-outlines
      layer)

    ;; Outer left/right boundaries
    (draw-pallet-side-outline
      layer)

    ;; Display finished image
    (gimp-display-new
      image)))


;; ============================================================
;; RUN
;; ============================================================

(script-fu-draw-pallet)

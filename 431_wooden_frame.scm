#!/usr/bin/env gimp-script-fu-interpreter-3.0
#!/home/emporas/repos/inventory-3d/gimp-plugin/inventory-3d/inventory-3d.py

;!#

;; ============================================================
;; GIMP SCRIPT-FU — RECTANGULAR WOODEN FRAME
;;
;; FRAME SIZE:
;;   60 cm width
;;   160 cm height
;;
;; SCALE:
;;   6 px = 1 cm
;;
;; FRAME:
;;   360 px x 960 px
;;
;; WOODEN BORDER:
;;   4 cm = 24 px
;;
;; INNER PATTERN AREA:
;;   52 cm x 152 cm
;;   312 px x 912 px
;;
;; DIAGONAL WOOD STRIPS:
;;   Width = 1.8 cm ≈ 11 px
;;   Gap   = 1.8 cm ≈ 11 px
;;   Total perpendicular pitch = 3.6 cm ≈ 21.6 px
;;
;; For 45 degree lines:
;;   equation pitch ≈ 21.6 × sqrt(2) ≈ 30.55 px
;;
;; Integer-only value:
;;   DIAGONAL-PITCH = 31 px
;;
;; PATTERN:
;;   Left side  = +45 degrees
;;   Right side = -45 degrees
;;
;; The patterns are mirrored so every +45 strip has a
;; corresponding -45 strip on the opposite side.
;;
;; No floating-point numbers are used.
;; ============================================================


;; ============================================================
;; CONFIGURATION
;; ============================================================

(define IMAGE-WIDTH 1080)
(define IMAGE-HEIGHT 1080)

;; ------------------------------------------------------------
;; SCALE
;; ------------------------------------------------------------

;; 1 cm = 6 pixels
(define PX-PER-CM 6)


;; ============================================================
;; FRAME DIMENSIONS
;; ============================================================

;; 60 cm x 160 cm
(define FRAME-WIDTH 360)
(define FRAME-HEIGHT 960)

;; Wooden border = 4 cm
(define BORDER-WIDTH 24)

;; Inner pattern dimensions
(define INNER-WIDTH
  (- FRAME-WIDTH
     (* 2 BORDER-WIDTH)))

(define INNER-HEIGHT
  (- FRAME-HEIGHT
     (* 2 BORDER-WIDTH)))


;; ============================================================
;; PATTERN DIMENSIONS
;; ============================================================

;; Wood strip width = 1.8 cm ≈ 11 px
(define STRIP-WIDTH 11)

;; Gap = 1.8 cm ≈ 11 px

;; Total pitch:
;; 1.8 cm + 1.8 cm = 3.6 cm
;;
;; At 45 degrees:
;; perpendicular spacing × sqrt(2)
;; ≈ 21.6 × 1.414
;; ≈ 30.55 px
;;
;; Integer-only approximation:
(define DIAGONAL-PITCH 31)


;; ============================================================
;; CENTER FRAME
;; ============================================================

(define FRAME-X
  (/ (- IMAGE-WIDTH FRAME-WIDTH) 2))

(define FRAME-Y
  (/ (- IMAGE-HEIGHT FRAME-HEIGHT) 2))


;; Inner opening
(define INNER-X
  (+ FRAME-X BORDER-WIDTH))

(define INNER-Y
  (+ FRAME-Y BORDER-WIDTH))


;; ============================================================
;; COLORS
;; ============================================================

;; Light wood fill
(define WOOD-R 196)
(define WOOD-G 145)
(define WOOD-B 85)

;; Dark wood outline
(define WOOD-LINE-R 96)
(define WOOD-LINE-G 62)
(define WOOD-LINE-B 30)

;; White
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
  (/ IMAGE-WIDTH IMAGE-WIDTH))

(define (scale-y)
  (/ IMAGE-HEIGHT IMAGE-HEIGHT))

(define (scale-uniform)
  (min (scale-x) (scale-y)))

(define (px value)
  value)

(define (psize value)
  value)


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
;; SET FOREGROUND COLOR
;; ============================================================

(define (set-color color)

  (gimp-context-set-foreground
    (list
      (color-r color)
      (color-g color)
      (color-b color))))


;; ============================================================
;; DRAW FILLED RECTANGLE
;; ============================================================

(define
  (draw-rectangle-filled drawable image x y width height color)

  (set-color color)

  (gimp-image-select-rectangle
    image
    CHANNEL-OP-REPLACE
    x
    y
    width
    height)

  (gimp-drawable-edit-fill
    drawable
    FILL-FOREGROUND)

  (gimp-selection-none image))


;; ============================================================
;; DRAW STRAIGHT LINE
;; ============================================================

(define
  (draw-straight-line drawable x1 y1 x2 y2 width color)

  (set-color color)

  (let*
    ((stroke
       (vector
         x1
         y1
         x2
         y2)))

    (gimp-context-set-brush-size width)

    (gimp-paintbrush-default
      drawable
      stroke)))


;; ============================================================
;; DRAW OUTER FRAME
;;
;; Entire 60 x 160 cm area becomes wood.
;; ============================================================

(define
  (draw-frame-base drawable image)

  ;; Entire frame wooden
  (draw-rectangle-filled
    drawable
    image
    FRAME-X
    FRAME-Y
    FRAME-WIDTH
    FRAME-HEIGHT
    (make-color
      WOOD-R
      WOOD-G
      WOOD-B))

  ;; Cut the inner opening to white
  (draw-rectangle-filled
    drawable
    image
    INNER-X
    INNER-Y
    INNER-WIDTH
    INNER-HEIGHT
    (make-color
      BG-R
      BG-G
      BG-B)))


;; ============================================================
;; DRAW INNER +45 DEGREE STRIPS
;;
;; Strips originate from the left side.
;;
;; They are clipped by the inner rectangle selection.
;; ============================================================

(define
  (draw-positive-diagonal-pattern drawable image)

  (let*
    ((wood
       (make-color
         WOOD-R
         WOOD-G
         WOOD-B))

     ;; Start well before the inner rectangle.
     ;; This guarantees complete diagonal coverage.
     (start-x
       (- INNER-X INNER-HEIGHT))

     (end-x
       (+ INNER-X INNER-WIDTH INNER-HEIGHT)))

    ;; Select only the inside area.
    (gimp-image-select-rectangle
      image
      CHANNEL-OP-REPLACE
      INNER-X
      INNER-Y
      INNER-WIDTH
      INNER-HEIGHT)

    ;; --------------------------------------------------------
    ;; +45 degree lines
    ;;
    ;; y = x + constant
    ;;
    ;; Integer pitch = 31 px
    ;; --------------------------------------------------------

    (let*
      ((c-start
         (- INNER-Y
            INNER-X
            INNER-HEIGHT)))

      (let loop
        ((c c-start))

        (if
          (<= c
              (+ INNER-Y INNER-HEIGHT))

          (begin

            (draw-straight-line
              drawable

              start-x

              (+ start-x c)

              end-x

              (+ end-x c)

              STRIP-WIDTH

              wood)

            (loop
              (+ c DIAGONAL-PITCH))))))

    ;; Remove clipping selection.
    (gimp-selection-none image)))


;; ============================================================
;; DRAW INNER -45 DEGREE STRIPS
;;
;; Strips originate from the right side.
;;
;; This creates the corresponding mirrored pattern.
;; ============================================================

(define
  (draw-negative-diagonal-pattern drawable image)

  (let*
    ((wood
       (make-color
         WOOD-R
         WOOD-G
         WOOD-B))

     ;; Start well beyond the inner rectangle.
     (start-x
       (- INNER-X INNER-HEIGHT))

     (end-x
       (+ INNER-X INNER-WIDTH INNER-HEIGHT)))

    ;; Select only inner opening.
    (gimp-image-select-rectangle
      image
      CHANNEL-OP-REPLACE
      INNER-X
      INNER-Y
      INNER-WIDTH
      INNER-HEIGHT)

    ;; --------------------------------------------------------
    ;; -45 degree lines
    ;;
    ;; y = -x + constant
    ;;
    ;; Same integer pitch as the +45 pattern.
    ;; --------------------------------------------------------

    (let*
      ((c-start
         (+ INNER-X
            INNER-Y)))

      (let loop
        ((c (- c-start
               INNER-HEIGHT)))

        (if
          (<= c
              (+ INNER-X
                 INNER-WIDTH
                 INNER-Y
                 INNER-HEIGHT))

          (begin

            (draw-straight-line
              drawable

              start-x

              (- c start-x)

              end-x

              (- c end-x)

              STRIP-WIDTH

              wood)

            (loop
              (+ c DIAGONAL-PITCH))))))

    ;; Remove clipping.
    (gimp-selection-none image)))


;; ============================================================
;; DRAW OUTER FRAME OUTLINES
;; ============================================================

(define
  (draw-frame-outline drawable)

  (let*
    ((c
       (make-color
         WOOD-LINE-R
         WOOD-LINE-G
         WOOD-LINE-B))

     (left
       FRAME-X)

     (right
       (+ FRAME-X FRAME-WIDTH))

     (top
       FRAME-Y)

     (bottom
       (+ FRAME-Y FRAME-HEIGHT))

     (inner-left
       INNER-X)

     (inner-right
       (+ INNER-X INNER-WIDTH))

     (inner-top
       INNER-Y)

     (inner-bottom
       (+ INNER-Y INNER-HEIGHT)))


    ;; ========================================================
    ;; OUTER FRAME
    ;; ========================================================

    ;; Top
    (draw-straight-line
      drawable
      left
      top
      right
      top
      BASE-LINE-WIDTH
      c)

    ;; Bottom
    (draw-straight-line
      drawable
      left
      bottom
      right
      bottom
      BASE-LINE-WIDTH
      c)

    ;; Left
    (draw-straight-line
      drawable
      left
      top
      left
      bottom
      BASE-LINE-WIDTH
      c)

    ;; Right
    (draw-straight-line
      drawable
      right
      top
      right
      bottom
      BASE-LINE-WIDTH
      c)


    ;; ========================================================
    ;; INNER FRAME BORDER
    ;; ========================================================

    ;; Inner top
    (draw-straight-line
      drawable
      inner-left
      inner-top
      inner-right
      inner-top
      BASE-LINE-WIDTH
      c)

    ;; Inner bottom
    (draw-straight-line
      drawable
      inner-left
      inner-bottom
      inner-right
      inner-bottom
      BASE-LINE-WIDTH
      c)

    ;; Inner left
    (draw-straight-line
      drawable
      inner-left
      inner-top
      inner-left
      inner-bottom
      BASE-LINE-WIDTH
      c)

    ;; Inner right
    (draw-straight-line
      drawable
      inner-right
      inner-top
      inner-right
      inner-bottom
      BASE-LINE-WIDTH
      c)))


;; ============================================================
;; MAIN
;; ============================================================

(define
  (script-fu-draw-wooden-frame)

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
         "Wooden Frame"
         IMAGE-WIDTH
         IMAGE-HEIGHT
         RGBA-IMAGE
         100
         LAYER-MODE-NORMAL)))

    ;; --------------------------------------------------------
    ;; Add layer
    ;; --------------------------------------------------------

    (gimp-image-insert-layer
      image
      layer
      0
      0)

    ;; --------------------------------------------------------
    ;; White canvas
    ;; --------------------------------------------------------

    (gimp-drawable-fill
      layer
      FILL-WHITE)

    ;; --------------------------------------------------------
    ;; Reset GIMP context
    ;; --------------------------------------------------------

    (gimp-context-set-defaults)
    (gimp-context-set-default-colors)

    ;; --------------------------------------------------------
    ;; Draw solid wooden frame
    ;; --------------------------------------------------------

    (draw-frame-base
      layer
      image)

    ;; --------------------------------------------------------
    ;; Draw +45 degree pattern
    ;; --------------------------------------------------------

    (draw-positive-diagonal-pattern
      layer
      image)

    ;; --------------------------------------------------------
    ;; Draw -45 degree corresponding pattern
    ;; --------------------------------------------------------

    (draw-negative-diagonal-pattern
      layer
      image)

    ;; --------------------------------------------------------
    ;; Frame outlines
    ;; --------------------------------------------------------

    (draw-frame-outline
      layer)

    ;; --------------------------------------------------------
    ;; Display result
    ;; --------------------------------------------------------

    (gimp-display-new
      image)))


;; ============================================================
;; RUN
;; ============================================================

(script-fu-draw-wooden-frame)

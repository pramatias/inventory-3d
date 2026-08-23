#!/usr/bin/env gimp-script-fu-interpreter-3.0
;!#

;; ============================================================
;; GIMP SCRIPT-FU — BUILDING OUTLINE
;;
;; All geometry is defined in a 1080 x 1080 reference system.
;; The geometry, line widths, elevators, and spectator marker
;; automatically scale to the actual IMAGE-WIDTH / IMAGE-HEIGHT.
;;
;; Change only IMAGE-WIDTH and IMAGE-HEIGHT to resize everything.
;; ============================================================


;; ============================================================
;; CONFIGURATION
;; ============================================================

(define IMAGE-WIDTH  2080)
(define IMAGE-HEIGHT 2080)

;; Reference/design dimensions.
;; All coordinates and sizes are specified relative to this.
(define BASE-WIDTH  1080.0)
(define BASE-HEIGHT 1080.0)


;; ============================================================
;; COLORS
;; ============================================================

;; Warehouse boundary and elevator outlines
(define GREEN-R 0)
(define GREEN-G 160)
(define GREEN-B 80)

;; Building and elevator outlines
(define BLACK-R 0)
(define BLACK-G 0)
(define BLACK-B 0)

;; Spectator marker / "Είστε Εδώ"
(define BLUE-R 0)
(define BLUE-G 70)
(define BLUE-B 180)

;; Shelf default color
(define PURPLE-R 128)
(define PURPLE-G 0)
(define PURPLE-B 128)


;; ============================================================
;; BASE SIZES
;; ============================================================

;; Reference line width in the 1080 x 1080 design.
(define BASE-LINE-WIDTH 10.0)

;; Spectator marker radius in the 1080 x 1080 design.
(define BASE-SPECTATOR-RADIUS 12.0)


;; ============================================================
;; SCALE FUNCTIONS
;; ============================================================

;; Horizontal and vertical coordinate scaling.
(define (scale-x)
  (/ IMAGE-WIDTH BASE-WIDTH))

(define (scale-y)
  (/ IMAGE-HEIGHT BASE-HEIGHT))

;; Uniform scale for sizes that should retain their proportions.
;; This prevents circles from becoming stretched on non-square images.
(define (scale-uniform)
  (min (scale-x) (scale-y)))


;; ============================================================
;; COORDINATE / SIZE TRANSFORMATION
;; ============================================================

;; Reference X coordinate -> actual image X coordinate.
(define (px x)
  (* x (scale-x)))

;; Reference Y coordinate -> actual image Y coordinate.
(define (py y)
  (* y (scale-y)))

;; Reference size -> actual image size.
(define (psize value)
  (* value (scale-uniform)))

;; Actual line width.
(define (line-width-pixels)
  (psize BASE-LINE-WIDTH))


;; ============================================================
;; FLOOR PLAN GEOMETRY
;;
;; Coordinates are in the 1080 x 1080 reference system.
;; ============================================================


;; ------------------------------------------------------------
;; Main building outline
;; ------------------------------------------------------------

(define BUILDING-OUTLINE
  (list

    ;; A -> B
    (list
      80.0 140.0
      400.0 140.0)

    ;; B -> C
    (list
      400.0 140.0
      400.0 420.0)

    ;; C -> D
    (list
      400.0 420.0
      340.0 420.0)

    ;; G -> H
    (list
      150.0 420.0
      80.0 420.0)

    ;; I -> A
    (list
      80.0 420.0
      80.0 140.0)
  ))


;; ------------------------------------------------------------
;; Warehouse green boundary
;; Y spans 420 to 510 in reference coordinates.
;; ------------------------------------------------------------

(define WAREHOUSE-SEGMENTS
  (list

    ;; D -> E
    (list
      340.0 420.0
      340.0 510.0)

    ;; E -> F
    (list
      340.0 510.0
      150.0 510.0)

    ;; F -> G
    (list
      150.0 510.0
      150.0 420.0)
  ))


;; ============================================================
;; TWO ELEVATORS
;; ============================================================

;; Elevator center positions in reference coordinates.
(define ELEVATOR-CENTER-1-X 280.0)
(define ELEVATOR-CENTER-2-X 300.0)
(define ELEVATOR-CENTER-Y   435.0)

;; Elevator half dimensions in reference coordinates.
(define ELEVATOR-HALF-WIDTH  7.0)
(define ELEVATOR-HALF-HEIGHT 12.5)


;; ============================================================
;; SHELF DATATYPES
;; ============================================================

;; SHELF:
;;   (x1 y1 x2 y2 side-count color segments)
;;
;; side-count = 1 for one-sided, 2 for two-sided.
;;
;; SHELF-SEGMENT:
;;   (start-offset length depth color)
;;
;; start-offset and length are measured along the shelf line.
;; For the vertical shelf below, offset 0 starts at the top.
;; A segment is drawn on the right side; for a two-sided shelf,
;; the same segment is mirrored to the left side.

(define (make-shelf x1 y1 x2 y2 side-count color segments)
  (list x1 y1 x2 y2 side-count color segments))

(define (shelf-x1 s)        (list-ref s 0))
(define (shelf-y1 s)        (list-ref s 1))
(define (shelf-x2 s)        (list-ref s 2))
(define (shelf-y2 s)        (list-ref s 3))
(define (shelf-side-count s) (list-ref s 4))
(define (shelf-color s)     (list-ref s 5))
(define (shelf-segments s)  (list-ref s 6))

(define (make-shelf-segment start-offset length depth color)
  (list start-offset length depth color))

(define (shelf-segment-start s)  (list-ref s 0))
(define (shelf-segment-length s) (list-ref s 1))
(define (shelf-segment-depth s)  (list-ref s 2))
(define (shelf-segment-color s)  (list-ref s 3))


;; ------------------------------------------------------------
;; Elevator outlines
;; ------------------------------------------------------------

(define ELEVATOR-SEGMENTS
  (list

    ;; --------------------------------------------------------
    ;; Elevator 1 - left
    ;; --------------------------------------------------------

    ;; Top
    (list
      (- ELEVATOR-CENTER-1-X ELEVATOR-HALF-WIDTH)
      (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT)
      (+ ELEVATOR-CENTER-1-X ELEVATOR-HALF-WIDTH)
      (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT))

    ;; Right
    (list
      (+ ELEVATOR-CENTER-1-X ELEVATOR-HALF-WIDTH)
      (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT)
      (+ ELEVATOR-CENTER-1-X ELEVATOR-HALF-WIDTH)
      (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT))

    ;; Bottom
    (list
      (+ ELEVATOR-CENTER-1-X ELEVATOR-HALF-WIDTH)
      (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT)
      (- ELEVATOR-CENTER-1-X ELEVATOR-HALF-WIDTH)
      (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT))

    ;; Left
    (list
      (- ELEVATOR-CENTER-1-X ELEVATOR-HALF-WIDTH)
      (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT)
      (- ELEVATOR-CENTER-1-X ELEVATOR-HALF-WIDTH)
      (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT))


    ;; --------------------------------------------------------
    ;; Elevator 2 - right
    ;; --------------------------------------------------------

    ;; Top
    (list
      (- ELEVATOR-CENTER-2-X ELEVATOR-HALF-WIDTH)
      (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT)
      (+ ELEVATOR-CENTER-2-X ELEVATOR-HALF-WIDTH)
      (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT))

    ;; Right
    (list
      (+ ELEVATOR-CENTER-2-X ELEVATOR-HALF-WIDTH)
      (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT)
      (+ ELEVATOR-CENTER-2-X ELEVATOR-HALF-WIDTH)
      (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT))

    ;; Bottom
    (list
      (+ ELEVATOR-CENTER-2-X ELEVATOR-HALF-WIDTH)
      (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT)
      (- ELEVATOR-CENTER-2-X ELEVATOR-HALF-WIDTH)
      (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT))

    ;; Left
    (list
      (- ELEVATOR-CENTER-2-X ELEVATOR-HALF-WIDTH)
      (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT)
      (- ELEVATOR-CENTER-2-X ELEVATOR-HALF-WIDTH)
      (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT))
  ))


;; ============================================================
;; COLOR HELPERS
;; ============================================================

(define (make-line-color r g b)
  (list r g b))

(define (line-color-r c)
  (list-ref c 0))

(define (line-color-g c)
  (list-ref c 1))

(define (line-color-b c)
  (list-ref c 2))


;; ============================================================
;; DEFAULT SHELF
;; ============================================================

;; One-sided shelf placed immediately to the right of the right
;; elevator. Its line length exactly matches the elevator height:
;; 2 * ELEVATOR-HALF-HEIGHT = 25.0 reference units.
(define SHELF-GAP 12.0)
(define SHELF-SEGMENT-DEPTH 16.0)
(define SHELF-LENGTH
  (* 2.0 ELEVATOR-HALF-HEIGHT))

(define DEFAULT-SHELF
  (make-shelf
    (+ ELEVATOR-CENTER-2-X
       ELEVATOR-HALF-WIDTH
       SHELF-GAP)
    (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT)
    (+ ELEVATOR-CENTER-2-X
       ELEVATOR-HALF-WIDTH
       SHELF-GAP)
    (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT)
    1
    (make-line-color PURPLE-R PURPLE-G PURPLE-B)
    (list
      (make-shelf-segment
        0.0
        (/ SHELF-LENGTH 2.0)
        SHELF-SEGMENT-DEPTH
        (make-line-color PURPLE-R PURPLE-G PURPLE-B))
      (make-shelf-segment
        (/ SHELF-LENGTH 2.0)
        (/ SHELF-LENGTH 2.0)
        SHELF-SEGMENT-DEPTH
        (make-line-color PURPLE-R PURPLE-G PURPLE-B)))))


;; ============================================================
;; SPECTATOR / "YOU ARE HERE" POINT
;; ============================================================

;; Centered on the right elevator.
(define SPECTATOR-X
  ELEVATOR-CENTER-2-X)

;; Positioned at the bottom of the right elevator.
(define SPECTATOR-Y
  (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT))


;; ============================================================
;; DRAWING FUNCTIONS
;; ============================================================

;; ------------------------------------------------------------
;; Draw one straight line.
;; ------------------------------------------------------------

(define (draw-straight-line drawable x1 y1 x2 y2 width)
  (let*
    ((stroke
       (vector
         x1
         y1
         x2
         y2)))

    (gimp-context-set-brush-size width)
    (gimp-paintbrush-default drawable stroke)))


;; ------------------------------------------------------------
;; Draw a list of line segments.
;; ------------------------------------------------------------

(define (draw-segment-list drawable segments width)

  (if (null? segments)

      #t

      (let*
        ((s  (car segments))
         (x1 (list-ref s 0))
         (y1 (list-ref s 1))
         (x2 (list-ref s 2))
         (y2 (list-ref s 3)))

        ;; Convert reference coordinates to actual image pixels.
        (draw-straight-line
          drawable
          (px x1)
          (py y1)
          (px x2)
          (py y2)
          width)

        (draw-segment-list
          drawable
          (cdr segments)
          width))))


;; ============================================================
;; DRAW BUILDING
;; ============================================================

(define (draw-building-outline drawable black-color)

  (gimp-context-set-foreground
    (list
      (line-color-r black-color)
      (line-color-g black-color)
      (line-color-b black-color)))

  (draw-segment-list
    drawable
    BUILDING-OUTLINE
    (line-width-pixels)))


;; ============================================================
;; DRAW WAREHOUSE
;; ============================================================

(define (draw-warehouse drawable color width)

  (gimp-context-set-foreground
    (list
      (line-color-r color)
      (line-color-g color)
      (line-color-b color)))

  (draw-segment-list
    drawable
    WAREHOUSE-SEGMENTS
    width))


;; ============================================================
;; DRAW ELEVATORS
;; ============================================================

(define (draw-elevators drawable color width)

  (gimp-context-set-foreground
    (list
      (line-color-r color)
      (line-color-g color)
      (line-color-b color)))

  (draw-segment-list
    drawable
    ELEVATOR-SEGMENTS
    width))


;; ============================================================
;; DRAW SHELVES
;; ============================================================

(define (draw-shelf-segment-rectangle drawable image shelf segment side)
  (let*
    ((x1 (shelf-x1 shelf))
     (y1 (shelf-y1 shelf))
     (x2 (shelf-x2 shelf))
     (y2 (shelf-y2 shelf))
     (start (shelf-segment-start segment))
     (length (shelf-segment-length segment))
     (depth (shelf-segment-depth segment))
     (color (shelf-segment-color segment)))

    (gimp-context-set-foreground
      (list
        (line-color-r color)
        (line-color-g color)
        (line-color-b color)))

    ;; The current default shelf is vertical. For a vertical shelf,
    ;; the right side is +X and the left side is -X.
    (if (= x1 x2)
        (let*
          ((top-y (+ y1 start))
           (rect-y (py top-y))
           (rect-height (psize length))
           (center-x (px x1))
           (rect-width (psize depth))
           (rect-x
             (if (= side 1)
                 center-x
                 (- center-x rect-width))))

          (gimp-image-select-rectangle
            image
            CHANNEL-OP-REPLACE
            rect-x
            rect-y
            rect-width
            rect-height)

          (gimp-drawable-edit-fill
            drawable
            FILL-FOREGROUND)

          (gimp-selection-none image))

        ;; Horizontal shelf support, included so the datatype remains
        ;; reusable for shelves in either orientation.
        (let*
          ((left-x (+ x1 start))
           (rect-x (px left-x))
           (rect-width (psize length))
           (center-y (py y1))
           (rect-height (psize depth))
           (rect-y
             (if (= side 1)
                 (- center-y rect-height)
                 center-y)))

          (gimp-image-select-rectangle
            image
            CHANNEL-OP-REPLACE
            rect-x
            rect-y
            rect-width
            rect-height)

          (gimp-drawable-edit-fill
            drawable
            FILL-FOREGROUND)

          (gimp-selection-none image)))))


(define (draw-shelf-segments drawable image shelf segments)
  (if (null? segments)
      #t
      (let*
        ((segment (car segments)))

        ;; Every shelf segment is drawn on the right side.
        (draw-shelf-segment-rectangle
          drawable image shelf segment 1)

        ;; A two-sided shelf gets the mirrored rectangle as well.
        (if (= (shelf-side-count shelf) 2)
            (draw-shelf-segment-rectangle
              drawable image shelf segment 2)
            #t)

        (draw-shelf-segments
          drawable
          image
          shelf
          (cdr segments)))))


(define (draw-shelf drawable image shelf width)
  (let*
    ((color (shelf-color shelf))
     (segments (shelf-segments shelf))
     (x1 (shelf-x1 shelf))
     (y1 (shelf-y1 shelf))
     (x2 (shelf-x2 shelf))
     (y2 (shelf-y2 shelf)))

    ;; Shelf line.
    (gimp-context-set-foreground
      (list
        (line-color-r color)
        (line-color-g color)
        (line-color-b color)))

    (draw-straight-line
      drawable
      (px x1)
      (py y1)
      (px x2)
      (py y2)
      width)

    ;; Shelf segment rectangles.
    (draw-shelf-segments
      drawable
      image
      shelf
      segments)))


;; ============================================================
;; DRAW SPECTATOR POINT
;; ============================================================

(define (draw-spectator-point drawable)

  (gimp-context-set-foreground
    (list
      BLUE-R
      BLUE-G
      BLUE-B))

  (let*
    ((image
       (gimp-item-get-image drawable))

     ;; Scale the radius together with the rest of the drawing.
     (radius
       (psize BASE-SPECTATOR-RADIUS))

     ;; Convert the reference position to actual pixels.
     (center-x
       (px SPECTATOR-X))

     (center-y
       (py SPECTATOR-Y)))

    (gimp-image-select-ellipse
      image
      CHANNEL-OP-REPLACE
      (- center-x radius)
      (- center-y radius)
      (* 2 radius)
      (* 2 radius))

    (gimp-drawable-edit-fill
      drawable
      FILL-FOREGROUND)

    (gimp-selection-none
      image)))


;; ============================================================
;; MAIN
;; ============================================================

(define (script-fu-draw-building-outline)

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
         "Building Outline"
         IMAGE-WIDTH
         IMAGE-HEIGHT
         RGBA-IMAGE
         100
         LAYER-MODE-NORMAL))

     (green-line
       (make-line-color
         GREEN-R
         GREEN-G
         GREEN-B))

     (black-line
       (make-line-color
         BLACK-R
         BLACK-G
         BLACK-B))

     ;; Automatically scales with image size.
     (line-width
       (line-width-pixels)))


    ;; Add layer to image.
    (gimp-image-insert-layer
      image
      layer
      0
      0)


    ;; White background.
    (gimp-drawable-fill
      layer
      FILL-WHITE)


    ;; Reset GIMP context.
    (gimp-context-set-defaults)
    (gimp-context-set-default-colors)


    ;; --------------------------------------------------------
    ;; Draw all elements.
    ;; --------------------------------------------------------

    ;; Main black building outline.
    (draw-building-outline
      layer
      black-line)

    ;; Green warehouse boundary.
    (draw-warehouse
      layer
      green-line
      line-width)

    ;; Two elevator rectangles.
    (draw-elevators
      layer
      black-line
      line-width)

    ;; Default purple one-sided shelf, immediately right of the
    ;; right elevator, with two rectangles on its right side.
    (draw-shelf
      layer
      image
      DEFAULT-SHELF
      line-width)

    ;; Blue spectator marker.
    (draw-spectator-point
      layer)


    ;; Display the finished image.
    (gimp-display-new
      image)))


;; ============================================================
;; RUN
;; ============================================================

(script-fu-draw-building-outline)

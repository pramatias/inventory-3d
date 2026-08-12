#!/usr/bin/env gimp-script-fu-interpreter-3.0
;!#

;; ============================================================
;; CONFIGURATION
;; ============================================================

(define IMAGE-WIDTH  1080)
(define IMAGE-HEIGHT 1080)

;; ------------------------------------------------------------
;; Colors
;; ------------------------------------------------------------

(define GREEN-R 0)
(define GREEN-G 160)
(define GREEN-B 80)

(define BLACK-R 0)
(define BLACK-G 0)
(define BLACK-B 0)

;; Spectator marker, matching the blue "Είστε Εδώ" point
(define BLUE-R 0)
(define BLUE-G 70)
(define BLUE-B 180)

;; ------------------------------------------------------------
;; Relative line width
;; ------------------------------------------------------------

(define RELATIVE-LINE-WIDTH (/ 10.0 1080.0))

;; ============================================================
;; FLOOR PLAN GEOMETRY
;; ============================================================

;; ------------------------------------------------------------
;; Building outline
;;
;; A = (80,140)
;; B = (400,140)
;; C = (400,420)
;; D = (340,420)
;; G = (150,420)
;; I = (80,420)
;; ------------------------------------------------------------

(define BUILDING-OUTLINE
  (list

    ;; A -> B
    (list
      (/ 80.0  IMAGE-WIDTH)
      (/ 140.0 IMAGE-HEIGHT)
      (/ 400.0 IMAGE-WIDTH)
      (/ 140.0 IMAGE-HEIGHT))

    ;; B -> C
    (list
      (/ 400.0 IMAGE-WIDTH)
      (/ 140.0 IMAGE-HEIGHT)
      (/ 400.0 IMAGE-WIDTH)
      (/ 420.0 IMAGE-HEIGHT))

    ;; C -> D
    (list
      (/ 400.0 IMAGE-WIDTH)
      (/ 420.0 IMAGE-HEIGHT)
      (/ 340.0 IMAGE-WIDTH)
      (/ 420.0 IMAGE-HEIGHT))

    ;; G -> H
    (list
      (/ 150.0 IMAGE-WIDTH)
      (/ 420.0 IMAGE-HEIGHT)
      (/ 80.0 IMAGE-WIDTH)
      (/ 420.0 IMAGE-HEIGHT))

    ;; I -> A
    (list
      (/ 80.0 IMAGE-WIDTH)
      (/ 420.0 IMAGE-HEIGHT)
      (/ 80.0 IMAGE-WIDTH)
      (/ 140.0 IMAGE-HEIGHT))
  ))

;; ------------------------------------------------------------
;; Warehouse
;; ------------------------------------------------------------

(define WAREHOUSE-SEGMENTS
  (list

    ;; D -> E
    (list
      (/ 340.0 IMAGE-WIDTH)
      (/ 420.0 IMAGE-HEIGHT)
      (/ 340.0 IMAGE-WIDTH)
      (/ 510.0 IMAGE-HEIGHT))

    ;; E -> F
    (list
      (/ 340.0 IMAGE-WIDTH)
      (/ 510.0 IMAGE-HEIGHT)
      (/ 150.0 IMAGE-WIDTH)
      (/ 510.0 IMAGE-HEIGHT))

    ;; F -> G
    (list
      (/ 150.0 IMAGE-WIDTH)
      (/ 510.0 IMAGE-HEIGHT)
      (/ 150.0 IMAGE-WIDTH)
      (/ 420.0 IMAGE-HEIGHT))
  ))

;; ============================================================
;; TWO ELEVATORS
;;
;; Based on the printed plan:
;; - two elevator shafts side-by-side
;; - positioned near the upper-right portion of the building
;; - spectator point is directly below the right elevator
;;
;; Elevator 1:
;;   left   = 275
;;   right  = 325
;;   top    = 190
;;   bottom = 260
;;
;; Elevator 2:
;;   left   = 325
;;   right  = 375
;;   top    = 190
;;   bottom = 260
;; ============================================================

(define ELEVATOR-SEGMENTS
  (list

    ;; ----------------------------
    ;; Elevator 1 - left
    ;; ----------------------------

    ;; top
    (list
      (/ 275.0 IMAGE-WIDTH)
      (/ 190.0 IMAGE-HEIGHT)
      (/ 325.0 IMAGE-WIDTH)
      (/ 190.0 IMAGE-HEIGHT))

    ;; right
    (list
      (/ 325.0 IMAGE-WIDTH)
      (/ 190.0 IMAGE-HEIGHT)
      (/ 325.0 IMAGE-WIDTH)
      (/ 260.0 IMAGE-HEIGHT))

    ;; bottom
    (list
      (/ 325.0 IMAGE-WIDTH)
      (/ 260.0 IMAGE-HEIGHT)
      (/ 275.0 IMAGE-WIDTH)
      (/ 260.0 IMAGE-HEIGHT))

    ;; left
    (list
      (/ 275.0 IMAGE-WIDTH)
      (/ 260.0 IMAGE-HEIGHT)
      (/ 275.0 IMAGE-WIDTH)
      (/ 190.0 IMAGE-HEIGHT))


    ;; ----------------------------
    ;; Elevator 2 - right
    ;; ----------------------------

    ;; top
    (list
      (/ 325.0 IMAGE-WIDTH)
      (/ 190.0 IMAGE-HEIGHT)
      (/ 375.0 IMAGE-WIDTH)
      (/ 190.0 IMAGE-HEIGHT))

    ;; right
    (list
      (/ 375.0 IMAGE-WIDTH)
      (/ 190.0 IMAGE-HEIGHT)
      (/ 375.0 IMAGE-WIDTH)
      (/ 260.0 IMAGE-HEIGHT))

    ;; bottom
    (list
      (/ 375.0 IMAGE-WIDTH)
      (/ 260.0 IMAGE-HEIGHT)
      (/ 325.0 IMAGE-WIDTH)
      (/ 260.0 IMAGE-HEIGHT))

    ;; left / central dividing wall
    (list
      (/ 325.0 IMAGE-WIDTH)
      (/ 190.0 IMAGE-HEIGHT)
      (/ 325.0 IMAGE-WIDTH)
      (/ 260.0 IMAGE-HEIGHT))
  ))

;; ============================================================
;; ELEVATOR DOORS
;;
;; Small horizontal lines at the bottom of each elevator,
;; representing the elevator entrance.
;; ============================================================

(define ELEVATOR-DOOR-SEGMENTS
  (list

    ;; Left elevator door
    (list
      (/ 290.0 IMAGE-WIDTH)
      (/ 260.0 IMAGE-HEIGHT)
      (/ 310.0 IMAGE-WIDTH)
      (/ 260.0 IMAGE-HEIGHT))

    ;; Right elevator door
    (list
      (/ 340.0 IMAGE-WIDTH)
      (/ 260.0 IMAGE-HEIGHT)
      (/ 360.0 IMAGE-WIDTH)
      (/ 260.0 IMAGE-HEIGHT))
  ))

;; ============================================================
;; SPECTATOR / "YOU ARE HERE" POINT
;;
;; Positioned immediately below the right elevator, similar
;; to the blue point in the photographed floor plan.
;; ============================================================

(define SPECTATOR-X
  (/ 350.0 IMAGE-WIDTH))

(define SPECTATOR-Y
  (/ 275.0 IMAGE-HEIGHT))

;; Radius in pixels
(define SPECTATOR-RADIUS 12)

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
;; COORDINATE TRANSFORMATION
;; ============================================================

(define (px x)
  (* x IMAGE-WIDTH))

(define (py y)
  (* y IMAGE-HEIGHT))

(define (line-width-pixels)
  (* RELATIVE-LINE-WIDTH
     (min IMAGE-WIDTH IMAGE-HEIGHT)))

;; ============================================================
;; DRAWING
;; ============================================================

;; ------------------------------------------------------------
;; Draw one straight line
;; ------------------------------------------------------------

(define (draw-straight-line drawable x1 y1 x2 y2 width)

  (let* (
      (stroke
        (vector
          x1 y1
          x2 y2)))

    (gimp-context-set-brush-size width)

    (gimp-paintbrush-default
      drawable
      stroke)))

;; ------------------------------------------------------------
;; Draw segment list
;; ------------------------------------------------------------

(define (draw-segment-list drawable segments width)

  (if (null? segments)

      #t

      (let* (
          (s  (car segments))

          (x1 (list-ref s 0))
          (y1 (list-ref s 1))
          (x2 (list-ref s 2))
          (y2 (list-ref s 3)))

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

  ;; Elevator boxes
  (gimp-context-set-foreground
    (list
      (line-color-r color)
      (line-color-g color)
      (line-color-b color)))

  (draw-segment-list
    drawable
    ELEVATOR-SEGMENTS
    width)

  ;; Elevator doors
  (draw-segment-list
    drawable
    ELEVATOR-DOOR-SEGMENTS
    width))

;; ============================================================
;; DRAW SPECTATOR POINT
;; ============================================================

(define (draw-spectator-point drawable)

  (gimp-context-set-foreground
    (list
      BLUE-R
      BLUE-G
      BLUE-B))

  ;; Get the image directly from the drawable.
  (let ((image
          (gimp-item-get-image drawable)))

    ;; Draw a filled circle
    (gimp-image-select-ellipse
      image
      (- (px SPECTATOR-X) SPECTATOR-RADIUS)
      (- (py SPECTATOR-Y) SPECTATOR-RADIUS)
      (* 2 SPECTATOR-RADIUS)
      (* 2 SPECTATOR-RADIUS))

    (gimp-edit-fill
      drawable
      FILL-FOREGROUND)

    (gimp-selection-none
      image)))

;; ============================================================
;; MAIN
;; ============================================================

(define (script-fu-draw-building-outline)

  (script-fu-use-v3)

  (let* (

      ;; ------------------------------------------------------
      ;; Create image
      ;; ------------------------------------------------------

      (image
        (gimp-image-new
          IMAGE-WIDTH
          IMAGE-HEIGHT
          RGB))

      ;; ------------------------------------------------------
      ;; Create drawing layer
      ;; ------------------------------------------------------

      (layer
        (gimp-layer-new
          image
          "Building Outline"
          IMAGE-WIDTH
          IMAGE-HEIGHT
          RGBA-IMAGE
          100
          LAYER-MODE-NORMAL))

      ;; ------------------------------------------------------
      ;; Colors
      ;; ------------------------------------------------------

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

      ;; ------------------------------------------------------
      ;; Line width
      ;; ------------------------------------------------------

      (line-width
        (line-width-pixels))
    )

    ;; --------------------------------------------------------
    ;; Insert layer
    ;; --------------------------------------------------------

    (gimp-image-insert-layer
      image
      layer
      0
      0)

    ;; White background
    (gimp-drawable-fill
      layer
      FILL-WHITE)

    ;; Default settings
    (gimp-context-set-defaults)
    (gimp-context-set-default-colors)

    ;; --------------------------------------------------------
    ;; BUILDING
    ;; --------------------------------------------------------

    (draw-building-outline
      layer
      black-line
      line-width)

    ;; --------------------------------------------------------
    ;; WAREHOUSE
    ;; --------------------------------------------------------

    (draw-warehouse
      layer
      green-line
      line-width)

    ;; --------------------------------------------------------
    ;; TWO ELEVATORS
    ;; --------------------------------------------------------

    (draw-elevators
      layer
      black-line
      line-width)

    ;; --------------------------------------------------------
    ;; SPECTATOR POINT
    ;; --------------------------------------------------------

    (draw-spectator-point
      layer)

    ;; --------------------------------------------------------
    ;; Display
    ;; --------------------------------------------------------

    (gimp-display-new image)
  ))

;; ============================================================
;; RUN
;; ============================================================

(script-fu-draw-building-outline)

;; ------------------------------------------------------------
;; Draw building outline
;; ------------------------------------------------------------

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

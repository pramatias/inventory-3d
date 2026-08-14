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

(define BUILDING-OUTLINE
  (list
    ;; A -> B
    (list (/ 80.0 IMAGE-WIDTH) (/ 140.0 IMAGE-HEIGHT) (/ 400.0 IMAGE-WIDTH) (/ 140.0 IMAGE-HEIGHT))
    ;; B -> C
    (list (/ 400.0 IMAGE-WIDTH) (/ 140.0 IMAGE-HEIGHT) (/ 400.0 IMAGE-WIDTH) (/ 420.0 IMAGE-HEIGHT))
    ;; C -> D
    (list (/ 400.0 IMAGE-WIDTH) (/ 420.0 IMAGE-HEIGHT) (/ 340.0 IMAGE-WIDTH) (/ 420.0 IMAGE-HEIGHT))
    ;; G -> H
    (list (/ 150.0 IMAGE-WIDTH) (/ 420.0 IMAGE-HEIGHT) (/ 80.0 IMAGE-WIDTH) (/ 420.0 IMAGE-HEIGHT))
    ;; I -> A
    (list (/ 80.0 IMAGE-WIDTH) (/ 420.0 IMAGE-HEIGHT) (/ 80.0 IMAGE-WIDTH) (/ 140.0 IMAGE-HEIGHT))
  ))

(define WAREHOUSE-SEGMENTS
  (list
    ;; D -> E
    (list (/ 340.0 IMAGE-WIDTH) (/ 420.0 IMAGE-HEIGHT) (/ 340.0 IMAGE-WIDTH) (/ 510.0 IMAGE-HEIGHT))
    ;; E -> F
    (list (/ 340.0 IMAGE-WIDTH) (/ 510.0 IMAGE-HEIGHT) (/ 150.0 IMAGE-WIDTH) (/ 510.0 IMAGE-HEIGHT))
    ;; F -> G
    (list (/ 150.0 IMAGE-WIDTH) (/ 510.0 IMAGE-HEIGHT) (/ 150.0 IMAGE-WIDTH) (/ 420.0 IMAGE-HEIGHT))
  ))

;; ============================================================
;; TWO ELEVATORS (Vertical Rectangles)
;; ============================================================

(define ELEVATOR-CENTER-1-X 285.0)
(define ELEVATOR-CENTER-2-X 325.0)
(define ELEVATOR-CENTER-Y   385.0)

(define ELEVATOR-HALF-WIDTH  15.0)
(define ELEVATOR-HALF-HEIGHT 25.0)

(define ELEVATOR-SEGMENTS
  (list
    ;; ----------------------------
    ;; Elevator 1 - left
    ;; ----------------------------
    (list (/ (- ELEVATOR-CENTER-1-X ELEVATOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT)
          (/ (+ ELEVATOR-CENTER-1-X ELEVATOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT))

    (list (/ (+ ELEVATOR-CENTER-1-X ELEVATOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT)
          (/ (+ ELEVATOR-CENTER-1-X ELEVATOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT))

    (list (/ (+ ELEVATOR-CENTER-1-X ELEVATOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT)
          (/ (- ELEVATOR-CENTER-1-X ELEVATOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT))

    (list (/ (- ELEVATOR-CENTER-1-X ELEVATOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT)
          (/ (- ELEVATOR-CENTER-1-X ELEVATOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT))

    ;; ----------------------------
    ;; Elevator 2 - right
    ;; ----------------------------
    (list (/ (- ELEVATOR-CENTER-2-X ELEVATOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT)
          (/ (+ ELEVATOR-CENTER-2-X ELEVATOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT))

    (list (/ (+ ELEVATOR-CENTER-2-X ELEVATOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT)
          (/ (+ ELEVATOR-CENTER-2-X ELEVATOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT))

    (list (/ (+ ELEVATOR-CENTER-2-X ELEVATOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT)
          (/ (- ELEVATOR-CENTER-2-X ELEVATOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT))

    (list (/ (- ELEVATOR-CENTER-2-X ELEVATOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (- ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT)
          (/ (- ELEVATOR-CENTER-2-X ELEVATOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT))
  ))

;; ============================================================
;; ELEVATOR DOORS
;; ============================================================

(define ELEVATOR-DOOR-HALF-WIDTH 8.0)

(define ELEVATOR-DOOR-SEGMENTS
  (list
    ;; Left elevator door
    (list (/ (- ELEVATOR-CENTER-1-X ELEVATOR-DOOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT)
          (/ (+ ELEVATOR-CENTER-1-X ELEVATOR-DOOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT))

    ;; Right elevator door
    (list (/ (- ELEVATOR-CENTER-2-X ELEVATOR-DOOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT)
          (/ (+ ELEVATOR-CENTER-2-X ELEVATOR-DOOR-HALF-WIDTH) IMAGE-WIDTH)
          (/ (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT))
  ))

;; ============================================================
;; SPECTATOR / "YOU ARE HERE" POINT
;; ============================================================

(define SPECTATOR-X
  (/ 325.0 IMAGE-WIDTH))  ; Centered on right elevator

(define SPECTATOR-Y
  (/ (+ ELEVATOR-CENTER-Y ELEVATOR-HALF-HEIGHT) IMAGE-HEIGHT)) ; Positioned at elevator entrance threshold

(define SPECTATOR-RADIUS 12) ; Prominent circular marker

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

(define (draw-straight-line drawable x1 y1 x2 y2 width)
  (let* ((stroke (vector x1 y1 x2 y2)))
    (gimp-context-set-brush-size width)
    (gimp-paintbrush-default drawable stroke)))

(define (draw-segment-list drawable segments width)
  (if (null? segments)
      #t
      (let* ((s  (car segments))
             (x1 (list-ref s 0))
             (y1 (list-ref s 1))
             (x2 (list-ref s 2))
             (y2 (list-ref s 3)))
        (draw-straight-line drawable (px x1) (py y1) (px x2) (py y2) width)
        (draw-segment-list drawable (cdr segments) width))))

;; ============================================================
;; DRAW FUNCTIONS
;; ============================================================

(define (draw-warehouse drawable color width)
  (gimp-context-set-foreground
    (list (line-color-r color) (line-color-g color) (line-color-b color)))
  (draw-segment-list drawable WAREHOUSE-SEGMENTS width))

(define (draw-elevators drawable color width)
  (gimp-context-set-foreground
    (list (line-color-r color) (line-color-g color) (line-color-b color)))
  (draw-segment-list drawable ELEVATOR-SEGMENTS width)
  (draw-segment-list drawable ELEVATOR-DOOR-SEGMENTS width))

(define (draw-building-outline drawable black-color)
  (gimp-context-set-foreground
    (list (line-color-r black-color) (line-color-g black-color) (line-color-b black-color)))
  (draw-segment-list drawable BUILDING-OUTLINE (line-width-pixels)))

(define (draw-spectator-point drawable)
  (gimp-context-set-foreground (list BLUE-R BLUE-G BLUE-B))
  (let ((image (gimp-item-get-image drawable)))
    (gimp-image-select-ellipse
      image
      CHANNEL-OP-REPLACE
      (- (px SPECTATOR-X) SPECTATOR-RADIUS)
      (- (py SPECTATOR-Y) SPECTATOR-RADIUS)
      (* 2 SPECTATOR-RADIUS)
      (* 2 SPECTATOR-RADIUS))
    (gimp-drawable-edit-fill drawable FILL-FOREGROUND)
    (gimp-selection-none image)))

;; ============================================================
;; MAIN
;; ============================================================

(define (script-fu-draw-building-outline)
  (script-fu-use-v3)
  (let* ((image (gimp-image-new IMAGE-WIDTH IMAGE-HEIGHT RGB))
         (layer (gimp-layer-new image "Building Outline" IMAGE-WIDTH IMAGE-HEIGHT RGBA-IMAGE 100 LAYER-MODE-NORMAL))
         (green-line (make-line-color GREEN-R GREEN-G GREEN-B))
         (black-line (make-line-color BLACK-R BLACK-G BLACK-B))
         (line-width (line-width-pixels)))

    (gimp-image-insert-layer image layer 0 0)
    (gimp-drawable-fill layer FILL-WHITE)
    (gimp-context-set-defaults)
    (gimp-context-set-default-colors)

    (draw-building-outline layer black-line)
    (draw-warehouse layer green-line line-width)
    (draw-elevators layer black-line line-width)
    (draw-spectator-point layer)

    (gimp-display-new image)))

;; ============================================================
;; RUN
;; ============================================================

(script-fu-draw-building-outline)

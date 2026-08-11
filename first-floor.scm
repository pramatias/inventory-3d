#!/usr/bin/env gimp-script-fu-interpreter-3.0
;!#

;; ============================================================
;; CONFIGURATION
;; ============================================================

;; ------------------------------------------------------------
;; Canvas
;; ------------------------------------------------------------

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

;; ------------------------------------------------------------
;; Relative line width
;;
;; 0.009259 means:
;;   0.009259 * 1080 ≈ 10 pixels
;; ------------------------------------------------------------

(define RELATIVE-LINE-WIDTH (/ 10.0 1080.0))


;; ============================================================
;; FLOOR PLAN GEOMETRY
;;
;; All coordinates are normalized to the whole image:
;;
;;   X = 0.0  -> left edge
;;   X = 1.0  -> right edge
;;   Y = 0.0  -> top edge
;;   Y = 1.0  -> bottom edge
;;
;; Each segment is:
;;
;;   (x1 y1 x2 y2)
;;
;; This means the geometry is independent of image resolution.
;; ============================================================


;; ------------------------------------------------------------
;; Building outline
;;
;; Original coordinates:
;;
;; A = (80,  140)
;; B = (400, 140)
;; C = (400, 420)
;; D = (340, 420)
;; G = (150, 420)
;; I = (80,  420)
;;
;; Converted to normalized coordinates for 1080x1080.
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
      (/ 80.0  IMAGE-WIDTH)
      (/ 420.0 IMAGE-HEIGHT)
      (/ 80.0  IMAGE-WIDTH)
      (/ 140.0 IMAGE-HEIGHT))
  ))


;; ------------------------------------------------------------
;; Warehouse
;;
;; Original coordinates:
;;
;; D = (340, 420)
;; E = (340, 510)
;; F = (150, 510)
;; G = (150, 420)
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
      (/ 440.0 IMAGE-HEIGHT))

    ;; F -> G
    (list
      (/ 150.0 IMAGE-WIDTH)
      (/ 510.0 IMAGE-HEIGHT)
      (/ 150.0 IMAGE-WIDTH)
      (/ 420.0 IMAGE-HEIGHT))

    ;; D -> G
    (list
      (/ 340.0 IMAGE-WIDTH)
      (/ 420.0 IMAGE-HEIGHT)
      (/ 150.0 IMAGE-WIDTH)
      (/ 420.0 IMAGE-HEIGHT))
  ))


;; ------------------------------------------------------------
;; Warehouse definition
;; ------------------------------------------------------------

(define WAREHOUSE
  (list
    (list GREEN-R GREEN-G GREEN-B)
    WAREHOUSE-SEGMENTS))


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
;; WAREHOUSE DATATYPE
;; ============================================================

;; warehouse = (color segments)

(define (make-warehouse color segments)
  (list color segments))

(define (warehouse-color w)
  (list-ref w 0))

(define (warehouse-segments w)
  (list-ref w 1))


;; ============================================================
;; COORDINATE TRANSFORMATION
;; ============================================================

;; Convert a normalized X coordinate into a pixel coordinate.

(define (px x)
  (* x IMAGE-WIDTH))


;; Convert a normalized Y coordinate into a pixel coordinate.

(define (py y)
  (* y IMAGE-HEIGHT))


;; Convert relative line width into pixels.
;;
;; We use the smaller canvas dimension so that the line thickness
;; behaves sensibly even when width and height are different.

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
        x2 y2))
    )
    (gimp-context-set-brush-size width)
    (gimp-paintbrush-default drawable stroke)))


;; ------------------------------------------------------------
;; Draw a list of normalized segments
;; ------------------------------------------------------------

(define (draw-segment-list drawable segments width)

  (if (null? segments)

      #t

      (let* (
        (s  (car segments))

        (x1 (list-ref s 0))
        (y1 (list-ref s 1))
        (x2 (list-ref s 2))
        (y2 (list-ref s 3))
        )

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


;; ------------------------------------------------------------
;; Draw warehouse
;; ------------------------------------------------------------

(define (draw-warehouse drawable warehouse width)

  (let* (
    (color
      (warehouse-color warehouse))

    (segments
      (warehouse-segments warehouse))
    )

    (gimp-context-set-foreground
      (list
        (line-color-r color)
        (line-color-g color)
        (line-color-b color)))

    (draw-segment-list
      drawable
      segments
      width)))


;; ============================================================
;; MAIN
;; ============================================================

(define (script-fu-draw-building-outline)

  (script-fu-use-v3)

  (let* (

    ;; --------------------------------------------------------
    ;; Create image
    ;; --------------------------------------------------------

    (image
      (gimp-image-new
        IMAGE-WIDTH
        IMAGE-HEIGHT
        RGB))

    ;; --------------------------------------------------------
    ;; Create drawing layer
    ;; --------------------------------------------------------

    (layer
      (gimp-layer-new
        image
        "Building Outline"
        IMAGE-WIDTH
        IMAGE-HEIGHT
        RGBA-IMAGE
        100
        LAYER-MODE-NORMAL))

    ;; --------------------------------------------------------
    ;; Colors
    ;; --------------------------------------------------------

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

    ;; --------------------------------------------------------
    ;; Warehouse
    ;; --------------------------------------------------------

    (warehouse
      (make-warehouse
        green-line
        WAREHOUSE-SEGMENTS))

    ;; --------------------------------------------------------
    ;; Line width
    ;; --------------------------------------------------------

    (line-width
      (line-width-pixels))
    )


    ;; ========================================================
    ;; IMAGE INITIALIZATION
    ;; ========================================================

    (gimp-image-insert-layer
      image
      layer
      0
      0)

    ;; White background

    (gimp-drawable-fill
      layer
      FILL-WHITE)

    ;; Default GIMP settings

    (gimp-context-set-defaults)
    (gimp-context-set-default-colors)


    ;; ========================================================
    ;; DRAW
    ;; ========================================================

    ;; Building outline

    (draw-building-outline
      layer
      black-line)

    ;; Warehouse

    (draw-warehouse
      layer
      warehouse
      line-width)


    ;; ========================================================
    ;; DISPLAY
    ;; ========================================================

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

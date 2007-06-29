; XEmacs: This file contains -*-Scheme-*- source code.

;;; srfi-1-tests: a test suite for procedures in the SRFI-1
;;; library

;;; John David Stone
;;; Department of Mathematics and Computer Science
;;; Grinnell College
;;; stone@math.grin.edu

;;; created January 8, 1999
;;; last revised January 13, 1999


;; ChangeLog
;;
;; 2007-06-30 yamaken   - Imported from
;;                        http://www.math.grin.edu/~stone/srfi/srfi-1-tests.ss
;;                        and adapted to SigScheme and final SRFI-1

(use srfi-1)
(load "./test/unittest.scm")

(define *test-track-progress* #f)

;;; The DISPLAY-LINE procedure transmits a human-readable
;;; representation of each of its arguments to the standard
;;; output port and then terminates the output line.

(define display-line
  (lambda scribenda
    (for-each display scribenda)
    (newline)))

;;; The TEST syntax takes three subexpressions.  The value of
;;; the first should identify or describe the nature of the test
;;; to be conducted; it is typically a symbol or a serial
;;; number.  The second should be an expression embodying the
;;; test: the values of the expression are the results of the test.
;;; The value of the third subexpression of TEST should be a
;;; predicate that can be applied to the results of the
;;; test to determine whether it passes or fails.

;;(define-syntax test
;;  (syntax-rules ()
;;    ((test name trial criterion)
;;     (begin
;;       (display-line "----------------------------------------")
;;       (display-line "Test " name ":")
;;       (newline)
;;       (display-line 'trial)
;;       (newline)
;;       (display-line "-->")
;;       (newline)
;;       (call-with-values
;;         (lambda () trial)
;;         (lambda results
;;           (for-each display-line results)
;;           (newline)
;;           (if (apply criterion results)
;;               (display-line "Test " name " passed.")
;;               (display-line "*** Test " name " failed."))))
;;       (display-line "----------------------------------------")
;;       (newline)))))

;; Cannot receive multiple values as result.
(define test
  (lambda (name result criterion)
    (assert-true (symbol->string name) (criterion result))))

(define test/values
  (lambda (name trial criterion)
    (assert-true (symbol->string name)
                 (call-with-values
                     (lambda () (eval trial (interaction-environment)))
                   criterion))))

;;; Some procedures are defined for their side effects only.
;;; The EFFECT-ONLY-TEST syntax invokes such procedures, with
;;; the appropriate decorations in the style of TEST.  It takes
;;; three subexpressions.  The value of the first should
;;; identify or describe the nature of the test to be conducted.
;;; The second should be an expression embodying the test and
;;; performing the desired side effect.  It is up to the
;;; programmer to determine whether the test succeeded or
;;; failed; to assist her in this effort, the third
;;; subexpression of EFFECT-ONLY-TEST is also evaluated and its
;;; results displayed.

;;(define-syntax effect-only-test
;;  (syntax-rules ()
;;    ((effect-only-test name trial check)
;;     (begin
;;       (display-line "----------------------------------------")
;;       (display-line "Test " name ":")
;;       (newline)
;;       (display-line 'trial)
;;       (newline)
;;       trial
;;       (display-line "Test " name " completed.")
;;       (newline)
;;       (display-line "Value(s) of check expression:")
;;       (newline)
;;       (display-line 'check)
;;       (newline)
;;       (display-line "-->")
;;       (newline)
;;       (call-with-values
;;         (lambda () check)
;;         (lambda results
;;           (for-each display-line results)))
;;       (display-line "----------------------------------------")
;;       (newline)))))

;;; The tests of CIRCULAR-LIST should not attempt to display the 
;;; result of the test expression, since some Scheme
;;; implementations cannot print cyclic data structures.  The
;;; NON-PRINTING-TEST syntax is used for such tests.

;;(define-syntax non-printing-test
;;  (syntax-rules ()
;;    ((non-printing-test name trial criterion)
;;     (begin
;;       (display-line "----------------------------------------")
;;       (display-line "Test " name ":")
;;       (newline)
;;       (display-line 'trial)
;;       (newline)
;;       (call-with-values
;;         (lambda () trial)
;;         (lambda results
;;           (if (apply criterion results)
;;               (display-line "Test " name " passed.")
;;               (display-line "*** Test " name " failed."))))
;;       (display-line "----------------------------------------")
;;       (newline)))))

(define non-printing-test test)

;;; XCONS

(test 'xcons:null-cdr
  (xcons '() 'Andromeda)
  (lambda (result) (equal? result '(Andromeda))))

(let ((base '(Antlia)))
  (test 'xcons:pair-cdr
    (xcons base 'Apus)
    (lambda (result)
      (and (equal? result '(Apus Antlia))
           (eq? (cdr result) base)))))

(test 'xcons:datum-cdr
  (xcons 'Aquarius 'Aquila)
  (lambda (result) (equal? result '(Aquila . Aquarius))))

;;; TREE-COPY

;;(test 'tree-copy:null-tree
;;  (tree-copy '())
;;  null?)
;;
;;(let ((original 43/17))
;;  (test 'tree-copy:non-pair
;;    (tree-copy original)
;;    (lambda (result) (equal? result original))))
;;
;;(let ((original '(Ara Argo Aries Auriga Bootes)))
;;  (test 'tree-copy:flat-list
;;    (tree-copy original)
;;    (lambda (result)
;;      (and (equal? result original)
;;           (not (eq? result original))
;;           (not (eq? (cdr result) (cdr original)))
;;           (not (eq? (cddr result) (cddr original)))
;;           (not (eq? (cdddr result) (cdddr original)))
;;           (not (eq? (cddddr result) (cddddr original)))))))
;;
;;(let ((original '((Caelum)
;;                  (Camelopardis Cancer Capricorn
;;                   (Carina Cassiopeia)
;;                   ((Centaurus Cepheus Cetus)))
;;                  Chamaeleon)))
;;  (test 'tree-copy:bush
;;    (tree-copy original)
;;    (lambda (result)
;;      (and (equal? result original)
;;           (not (eq? result original))
;;           (not (eq? (car result) (car original)))
;;           (not (eq? (cdr result) (cdr original)))
;;           (not (eq? (cadr result) (cadr original)))
;;           (not (eq? (cddr result) (cddr original)))
;;           (not (eq? (cdadr result) (cdadr original)))
;;           (not (eq? (cddadr result) (cddadr original)))
;;           (not (eq? (cdr (cddadr result))
;;                     (cdr (cddadr original))))
;;           (not (eq? (cddr (cddadr result))
;;                     (cddr (cddadr original))))
;;           (not (eq? (cadr (cddadr result))
;;                     (cadr (cddadr original))))
;;           (not (eq? (cddr (cddadr result))
;;                     (cddr (cddadr original))))
;;           (not (eq? (caddr (cddadr result))
;;                     (caddr (cddadr original))))
;;           (not (eq? (caaddr (cddadr result))
;;                     (caaddr (cddadr original))))
;;           (not (eq? (cdr (caaddr (cddadr result)))
;;                     (cdr (caaddr (cddadr original)))))
;;           (not (eq? (cddr (caaddr (cddadr result)))
;;                     (cddr (caaddr (cddadr original)))))))))
;;
;;(let ((original '(Arcturus Canopus Sirius . Vega)))
;;  (test 'tree-copy:improper-list
;;    (tree-copy original)
;;    (lambda (result)
;;      (and (equal? result original)
;;           (not (eq? result original))
;;           (not (eq? (cdr result) (cdr original)))
;;           (not (eq? (cddr result) (cddr original)))))))

;;; MAKE-LIST

(test 'make-list:zero-length
  (make-list 0)
  null?)

(test 'make-list:default-element
  (make-list 5)
  (lambda (result) (equal? result '(#f #f #f #f #f))))

(test 'make-list:fill-element
  (make-list 7 'Circinus)
  (lambda (result)
    (equal? result '(Circinus Circinus Circinus Circinus
                     Circinus Circinus Circinus))))

;;; LIST-TABULATE

(test 'list-tabulate:zero-length
  (list-tabulate 0 (lambda (position) #f))
  null?)

(test 'list-tabulate:identity
  (list-tabulate 5 (lambda (position) position))
  (lambda (result)
    (equal? result '(0 1 2 3 4))))

(test 'list-tabulate:factorial
  (list-tabulate 7 (lambda (position)
                     (do ((multiplier 1 (+ multiplier 1))
                          (product 1 (* product multiplier)))
                         ((< position multiplier) product))))
  (lambda (result) (equal? result '(1 1 2 6 24 120 720))))

;;; CONS*

(test 'cons*:one-argument
  (cons* 'Columba)
  (lambda (result) (eq? result 'Columba)))

(test 'cons*:two-arguments
  (cons* 'Corvus 'Crater)
  (lambda (result) (equal? result '(Corvus . Crater))))

(test 'cons*:many-arguments
  (cons* 'Crux 'Cygnus 'Delphinus 'Dorado 'Draco)
  (lambda (result)
    (equal? result '(Crux Cygnus Delphinus Dorado . Draco))))

(test 'cons*:last-argument-null
  (cons* 'Equuleus 'Fornax '())
  (lambda (result) (equal? result '(Equuleus Fornax))))

(let ((base '(Gemini Grus)))
  (test 'cons*:last-argument-non-empty-list
    (cons* 'Hercules 'Horologium 'Hydra 'Hydrus base)
    (lambda (result)
      (and (equal? result '(Hercules Horologium Hydra Hydrus
                            Gemini Grus))
           (eq? (cddddr result) base)))))

;;; LIST-COPY

(test 'list-copy:null-list
  (list-copy '())
  null?)

(let ((original '(Indus Lacerta Leo Lepus Libra)))
  (test 'list-copy:flat-list
    (list-copy original)
    (lambda (result)
      (and (equal? result original)
           (not (eq? result original))
           (not (eq? (cdr result) (cdr original)))
           (not (eq? (cddr result) (cddr original)))
           (not (eq? (cdddr result) (cdddr original)))
           (not (eq? (cddddr result) (cddddr original)))))))

(let ((first '(Lupus))
      (second '(Lynx Malus Mensa (Microscopium Monoceros)
                     ((Musca Norma Octans))))
      (third 'Ophiuchus))
  (let ((original (list first second third)))
    (test 'list-copy:bush
      (list-copy original)
      (lambda (result)
        (and (equal? result original)
             (not (eq? result original))
             (eq? (car result) first)
             (not (eq? (cdr result) (cdr original)))
             (eq? (cadr result) second)
             (not (eq? (cddr result) (cddr original)))
             (eq? (caddr result) third))))))

;;;;; .IOTA
;;
;;(test '.iota:zero-count
;;  (.iota 0)
;;  null?)
;;
;;(test '.iota:upper-limit-only
;;  (.iota 5)
;;  (lambda (result) (equal? result '(0 1 2 3 4))))
;;
;;(test '.iota:non-integer-upper-limit
;;  (.iota 43/7)
;;  (lambda (result) (equal? result '(0 1 2 3 4 5 6))))
;;
;;(test '.iota:lower-and-upper-limits
;;  (.iota 1997 2004)
;;  (lambda (result)
;;    (equal? result '(1997 1998 1999 2000 2001 2002 2003))))
;;
;;(test '.iota:non-integer-lower-and-upper-limits
;;  (.iota -13/7 41/7)
;;  (lambda (result)
;;    (equal? result '(-13/7 -6/7 1/7 8/7 15/7 22/7 29/7 36/7))))
;;
;;(test '.iota:positive-step
;;  (.iota 1988 2008 4)
;;  (lambda (result) (equal? result '(1988 1992 1996 2000 2004)))) 
;;
;;(test '.iota:negative-step
;;  (.iota 3 -13 -3)
;;  (lambda (result) (equal? result '(3 0 -3 -6 -9 -12))))
;;
;;(test '.iota:non-integer-arguments
;;  (.iota 71/3 2297/100 -1/10)
;;  (lambda (result)
;;    (equal? result
;;            '(71/3 707/30 352/15 701/30 349/15 139/6 346/15))))
;;
;;;;; IOTA.
;;
;;(test 'iota.:zero-count
;;  (iota. 0)
;;  null?)
;;
;;(test 'iota.:upper-limit-only
;;  (iota. 5)
;;  (lambda (result) (equal? result '(1 2 3 4 5))))
;;
;;(test 'iota.:non-integer-upper-limit
;;  (iota. 43/7)
;;  (lambda (result) (equal? result '(1 2 3 4 5 6))))
;;
;;(test 'iota.:lower-and-upper-limits
;;  (iota. 1997 2004)
;;  (lambda (result)
;;    (equal? result '(1998 1999 2000 2001 2002 2003 2004))))
;;
;;(test 'iota.:non-integer-lower-and-upper-limits
;;  (iota. -13/7 41/7)
;;  (lambda (result)
;;    (equal? result '(-6/7 1/7 8/7 15/7 22/7 29/7 36/7))))
;;
;;(test 'iota.:positive-step
;;  (iota. 1988 2008 4)
;;  (lambda (result) (equal? result '(1992 1996 2000 2004 2008)))) 
;;
;;(test 'iota.:negative-step
;;  (iota. 3 -13 -3)
;;  (lambda (result) (equal? result '(0 -3 -6 -9 -12))))
;;
;;(test 'iota.:non-integer-arguments
;;  (iota. 71/3 2297/100 -1/10)
;;  (lambda (result)
;;    (equal? result
;;            '(707/30 352/15 701/30 349/15 139/6 346/15))))

;;; CIRCULAR-LIST

(non-printing-test 'circular-list:one-element
  (circular-list 'Orion)
  (lambda (result)
    (and (pair? result)
         (eq? (car result) 'Orion)
         (eq? (cdr result) result))))

(non-printing-test 'circular-list:many-elements
  (circular-list 'Pavo 'Pegasus 'Perseus 'Phoenix 'Pictor)
  (lambda (result)
    (and (pair? result)
         (eq? (car result) 'Pavo)
         (pair? (cdr result))
         (eq? (cadr result) 'Pegasus)
         (pair? (cddr result))
         (eq? (caddr result) 'Perseus)
         (pair? (cdddr result))
         (eq? (cadddr result) 'Phoenix)
         (pair? (cddddr result))
         (eq? (car (cddddr result)) 'Pictor)
         (eq? (cdr (cddddr result)) result))))

;;; ZIP

(test 'zip:all-lists-empty
  (zip '() '() '() '() '())
  null?)

(test 'zip:one-list
  (zip '(Pisces Puppis Reticulum))
  (lambda (result)
    (equal? result '((Pisces) (Puppis) (Reticulum)))))

(test 'zip:two-lists
  (zip '(Sagitta Sagittarius Scorpio Scutum Serpens)
       '(Sextans Taurus Telescopium Triangulum Tucana))
  (lambda (result)
    (equal? result '((Sagitta Sextans)
                     (Sagittarius Taurus)
                     (Scorpio Telescopium)
                     (Scutum Triangulum)
                     (Serpens Tucana)))))

(test 'zip:short-lists
  (zip '(Vela) '(Virgo) '(Volens) '(Vulpecula))
  (lambda (result)
    (equal? result '((Vela Virgo Volens Vulpecula)))))

(test 'zip:several-lists
  (zip '(actinium aluminum americium antimony argon)
       '(arsenic astatine barium berkeleium beryllium)
       '(bismuth boron bromine cadmium calcium)
       '(californium carbon cerium cesium chlorine)
       '(chromium cobalt copper curium dysprosium)
       '(einsteinium erbium europium fermium fluorine)
       '(francium gadolinium gallium germanium gold))
  (lambda (result)
    (equal? result '((actinium arsenic bismuth californium
                      chromium einsteinium francium)
                     (aluminum astatine boron carbon cobalt
                      erbium gadolinium)
                     (americium barium bromine cerium copper
                      europium gallium)
                     (antimony berkeleium cadmium cesium curium
                      fermium germanium)
                     (argon beryllium calcium chlorine
                      dysprosium fluorine gold)))))

;;; FIRST

(test 'first:of-one
  (first '(hafnium))
  (lambda (result) (eq? result 'hafnium)))

(test 'first:of-many
  (first '(hahnium helium holmium hydrogen indium))
  (lambda (result) (eq? result 'hahnium)))

;;; SECOND

(test 'second:of-two
  (second '(iodine iridium))
  (lambda (result) (eq? result 'iridium)))

(test 'second:of-many
  (second '(iron krypton lanthanum lawrencium lead lithium))
  (lambda (result) (eq? result 'krypton)))

;;; THIRD

(test 'third:of-three
  (third '(lutetium magnesium manganese))
  (lambda (result) (eq? result 'manganese)))

(test 'third:of-many
  (third '(mendelevium mercury molybdenum neodymium neon
                       neptunium nickel))
  (lambda (result) (eq? result 'molybdenum)))

;;; FOURTH

(test 'fourth:of-four
  (fourth '(niobium nitrogen nobelium osmium))
  (lambda (result) (eq? result 'osmium)))

(test 'fourth:of-many
  (fourth '(oxygen palladium phosphorus platinum plutonium
                   polonium potassium praseodymium))
  (lambda (result) (eq? result 'platinum)))

;;; FIFTH

(test 'fifth:of-five
  (fifth '(promethium protatctinium radium radon rhenium))
  (lambda (result) (eq? result 'rhenium)))

(test 'fifth:of-many
  (fifth '(rhodium rubidium ruthenium rutherfordium samarium
                   scandium selenium silicon silver))
  (lambda (result) (eq? result 'samarium)))

;;; SIXTH

(test 'sixth:of-six
  (sixth '(sodium strontium sulfur tantalum technetium
                  tellurium))
  (lambda (result) (eq? result 'tellurium)))

(test 'sixth:of-many
  (sixth '(terbium thallium thorium thulium tin titanium
                   tungsten uranium vanadium xenon))
  (lambda (result) (eq? result 'titanium)))

;;; SEVENTH

(test 'seventh:of-seven
  (seventh '(ytterbium yttrium zinc zirconium acacia abele
                       ailanthus))
  (lambda (result) (eq? result 'ailanthus)))

(test 'seventh:of-many
  (seventh '(alder allspice almond apple apricot ash aspen
                   avocado balsa balsam banyan))
  (lambda (result) (eq? result 'aspen)))

;;; EIGHTH

(test 'eighth:of-eight
  (eighth '(basswood bay bayberry beech birch boxwood breadfruit
                     buckeye))
  (lambda (result) (eq? result 'buckeye)))

(test 'eighth:of-many
  (eighth '(butternut buttonwood cacao candleberry cashew cassia 
                      catalpa cedar cherry chestnut chinaberry
                      chinquapin))
  (lambda (result) (eq? result 'cedar)))

;;; NINTH

(test 'ninth:of-nine
  (ninth '(cinnamon citron clove coconut cork cottonwood cypress 
                    date dogwood))
  (lambda (result) (eq? result 'dogwood)))

(test 'ninth:of-many
  (ninth '(ebony elder elm eucalyptus ficus fig fir frankincense 
                 ginkgo grapefruit guava gum hawthorn))
  (lambda (result) (eq? result 'ginkgo)))

;;; TENTH

(test 'tenth:of-ten
  (tenth '(hazel hemlock henna hickory holly hornbeam ironwood
                 juniper kumquat laburnum))
  (lambda (result) (eq? result 'laburnum)))

(test 'tenth:of-many
  (tenth '(lancewood larch laurel lemon lime linden litchi
                     locust logwood magnolia mahogany mango
                     mangrove maple))
  (lambda (result) (eq? result 'magnolia)))

;;; TAKE

(test 'take:all-of-list
  (take '(medlar mimosa mulberry nutmeg oak) 5)
  (lambda (result)
    (equal? result '(medlar mimosa mulberry nutmeg oak))))

(test 'take:front-of-list
  (take '(olive orange osier palm papaw peach pear) 5)
  (lambda (result)
    (equal? result '(olive orange osier palm papaw))))

(test 'take-right:rear-of-list
  (take-right '(pecan persimmon pine pistachio plane plum pomegranite) 
              5)
  (lambda (result)
    (equal? result '(pine pistachio plane plum pomegranite))))

(test 'take:none-of-list
  (take '(poplar quince redwood) 0)
  null?)

(test 'take:empty-list
  (take '() 0)
  null?)

;;; DROP

(test 'drop:all-of-list
  (drop '(rosewood sandalwood sassfras satinwood senna) 5)
  null?)

(test 'drop:front-of-list
  (drop '(sequoia serviceberry spruce sycamore tamarack tamarind 
                  tamarugo)
        5)
  (lambda (result) (equal? result '(tamarind tamarugo))))

(test 'drop-right:rear-of-list
  (drop-right '(tangerine teak thuja torchwood upas walnut wandoo) 5)
  (lambda (result) (equal? result '(tangerine teak))))

(test 'drop:none-of-list
  (drop '(whitebeam whitethorn wicopy) 0)
  (lambda (result)
    (equal? result '(whitebeam whitethorn wicopy))))

(test 'drop:empty-list
  (drop '() 0)
  null?)

;;; TAKE!

;;; List arguments to linear-update procedures are constructed
;;; with the LIST procedure rather than as quoted data, since in
;;; some implementations quoted data are not mutable.

(test 'take!:all-of-list
  (take! (list 'willow 'woollybutt 'wychelm 'yellowwood 'yew) 5) 
  (lambda (result)
    (equal? result '(willow woollybutt wychelm yellowwood yew))))

(test 'take!:front-of-list
  (take! (list 'ylang-ylang 'zebrawood 'affenpinscher 'afghan
               'airedale 'alsatian 'barbet)
         5)
  (lambda (result)
    (equal? result '(ylang-ylang zebrawood affenpinscher afghan
                                 airedale))))

;;(test 'take!:rear-of-list
;;  (take! (list 'basenji 'basset 'beagle 'bloodhound 'boarhound
;;               'borzoi 'boxer) 
;;        -5)
;;  (lambda (result)
;;    (equal? result '(beagle bloodhound boarhound borzoi
;;                            boxer))))

(test 'take!:none-of-list
  (take! (list 'briard 'bulldog 'chihuahua) 0)
  null?)

(test 'take!:empty-list
  (take! '() 0)
  null?)

;;; DROP!

;;(test 'drop!:all-of-list
;;  (drop! (list 'chow 'collie 'coonhound 'clydesdale 'dachshund)
;;         5)
;;  null?)
;;
;;(test 'drop!:front-of-list
;;  (drop! (list 'dalmatian 'deerhound 'doberman 'elkhound
;;               'foxhound 'greyhound 'griffon)
;;        5)
;;  (lambda (result) (equal? result '(greyhound griffon))))
;;
;;(test 'drop!:rear-of-list
;;  (drop! (list 'groenendael 'harrier 'hound 'husky 'keeshond
;;               'komondor 'kuvasz)
;;         -5)
;;  (lambda (result) (equal? result '(groenendael harrier))))
;;
;;(test 'drop!:none-of-list
;;  (drop! (list 'labrador 'malamute 'malinois) 0)
;;  (lambda (result)
;;    (equal? result '(labrador malamute malinois)))) 
;;
;;(test 'drop!:empty-list
;;  (drop! '() 0)
;;  null?)

;;; LAST

(test 'last:of-singleton
  (last '(maltese))
  (lambda (result) (eq? result 'maltese)))

(test 'last:of-longer-list
  (last '(mastiff newfoundland nizinny otterhound papillon))
  (lambda (result) (eq? result 'papillon)))

;;; LAST-PAIR

(let ((pair '(pekingese)))
  (test 'last-pair:of-singleton
    (last-pair pair)
    (lambda (result) (eq? result pair))))

(let ((pair '(pointer)))
  (test 'last-pair:of-longer-list
    (last-pair (cons 'pomeranian
                     (cons 'poodle
                           (cons 'pug (cons 'puli pair)))))
    (lambda (result) (eq? result pair))))

(let ((pair '(manx . siamese)))
  (test 'last-pair:of-improper-list
    (last-pair (cons 'abyssinian (cons 'calico pair)))
    (lambda (result) (eq? result pair))))

;;; UNZIP2

(test/values 'unzip2:empty-list-of-lists
  '(unzip2 '())
  (lambda (firsts seconds)
    (and (null? firsts) (null? seconds))))

(test/values 'unzip2:singleton-list-of-lists
  '(unzip2 '((retriever rottweiler)))
  (lambda (firsts seconds)
    (and (equal? firsts '(retriever))
         (equal? seconds '(rottweiler)))))

(test/values 'unzip2:longer-list-of-lists
  '(unzip2 '((saluki samoyed)
            (shipperke schnauzer)
            (setter shepherd)
            (skye spaniel)
            (spitz staghound)))
  (lambda (firsts seconds)
    (and (equal? firsts '(saluki shipperke setter skye spitz))
         (equal? seconds '(samoyed schnauzer shepherd spaniel
                                   staghound)))))

(test/values 'unzip2:lists-with-extra-elements
  '(unzip2 '((terrier turnspit vizsla wiemaraner)
            (whippet wolfhound)
            (bells bones bongo carillon celesta)
            (chimes clappers conga)))
  (lambda (firsts seconds)
    (and (equal? firsts '(terrier whippet bells chimes))
         (equal? seconds
                 '(turnspit wolfhound bones clappers)))))

;;; UNZIP3

(test/values 'unzip3:empty-list-of-lists
  '(unzip3 '())
  (lambda (firsts seconds thirds)
    (and (null? firsts) (null? seconds) (null? thirds))))

(test/values 'unzip3:singleton-list-of-lists
  '(unzip3 '((cymbals gamelan glockenspiel)))
  (lambda (firsts seconds thirds)
    (and (equal? firsts '(cymbals))
         (equal? seconds '(gamelan))
         (equal? thirds '(glockenspiel)))))

(test/values 'unzip3:longer-list-of-lists
  '(unzip3 '((gong handbells kettledrum)
            (lyra maraca marimba)
            (mbira membranophone metallophone)
            (nagara naker rattle)
            (sizzler snappers tabor)))
  (lambda (firsts seconds thirds)
    (and (equal? firsts '(gong lyra mbira nagara sizzler))
         (equal? seconds '(handbells maraca membranophone naker
                                     snappers))
         (equal? thirds '(kettledrum marimba metallophone rattle 
                                     tabor)))))

(test/values 'unzip3:lists-with-extra-elements
  '(unzip3 '((tambourine timbrel timpani tintinnabula tonitruone)
            (triangle vibraphone xylophone)
            (baccarat banker bezique bingo bridge canasta)
            (casino craps cribbage euchre)))
  (lambda (firsts seconds thirds)
    (and (equal? firsts '(tambourine triangle baccarat casino))
         (equal? seconds '(timbrel vibraphone banker craps))
         (equal? thirds
                 '(timpani xylophone bezique cribbage)))))

;;; UNZIP4

(test/values 'unzip4:empty-list-of-lists
  '(unzip4 '())
  (lambda (firsts seconds thirds fourths)
    (and (null? firsts)
         (null? seconds)
         (null? thirds)
         (null? fourths)))) 

(test/values 'unzip4:singleton-list-of-lists
  '(unzip4 '((fantan faro gin hazard)))
  (lambda (firsts seconds thirds fourths)
    (and (equal? firsts '(fantan))
         (equal? seconds '(faro))
         (equal? thirds '(gin))
         (equal? fourths '(hazard)))))

(test/values 'unzip4:longer-list-of-lists
  '(unzip4 '((hearts keno loo lottery)
            (lotto lowball monte numbers)
            (ombre picquet pinball pinochle)
            (poker policy quinze romesteq)
            (roulette rum rummy skat)))
  (lambda (firsts seconds thirds fourths)
    (and (equal? firsts '(hearts lotto ombre poker roulette))
         (equal? seconds '(keno lowball picquet policy rum))
         (equal? thirds '(loo monte pinball quinze rummy))
         (equal? fourths
                 '(lottery numbers pinochle romesteq skat)))))

(test/values 'unzip4:lists-with-extra-elements
  '(unzip4 '((adamant agate alexandrite amethyst aquamarine
                     beryl)
            (bloodstone brilliant carbuncle carnelian)
            (chalcedony chrysoberyl chrysolite chrysoprase
                        citrine coral demantoid)
            (diamond emerald garnet girasol heliotrope)))
  (lambda (firsts seconds thirds fourths)
    (and (equal? firsts '(adamant bloodstone chalcedony diamond)) 
         (equal? seconds '(agate brilliant chrysoberyl emerald))
         (equal? thirds
                 '(alexandrite carbuncle chrysolite garnet))
         (equal? fourths
                 '(amethyst carnelian chrysoprase girasol)))))

;;; UNZIP5

(test/values 'unzip5:empty-list-of-lists
  '(unzip5 '())
  (lambda (firsts seconds thirds fourths fifths)
    (and (null? firsts)
         (null? seconds)
         (null? thirds)
         (null? fourths)
         (null? fifths))))

(test/values 'unzip5:singleton-list-of-lists
  '(unzip5 '((hyacinth jacinth jade jargoon jasper)))
  (lambda (firsts seconds thirds fourths fifths)
    (and (equal? firsts '(hyacinth))
         (equal? seconds '(jacinth))
         (equal? thirds '(jade))
         (equal? fourths '(jargoon))
         (equal? fifths '(jasper)))))

(test/values 'unzip5:longer-list-of-lists
  '(unzip5 '((kunzite moonstone morganite onyx opal)
            (peridot plasma ruby sapphire sard)
            (sardonyx spinel star sunstone topaz)
            (tourmaline turquoise zircon Argus basilisk)
            (Bigfoot Briareus bucentur Cacus Caliban)))
  (lambda (firsts seconds thirds fourths fifths)
    (and (equal? firsts
                 '(kunzite peridot sardonyx tourmaline Bigfoot)) 
         (equal? seconds
                 '(moonstone plasma spinel turquoise Briareus))
         (equal? thirds '(morganite ruby star zircon bucentur))
         (equal? fourths '(onyx sapphire sunstone Argus Cacus))
         (equal? fifths '(opal sard topaz basilisk Caliban)))))

(test/values 'unzip5:lists-with-extra-elements
  '(unzip5 '((centaur Cerberus Ceto Charybdis chimera cockatrice
                     Cyclops)
            (dipsas dragon drake Echidna Geryon)
            (Gigantes Gorgon Grendel griffin Harpy hippocampus
                      hippocentaur hippocerf)
            (hirocervus Hydra Kraken Ladon manticore Medusa)))
  (lambda (firsts seconds thirds fourths fifths)
    (and (equal? firsts '(centaur dipsas Gigantes hirocervus)) 
         (equal? seconds '(Cerberus dragon Gorgon Hydra))
         (equal? thirds '(Ceto drake Grendel Kraken))
         (equal? fourths '(Charybdis Echidna griffin Ladon))
         (equal? fifths '(chimera Geryon Harpy manticore)))))

;;; APPEND!

(test 'append!:no-arguments
  (append!)
  null?)

(test 'append!:one-argument
  (append! (list 'mermaid 'merman 'Minotaur))
  (lambda (result)
    (equal? result '(mermaid merman Minotaur))))

(test 'append!:several-arguments
  (append! (list 'nixie 'ogre 'ogress 'opinicus)
           (list 'Orthos)
           (list 'Pegasus 'Python)
           (list 'roc 'Sagittary 'salamander 'Sasquatch 'satyr)
           (list 'Scylla 'simurgh 'siren))
  (lambda (result)
    (equal? result '(nixie ogre ogress opinicus Orthos Pegasus
                     Python roc Sagittary salamander Sasquatch
                     satyr Scylla simurgh siren))))

(test 'append!:some-null-arguments
  (append! (list) (list) (list 'Sphinx 'Talos 'troll) (list)
           (list 'Typhoeus) (list) (list) (list))
  (lambda (result)
    (equal? result '(Sphinx Talos troll Typhoeus))))

(test 'append!:all-null-arguments
  (append! (list) (list) (list) (list) (list))
  null?)

;;; APPEND-REVERSE

(test 'append-reverse:first-argument-null
  (append-reverse '() '(Typhon unicorn vampire werewolf))
  (lambda (result)
    (equal? result '(Typhon unicorn vampire werewolf))))

(test 'append-reverse:second-argument-null
  (append-reverse '(windigo wivern xiphopagus yeti zombie) '())
  (lambda (result)
    (equal? result '(zombie yeti xiphopagus wivern windigo))))

(test 'append-reverse:both-arguments-null
  (append-reverse '() '())
  null?)

(test 'append-reverse:neither-argument-null
  (append-reverse '(Afghanistan Albania Algeria Andorra)
                  '(Angola Argentina Armenia))
  (lambda (result)
    (equal? result '(Andorra Algeria Albania Afghanistan Angola
                     Argentina Armenia))))

;;; APPEND-REVERSE!

(test 'append-reverse!:first-argument-null
  (append-reverse! (list)
                   (list 'Australia 'Austria 'Azerbaijan))
  (lambda (result)
    (equal? result '(Australia Austria Azerbaijan))))

(test 'append-reverse!:second-argument-null
  (append-reverse! (list 'Bahrain 'Bangladesh 'Barbados
                         'Belarus 'Belgium)
                   (list))
  (lambda (result)
    (equal? result
            '(Belgium Belarus Barbados Bangladesh Bahrain))))

(test 'append-reverse!:both-arguments-null
  (append-reverse! (list) (list))
  null?)

(test 'append-reverse!:neither-argument-null
  (append-reverse! (list 'Belize 'Benin 'Bhutan 'Bolivia)
                   (list 'Bosnia 'Botswana 'Brazil))
  (lambda (result)
    (equal? result '(Bolivia Bhutan Benin Belize Bosnia Botswana 
                     Brazil))))

;;; REVERSE!

(test 'reverse!:empty-list
  (reverse! (list))
  null?)

(test 'reverse!:singleton-list
  (reverse! (list 'Brunei))
  (lambda (result)
    (equal? result '(Brunei))))

(test 'reverse!:longer-list
  (reverse! (list 'Bulgaria 'Burundi 'Cambodia 'Cameroon
                  'Canada))
  (lambda (result)
    (equal? result
            '(Canada Cameroon Cambodia Burundi Bulgaria))))

;;; UNFOLD

(test 'unfold:predicate-always-satisfied
  (unfold (lambda (seed) #t)
          (lambda (seed) (* seed 2))
          (lambda (seed) (* seed 3))
          1)
  null?)

(test 'unfold:normal-case
  (unfold (lambda (seed) (= seed 729))
          (lambda (seed) (* seed 2))
          (lambda (seed) (* seed 3))
          1)
  (lambda (result) (equal? result '(2 6 18 54 162 486))))

;;; UNFOLD/TAIL

;;(test 'unfold/tail:predicate-always-satisfied
;;  (unfold/tail (lambda (seed) #t)
;;               (lambda (seed) (* seed 2))
;;               (lambda (seed) (* seed 3))
;;               (lambda (seed) (* seed 5))
;;               1)
;;  (lambda (result) (equal? result 5)))
;;
;;(test 'unfold/tail:normal-case
;;  (unfold/tail (lambda (seed) (= seed 729))
;;               (lambda (seed) (* seed 2))
;;               (lambda (seed) (* seed 3))
;;               (lambda (seed) (* seed 5))
;;               1)
;;  (lambda (result) (equal? result '(2 6 18 54 162 486 . 3645)))) 

;;; FOLD

(test 'fold:one-null-list
  (fold (lambda (alpha beta) (* alpha (+ beta 1))) 13 '())
  (lambda (result) (= result 13)))

(test 'fold:one-singleton-list
  (fold (lambda (alpha beta) (* alpha (+ beta 1))) 13 '(15))
  (lambda (result) (= result 210)))

(test 'fold:one-longer-list
  (fold (lambda (alpha beta) (* alpha (+ beta 1)))
         13
         '(15 17 19 21 23))
  (lambda (result) (= result 32927582)))

(test 'fold:several-null-lists
  (fold vector 'Chad '() '() '() '() '())
  (lambda (result) (eq? result 'Chad)))

(test 'fold:several-singleton-lists
  (fold vector 'Chile '(China) '(Colombia) '(Comoros) '(Congo)
         '(Croatia))
  (lambda (result)
    (equal? result
            '#(China Colombia Comoros Congo Croatia Chile))))

(test 'fold:several-longer-lists
  (fold (lambda (alpha beta gamma delta epsilon zeta)
           (cons (vector alpha beta gamma delta epsilon) zeta))
         '()
         '(Cuba Cyprus Denmark Djibouti Dominica Ecuador Egypt)
         '(Eritrea Estonia Ethiopia Fiji Finland France Gabon)
         '(Gambia Georgia Germany Ghana Greece Grenada
                  Guatemala)
         '(Guinea Guyana Haiti Honduras Hungary Iceland India)
         '(Indonesia Iran Iraq Ireland Israel Italy Jamaica))
  (lambda (result)
    (equal? result
            '(#(Egypt Gabon Guatemala India Jamaica)
              #(Ecuador France Grenada Iceland Italy)
              #(Dominica Finland Greece Hungary Israel)
              #(Djibouti Fiji Ghana Honduras Ireland)
              #(Denmark Ethiopia Germany Haiti Iraq)
              #(Cyprus Estonia Georgia Guyana Iran)
              #(Cuba Eritrea Gambia Guinea Indonesia)))))

(test 'fold:lists-of-different-lengths
  (fold (lambda (alpha beta gamma delta)
           (cons (vector alpha beta gamma) delta))
         '()
         '(Japan Jordan Kazakhstan Kenya)
         '(Kiribati Kuwait)
         '(Kyrgyzstan Laos Latvia))
  (lambda (result)
    (equal? result '(#(Jordan Kuwait Laos)
                     #(Japan Kiribati Kyrgyzstan)))))

;;; FOLD-RIGHT

(test 'fold-right:one-null-list
  (fold-right (lambda (alpha beta) (* alpha (+ beta 1))) 13 '())
  (lambda (result) (= result 13)))

(test 'fold-right:one-singleton-list
  (fold-right (lambda (alpha beta) (* alpha (+ beta 1))) 13 '(15))
  (lambda (result) (= result 210)))

(test 'fold-right:one-longer-list
  (fold-right (lambda (alpha beta) (* alpha (+ beta 1)))
         13
         '(15 17 19 21 23))
  (lambda (result) (= result 32868750)))

(test 'fold-right:several-null-lists
  (fold-right vector 'Lebanon '() '() '() '() '())
  (lambda (result) (eq? result 'Lebanon)))

(test 'fold-right:several-singleton-lists
  (fold-right vector 'Lesotho '(Liberia) '(Libya) '(Liechtenstein)
         '(Lithuania) '(Luxembourg))
  (lambda (result)
    (equal? result '#(Liberia Libya Liechtenstein Lithuania
                             Luxembourg Lesotho))))

(test 'fold-right:several-longer-lists
  (fold-right (lambda (alpha beta gamma delta epsilon zeta)
           (cons (vector alpha beta gamma delta epsilon) zeta))
         '()
         '(Macedonia Madagascar Malawi Malaysia Maldives Mali
                     Malta)
         '(Mauritania Mauritius Mexico Micronesia Moldova Monaco 
                      Mongolia)
         '(Morocco Mozambique Myanmar Namibia Nauru Nepal
                   Netherlands)
         '(Nicaragua Niger Nigeria Norway Oman Pakistan Palau)
         '(Panama Paraguay Peru Philippines Poland Portugal
                  Qatar))
  (lambda (result)
    (equal? result
            '(#(Macedonia Mauritania Morocco Nicaragua Panama)
              #(Madagascar Mauritius Mozambique Niger Paraguay)
              #(Malawi Mexico Myanmar Nigeria Peru)
              #(Malaysia Micronesia Namibia Norway Philippines)
              #(Maldives Moldova Nauru Oman Poland)
              #(Mali Monaco Nepal Pakistan Portugal)
              #(Malta Mongolia Netherlands Palau Qatar)))))

(test 'fold-right:lists-of-different-lengths
  (fold-right (lambda (alpha beta gamma delta)
           (cons (vector alpha beta gamma) delta))
         '()
         '(Romania Russia Rwanda Senegal)
         '(Seychelles Singapore)
         '(Slovakia Slovenia Somalia))
  (lambda (result)
    (equal? result '(#(Romania Seychelles Slovakia)
                     #(Russia Singapore Slovenia)))))

;;; PAIR-FOLD

(let* ((revappend (lambda (reversend base)
                    (do ((rest reversend (cdr rest))
                         (result base (cons (car rest) result)))
                        ((null? rest) result))))
       (revappall (lambda (first . rest)
                    (let loop ((first first) (rest rest))
                      (if (null? rest)
                          first
                          (revappend first
                                     (loop (car rest)
                                           (cdr rest))))))))

  (test 'pair-fold:one-null-list
    (pair-fold revappend '(Spain Sudan) '())
    (lambda (result) (equal? result '(Spain Sudan))))

  (test 'pair-fold:one-singleton-list
    (pair-fold revappend '(Suriname Swaziland) '(Sweden))
    (lambda (result)
      (equal? result '(Sweden Suriname Swaziland)))) 

  (test 'pair-fold:one-longer-list
    (pair-fold revappend
                '(Switzerland Syria)
                '(Taiwan Tajikistan Tanzania Thailand Togo))
    (lambda (result)
      (equal? result
              '(Togo Togo Thailand Togo Thailand Tanzania Togo
                Thailand Tanzania Tajikistan Togo Thailand
                Tanzania Tajikistan Taiwan Switzerland Syria))))

  (test 'pair-fold:several-null-lists
    (pair-fold revappall '(Tonga Tunisia) '() '() '() '() '())
    (lambda (result) (equal? result '(Tonga Tunisia))))

  (test 'pair-fold:several-singleton-lists
    (pair-fold revappall
                '(Turkey Turkmenistan)
                '(Tuvalu)
                '(Uganda)
                '(Ukraine)
                '(Uruguay)
                '(Uzbekistan))
    (lambda (result)
      (equal? result
              '(Tuvalu Uganda Ukraine Uruguay Uzbekistan Turkey 
                Turkmenistan))))

  (test 'pair-fold:several-longer-lists
    (pair-fold revappall
                '(Vanuatu Venezuela)
                '(Vietnam Yemen Yugoslavia Zaire Zambia Zimbabwe
                  Agnon) 
                '(Aleixandre Andric Asturias Beckett Bellow
                  Benavente Bergson)
                '(Bjornson Brodsky Buck Bunin Camus Canetti
                  Carducci)
                '(Cela Churchill Deledda Echegary Eliot Elytis
                  Eucken)
                '(Faulkner Galsworthy Gide Gjellerup Golding
                  Gordimer Hamsun))
    (lambda (result)
      (equal? result
              '(Agnon Bergson Carducci Eucken Hamsun Agnon
                Zimbabwe Bergson Benavente Carducci Canetti
                Eucken Elytis Hamsun Gordimer Agnon Zimbabwe
                Zambia Bergson Benavente Bellow Carducci Canetti
                Camus Eucken Elytis Eliot Hamsun Gordimer
                Golding Agnon Zimbabwe Zambia Zaire Bergson
                Benavente Bellow Beckett Carducci Canetti Camus
                Bunin Eucken Elytis Eliot Echegary Hamsun
                Gordimer Golding Gjellerup Agnon Zimbabwe Zambia
                Zaire Yugoslavia Bergson Benavente Bellow
                Beckett Asturias Carducci Canetti Camus Bunin
                Buck Eucken Elytis Eliot Echegary Deledda Hamsun
                Gordimer Golding Gjellerup Gide Agnon Zimbabwe
                Zambia Zaire Yugoslavia Yemen Bergson Benavente
                Bellow Beckett Asturias Andric Carducci Canetti
                Camus Bunin Buck Brodsky Eucken Elytis Eliot
                Echegary Deledda Churchill Hamsun Gordimer
                Golding Gjellerup Gide Galsworthy Agnon Zimbabwe
                Zambia Zaire Yugoslavia Yemen Vietnam Bergson
                Benavente Bellow Beckett Asturias Andric
                Aleixandre Carducci Canetti Camus Bunin Buck
                Brodsky Bjornson Eucken Elytis Eliot Echegary
                Deledda Churchill Cela Hamsun Gordimer Golding
                Gjellerup Gide Galsworthy Faulkner Vanuatu
                Venezuela))))

  (test 'pair-fold:lists-of-different-lengths
    (pair-fold revappall
                '(Hauptmann Hemingway Hesse)
                '(Heyse Jensen Jimenez Johnson)
                '(Karlfeldt Kawabata)
                '(Kipling Lagerkvist Lagerlof Laxness Lewis))
    (lambda (result)
      (equal? result
              '(Johnson Jimenez Jensen Kawabata Lewis Laxness
                Lagerlof Lagerkvist Johnson Jimenez Jensen Heyse
                Kawabata Karlfeldt Lewis Laxness Lagerlof
                Lagerkvist Kipling Hauptmann Hemingway
                Hesse)))))

;;; PAIR-FOLD-RIGHT

(let* ((revappend (lambda (reversend base)
                    (do ((rest reversend (cdr rest))
                         (result base (cons (car rest) result)))
                        ((null? rest) result))))
       (revappall (lambda (first . rest)
                    (let loop ((first first) (rest rest))
                      (if (null? rest)
                          first
                          (revappend first
                                     (loop (car rest)
                                           (cdr rest))))))))

  (test 'pair-fold-right:one-null-list
    (pair-fold-right revappend '(Maeterlinck Mahfouz) '())
    (lambda (result) (equal? result '(Maeterlinck Mahfouz))))

  (test 'pair-fold-right:one-singleton-list
    (pair-fold-right revappend '(Mann Martinson) '(Mauriac))
    (lambda (result)
      (equal? result '(Mauriac Mann Martinson)))) 

  (test 'pair-fold-right:one-longer-list
    (pair-fold-right revappend
                '(Milosz Mistral)
                '(Mommsen Montale Morrison Neruda Oe))
    (lambda (result)
      (equal? result
              '(Oe Neruda Morrison Montale Mommsen Oe Neruda
                Morrison Montale Oe Neruda Morrison Oe Neruda Oe 
                Milosz Mistral))))

  (test 'pair-fold-right:several-null-lists
    (pair-fold-right revappall '(Pasternak Paz) '() '() '() '() '())
    (lambda (result) (equal? result '(Pasternak Paz))))

  (test 'pair-fold-right:several-singleton-lists
    (pair-fold-right revappall
                '(Perse Pirandello)
                '(Pontoppidan)
                '(Quasimodo)
                '(Reymont)
                '(Rolland)
                '(Russell))
    (lambda (result)
      (equal? result
              '(Pontoppidan Quasimodo Reymont Rolland Russell
                Perse Pirandello))))

  (test 'pair-fold-right:several-longer-lists
    (pair-fold-right revappall
                '(Sachs Sartre)
                '(Seferis Shaw Sholokov Siefert Sienkiewicz
                  Sillanpaa Simon)
                '(Singer Solzhenitsyn Soyinka Spitteler
                  Steinbeck Tagore Undset)
                '(Walcott White Yeats Anderson Andrews Angelina
                  Aransas)
                '(Archer Armstrong Alascosa Austin Bailey
                  Bandera Bastrop)
                '(Baylor Bee Bell Bexar Blanco Borden Bosque
                  Bowie))
    (lambda (result)
      (equal? result
              '(Simon Sillanpaa Sienkiewicz Siefert Sholokov
                Shaw Seferis Undset Tagore Steinbeck Spitteler
                Soyinka Solzhenitsyn Singer Aransas Angelina
                Andrews Anderson Yeats White Walcott Bastrop
                Bandera Bailey Austin Alascosa Armstrong Archer
                Bowie Bosque Borden Blanco Bexar Bell Bee Baylor 
                Simon Sillanpaa Sienkiewicz Siefert Sholokov
                Shaw Undset Tagore Steinbeck Spitteler Soyinka
                Solzhenitsyn Aransas Angelina Andrews Anderson
                Yeats White Bastrop Bandera Bailey Austin
                Alascosa Armstrong Bowie Bosque Borden Blanco
                Bexar Bell Bee Simon Sillanpaa Sienkiewicz
                Siefert Sholokov Undset Tagore Steinbeck
                Spitteler Soyinka Aransas Angelina Andrews
                Anderson Yeats Bastrop Bandera Bailey Austin
                Alascosa Bowie Bosque Borden Blanco Bexar Bell
                Simon Sillanpaa Sienkiewicz Siefert Undset
                Tagore Steinbeck Spitteler Aransas Angelina
                Andrews Anderson Bastrop Bandera Bailey Austin
                Bowie Bosque Borden Blanco Bexar Simon Sillanpaa
                Sienkiewicz Undset Tagore Steinbeck Aransas
                Angelina Andrews Bastrop Bandera Bailey Bowie
                Bosque Borden Blanco Simon Sillanpaa Undset
                Tagore Aransas Angelina Bastrop Bandera Bowie
                Bosque Borden Simon Undset Aransas Bastrop Bowie
                Bosque Sachs Sartre)))) 

  (test 'pair-fold-right:lists-of-different-lengths
    (pair-fold-right revappall
                '(Brazoria Brazos Brewster)
                '(Briscoe Brooks Brown Burleson)
                '(Burnet Caldwell)
                '(Calhoun Callahan Cameron Camp Carson))
    (lambda (result)
      (equal? result
              '(Burleson Brown Brooks Briscoe Caldwell Burnet
                Carson Camp Cameron Callahan Calhoun Burleson
                Brown Brooks Caldwell Carson Camp Cameron
                Callahan Brazoria Brazos Brewster)))))

;;; REDUCE

(test 'reduce:null-list
  (reduce (lambda (alpha beta) (* alpha (+ beta 1))) 0 '())
  zero?)

(test 'reduce:singleton-list
  (reduce (lambda (alpha beta) (* alpha (+ beta 1))) 0 '(25))
  (lambda (result) (= result 25)))

(test 'reduce:doubleton-list
  (reduce (lambda (alpha beta) (* alpha (+ beta 1)))
           0
           '(27 29))
  (lambda (result) (= result 812)))

;;; Fixnum overflow on SigScheme storage-compact
;;(test 'reduce:longer-list
;;  (reduce (lambda (alpha beta) (* alpha (+ beta 1)))
;;           0
;;           '(31 33 35 37 39 41 43))
;;  (lambda (result) (= result 94118227527)))

;;; REDUCE-RIGHT

(test 'reduce-right:null-list
  (reduce-right (lambda (alpha beta) (* alpha (+ beta 1))) 0 '())
  zero?)

(test 'reduce-right:singleton-list
  (reduce-right (lambda (alpha beta) (* alpha (+ beta 1))) 0 '(25))
  (lambda (result) (= result 25)))

(test 'reduce-right:doubleton-list
  (reduce-right (lambda (alpha beta) (* alpha (+ beta 1)))
           0
           '(27 29))
  (lambda (result) (= result 810)))

;;; Fixnum overflow on SigScheme storage-compact
;;(test 'reduce-right:longer-list
;;  (reduce-right (lambda (alpha beta) (* alpha (+ beta 1)))
;;           0
;;           '(31 33 35 37 39 41 43))
;;  (lambda (result) (= result 93259601719)))

;;; APPEND-MAP

(test 'append-map:one-null-list
  (append-map (lambda (element) (list element element)) '())
  null?)

(test 'append-map:one-singleton-list
  (append-map (lambda (element) (list element element)) '(Cass))
  (lambda (result) (equal? result '(Cass Cass))))

(test 'append-map:one-longer-list
  (append-map (lambda (element) (list element element))
              '(Castro Chambers Cherokee Childress Clay))
  (lambda (result)
    (equal? result
            '(Castro Castro Chambers Chambers Cherokee Cherokee
              Childress Childress Clay Clay))))

(test 'append-map:several-null-lists
  (append-map (lambda elements (reverse elements))
              '() '() '() '() '())
  null?)

(test 'append-map:several-singleton-lists
  (append-map (lambda elements (reverse elements))
              '(Cochran)
              '(Coke)
              '(Coleman)
              '(Collin)
              '(Collingsworth))
  (lambda (result)
    (equal? result
            '(Collingsworth Collin Coleman Coke Cochran))))

(test 'append-map:several-longer-lists
  (append-map (lambda elements (reverse elements))
              '(Colorado Comal Comanche Concho Cooke Coryell
                Cottle)
              '(Crane Crockett Crosby Culberson Dallam Dallas
                Dawson)
              '(Delta Denton Dewitt Dickens Dimmit Donley Duval) 
              '(Eastland Ector Edwards Ellis Erath Falls Fannin)
              '(Fayette Fisher Floyd Foard Franklin Freestone
                Frio))
  (lambda (result)
    (equal? result
            '(Fayette Eastland Delta Crane Colorado Fisher Ector 
              Denton Crockett Comal Floyd Edwards Dewitt Crosby
              Comanche Foard Ellis Dickens Culberson Concho
              Franklin Erath Dimmit Dallam Cooke Freestone Falls 
              Donley Dallas Coryell Frio Fannin Duval Dawson
              Cottle))))

;;; APPEND-MAP!

(test 'append-map!:one-null-list
  (append-map! (lambda (element) (list element element))
               (list))
  null?)

(test 'append-map!:one-singleton-list
  (append-map! (lambda (element) (list element element))
               (list 'Gaines))
  (lambda (result) (equal? result '(Gaines Gaines))))

(test 'append-map!:one-longer-list
  (append-map! (lambda (element) (list element element))
               (list 'Galveston 'Garza 'Gillespie 'Glasscock
                     'Goliad))
  (lambda (result)
    (equal? result
            '(Galveston Galveston Garza Garza Gillespie
              Gillespie Glasscock Glasscock Goliad Goliad))))

(test 'append-map!:several-null-lists
  (append-map! (lambda elements (reverse elements))
               (list)
               (list)
               (list)
               (list)
               (list))
  null?)

(test 'append-map!:several-singleton-lists
  (append-map! (lambda elements (reverse elements))
               (list 'Gonzales)
               (list 'Gray)
               (list 'Grayson)
               (list 'Gregg)
               (list 'Grimes))
  (lambda (result)
    (equal? result
            '(Grimes Gregg Grayson Gray Gonzales))))

(test 'append-map!:several-longer-lists
  (append-map! (lambda elements (reverse elements))
               (list 'Guadalupe 'Hale 'Hall 'Hamilton 'Hansford
                     'Hardeman 'Hardin)
               (list 'Harris 'Harrison 'Hartley 'Haskell 'Hays
                     'Hemphill 'Henderson)
               (list 'Hidalgo 'Hill 'Hockley 'Hood 'Hopkins
                     'Houston 'Howard)
               (list 'Hudspeth 'Hunt 'Hutchinson 'Irion 'Jack
                     'Jackson 'Jasper)
               (list 'Jefferson 'Johnson 'Jones 'Karnes 'Kaufman
                     'Kendall 'Kenedy))
  (lambda (result)
    (equal? result
            '(Jefferson Hudspeth Hidalgo Harris Guadalupe
              Johnson Hunt Hill Harrison Hale Jones Hutchinson
              Hockley Hartley Hall Karnes Irion Hood Haskell
              Hamilton Kaufman Jack Hopkins Hays Hansford
              Kendall Jackson Houston Hemphill Hardeman Kenedy
              Jasper Howard Henderson Hardin))))

;;; MAP!

(test 'map!:one-null-list
  (map! vector (list))
  null?)

(test 'map!:one-singleton-list
  (map! vector (list 'Kent))
  (lambda (result) (equal? result '(#(Kent)))))

(test 'map!:one-longer-list
  (map vector (list 'Kerr 'Kimble 'King 'Kinney 'Kleberg))
  (lambda (result)
    (equal? result
            '(#(Kerr) #(Kimble) #(King) #(Kinney) #(Kleberg))))) 

(test 'map!:several-null-lists
  (map! vector (list) (list) (list) (list) (list))
  null?)

(test 'map!:several-singleton-lists
  (map! vector
        (list 'Knox)
        (list 'Lamar)
        (list 'Lamb)
        (list 'Lampasas)
        (list 'Lavaca))
  (lambda (result)
    (equal? result '(#(Knox Lamar Lamb Lampasas Lavaca)))))

(test 'map!:several-longer-lists
  (map! vector
        (list 'Lee 'Leon 'Liberty 'Limestone 'Lipscomb 'Llano
              'Loving)
        (list 'Lubbock 'Lynn 'McCulloch 'McLennan 'McMullen
              'Madison 'Marion)
        (list 'Martin 'Mason 'Matagorda 'Maverick 'Medina
              'Menard 'Midland)
        (list 'Milam 'Mills 'Mitchell 'Montague 'Montgomery
              'Moore 'Morris)
        (list 'Motley 'Nacogdoches 'Navarro 'Newton 'Nolan
              'Nueces 'Ochiltree))
  (lambda (result)
    (equal? result
            '(#(Lee Lubbock Martin Milam Motley)
              #(Leon Lynn Mason Mills Nacogdoches)
              #(Liberty McCulloch Matagorda Mitchell Navarro)
              #(Limestone McLennan Maverick Montague Newton)
              #(Lipscomb McMullen Medina Montgomery Nolan)
              #(Llano Madison Menard Moore Nueces)
              #(Loving Marion Midland Morris Ochiltree)))))

;;; MAP-IN-ORDER

(test 'map-in-order:one-null-list
  (let ((counter 0))
    (map-in-order (lambda (element)
                    (set! counter (+ counter 1))
                    (cons counter element))
                  '()))
  null?)

(test 'map-in-order:one-singleton-list
  (let ((counter 0))
    (map-in-order (lambda (element)
                    (set! counter (+ counter 1))
                    (cons counter element))
                  '(Oldham)))
  (lambda (result) (equal? result '((1 . Oldham)))))

(test 'map-in-order:one-longer-list
  (let ((counter 0))
    (map-in-order (lambda (element)
                    (set! counter (+ counter 1))
                    (cons counter element))
                  '(Orange Panola Parker Parmer Pecos)))
  (lambda (result)
    (equal? result '((1 . Orange)
                     (2 . Panola)
                     (3 . Parker)
                     (4 . Parmer)
                     (5 . Pecos)))))

(test 'map-in-order:several-null-lists
  (let ((counter 0))
    (map-in-order (lambda elements
                    (set! counter (+ counter 1))
                    (apply vector counter elements))
                  '() '() '() '() '()))
  null?)

(test 'map-in-order:several-singleton-lists
  (let ((counter 0))
    (map-in-order (lambda elements
                    (set! counter (+ counter 1))
                    (apply vector counter elements))
                  '(Polk)
                  '(Potter)
                  '(Presidio)
                  '(Rains)
                  '(Randall)))
  (lambda (result)
    (equal? result '(#(1 Polk Potter Presidio Rains Randall))))) 

(test 'map-in-order:several-longer-lists
  (let ((counter 0))
    (map-in-order (lambda elements
                    (set! counter (+ counter 1))
                    (apply vector counter elements))
                  '(Reagan Real Reeves Refugio Roberts Robertson
                    Rockwall)
                  '(Runnels Rusk Sabine Schleicher Scurry
                    Shackelford Shelby)
                  '(Sherman Smith Somervell Starr Stephens
                    Sterling Stonewall)
                  '(Sutton Swisher Tarrant Taylor Terrell Terry
                    Throckmorton)
                  '(Titus Travis Trinity Tyler Upshur Upton
                    Uvalde)))
  (lambda (result)
    (equal? result
            '(#(1 Reagan Runnels Sherman Sutton Titus)
              #(2 Real Rusk Smith Swisher Travis)
              #(3 Reeves Sabine Somervell Tarrant Trinity)
              #(4 Refugio Schleicher Starr Taylor Tyler)
              #(5 Roberts Scurry Stephens Terrell Upshur)
              #(6 Robertson Shackelford Sterling Terry Upton)
              #(7 Rockwall Shelby Stonewall Throckmorton
                Uvalde)))))

;;; PAIR-FOR-EACH

(test 'pair-for-each:one-null-list
  (let ((base '()))
    (pair-for-each (lambda (tail)
                     (set! base (append tail base)))
                   '())
    base)
  null?)

(test 'pair-for-each:one-singleton-list
  (let ((base '()))   
    (pair-for-each (lambda (tail)
                     (set! base (append tail base)))
                   '(Victoria))
    base)
  (lambda (result) (equal? result '(Victoria))))

(test 'pair-for-each:one-longer-list
  (let ((base '()))
    (pair-for-each (lambda (tail)
                     (set! base (append tail base)))
                   '(Walker Waller Ward Washington Webb))
    base)
  (lambda (result)
    (equal? result
            '(Webb Washington Webb Ward Washington Webb Waller
                   Ward Washington Webb Walker Waller Ward
                   Washington Webb))))

(test 'pair-for-each:several-null-lists
  (let ((base '()))
    (pair-for-each (lambda tails
                     (set! base
                           (cons (apply vector tails) base)))
                   '() '() '() '() '())
    base)
  null?)

(test 'pair-for-each:several-singleton-lists
  (let ((base '()))
    (pair-for-each (lambda tails
                     (set! base
                           (cons (apply vector tails) base)))
                   '(Wharton)
                   '(Wheeler)
                   '(Wichita)
                   '(Wilbarger)
                   '(Willacy))
    base)
  (lambda (result)
    (equal? result
            '(#((Wharton) (Wheeler) (Wichita) (Wilbarger)
                (Willacy))))))

(test 'pair-for-each:several-longer-lists
  (let ((base '()))
    (pair-for-each (lambda tails
                     (set! base
                           (cons (apply vector tails) base)))
                   '(Williamson Wilson Winkler Wise Wood Yoakum
                     Young)
                   '(Zapata Zavala Admiral Advil Ajax Anacin
                     Arrid)
                   '(Arnold Ban Barbie Beech Blockbuster Bounce
                     Breck)
                   '(Budweiser Bufferin BVD Carrier Celeste
                     Charmin Cheer)
                   '(Cheerios Cinemax Clairol Clorets Combat
                     Comet Coppertone))
    base)
  (lambda (result)
    (equal? result
            '(#((Young) (Arrid) (Breck) (Cheer) (Coppertone))
              #((Yoakum Young) (Anacin Arrid) (Bounce Breck)
                (Charmin Cheer) (Comet Coppertone))
              #((Wood Yoakum Young)
                (Ajax Anacin Arrid)
                (Blockbuster Bounce Breck)
                (Celeste Charmin Cheer) 
                (Combat Comet Coppertone))
              #((Wise Wood Yoakum Young) 
                (Advil Ajax Anacin Arrid)
                (Beech Blockbuster Bounce Breck)
                (Carrier Celeste Charmin Cheer)
                (Clorets Combat Comet Coppertone))
              #((Winkler Wise Wood Yoakum Young) 
                (Admiral Advil Ajax Anacin Arrid)
                (Barbie Beech Blockbuster Bounce Breck)
                (BVD Carrier Celeste Charmin Cheer)
                (Clairol Clorets Combat Comet Coppertone))
              #((Wilson Winkler Wise Wood Yoakum Young) 
                (Zavala Admiral Advil Ajax Anacin Arrid)
                (Ban Barbie Beech Blockbuster Bounce Breck)
                (Bufferin BVD Carrier Celeste Charmin Cheer)
                (Cinemax Clairol Clorets Combat Comet
                 Coppertone))
              #((Williamson Wilson Winkler Wise Wood Yoakum
                 Young) 
                (Zapata Zavala Admiral Advil Ajax Anacin Arrid)
                (Arnold Ban Barbie Beech Blockbuster Bounce
                 Breck)
                (Budweiser Bufferin BVD Carrier Celeste Charmin
                 Cheer)
                (Cheerios Cinemax Clairol Clorets Combat Comet
                 Coppertone))))))

;;; FILTER-MAP

(test 'filter-map:one-null-list
  (filter-map values '())
  null?)

(test 'filter-map:one-singleton-list
  (filter-map values '(Crest))
  (lambda (result) (equal? result '(Crest))))

(test 'filter-map:one-list-all-elements-removed
  (filter-map (lambda (x) #f)
              '(Crisco Degree Doritos Dristan Efferdent))
  null?)

(test 'filter-map:one-list-some-elements-removed
  (filter-map (lambda (n) (and (even? n) n))
              '(44 45 46 47 48 49 50))
  (lambda (result) (equal? result '(44 46 48 50))))

(test 'filter-map:one-list-no-elements-removed
  (filter-map values '(ESPN Everready Excedrin Fab Fantastik))
  (lambda (result)
    (equal? result '(ESPN Everready Excedrin Fab Fantastik))))

(test 'filter-map:several-null-lists
  (filter-map vector '() '() '() '() '())
  null?)

(test 'filter-map:several-singleton-lists
  (filter-map vector
              '(Foamy)
              '(Gatorade)
              '(Glad)
              '(Gleem)
              '(Halcion))
  (lambda (result)
    (equal? result '(#(Foamy Gatorade Glad Gleem Halcion)))))

(test 'filter-map:several-lists-all-elements-removed
  (filter-map (lambda arguments #f)
              '(Hanes HBO Hostess Huggies Ivory Kent Kinney)
              '(Kleenex Knorr Lee Lenox Lerner Listerine
                Marlboro)
              '(Mazola Michelob Midas Miller NBC Newsweek
                Noxema)
              '(NutraSweet Oreo Pampers People Planters
                Playskool Playtex)
              '(Prego Prell Prozac Purex Ritz Robitussin
                      Rolaids))
  null?)

(test 'filter-map:several-lists-some-elements-removed
  (filter-map (lambda arguments
                (let ((sum (apply + arguments)))
                  (and (odd? sum) sum)))
              '(51 52 53 54 55 56 57)
              '(58 59 60 61 62 63 64)
              '(65 66 67 68 69 70 71)
              '(72 73 74 75 76 77 78)
              '(79 80 81 82 83 84 85))
  (lambda (result) (equal? result '(325 335 345 355))))

(test 'filter-map:several-lists-no-elements-removed
  (filter-map vector
              '(Ronzoni Ruffles Scotch Skippy SnackWell Snapple
                Spam)
              '(Sprite Swanson Thomas Tide Tonka Trojan
                Tupperware)
              '(Tylenol Velveeta Vicks Victory Visine Wheaties
                Wise)
              '(Wonder Ziploc Abbott Abingdon Ackley Ackworth
                Adair)
              '(Adams Adaville Adaza Adel Adelphi Adena Afton))
  (lambda (result)
    (equal? result
            '(#(Ronzoni Sprite Tylenol Wonder Adams)
              #(Ruffles Swanson Velveeta Ziploc Adaville)
              #(Scotch Thomas Vicks Abbott Adaza)
              #(Skippy Tide Victory Abingdon Adel)
              #(SnackWell Tonka Visine Ackley Adelphi)
              #(Snapple Trojan Wheaties Ackworth Adena)
              #(Spam Tupperware Wise Adair Afton)))))

;;; FILTER

(test 'filter:null-list
  (filter (lambda (x) #t) '())
  null?)

(test 'filter:singleton-list
  (filter (lambda (x) #t) '(Agency))
  (lambda (result) (equal? result '(Agency))))

(test 'filter:all-elements-removed
  (filter (lambda (x) #f)
          '(Ainsworth Akron Albany Albaton Albia))
  null?)

(test 'filter:some-elements-removed
  (filter even? '(86 87 88 89 90))
  (lambda (result) (equal? result '(86 88 90))))

(test 'filter:no-elements-removed
  (filter (lambda (x) #t)
          '(Albion Alburnett Alden Alexander Algona))
  (lambda (result)
    (equal? result '(Albion Alburnett Alden Alexander Algona))))

;;; FILTER!

(test 'filter!:null-list
  (filter! (lambda (x) #t) (list))
  null?)

(test 'filter!:singleton-list
  (filter! (lambda (x) #t) (list 'Alice))
  (lambda (result) (equal? result '(Alice))))

(test 'filter!:all-elements-removed
  (filter! (lambda (x) #f)
           (list 'Alleman 'Allendorf 'Allerton 'Allison 'Almont))
  null?)

(test 'filter!:some-elements-removed
  (filter! even? (list 91 92 93 94 95))
  (lambda (result) (equal? result '(92 94))))

(test 'filter!:no-elements-removed
  (filter! (lambda (x) #t)
           (list 'Almoral 'Alpha 'Alta 'Alton 'Altoona))
  (lambda (result)
    (equal? result '(Almoral Alpha Alta Alton Altoona))))

;;; REMOVE

(test 'remove:null-list
  (remove (lambda (x) #t) '())
  null?)

(test 'remove:singleton-list
  (remove (lambda (x) #f) '(Alvord))
  (lambda (result) (equal? result '(Alvord))))

(test 'remove:all-elements-removed
  (remove (lambda (x) #t) '(Amana Amber Ames Amish Anamosa))
  null?)

(test 'remove:some-elements-removed
  (remove even? '(96 97 98 99 100))
  (lambda (result) (equal? result '(97 99))))

(test 'remove:no-elements-removed
  (remove (lambda (x) #f)
          '(Anderson Andover Andrew Andrews Angus))
  (lambda (result)
    (equal? result '(Anderson Andover Andrew Andrews Angus))))

;;; REMOVE!

(test 'remove!:null-list
  (remove! (lambda (x) #t) (list))
  null?)

(test 'remove!:singleton-list
  (remove! (lambda (x) #f) (list 'Anita))
  (lambda (result) (equal? result '(Anita))))

(test 'remove!:all-elements-removed
  (remove! (lambda (x) #t)
           (list 'Ankeny 'Anthon 'Aplington 'Arcadia 'Archer))
  null?)

(test 'remove!:some-elements-removed
  (remove! even? (list 101 102 103 104 105))
  (lambda (result) (equal? result '(101 103 105))))

(test 'remove!:no-elements-removed
  (remove! (lambda (x) #f)
           (list 'Ardon 'Aredale 'Argo 'Argyle 'Arion))
  (lambda (result)
    (equal? result  '(Ardon Aredale Argo Argyle Arion))))

;;; PARTITION

(test/values 'partition:null-list
  '(partition (lambda (x) #f) '())
  (lambda (in out) (and (null? in) (null? out))))

(test/values 'partition:singleton-list
  '(partition (lambda (x) #f) '(Arispe))
  (lambda (in out) (and (null? in) (equal? out '(Arispe)))))

(test/values 'partition:all-satisfying
  '(partition (lambda (x) #t)
             '(Arlington Armstrong Arnold Artesian Arthur))
  (lambda (in out)
    (and (equal? in
                 '(Arlington Armstrong Arnold Artesian Arthur))
         (null? out))))

(test/values 'partition:mixed-starting-in
  '(partition even? '(106 108 109 111 113 114 115 117 118 120))
  (lambda (in out)
    (and (equal? in '(106 108 114 118 120))
         (equal? out '(109 111 113 115 117)))))

(test/values 'partition:mixed-starting-out
  '(partition even? '(121 122 124 126))
  (lambda (in out)
    (and (equal? in '(122 124 126))
         (equal? out '(121)))))

(test/values 'partition:none-satisfying
  '(partition (lambda (x) #f)
             '(Asbury Ashawa Ashland Ashton Aspinwall))
  (lambda (in out)
    (and (null? in)
         (equal? out
                 '(Asbury Ashawa Ashland Ashton Aspinwall)))))

;;; PARTITION!

(test/values 'partition!:null-list
  '(partition! (lambda (x) #f) (list))
  (lambda (in out) (and (null? in) (null? out))))

(test/values 'partition!:singleton-list
  '(partition! (lambda (x) #f) (list 'Astor))
  (lambda (in out) (and (null? in) (equal? out '(Astor)))))

(test/values 'partition!:all-satisfying
  '(partition! (lambda (x) #t)
              (list 'Atalissa 'Athelstan 'Atkins 'Atlantic
                    'Attica))
  (lambda (in out)
    (and (equal? in
                 '(Atalissa Athelstan Atkins Atlantic Attica))
         (null? out))))

(test/values 'partition!:mixed-starting-in
  '(partition! odd?
              (list 127 129 130 132 134 135 136 138 139 141))
  (lambda (in out)
    (and (equal? in '(127 129 135 139 141))
         (equal? out '(130 132 134 136 138)))))

(test/values 'partition!:mixed-starting-out
  '(partition! odd? (list 142 143 145 147))
  (lambda (in out)
    (and (equal? in '(143 145 147))
         (equal? out '(142)))))

(test/values 'partition!:none-satisfying
  '(partition! (lambda (x) #f)
              (list 'Auburn 'Audubon 'Augusta 'Aurelia
                    'Aureola))
  (lambda (in out)
    (and (null? in)
         (equal? out
                 '(Auburn Audubon Augusta Aurelia Aureola)))))

;;; FIND

(test 'find:in-null-list
  (find (lambda (x) #t) '())
  not)

(test 'find:in-singleton-list
  (find (lambda (x) #t) '(Aurora))
  (lambda (result) (eq? result 'Aurora)))

(test 'find:not-in-singleton-list
  (find (lambda (x) #f) '(Austinville))
  not)

(test 'find:at-front-of-longer-list
  (find (lambda (x) #t) '(Avery Avoca Avon Ayrshire Badger))
  (lambda (result) (eq? result 'Avery)))

(test 'find:in-middle-of-longer-list
  (find even? '(149 151 153 155 156 157 159))
  (lambda (result) (= result 156)))

(test 'find:at-end-of-longer-list
  (find even? '(161 163 165 167 168))
  (lambda (result) (= result 168)))

(test 'find:not-in-longer-list
  (find (lambda (x) #f)
        '(Bagley Bailey Badwin Balfour Balltown))
  not)

;;; FIND-TAIL

(test 'find-tail:in-null-list
  (find-tail (lambda (x) #t) '())
  not)

(let ((source '(Ballyclough)))
  (test 'find-tail:in-singleton-list
    (find-tail (lambda (x) #t) source)
    (lambda (result) (eq? result source))))

(test 'find-tail:not-in-singleton-list
  (find-tail (lambda (x) #f) '(Bancroft))
  not)

(let ((source '(Bangor Bankston Barney Barnum Bartlett)))
  (test 'find-tail:at-front-of-longer-list
    (find-tail (lambda (x) #t) source)             
    (lambda (result) (eq? result source))))

(let ((source '(169 171 173 175 176 177 179)))
  (test 'find-tail:in-middle-of-longer-list
    (find-tail even? source)
    (lambda (result) (eq? result (cddddr source)))))

(let ((source '(181 183 185 187 188)))
  (test 'find-tail:at-end-of-longer-list
    (find-tail even? source)
    (lambda (result) (eq? result (cddddr source)))))

(test 'find-tail:not-in-longer-list
  (find-tail (lambda (x) #f)
             '(Batavia Bauer Baxter Bayard Beacon)) 
  not)

;;; ANY

(test 'any:in-one-null-list
  (any values '())
  not)

(test 'any:in-one-singleton-list
  (any vector '(Beaconsfield))
  (lambda (result) (equal? result '#(Beaconsfield))))

(test 'any:not-in-one-singleton-list
  (any (lambda (x) #f) '(Beaman))
  not)

(test 'any:at-beginning-of-one-longer-list
  (any vector '(Beaver Beaverdale Beckwith Bedford Beebeetown))
  (lambda (result) (equal? result '#(Beaver))))

(test 'any:in-middle-of-one-longer-list
  (any (lambda (x) (and (odd? x) (+ x 189)))
       '(190 192 194 196 197 198 200))
  (lambda (result) (= result 386)))

(test 'any:at-end-of-one-longer-list
  (any (lambda (x) (and (odd? x) (+ x 201)))
       '(202 204 206 208 209))
  (lambda (result) (= result 410)))

(test 'any:not-in-one-longer-list
  (any (lambda (x) #f)
       '(Beech Belinda Belknap Bellefountain Bellevue))
  not)

(test 'any:in-several-null-lists
  (any vector '() '() '() '() '())
  not)

(test 'any:in-several-singleton-lists
  (any vector
       '(Belmond)
       '(Beloit)
       '(Bennett)
       '(Benson)
       '(Bentley))
  (lambda (result)
    (equal? result '#(Belmond Beloit Bennett Benson Bentley))))

(test 'any:not-in-several-singleton-lists
  (any (lambda arguments #f)
       '(Benton)
       '(Bentonsport)
       '(Berea)
       '(Berkley)
       '(Bernard))
  not)

(test 'any:at-beginning-of-several-longer-lists
  (any vector
       '(Berne Bertram Berwick Bethesda Bethlehem Bettendorf
         Beulah)
       '(Bevington Bidwell Bingham Birmingham Bladensburg
         Blairsburg Blairstown)
       '(Blakesburg Blanchard Blencoe Bliedorn Blockton
         Bloomfield Bloomington)
       '(Bluffton Bode Bolan Bonair Bonaparte Bondurant Boone)
       '(Booneville Botany Botna Bouton Bowsher Boxholm Boyd))
  (lambda (result)
    (equal? result
            '#(Berne Bevington Blakesburg Bluffton Booneville))))

(test 'any:in-middle-of-several-longer-lists
  (any (lambda arguments
         (let ((sum (apply + arguments)))
           (and (odd? sum) (+ sum 210))))
       '(211 212 213 214 215 216 217)
       '(218 219 220 221 222 223 224)
       '(225 226 227 228 229 230 231)
       '(232 233 234 235 236 237 238)
       '(240 242 244 246 247 248 250))
  (lambda (result) (= result 1359)))

(test 'any:at-end-of-several-longer-lists
  (any (lambda arguments
         (let ((sum (apply + arguments)))
           (and (even? sum) (+ sum 210))))
       '(252 253 254 255 256 257 258)
       '(259 260 261 262 263 264 265)
       '(266 267 268 269 270 271 272)
       '(273 274 275 276 277 278 279)
       '(281 283 285 287 289 291 292))
  (lambda (result) (= result 1576)))

(test 'any:not-in-several-longer-lists
  (any (lambda arguments #f)
       '(Boyden Boyer Braddyville Bradford Bradgate Brainard
         Brandon)
       '(Brayton Brazil Breda Bridgewater Brighton Bristol
         Bristow)
       '(Britt Bromley Brompton Bronson Brooklyn Brooks
         Brookville)
       '(Browns Brownville Brunsville Brushy Bryant Bryantsburg
         Buchanan)
       '(Buckeye Buckhorn Buckingham Bucknell Budd Buffalo
         Burchinal))
  not)

(test 'any:not-in-lists-of-unequal-length
  (any (lambda arguments #f)
       '(Burdette Burlington Burnside Burt)
       '(Bushville Bussey)
       '(Buxton Cairo Calamus)
       '(Caledonia Clahoun Callender Calmar Caloma Calumet))
  not)

;;; EVERY

(test 'every:in-one-null-list
  (every values '())
  (lambda (result) (eq? result #t)))

(test 'every:in-one-singleton-list
  (every vector '(Camanche))
  (lambda (result) (equal? result '#(Camanche))))

(test 'every:not-in-one-singleton-list
  (every (lambda (x) #f) '(Cambria))
  not)

(test 'every:failing-at-beginning-of-one-longer-list
  (every (lambda (x) #f)
         '(Cambridge Cameron Canby Canton Cantril)) 
  not)

(test 'every:failing-in-middle-of-one-longer-list
  (every (lambda (x) (and (even? x) (+ x 293)))
         '(294 296 298 300 301 302 304))
  not)

(test 'every:failing-at-end-of-one-longer-list
  (every (lambda (x) (and (even? x) (+ x 305)))
         '(306 308 310 312 313))
  not)

(test 'every:in-one-longer-list
  (every vector
         '(Carbon Carbondale Carl Carlisle Carmel))
  (lambda (result) (equal? result '#(Carmel))))

(test 'every:in-several-null-lists
  (every vector '() '() '() '() '())
  (lambda (result) (eq? result #t)))

(test 'every:in-several-singleton-lists
  (every vector
         '(Carnarvon)
         '(Carnes)
         '(Carney)
         '(Carnforth)
         '(Carpenter))
  (lambda (result)
    (equal? result
            '#(Carnarvon Carnes Carney Carnforth Carpenter))))

(test 'every:not-in-several-singleton-lists
  (every (lambda arguments #f)
         '(Carroll)
         '(Carrollton)
         '(Carrville)
         '(Carson)
         '(Cartersville))
  not)

(test 'every:failing-at-beginning-of-several-longer-lists
  (every (lambda arguments #f)
         '(Cascade Casey Castalia Castana Cattese Cedar
           Centerdale)
         '(Centerville Centralia Ceres Chapin Chariton
           Charleston Charlotte)
         '(Chatsworth Chautauqua Chelsea Cheney Cherokee Chester 
           Chickasaw)
         '(Chillicothe Churchtown Churchville Churdan Cincinnati 
           Clare Clarence)
         '(Clarinda Clarion Clark Clarkdale Clarksville Clayton
           Clearfield))
  not)

(test 'every:failing-in-middle-of-several-longer-lists
  (every (lambda arguments
           (let ((sum (apply + arguments)))
             (and (odd? sum) (+ sum 314))))
         '(315 316 317 318 319 320 321)
         '(322 323 324 325 326 327 328)
         '(329 330 331 332 333 334 335)
         '(336 337 338 339 340 341 342)
         '(343 345 347 349 350 351 353))
  not)

(test 'every:failing-at-end-of-several-longer-lists
  (every (lambda arguments
         (let ((sum (apply + arguments)))
           (and (odd? sum) (+ sum 354))))
         '(355 356 357 358 359 360 361)
         '(362 363 364 365 366 367 368)
         '(369 370 371 372 373 374 375)
         '(376 377 378 379 380 381 382)
         '(383 385 387 389 391 393 394))
  not)

(test 'every:in-several-longer-lists
  (every vector
         '(Cleghorn Clemons Clermont Cleves Cliffland Climax
           Clinton)
         '(Clio Clive Cloverdale Clucas Clutier Clyde Coalville)
         '(Coburg Coggon Coin Colesburg Colfax Collett Collins)
         '(Colo Columbia Colwell Commerce Communia Competine
           Concord)
         '(Conesville Confidence Cono Conover Conrad Conroy
           Consol))
  (lambda (result)
    (equal? result 
            '#(Clinton Coalville Collins Concord Consol))))

(test 'every:in-lists-of-unequal-length
  (every vector
         '(Conway Cool Cooper Coppock)
         '(Coralville Corley)
         '(Cornelia Cornell Corning)
         '(Correctionville Corwith Corydon Cosgrove Coster
           Cotter))
  (lambda (result)
    (equal? result '#(Cool Corley Cornell Corwith))))

;;; LIST-INDEX

(test 'list-index:in-one-null-list
  (list-index (lambda (x) #t) '())
  not)

(test 'list-index:in-one-singleton-list
  (list-index (lambda (x) #t) '(Cottonville))
  zero?)

(test 'list-index:not-in-one-singleton-list
  (list-index (lambda (x) #f) '(Coulter))
  not)

(test 'list-index:at-front-of-one-longer-list
  (list-index (lambda (x) #t)
              '(Covington Craig Cranston Crathorne
                Crawfordsville))
  zero?)

(test 'list-index:in-middle-of-one-longer-list
  (list-index even? '(395 397 399 401 402 403 405))
  (lambda (result) (= result 4)))

(test 'list-index:at-end-of-one-longer-list
  (list-index odd? '(406 408 410 412 414 415))
  (lambda (result) (= result 5)))

(test 'list-index:not-in-one-longer-list
  (list-index (lambda (x) #f)
              '(Crescent Cresco Creston Crocker Crombie))
  not)

(test 'list-index:in-several-null-lists
  (list-index (lambda arguments #t) '() '() '() '() '())
  not)

(test 'list-index:in-several-singleton-lists
  (list-index (lambda arguments #t)
              '(Cromwell)
              '(Croton)
              '(Cumberland)
              '(Cumming)
              '(Curlew))
  zero?)

(test 'list-index:not-in-several-singleton-lists
  (list-index (lambda arguments #f)
              '(Cushing)
              '(Cylinder)
              '(Dahlonega)
              '(Dalby)
              '(Dale))
  not)

(test 'list-index:at-front-of-several-longer-lists
  (list-index (lambda arguments #t)
              '(Dallas Dana Danbury Danville Darbyville
                Davenport Dawson)
              '(Dayton Daytonville Dean Decorah Dedham Deerfield 
                Defiance)
              '(Delaware Delhi Delmar Deloit Delphos Delta
                Denhart)
              '(Denison Denmark Denova Denver Depew Derby Devon)
              '(Dewar Dexter Diagonal Dickens Dickieville Dike
                Dillon))
  zero?)

(test 'list-index:in-middle-of-several-longer-lists
  (list-index (lambda arguments (odd? (apply + arguments)))
              '(416 417 418 419 420 421 422)
              '(423 424 425 426 427 428 429)
              '(430 431 432 433 434 435 436)
              '(437 438 439 440 441 442 443)
              '(444 446 448 450 451 452 454))
  (lambda (result) (= result 4)))

(test 'list-index:at-end-of-several-longer-lists
  (list-index (lambda arguments (even? (apply + arguments)))
              '(455 456 457 458 459 460)
              '(461 462 463 464 465 466)
              '(467 468 469 470 471 472)
              '(473 474 475 476 477 478)
              '(479 481 483 485 487 488))
  (lambda (result) (= result 5)))

(test 'list-index:not-in-several-longer-lists
  (list-index (lambda arguments #f)
              '(Dinsdale Dixon Dodgeville Dolliver Donahue
                Donnan Donnelley)
              '(Donnellson Doon Dorchester Doris Douds Dougherty 
                Douglas)
              '(Doney Dows Drakesville Dresden Dubuque Dudley
                Dumfries)
              '(Dumont Dunbar Duncan Duncombe Dundee Dunkerton
                Dunlap)
              '(Durango Durant Durham Dutchtown Dyersville
                Dysart Earlham))
  not)

;;; DELETE

(test 'delete:null-list
  (delete 'Earling '() (lambda (x y) #t))
  null?)

(test 'delete:singleton-list
  (delete 'Earlville '(Early) (lambda (x y) #f))
  (lambda (result) (equal? result '(Early))))

(test 'delete:all-elements-removed
  (delete
       'Eckards
       '(Eddyville Edgewood Edinburg Edmore Edna)
       (lambda (x y) #t))
  null?)

(test 'delete:some-elements-removed
  (delete
       489
       '(490 491 492 493 494)
       (lambda (x y) (even? (+ x y))))
  (lambda (result) (equal? result '(490 492 494))))

(test 'delete:no-elements-removed
  (delete
       'Egan
       '(Egralharve Ehler Elberon Eldergrove Eldon)
       (lambda (x y) #f))
  (lambda (result)
    (equal? result '(Egralharve Ehler Elberon Eldergrove Eldon))))

;;; DELETE!

(test 'delete!:null-list
  (delete! 'Eldora (list) (lambda (x y) #t))
  null?)

(test 'delete!:singleton-list
  (delete! 'Eldorado (list 'Eldridge) (lambda (x y) #f))
  (lambda (result) (equal? result '(Eldridge))))

(test 'delete!:all-elements-removed
  (delete!
        'Eleanor
        (list 'Elgin 'Elkader 'Elkhart 'Elkport 'Elliott)
        (lambda (x y) #t))
  null?)

(test 'delete!:some-elements-removed
  (delete!
        495
        (list 496 497 498 499 500)
        (lambda (x y) (odd? (+ x y))))
  (lambda (result) (equal? result '(497 499))))

(test 'delete!:no-elements-removed
  (delete!
        'Ellston
        (list 'Ellsworth 'Elma 'Elmira 'Elon 'Elvira)
        (lambda (x y) #f))
  (lambda (result)
    (equal? result '(Ellsworth Elma Elmira Elon Elvira))))

;;; DELQ

(define delq
  (lambda (x lst)
    (delete x lst eq?)))

(test 'delq:null-list
  (delq 'Elwood '())
  null?)

(test 'delq:in-singleton-list
  (delq 'Ely '(Ely))
  null?)

(test 'delq:not-in-singleton-list
  (delq 'Emeline '(Emerson))
  (lambda (result) (equal? result '(Emerson))))

(test 'delq:at-beginning-of-longer-list
  (delq 'Emery '(Emery Emmetsburg Enterprise Epworth Ericson))
  (lambda (result)
    (equal? result '(Emmetsburg Enterprise Epworth Ericson))))

(test 'delq:in-middle-of-longer-list
  (delq 'Essex '(Estherville Euclid Evans Evansdale Essex
                 Evanston Everly))
  (lambda (result)
    (equal? result '(Estherville Euclid Evans Evansdale Evanston 
                     Everly))))

(test 'delq:at-end-of-longer-list
  (delq 'Ewart '(Exira Exline Fairbank Fairfax Ewart))
  (lambda (result)
    (equal? result '(Exira Exline Fairbank Fairfax))))

(test 'delq:not-in-longer-list
  (delq 'Fairfield
        '(Fairport Fairview Fairville Fanslers Farley))
  (lambda (result)
    (equal? result
            '(Fairport Fairview Fairville Fanslers Farley))))

(test 'delq:several-matches-in-longer-list
  (delq 'Farlin '(Farmersburg Farmington Farlin Farnhamville
                  Farlin Farragut Farlin))
  (lambda (result)
    (equal? result
            '(Farmersburg Farmington Farnhamville Farragut))))

;;; DELV

(define delv
  (lambda (x lst)
    (delete x lst eqv?)))

(test 'delv:null-list
  (delv 'Farrar '())
  null?)

(test 'delv:in-singleton-list
  (delv 'Farson '(Farson))
  null?)

(test 'delv:not-in-singleton-list
  (delv 'Faulkner '(Fayette))
  (lambda (result) (equal? result '(Fayette))))

(test 'delv:at-beginning-of-longer-list
  (delv 'Fenton '(Fenton Fern Fernald Fertile Festina))
  (lambda (result)
    (equal? result '(Fern Fernald Fertile Festina))))

(test 'delv:in-middle-of-longer-list
  (delv 'Fielding
        '(Fillmore Finchford Findley Fiscus Fielding Fisk Flagler))
  (lambda (result)
    (equal? result
            '(Fillmore Finchford Findley Fiscus Fisk Flagler))))

(test 'delv:at-end-of-longer-list
  (delv 'Florence '(Florenceville Floris Floyd Flugstad Florence))
  (lambda (result)
    (equal? result '(Florenceville Floris Floyd Flugstad))))

(test 'delv:not-in-longer-list
  (delv 'Folletts
        '(Folson Fonda Fontanelle Forbush Forestville))
  (lambda (result)
    (equal? result
            '(Folson Fonda Fontanelle Forbush Forestville))))

(test 'delv:several-matches-in-longer-list
  (delv 'Foster '(Fostoria Frankfort Foster Franklin Foster
                  Frankville Foster))
  (lambda (result)
    (equal? result
            '(Fostoria Frankfort Franklin Frankville))))

;;; DELETE

(test 'delete:null-list
  (delete '(Fraser . Frederic) '())
  null?)

(test 'delete:in-singleton-list
  (delete '(Fredericksburg . Frederika)
          '((Fredericksburg . Frederika)))
  null?)

(test 'delete:not-in-singleton-list
  (delete '(Fredonia . Fredsville) '((Freeman . Freeport)))
  (lambda (result) (equal? result '((Freeman . Freeport)))))

(test 'delete:at-beginning-of-longer-list
  (delete '(Fremont . Froelich) '((Fremont . Froelich)
                                  (Fruitland . Fulton)
                                  (Furay . Galbraith)
                                  (Galesburg . Galland)
                                  (Galt . Galva)))
  (lambda (result)
    (equal? result '((Fruitland . Fulton)
                     (Furay . Galbraith)
                     (Galesburg . Galland)
                     (Galt . Galva)))))

(test 'delete:in-middle-of-longer-list
  (delete '(Gambrill . Garber) '((Gardiner . Gardner)
                                 (Garfield . Garland)
                                 (Garnavillo . Garner)
                                 (Garrison . Garwin)
                                 (Gambrill . Garber)
                                 (Gaza . Geneva)
                                 (Genoa . George)))
  (lambda (result)
    (equal? result '((Gardiner . Gardner)
                     (Garfield . Garland)
                     (Garnavillo . Garner)
                     (Garrison . Garwin)
                     (Gaza . Geneva)
                     (Genoa . George)))))

(test 'delete:at-end-of-longer-list
  (delete '(Georgetown . Gerled) '((Germantown . Germanville)
                                   (Giard . Gibbsville)
                                   (Gibson . Gifford)
                                   (Gilbert . Gilbertville)
                                   (Georgetown . Gerled)))
  (lambda (result)
    (equal? result '((Germantown . Germanville)
                     (Giard . Gibbsville)
                     (Gibson . Gifford)
                     (Gilbert . Gilbertville)))))

(test 'delete:not-in-longer-list
  (delete '(Gilliatt . Gilman) '((Givin . Gladbrook)
                                 (Gladstone . Gladwin)
                                 (Glasgow . Glendon)
                                 (Glenwood . Glidden)
                                 (Goddard . Goldfield)))
  (lambda (result)
    (equal? result '((Givin . Gladbrook)
                     (Gladstone . Gladwin)
                     (Glasgow . Glendon)
                     (Glenwood . Glidden)
                     (Goddard . Goldfield)))))

(test 'delete:several-matches-in-longer-list
  (delete '(Goodell . Gosport) '((Gowrie . Goddard)
                                 (Grable . Graettinger)
                                 (Goodell . Gosport)
                                 (Graf . Grafton)
                                 (Goodell . Gosport)
                                 (Grandview . Granger)
                                 (Goodell . Gosport)))
  (lambda (result)
    (equal? result '((Gowrie . Goddard)
                     (Grable . Graettinger)
                     (Graf . Grafton)
                     (Grandview . Granger)))))

;;; DELQ!

(define delq!
  (lambda (x lst)
    (delete! x lst eq?)))

(test 'delq!:null-list
  (delq! 'Granite (list))
  null?)

(test 'delq!:in-singleton-list
  (delq! 'Grant (list 'Grant))
  null?)

(test 'delq!:not-in-singleton-list
  (delq! 'Granville (list 'Gravity))
  (lambda (result) (equal? result '(Gravity))))

(test 'delq!:at-beginning-of-longer-list
  (delq! 'Gray
         (list 'Gray 'Greeley 'Greenbush 'Greene 'Greenfield))
  (lambda (result)
    (equal? result '(Greeley Greenbush Greene Greenfield))))

(test 'delq!:in-middle-of-longer-list
  (delq! 'Gridley (list 'Griffinsville 'Grimes 'Grinnell
                        'Griswold 'Gridley 'Gruver 'Guernsey))
  (lambda (result)
    (equal? result '(Griffinsville Grimes Grinnell Griswold
                     Gruver Guernsey))))

(test 'delq!:at-end-of-longer-list
  (delq! 'Gunder
         (list 'Guss 'Guttenberg 'Gypsum 'Halbur 'Gunder))
  (lambda (result)
    (equal? result '(Guss Guttenberg Gypsum Halbur))))

(test 'delq!:not-in-longer-list
  (delq! 'Hale
         (list 'Hamburg 'Hamilton 'Hamlin 'Hampton 'Hancock))
  (lambda (result)
    (equal? result
            '(Hamburg Hamilton Hamlin Hampton Hancock))))

(test 'delq!:several-matches-in-longer-list
  (delq! 'Hanford (list 'Hanley 'Hanlontown 'Hanford 'Hanna
                        'Hanford 'Hanover 'Hanford))
  (lambda (result)
    (equal? result '(Hanley Hanlontown Hanna Hanover))))

;;; DELV!

(define delv!
  (lambda (x lst)
    (delete! x lst eqv?)))

(test 'delv!:null-list
  (delv! 'Hansell (list))
  null?)

(test 'delv!:in-singleton-list
  (delv! 'Harcourt (list 'Harcourt))
  null?)

(test 'delv!:not-in-singleton-list
  (delv! 'Hardin (list 'Hardy))
  (lambda (result) (equal? result '(Hardy))))

(test 'delv!:at-beginning-of-longer-list
  (delv! 'Harlan
         (list 'Harlan 'Harper 'Harris 'Harrisburg 'Hartford))
  (lambda (result)
    (equal? result '(Harper Harris Harrisburg Hartford))))

(test 'delv!:in-middle-of-longer-list
  (delv! 'Hartley (list 'Hartwick 'Harvard 'Harvey 'Haskins
                        'Hartley 'Hastie 'Hastings))
  (lambda (result)
    (equal? result '(Hartwick Harvard Harvey Haskins Hastie
                     Hastings))))

(test 'delv!:at-end-of-longer-list
  (delv! 'Hauntown
         (list 'Havelock 'Haven 'Haverhill 'Havre 'Hauntown))
  (lambda (result)
    (equal? result '(Havelock Haven Haverhill Havre))))

(test 'delv!:not-in-longer-list
  (delv! 'Hawarden (list 'Hawkeye 'Hawleyville 'Hawthorne
                         'Hayesville 'Hayfield))
  (lambda (result)
    (equal? result '(Hawkeye Hawleyville Hawthorne Hayesville
                     Hayfield))))

(test 'delv!:several-matches-in-longer-list
  (delv! 'Hazleton (list 'Hebron 'Hedrick 'Hazleton 'Helena
                         'Hazleton 'Henderson 'Hazleton))
  (lambda (result)
    (equal? result '(Hebron Hedrick Helena Henderson))))

;;; DELETE!

(test 'delete!:null-list
  (delete! (cons 'Henshaw 'Hentons) (list))
  null?)

(test 'delete!:in-singleton-list
  (delete! (cons 'Hepburn 'Herndon)
           (list (cons 'Hepburn 'Herndon)))
  null?)

(test 'delete!:not-in-singleton-list
  (delete! (cons 'Hesper 'Hiattsville)
           (list (cons 'Hiawatha 'Hicks)))
  (lambda (result) (equal? result '((Hiawatha . Hicks)))))

(test 'delete!:at-beginning-of-longer-list
  (delete! (cons 'Highland 'Highlandville)
           (list (cons 'Highland 'Highlandville)
                 (cons 'Highview 'Hills)
                 (cons 'Hillsboro 'Hillsdale)
                 (cons 'Hilltop 'Hinton)
                 (cons 'Hiteman 'Hobarton)))
  (lambda (result)
    (equal? result '((Highview . Hills)
                     (Hillsboro . Hillsdale)
                     (Hilltop . Hinton)
                     (Hiteman . Hobarton)))))

(test 'delete!:in-middle-of-longer-list
  (delete! (cons 'Hocking 'Holbrook)
           (list (cons 'Holland 'Holmes)
                 (cons 'Holstein 'Homer)
                 (cons 'Homestead 'Hopeville)
                 (cons 'Hopkinton 'Hornick)
                 (cons 'Hocking 'Holbrook)
                 (cons 'Horton 'Hospers)
                 (cons 'Houghton 'Howardville)))
  (lambda (result)
    (equal? result '((Holland . Holmes)
                     (Holstein . Homer)
                     (Homestead . Hopeville)
                     (Hopkinton . Hornick)
                     (Horton . Hospers)
                     (Houghton . Howardville)))))

(test 'delete!:at-end-of-longer-list
  (delete! (cons 'Howe 'Hubbard)
           (list (cons 'Hudson 'Hugo)
                 (cons 'Hull 'Humboldt)
                 (cons 'Humeston 'Huntington)
                 (cons 'Hurley 'Huron)
                 (cons 'Howe 'Hubbard)))
  (lambda (result)
    (equal? result '((Hudson . Hugo)
                     (Hull . Humboldt)
                     (Humeston . Huntington)
                     (Hurley . Huron)))))

(test 'delete!:not-in-longer-list
  (delete! (cons 'Hurstville 'Hutchins)
           (list (cons 'Huxley 'Iconium)
                 (cons 'Illyria 'Imogene)
                 (cons 'Independence 'Indianapolis)
                 (cons 'Indianola 'Industry)
                 (cons 'Inwood 'Ion)))
  (lambda (result)
    (equal? result '((Huxley . Iconium)
                     (Illyria . Imogene)
                     (Independence . Indianapolis)
                     (Indianola . Industry)
                     (Inwood . Ion)))))

(test 'delete!:several-matches-in-longer-list
  (delete! (cons 'Ionia 'Ira)
           (list (cons 'Ireton 'Ironhills)
                 (cons 'Irving 'Irvington)
                 (cons 'Ionia 'Ira)
                 (cons 'Irwin 'Ivester)
                 (cons 'Ionia 'Ira)
                 (cons 'Iveyville 'Ivy)
                 (cons 'Ionia 'Ira)))
  (lambda (result)
    (equal? result '((Ireton . Ironhills)
                     (Irving . Irvington)
                     (Irwin . Ivester)
                     (Iveyville . Ivy)))))

;;; DEL-DUPLICATES

(define del-duplicates
  (lambda (f lst)
    (delete-duplicates lst f)))

(test 'del-duplicates:null-list
  (del-duplicates (lambda (x y) #t) '())
  null?)

(test 'del-duplicates:singleton-list
  (del-duplicates (lambda (x y) #t) '(Jacksonville))
  (lambda (result) (equal? result '(Jacksonville))))

(test 'del-duplicates:in-doubleton-list
  (del-duplicates (lambda (x y) #t) '(Jamaica James))
  (lambda (result) (equal? result '(Jamaica))))

(test 'del-duplicates:none-removed-in-longer-list
  (del-duplicates (lambda (x y) #f)
                  '(Jamestown Jamison Janesville Jefferson
                    Jerome))
  (lambda (result)
    (equal? result '(Jamestown Jamison Janesville Jefferson
                     Jerome))))

(test 'del-duplicates:some-removed-in-longer-list
  (del-duplicates (lambda (x y) (= (+ x y) 1011))
                  '(501 502 503 504 508 510 511))
  (lambda (result) (equal? result '(501 502 503 504 511))))

(test 'del-duplicates:all-but-one-removed-in-longer-list
  (del-duplicates (lambda (x y) #t)
                  '(Jesup Jewell Johnston Joice Jolley))
  (lambda (result) (equal? result '(Jesup))))

;;; DEL-DUPLICATES!

(define del-duplicates!
  (lambda (f lst)
    (delete-duplicates! lst f)))

(test 'del-duplicates!:null-list
  (del-duplicates! (lambda (x y) #t) '())
  null?)

(test 'del-duplicates!:singleton-list
  (del-duplicates! (lambda (x y) #t) (list 'Jordan))
  (lambda (result) (equal? result '(Jordan))))

(test 'del-duplicates!:in-doubleton-list
  (del-duplicates! (lambda (x y) #t) (list 'Jubilee 'Judd))
  (lambda (result) (equal? result '(Jubilee))))

(test 'del-duplicates!:none-removed-in-longer-list
  (del-duplicates! (lambda (x y) #f)
                   (list 'Julien 'Juniata 'Kalo 'Kalona
                         'Kamrar))
  (lambda (result)
    (equal? result '(Julien Juniata Kalo Kalona Kamrar))))

(test 'del-duplicates!:some-removed-in-longer-list
  (del-duplicates! (lambda (x y) (= (+ x y) 1031))
                   (list 511 512 513 514 518 520 521))
  (lambda (result) (equal? result '(511 512 513 514 521))))

(test 'del-duplicates!:all-but-one-removed-in-longer-list
  (del-duplicates! (lambda (x y) #t)
                   (list 'Kanawha 'Kellerton 'Kelley 'Kellogg
                         'Kendallville))
  (lambda (result) (equal? result '(Kanawha))))

;;; DELQ-DUPLICATES

(define delq-duplicates
  (lambda (lst)
    (delete-duplicates lst eq?)))

(test 'delq-duplicates:null-list
  (delq-duplicates '())
  null?)

(test 'delq-duplicates:singleton-list
  (delq-duplicates '(Kenfield))
  (lambda (result) (equal? result '(Kenfield))))

(test 'delq-duplicates:in-doubleton-list
  (delq-duplicates '(Kennebec Kennebec))
  (lambda (result) (equal? result '(Kennebec))))

(test 'delq-duplicates:none-removed-in-longer-list
  (delq-duplicates '(Kennedy Kensett Kent Kenwood Keokuk))
  (lambda (result)
    (equal? result '(Kennedy Kensett Kent Kenwood Keokuk))))

(test 'delq-duplicates:some-removed-in-longer-list
  (delq-duplicates '(Keosauqua Keota Keota Kesley Keosauqua
                     Keswick Keota Keystone Keota))
  (lambda (result)
    (equal? result '(Keosauqua Keota Kesley Keswick Keystone)))) 

(test 'delq-duplicates:all-but-one-removed-in-longer-list
  (delq-duplicates '(Kidder Kidder Kidder Kidder Kidder))
  (lambda (result) (equal? result '(Kidder))))

;;; DELV-DUPLICATES

(define delv-duplicates
  (lambda (lst)
    (delete-duplicates lst eqv?)))

(test 'delv-duplicates:null-list
  (delv-duplicates '())
  null?)

(test 'delv-duplicates:singleton-list
  (delv-duplicates '(Kilbourn))
  (lambda (result) (equal? result '(Kilbourn))))

(test 'delv-duplicates:in-doubleton-list
  (delv-duplicates '(Killduff Killduff))
  (lambda (result) (equal? result '(Killduff))))

(test 'delv-duplicates:none-removed-in-longer-list
  (delv-duplicates '(Kimballton King Kingsley Kingston Kinross)) 
  (lambda (result)
    (equal? result
            '(Kimballton King Kingsley Kingston Kinross))))

(test 'delv-duplicates:some-removed-in-longer-list
  (delv-duplicates '(Kirkman Kirkville Kirkville Kiron Kirkman
                     Klemme Kirkville Klinger Kirkville))
  (lambda (result)
    (equal? result '(Kirkman Kirkville Kiron Klemme Klinger))))

(test 'delv-duplicates:all-but-one-removed-in-longer-list
  (delv-duplicates '(Klondike Klondike Klondike Klondike Klondike))
  (lambda (result) (equal? result '(Klondike))))

;;; DELETE-DUPLICATES

(test 'delete-duplicates:null-list
  (delete-duplicates '())
  null?)

(test 'delete-duplicates:singleton-list
  (delete-duplicates '((Knierim . Knittel)))
  (lambda (result) (equal? result '((Knierim . Knittel)))))

(test 'delete-duplicates:in-doubleton-list
  (delete-duplicates '((Knoke . Knowlton) (Knoke . Knowlton)))
  (lambda (result) (equal? result '((Knoke . Knowlton)))))

(test 'delete-duplicates:none-removed-in-longer-list
  (delete-duplicates '((Knox . Knoxville)
                       (Konigsmark . Kossuth)
                       (Koszta . Lacelle)
                       (Lacey . Lacona)
                       (Ladoga . Ladora)))
  (lambda (result)
    (equal? result '((Knox . Knoxville)
                     (Konigsmark . Kossuth)
                     (Koszta . Lacelle)
                     (Lacey . Lacona)
                     (Ladoga . Ladora)))))

(test 'delete-duplicates:some-removed-in-longer-list
  (delete-duplicates '((Lafayette . Lainsville)
                       (Lakeside . Lakewood)
                       (Lakeside . Lakewood)
                       (Lakonta . Lakota)
                       (Lafayette . Lainsville)
                       (Lamoille . Lamoni)
                       (Lakeside . Lakewood)
                       (Lamont . Lancaster)
                       (Lakeside . Lakewood)))
  (lambda (result)
    (equal? result '((Lafayette . Lainsville)
                     (Lakeside . Lakewood)
                     (Lakonta . Lakota)
                     (Lamoille . Lamoni)
                     (Lamont . Lancaster)))))

(test 'delete-duplicates:all-but-one-removed-in-longer-list
  (delete-duplicates '((Lanesboro . Langdon)
                       (Lanesboro . Langdon)
                       (Lanesboro . Langdon)
                       (Lanesboro . Langdon)
                       (Lanesboro . Langdon)))
  (lambda (result) (equal? result '((Lanesboro . Langdon)))))

;;; DELQ-DUPLICATES!

(define delq-duplicates!
  (lambda (lst)
    (delete-duplicates! lst eq?)))

(test 'delq-duplicates!:null-list
  (delq-duplicates! (list))
  null?)

(test 'delq-duplicates!:singleton-list
  (delq-duplicates! (list 'Langworthy))
  (lambda (result) (equal? result '(Langworthy))))

(test 'delq-duplicates!:in-doubleton-list
  (delq-duplicates! (list 'Lansing 'Lansing))
  (lambda (result) (equal? result '(Lansing))))

(test 'delq-duplicates!:none-removed-in-longer-list
  (delq-duplicates! (list 'Lanyon 'Larchwood 'Larland 'Larrabee
                          'Latimer))
  (lambda (result)
    (equal? result
            '(Lanyon Larchwood Larland Larrabee Latimer))))

(test 'delq-duplicates!:some-removed-in-longer-list
  (delq-duplicates! (list 'Lattnerville 'Latty 'Latty 'Laurel
                          'Lattnerville 'Laurens 'Latty 'Lavinia 
                          'Latty))
  (lambda (result)
    (equal? result
            '(Lattnerville Latty Laurel Laurens Lavinia)))) 

(test 'delq-duplicates!:all-but-one-removed-in-longer-list
  (delq-duplicates! (list 'Lawler 'Lawler 'Lawler 'Lawler
                          'Lawler))
  (lambda (result) (equal? result '(Lawler))))

;;; DELV-DUPLICATES!

(define delv-duplicates!
  (lambda (lst)
    (delete-duplicates! lst eqv?)))

(test 'delv-duplicates!:null-list
  (delv-duplicates! (list))
  null?)

(test 'delv-duplicates!:singleton-list
  (delv-duplicates! (list 'Lawton))
  (lambda (result) (equal? result '(Lawton))))

(test 'delv-duplicates!:in-doubleton-list
  (delv-duplicates! (list 'Leando 'Leando))
  (lambda (result) (equal? result '(Leando))))

(test 'delv-duplicates!:none-removed-in-longer-list
  (delv-duplicates! (list 'Lebanon 'Ledyard 'Leeds 'Lehigh
                          'Leighton))
  (lambda (result)
    (equal? result '(Lebanon Ledyard Leeds Lehigh Leighton))))

(test 'delv-duplicates!:some-removed-in-longer-list
  (delv-duplicates! (list 'Leland 'Lena 'Lena 'Lenox 'Leland
                          'Leon 'Lena 'LeRoy 'Lena))
  (lambda (result)
    (equal? result '(Leland Lena Lenox Leon LeRoy))))

(test 'delv-duplicates!:all-but-one-removed-in-longer-list
  (delv-duplicates! (list 'Leslie 'Leslie 'Leslie 'Leslie
                          'Leslie))
  (lambda (result) (equal? result '(Leslie))))

;;; DELETE-DUPLICATES!

(test 'delete-duplicates!:null-list
  (delete-duplicates! (list))
  null?)

(test 'delete-duplicates!:singleton-list
  (delete-duplicates! (list (cons 'Lester 'Letts)))
  (lambda (result) (equal? result '((Lester . Letts)))))

(test 'delete-duplicates!:in-doubleton-list
  (delete-duplicates! (list (cons 'Leverette 'Levey)
                            (cons 'Leverette 'Levey)))
  (lambda (result) (equal? result '((Leverette . Levey)))))

(test 'delete-duplicates!:none-removed-in-longer-list
  (delete-duplicates! (list (cons 'Lewis 'Lexington)
                            (cons 'Liberty 'Libertyville)
                            (cons 'Lidderdale 'Lima)
                            (cons 'Linby 'Lincoln)
                            (cons 'Linden 'Lineville)))
  (lambda (result)
    (equal? result '((Lewis . Lexington)
                     (Liberty . Libertyville)
                     (Lidderdale . Lima)
                     (Linby . Lincoln)
                     (Linden . Lineville)))))

(test 'delete-duplicates!:some-removed-in-longer-list
  (delete-duplicates! (list (cons 'Lisbon 'Liscomb)
                            (cons 'Littleport 'Littleton)
                            (cons 'Littleport 'Littleton)
                            (cons 'Livermore 'Livingston)
                            (cons 'Lisbon 'Liscomb)
                            (cons 'Lockman 'Lockridge)
                            (cons 'Littleport 'Littleton)
                            (cons 'Locust 'Logan)
                            (cons 'Littleport 'Littleton)))
  (lambda (result)
    (equal? result '((Lisbon . Liscomb)
                     (Littleport . Littleton)
                     (Livermore . Livingston)
                     (Lockman . Lockridge)
                     (Locust . Logan)))))

(test 'delete-duplicates!:all-but-one-removed-in-longer-list
  (delete-duplicates! (list (cons 'Logansport 'Lohrville)
                            (cons 'Logansport 'Lohrville)
                            (cons 'Logansport 'Lohrville)
                            (cons 'Logansport 'Lohrville)
                            (cons 'Logansport 'Lohrville)))
  (lambda (result)
    (equal? result '((Logansport . Lohrville)))))

;;; MEM

(define mem
  (lambda (elm= x lst)
    (srfi-1:member x lst elm=)))

(test 'mem:null-list
  (mem (lambda (x y) #t) 'Lorah '())
  not)

(let ((source '(Lore)))
  (test 'mem:in-singleton-list
    (mem (lambda (x y) #t) 'Lorimor source)
    (lambda (result) (eq? result source))))

(test 'mem:not-in-singleton-list
  (mem (lambda (x y) #f) 'Loring '(Loring))
  not)

(let ((source '(Lossing Louisa Lourdes Loveland Lovilla)))
  (test 'mem:at-beginning-of-longer-list
    (mem (lambda (x y) #t) 'Lovington source)
    (lambda (result) (eq? result source))))

(let ((source '(521 522 523 524 528 525 526)))
  (test 'mem:in-middle-of-longer-list
    (mem < 527 source)
    (lambda (result) (eq? result (cddddr source)))))

(let ((source '(529 530 531 532 534)))
  (test 'mem:at-end-of-longer-list
    (mem < 533 source)
    (lambda (result) (eq? result (cddddr source)))))

(test 'mem:not-in-longer-list
  (mem (lambda (x y) #f)
       'Lowden
       '(Lowell Luana Lucas Ludlow Lundgren))
  not)

;;; ASS

(define ass
  (lambda (elm= x lst)
    (srfi-1:assoc x lst elm=)))

(test 'ass:null-list
  (ass (lambda (x y) #t) 'Lunsford '())
  not)

(let ((source '((Luray . Luther))))
  (test 'ass:in-singleton-list
    (ass (lambda (x y) #t) 'Luton source)
    (lambda (result) (eq? result (car source)))))

(test 'ass:not-in-singleton-list
  (ass (lambda (x y) #f) 'LuVerne '((Luxemburg . Luzerne)))
  not)

(let ((source '((Lycurgus . Lyman)
                (Lyndale . Lynnville)
                (Lytton . Macedonia)
                (Mackey . Macksburg)
                (Madrid . Magnolia))))
  (test 'ass:at-beginning-of-longer-list
    (ass (lambda (x y) #t) 'Maine source)
    (lambda (result) (eq? result (car source)))))

(let ((source '((535 . 536)
                (537 . 538)
                (539 . 540)
                (541 . 542)
                (549 . 543)
                (544 . 545)
                (546 . 547))))
  (test 'ass:in-middle-of-longer-list
    (ass < 548 source)
    (lambda (result) (eq? result (car (cddddr source))))))

(let ((source '((550 . 551)
                (552 . 553)
                (554 . 555)
                (556 . 557)
                (560 . 558))))
  (test 'ass:at-end-of-longer-list
    (ass < 559 source)
    (lambda (result) (eq? result (car (cddddr source))))))

(test 'ass:not-in-longer-list
  (ass (lambda (x y) #f)
       'Malcom
       '((Malcom . Mallard)
         (Malcom . Malone)
         (Malcom . Maloy)
         (Malcom . Malvern)
         (Malcom . Mammon)))
  not)

;;; ACONS

(define acons alist-cons)

(test 'acons:null-list
  (acons 'Manawa 'Manchester '())
  (lambda (result) (equal? result '((Manawa . Manchester)))))

(let ((base '((Manilla . Manly))))
  (test 'acons:singleton-list
    (acons 'Manning 'Manson base)
    (lambda (result)
      (and (equal? result '((Manning . Manson)
                            (Manilla . Manly)))
           (eq? (cdr result) base)))))

(let ((base '((Manteno . Mapleside)
              (Mapleton . Maquoketa)
              (Marathon . Marcus)
              (Marengo . Marietta)
              (Marion . Mark))))
  (test 'acons:longer-list
    (acons 'Marne 'Marquette base)
    (lambda (result)
      (and (equal? result '((Marne . Marquette)
                            (Manteno . Mapleside)
                            (Mapleton . Maquoketa)
                            (Marathon . Marcus)
                            (Marengo . Marietta)
                            (Marion . Mark)))
           (eq? (cdr result) base)))))

(let ((base '((Marquisville . Marsh)
              (Marshalltown . Martelle)
              (Martensdale . Martinsburg)
              (Martinstown . Marysville)
              (Masonville . Massena)
              (Massey . Massilon)
              (Matlock . Maud))))
  (test 'acons:longer-list-with-duplicate-key
    (acons 'Masonville 'Maurice base)
    (lambda (result)
      (and (equal? result '((Masonville . Maurice)
                            (Marquisville . Marsh)
                            (Marshalltown . Martelle)
                            (Martensdale . Martinsburg)
                            (Martinstown . Marysville)
                            (Masonville . Massena)
                            (Massey . Massilon)
                            (Matlock . Maud)))
           (eq? (cdr result) base)))))

;;; ALIST-COPY

(test 'alist-copy:null-list
  (alist-copy '())
  null?)

(let ((original '((Maxon . Maxwell)
                  (Maynard . Maysville)
                  (McCallsburg . McCausland)
                  (McClelland . McGregor)
                  (McIntire . McNally))))
  (test 'alist-copy:flat-list
    (alist-copy original)
    (lambda (result)
      (and (equal? result original)
           (not (eq? result original))
           (not (eq? (car result) (car original)))
           (not (eq? (cdr result) (cdr original)))
           (not (eq? (cadr result) (cadr original)))
           (not (eq? (cddr result) (cddr original)))
           (not (eq? (caddr result) (caddr original)))
           (not (eq? (cdddr result) (cdddr original)))
           (not (eq? (cadddr result) (cadddr original)))
           (not (eq? (cddddr result) (cddddr original)))
           (not (eq? (car (cddddr result))
                     (car (cddddr original))))))))

(let ((first '(McPaul))
      (second '(McPherson
                Mechanicsville
                Mederville
                (Mediapolis Medora)
                ((Mekee Melbourne Melcher))))
      (third 'Melrose))
  (let ((original (list (cons 'Meltonville first)
                        (cons 'Melvin second)
                        (cons 'Menlo third))))
    (test 'alist-copy:bush
      (alist-copy original)
      (lambda (result)
        (and (equal? result original)
             (not (eq? result original))
             (not (eq? (car result) (car original)))
             (eq? (cdar result) first)
             (not (eq? (cdr result) (cdr original)))
             (not (eq? (cadr result) (cadr original)))
             (eq? (cdadr result) second)
             (not (eq? (cddr result) (cddr original)))
             (not (eq? (caddr result) (caddr original)))
             (eq? (cdaddr result) third))))))

;;; ALIST-DELETE

(test 'alist-delete:null-list
  (alist-delete 'Mercer '() (lambda (x y) #t))
  null?)

(test 'alist-delete:singleton-list
  (alist-delete
                'Meriden
                '((Merrill . Merrimac))
                (lambda (x y) #f))
  (lambda (result) (equal? result '((Merrill . Merrimac)))))

(test 'alist-delete:all-elements-removed
  (alist-delete
                'Meservey
                '((Metz . Meyer)
                  (Middleburg . Middletwon)
                  (Midvale . Midway)
                  (Miles . Milford)
                  (Miller . Millersburg))
                (lambda (x y) #t))
  null?)

(test 'alist-delete:some-elements-removed
  (alist-delete
                561
                '((562 . 563)
                  (565 . 564)
                  (566 . 567)
                  (569 . 568)
                  (570 . 571))
                (lambda (x y) (odd? (+ x y))))
  (lambda (result)
    (equal? result '((565 . 564) (569 . 568)))))

(test 'alist-delete:no-elements-removed
  (alist-delete
                'Millerton
                '((Millman . Millnerville)
                  (Millville . Milo)
                  (Milton . Minburn)
                  (Minden . Mineola)
                  (Minerva . Mingo))
                (lambda (x y) #f))
  (lambda (result)
    (equal? result '((Millman . Millnerville)
                     (Millville . Milo)
                     (Milton . Minburn)
                     (Minden . Mineola)
                     (Minerva . Mingo)))))

;;; ALIST-DELETE!

(test 'alist-delete!:null-list
  (alist-delete! 'Mitchell '() (lambda (x y) #t))
  null?)

(test 'alist-delete!:singleton-list
  (alist-delete!
                 'Mitchellville
                 (list (cons 'Modale 'Moingona))
                 (lambda (x y) #f))
  (lambda (result) (equal? result '((Modale . Moingona)))))

(test 'alist-delete!:all-elements-removed
  (alist-delete!
                'Mona
                (list (cons 'Mondamin 'Moneta)
                      (cons 'Moningers 'Monmouth)
                      (cons 'Monona 'Monroe)
                      (cons 'Monteith 'Monterey)
                      (cons 'Montezuma 'Montgomery))
                (lambda (x y) #t))
  null?)

(test 'alist-delete!:some-elements-removed
  (alist-delete!
                 572
                 (list (cons 573 574)
                       (cons 576 575)
                       (cons 577 578)
                       (cons 580 579)
                       (cons 581 582))
                 (lambda (x y) (even? (+ x y))))
  (lambda (result)
    (equal? result '((573 . 574) (577 . 578) (581 . 582)))))

(test 'alist-delete!:no-elements-removed
  (alist-delete!
                 'Monti
                 (list (cons 'Monticello 'Montour)
                       (cons 'Montpelier 'Montrose)
                       (cons 'Mooar 'Moorhead)
                       (cons 'Moorland 'Moran)
                       (cons 'Moravia 'Morley))
                 (lambda (x y) #f))
  (lambda (result)
    (equal? result '((Monticello . Montour)
                     (Montpelier . Montrose)
                     (Mooar . Moorhead)
                     (Moorland . Moran)
                     (Moravia . Morley)))))

;;;;; DEL-ASS
;;
;;(test 'del-ass:null-list
;;  (del-ass (lambda (x y) #t) 'Morningside '())
;;  null?)
;;
;;(test 'del-ass:singleton-list
;;  (del-ass (lambda (x y) #f) 'Morrison '((Morse . Moscow)))
;;  (lambda (result) (equal? result '((Morse . Moscow)))))
;;
;;(test 'del-ass:all-elements-removed
;;  (del-ass (lambda (x y) #t) 'Motor '((Moulton . Moville)
;;                                      (Munterville . Murray)
;;                                      (Muscatine . Mystic)
;;                                      (Napier . Nashua)
;;                                      (Nashville . National)))
;;  null?)
;;
;;(test 'del-ass:some-elements-removed
;;  (del-ass (lambda (x y) (even? (+ x y))) 583 '((584 . 585)
;;                                                (587 . 586)
;;                                                (588 . 589)
;;                                                (591 . 590)
;;                                                (592 . 593)))
;;  (lambda (result)
;;    (equal? result '((584 . 585) (588 . 589) (592 . 593)))))
;;
;;(test 'del-ass:no-elements-removed
;;  (del-ass (lambda (x y) #f) 'Nemaha '((Neola . Neptune)
;;                                       (Nevada . Nevinville)
;;                                       (Newbern . Newburg)
;;                                       (Newell . Newhall)
;;                                       (Newkirk . Newport)))
;;  (lambda (result)
;;    (equal? result '((Neola . Neptune)
;;                     (Nevada . Nevinville)
;;                     (Newbern . Newburg)
;;                     (Newell . Newhall)
;;                     (Newkirk . Newport)))))
;;
;;;;; DEL-ASS!
;;
;;(test 'del-ass!:null-list
;;  (del-ass! (lambda (x y) #t) 'Newton '())
;;  null?)
;;
;;(test 'del-ass!:singleton-list
;;  (del-ass! (lambda (x y) #f)
;;            'Nichols
;;            (list (cons 'Nira 'Nishna))) 
;;  (lambda (result) (equal? result '((Nira . Nishna)))))
;;
;;(test 'del-ass!:all-elements-removed
;;  (del-ass! (lambda (x y) #t)
;;            'Noble
;;            (list (cons 'Nodaway 'Norness)
;;                  (cons 'Northboro 'Northfield)
;;                  (cons 'Northwood 'Norwalk)
;;                  (cons 'Norway 'Norwich)
;;                  (cons 'Norwood 'Norwoodville)))
;;  null?)
;;
;;(test 'del-ass!:some-elements-removed
;;  (del-ass! (lambda (x y) (odd? (+ x y)))
;;            594
;;            (list (cons 595 596)
;;                  (cons 598 597)
;;                  (cons 599 600)
;;                  (cons 602 601)
;;                  (cons 603 604)))
;;  (lambda (result)
;;    (equal? result '((598 . 597) (602 . 601)))))
;;
;;(test 'del-ass!:no-elements-removed
;;  (del-ass! (lambda (x y) #f)
;;            'Numa
;;            (list (cons 'Nyman 'Oakdale)
;;                  (cons 'Oakley 'Oakville)
;;                  (cons 'Oakwood 'Oasis)
;;                  (cons 'Ocheyedan 'Odebolt)
;;                  (cons 'Oelwein 'Ogden)))
;;  (lambda (result)
;;    (equal? result '((Nyman . Oakdale)
;;                     (Oakley . Oakville)
;;                     (Oakwood . Oasis)
;;                     (Ocheyedan . Odebolt)
;;                     (Oelwein . Ogden)))))
;;
;;;;; DEL-ASSQ
;;
;;(test 'del-assq:null-list
;;  (del-assq 'Okoboji '())
;;  null?)
;;
;;(test 'del-assq:in-singleton-list
;;  (del-assq 'Olaf '((Olaf . Olds)))
;;  null?)
;;
;;(test 'del-assq:not-in-singleton-list
;;  (del-assq 'Olin '((Olivet . Ollie)))
;;  (lambda (result) (equal? result '((Olivet . Ollie)))))
;;
;;(test 'del-assq:at-beginning-of-longer-list
;;  (del-assq 'Olmitz '((Olmitz . Onawa)
;;                      (Oneida . Onslow)
;;                      (Ontario . Oralabor)
;;                      (Oran . Orange)
;;                      (Orchard . Orient)))
;;  (lambda (result)
;;    (equal? result '((Oneida . Onslow)
;;                     (Ontario . Oralabor)
;;                     (Oran . Orange)
;;                     (Orchard . Orient)))))
;;
;;(test 'del-assq:in-middle-of-longer-list
;;  (del-assq 'Orilla '((Orleans . Ormanville)
;;                      (Orson . Ortonville)
;;                      (Osage . Osborne)
;;                      (Osceola . Osgood)
;;                      (Orilla . Oskaloosa)
;;                      (Ossian . Osterdock)
;;                      (Oswalt . Otho)))
;;  (lambda (result)
;;    (equal? result '((Orleans . Ormanville)
;;                     (Orson . Ortonville)
;;                     (Osage . Osborne)
;;                     (Osceola . Osgood)
;;                     (Ossian . Osterdock)
;;                     (Oswalt . Otho)))))
;;
;;(test 'del-assq:at-end-of-longer-list
;;  (del-assq 'Otley '((Oto . Otranto)
;;                     (Ottawa . Otterville)
;;                     (Ottosen . Ottumwa)
;;                     (Owasa . Owego)
;;                     (Otley . Oxford)))
;;  (lambda (result)
;;    (equal? result '((Oto . Otranto)
;;                     (Ottawa . Otterville)
;;                     (Ottosen . Ottumwa)
;;                     (Owasa . Owego)))))
;;
;;(test 'del-assq:not-in-longer-list
;;  (del-assq 'Oyens '((Ozark .Packard)
;;                     (Packwood . Palmer)
;;                     (Palmyra . Palo)
;;                     (Panama . Panora)
;;                     (Panther . Paralta)))
;;  (lambda (result)
;;    (equal? result '((Ozark .Packard)
;;                     (Packwood . Palmer)
;;                     (Palmyra . Palo)
;;                     (Panama . Panora)
;;                     (Panther . Paralta)))))
;;
;;(test 'del-assq:several-matches-in-longer-list
;;  (del-assq 'Paris '((Parkersburg . Parkview)
;;                     (Parnell . Paton)
;;                     (Paris . Patterson)
;;                     (Paullina . Pekin)
;;                     (Paris . Pella)
;;                     (Peoria . Peosta)
;;                     (Paris . Percival)))
;;  (lambda (result)
;;    (equal? result '((Parkersburg . Parkview)
;;                     (Parnell . Paton)
;;                     (Paullina . Pekin)
;;                     (Peoria . Peosta)))))
;;
;;;;; DEL-ASSV
;;
;;(test 'del-assv:null-list
;;  (del-assv 'Perkins '())
;;  null?)
;;
;;(test 'del-assv:in-singleton-list
;;  (del-assv 'Perlee '((Perlee . Perry)))
;;  null?)
;;
;;(test 'del-assv:not-in-singleton-list
;;  (del-assv 'Pershing '((Persia . Peter)))
;;  (lambda (result) (equal? result '((Persia . Peter)))))
;;
;;(test 'del-assv:at-beginning-of-longer-list
;;  (del-assv 'Petersburg '((Petersburg . Peterson)
;;                          (Petersville . Philby)
;;                          (Pickering . Pierson)
;;                          (Pilotsburg . Pioneer)
;;                          (Piper . Pisgah)))
;;  (lambda (result)
;;    (equal? result '((Petersville . Philby)
;;                     (Pickering . Pierson)
;;                     (Pilotsburg . Pioneer)
;;                     (Piper . Pisgah)))))
;;
;;(test 'del-assv:in-middle-of-longer-list
;;  (del-assv 'Pittsburg '((Pitzer . Plainfield)
;;                         (Plainview . Plano)
;;                         (Pleasanton . Pleasantville)
;;                         (Plessis . Plover)
;;                         (Pittsburg . Plymouth)
;;                         (Pocahontas . Pomeroy)
;;                         (Popejoy . Poplar)))
;;  (lambda (result)
;;    (equal? result '((Pitzer . Plainfield)
;;                     (Plainview . Plano)
;;                     (Pleasanton . Pleasantville)
;;                     (Plessis . Plover)
;;                     (Pocahontas . Pomeroy)
;;                     (Popejoy . Poplar)))))
;;
;;(test 'del-assv:at-end-of-longer-list
;;  (del-assv 'Portland '((Portsmouth . Postville)
;;                        (Powersville . Prairieburg)
;;                        (Prescott . Preston)
;;                        (Primghar . Primrose)
;;                        (Portland . Princeton)))
;;  (lambda (result)
;;    (equal? result '((Portsmouth . Postville)
;;                     (Powersville . Prairieburg)
;;                     (Prescott . Preston)
;;                     (Primghar . Primrose)))))
;;
;;(test 'del-assv:not-in-longer-list
;;  (del-assv 'Probstel '((Prole . Protivin)
;;                        (Pulaski . Purdy)
;;                        (Quandahl . Quarry)
;;                        (Quasqueton . Quick)
;;                        (Quimby . Quincy)))
;;  (lambda (result)
;;    (equal? result '((Prole . Protivin)
;;                     (Pulaski . Purdy)
;;                     (Quandahl . Quarry)
;;                     (Quasqueton . Quick)
;;                     (Quimby . Quincy)))))
;;
;;(test 'del-assv:several-matches-in-longer-list
;;  (del-assv 'Radcliffe '((Rake . Raleigh)
;;                         (Ralston . Randalia)
;;                         (Radcliffe . Randall)
;;                         (Randolph . Rands)
;;                         (Radcliffe . Rathbun)
;;                         (Raymar . Raymond)
;;                         (Radcliffe . Readlyn)))
;;  (lambda (result)
;;    (equal? result '((Rake . Raleigh)
;;                     (Ralston . Randalia)
;;                     (Randolph . Rands)
;;                     (Raymar . Raymond)))))
;;
;;;;; DEL-ASSOC
;;
;;(test 'del-assoc:null-list
;;  (del-assoc '(Reasnor . Redding) '())
;;  null?)
;;
;;(test 'del-assoc:in-singleton-list
;;  (del-assoc '(Redfield . Reeceville)
;;             '(((Redfield . Reeceville) . Reinbeck)))
;;  null?)
;;
;;(test 'del-assoc:not-in-singleton-list
;;  (del-assoc '(Rembrandt . Remsen)
;;             '(((Renwick . Republic) . Rhodes)))
;;  (lambda (result)
;;    (equal? result '(((Renwick . Republic) . Rhodes)))))
;;
;;(test 'del-assoc:at-beginning-of-longer-list
;;  (del-assoc '(Riceville . Richard)
;;             '(((Riceville . Richard) . Richfield)
;;               ((Richland . Richmond) . Rickardsville)
;;               ((Ricketts . Rider) . Ridgeport)
;;               ((Ridgeway . Riggs) . Rinard)
;;               ((Ringgold . Ringsted) . Rippey)))
;;  (lambda (result)
;;    (equal? result '(((Richland . Richmond) . Rickardsville)
;;                     ((Ricketts . Rider) . Ridgeport)
;;                     ((Ridgeway . Riggs) . Rinard)
;;                     ((Ringgold . Ringsted) . Rippey)))))
;;
;;(test 'del-assoc:in-middle-of-longer-list
;;  (del-assoc '(Ritter . Riverdale)
;;             '(((Riverside . Riverton) . Roberts)
;;               ((Robertson . Robins) . Robinson)
;;               ((Rochester . Rockdale) . Rockford)
;;               ((Rockville . Rockwell) . Rodman)
;;               ((Ritter . Riverdale) . Rodney)
;;               ((Roelyn . Rogers) . Roland)
;;               ((Rolfe . Rome) . Roscoe)))
;;  (lambda (result)
;;    (equal? result '(((Riverside . Riverton) . Roberts)
;;                     ((Robertson . Robins) . Robinson)
;;                     ((Rochester . Rockdale) . Rockford)
;;                     ((Rockville . Rockwell) . Rodman)
;;                     ((Roelyn . Rogers) . Roland)
;;                     ((Rolfe . Rome) . Roscoe)))))
;;
;;(test 'del-assoc:at-end-of-longer-list
;;  (del-assoc '(Rose . Roselle)
;;             '(((Roseville . Ross) . Rosserdale)
;;               ((Rossie . Rossville) . Rowan)
;;               ((Rowley . Royal) . Rubio)
;;               ((Ruble . Rudd) . Runnells)
;;               ((Rose . Roselle) . Russell)))
;;  (lambda (result)
;;    (equal? result '(((Roseville . Ross) . Rosserdale)
;;                     ((Rossie . Rossville) . Rowan)
;;                     ((Rowley . Royal) . Rubio)
;;                     ((Ruble . Rudd) . Runnells)))))
;;
;;(test 'del-assoc:not-in-longer-list
;;  (del-assoc '(Ruthven . Rutland)
;;             '(((Rutledge . Ryan) . Sabula)
;;               ((Sageville . Salem) . Salina)
;;               ((Salix . Sanborn) . Sandusky)
;;               ((Sandyville . Santiago) . Saratoga)
;;               ((Sattre . Saude) . Savannah)))
;;  (lambda (result)
;;    (equal? result '(((Rutledge . Ryan) . Sabula)
;;                     ((Sageville . Salem) . Salina)
;;                     ((Salix . Sanborn) . Sandusky)
;;                     ((Sandyville . Santiago) . Saratoga)
;;                     ((Sattre . Saude) . Savannah)))))
;;
;;(test 'del-assoc:several-matches-in-longer-list
;;  (del-assoc '(Sawyer . Saylor)
;;             '(((Saylorville . Scarville) . Schaller)
;;               ((Schleswig . Schley) . Sciola)
;;               ((Sawyer . Saylor) . Scranton)
;;               ((Searsboro . Sedan) . Selma)
;;               ((Sawyer . Saylor) . Seneca)
;;               ((Seney . Sewal) . Sexton)
;;               ((Sawyer . Saylor) . Seymour)))
;;  (lambda (result)
;;    (equal? result '(((Saylorville . Scarville) . Schaller)
;;                     ((Schleswig . Schley) . Sciola)
;;                     ((Searsboro . Sedan) . Selma)
;;                     ((Seney . Sewal) . Sexton)))))
;;
;;;;; DEL-ASSQ!
;;
;;(test 'del-assq!:null-list
;;  (del-assq! 'Shaffton (list))
;;  null?)
;;
;;(test 'del-assq!:in-singleton-list
;;  (del-assq! 'Shambaugh (list (cons 'Shambaugh 'Sharon)))
;;  null?)
;;
;;(test 'del-assq!:not-in-singleton-list
;;  (del-assq! 'Sharpsburg (list (cons 'Shawondasse 'Sheffield)))
;;  (lambda (result)
;;    (equal? result '((Shawondasse . Sheffield))))) 
;;
;;(test 'del-assq!:at-beginning-of-longer-list
;;  (del-assq! 'Shelby (list (cons 'Shelby 'Sheldahl)
;;                           (cons 'Sheldon 'Shellsburg)
;;                           (cons 'Shenandoah 'Sheridan)
;;                           (cons 'Sherrill 'Sherwood)
;;                           (cons 'Shipley 'Shueyville)))
;;  (lambda (result)
;;    (equal? result '((Sheldon . Shellsburg)
;;                     (Shenandoah . Sheridan)
;;                     (Sherrill . Sherwood)
;;                     (Shipley . Shueyville)))))
;;
;;(test 'del-assq!:in-middle-of-longer-list
;;  (del-assq! 'Siam (list (cons 'Sibley 'Sidney)
;;                         (cons 'Sigourney 'Sinclair)
;;                         (cons 'Sixmile 'Sixteen)
;;                         (cons 'Slater 'Slifer)
;;                         (cons 'Siam 'Sloan)
;;                         (cons 'Smithland 'Smiths)
;;                         (cons 'Smyrna 'Soldier)))
;;  (lambda (result)
;;    (equal? result '((Sibley . Sidney)
;;                     (Sigourney . Sinclair)
;;                     (Sixmile . Sixteen)
;;                     (Slater . Slifer)
;;                     (Smithland . Smiths)
;;                     (Smyrna . Soldier)))))
;;
;;(test 'del-assq!:at-end-of-longer-list
;;  (del-assq! 'Solomon (list (cons 'Solon 'Somers)
;;                            (cons 'Spaulding 'Spencer)
;;                            (cons 'Sperry 'Spillville)
;;                            (cons 'Sprague 'Spragueville)
;;                            (cons 'Solomon 'Springbrook)))
;;  (lambda (result)
;;    (equal? result '((Solon . Somers)
;;                     (Spaulding . Spencer)
;;                     (Sperry . Spillville)
;;                     (Sprague . Spragueville)))))
;;
;;(test 'del-assq!:not-in-longer-list
;;  (del-assq! 'Springdale (list (cons 'Springville 'Stacyville)
;;                               (cons 'Stanhope 'Stanley)
;;                               (cons 'Stanton 'Stanwood)
;;                               (cons 'Stanzel 'Stennett)
;;                               (cons 'Sterling 'Stevens)))
;;  (lambda (result)
;;    (equal? result '((Springville . Stacyville)
;;                     (Stanhope . Stanley)
;;                     (Stanton . Stanwood)
;;                     (Stanzel . Stennett)
;;                     (Sterling . Stevens)))))
;;
;;(test 'del-assq!:several-matches-in-longer-list
;;  (del-assq! 'Stiles (list (cons 'Stilson 'Stockport)
;;                           (cons 'Stockton 'Stonega)
;;                           (cons 'Stiles 'Stout)
;;                           (cons 'Strahan 'Stratford)
;;                           (cons 'Stiles 'Streepyville)
;;                           (cons 'Stringtown 'Struble)
;;                           (cons 'Stiles 'Stuart)))
;;  (lambda (result)
;;    (equal? result '((Stilson . Stockport)
;;                     (Stockton . Stonega)
;;                     (Strahan . Stratford)
;;                     (Stringtown . Struble)))))
;;
;;;;; DEL-ASSV!
;;
;;(test 'del-assv!:null-list
;;  (del-assv! 'Sully (list))
;;  null?)
;;
;;(test 'del-assv!:in-singleton-list
;;  (del-assv! 'Summerset (list (cons 'Summerset 'Summitville)))
;;  null?)
;;
;;(test 'del-assv!:not-in-singleton-list
;;  (del-assv! 'Sumner (list (cons 'Sunbury 'Sunshine)))
;;  (lambda (result)
;;    (equal? result '((Sunbury . Sunshine))))) 
;;
;;(test 'del-assv!:at-beginning-of-longer-list
;;  (del-assv! 'Superior (list (cons 'Superior 'Sutherland)
;;                             (cons 'Sutiff 'Swaledale)
;;                             (cons 'Swan 'Swanwood)
;;                             (cons 'Swedesburg 'Swisher)
;;                             (cons 'Tabor 'Taintor)))
;;  (lambda (result)
;;    (equal? result '((Sutiff . Swaledale)
;;                     (Swan . Swanwood)
;;                     (Swedesburg . Swisher)
;;                     (Tabor . Taintor)))))
;;
;;(test 'del-assv!:in-middle-of-longer-list
;;  (del-assv! 'Talleyrand (list (cons 'Talmage 'Tama)
;;                               (cons 'Tara 'Taylor)
;;                               (cons 'Taylorsville 'Templeton)
;;                               (cons 'Tenmile 'Tennant)
;;                               (cons 'Talleyrand 'Tenville)
;;                               (cons 'Terril 'Thayer)
;;                               (cons 'Thirty 'Thomasville)))
;;  (lambda (result)
;;    (equal? result '((Talmage . Tama)
;;                     (Tara . Taylor)
;;                     (Taylorsville . Templeton)
;;                     (Tenmile . Tennant)
;;                     (Terril . Thayer)
;;                     (Thirty . Thomasville)))))
;;
;;(test 'del-assv!:at-end-of-longer-list
;;  (del-assv! 'Thompson (list (cons 'Thor 'Thornburg)
;;                             (cons 'Thornton 'Thorpe)
;;                             (cons 'Thurman 'Ticonic)
;;                             (cons 'Tiffin 'Tilton)
;;                             (cons 'Thompson 'Tingley)))
;;  (lambda (result)
;;    (equal? result '((Thor . Thornburg)
;;                     (Thornton . Thorpe)
;;                     (Thurman . Ticonic)
;;                     (Tiffin . Tilton)))))
;;
;;(test 'del-assv!:not-in-longer-list
;;  (del-assv! 'Tipton (list (cons 'Titonka 'Tivali)
;;                           (cons 'Toddville 'Toeterville)
;;                           (cons 'Toledo 'Toolesboro)
;;                           (cons 'Toronto 'Tracy)
;;                           (cons 'Traer 'Trenton)))
;;  (lambda (result)
;;    (equal? result '((Titonka . Tivali)
;;                     (Toddville . Toeterville)
;;                     (Toledo . Toolesboro)
;;                     (Toronto . Tracy)
;;                     (Traer . Trenton)))))
;;
;;(test 'del-assv!:several-matches-in-longer-list
;;  (del-assv! 'Treynor (list (cons 'Tripoli 'Troy)
;;                            (cons 'Truesdale 'Truro)
;;                            (cons 'Treynor 'Turin)
;;                            (cons 'Tuskeego 'Tyrone)
;;                            (cons 'Treynor 'Udell)
;;                            (cons 'Ulmer 'Underwood)
;;                            (cons 'Treynor 'Union)))
;;  (lambda (result)
;;    (equal? result '((Tripoli . Troy)
;;                     (Truesdale . Truro)
;;                     (Tuskeego . Tyrone)
;;                     (Ulmer . Underwood)))))
;;
;;;;; DEL-ASSOC!
;;
;;(test 'del-assoc!:null-list
;;  (del-assoc! (cons 'Unionville 'Unique) (list))
;;  null?)
;;
;;(test 'del-assoc!:in-singleton-list
;;  (del-assoc! (cons 'Updegraff 'Urbana)
;;              (list (cons (cons 'Updegraff 'Urbana)
;;                          'Summitville)))
;;  null?)
;;
;;(test 'del-assoc!:not-in-singleton-list
;;  (del-assoc! (cons 'Urbandale 'Ute)
;;              (list (cons (cons 'Utica 'Vail) 'Valeria)))
;;  (lambda (result)
;;    (equal? result '(((Utica . Vail) . Valeria)))))
;;
;;(test 'del-assoc!:at-beginning-of-longer-list
;;  (del-assoc! (cons 'Valley 'Vandalia)
;;              (list (cons (cons 'Valley 'Vandalia) 'Varina)
;;                    (cons (cons 'Ventura 'Vernon) 'Victor)
;;                    (cons (cons 'Viele 'Villisca) 'Vincennes)
;;                    (cons (cons 'Vincent 'Vining) 'Vinje)
;;                    (cons (cons 'Vinton 'Viola) 'Volga)))
;;  (lambda (result)
;;    (equal? result '(((Ventura . Vernon) . Victor)
;;                     ((Viele . Villisca) . Vincennes)
;;                     ((Vincent . Vining) . Vinje)
;;                     ((Vinton . Viola) . Volga)))))
;;
;;(test 'del-assoc!:in-middle-of-longer-list
;;  (del-assoc! (cons 'Volney 'Voorhies)
;;              (list (cons (cons 'Wadena 'Wahpeton) 'Walcott)
;;                    (cons (cons 'Wald 'Wales) 'Walford)
;;                    (cons (cons 'Walker 'Wallin) 'Wallingford)
;;                    (cons (cons 'Walnut 'Wapello) 'Ward)
;;                    (cons (cons 'Volney 'Voorhies) 'Ware)
;;                    (cons (cons 'Washburn 'Washington) 'Washta)
;;                    (cons (cons 'Waterloo 'Waterville)
;;                          'Watkins)))
;;  (lambda (result)
;;    (equal? result '(((Wadena . Wahpeton) . Walcott)
;;                     ((Wald . Wales) . Walford)
;;                     ((Walker . Wallin) . Wallingford)
;;                     ((Walnut . Wapello) . Ward)
;;                     ((Washburn . Washington) . Washta)
;;                     ((Waterloo . Waterville) . Watkins)))))
;;
;;(test 'del-assoc!:at-end-of-longer-list
;;  (del-assoc! (cons 'Watson 'Watterson)
;;              (list (cons (cons 'Waubeek 'Waucoma) 'Waukee)
;;                    (cons (cons 'Waukon 'Waupeton) 'Waverly)
;;                    (cons (cons 'Wayland 'Webb) 'Webster)
;;                    (cons (cons 'Weldon 'Weller) 'Wellman)
;;                    (cons (cons 'Watson 'Watterson) 'Wellsburg)))
;;  (lambda (result)
;;    (equal? result '(((Waubeek . Waucoma) . Waukee)
;;                     ((Waukon . Waupeton) . Waverly)
;;                     ((Wayland . Webb) . Webster)
;;                     ((Weldon . Weller) . Wellman)))))
;;
;;(test 'del-assoc!:not-in-longer-list
;;  (del-assoc! (cons 'Welton 'Wesley)
;;              (list (cons (cons 'Western 'Westerville)
;;                          'Westfield)
;;                    (cons (cons 'Westgate 'Weston) 'Westphalia)
;;                    (cons (cons 'Westside 'Westview) 'Wever)
;;                    (cons (cons 'Wheatland 'Whiting)
;;                          'Whittemore)
;;                    (cons (cons 'Whitten 'Whittier) 'Wichita)))
;;  (lambda (result)
;;    (equal? result '(((Western . Westerville) . Westfield)
;;                     ((Westgate . Weston) . Westphalia)
;;                     ((Westside . Westview) . Wever)
;;                     ((Wheatland . Whiting) . Whittemore)
;;                     ((Whitten . Whittier) . Wichita)))))
;;
;;(test 'del-assoc!:several-matches-in-longer-list
;;  (del-assoc! (cons 'Wick 'Wightman)
;;              (list (cons (cons 'Wilke 'Willey) 'Williams)
;;                    (cons (cons 'Williamsburg 'Williamson)
;;                          'Williamstown)
;;                    (cons (cons 'Wick 'Wightman) 'Wilmar)
;;                    (cons (cons 'Wilton 'Winchester) 'Windham)
;;                    (cons (cons 'Wick 'Wightman) 'Winfield)
;;                    (cons (cons 'Winkelmans 'Winterset)
;;                          'Winthrop)
;;                    (cons (cons 'Wick 'Wightman) 'Wiota)))
;;  (lambda (result)
;;    (equal? result '(((Wilke . Willey) . Williams)
;;                     ((Williamsburg . Williamson)
;;                      . Williamstown)
;;                     ((Wilton . Winchester) . Windham)
;;                     ((Winkelmans . Winterset) . Winthrop)))))


(total-report)

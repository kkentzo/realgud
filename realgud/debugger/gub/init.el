;;; Copyright (C) 2013 Rocky Bernstein <rocky@gnu.org>
;;; Regular expressions for Go SSA debugger: gub

(eval-when-compile (require 'cl))

(require 'load-relative)
(require-relative-list '("../../common/regexp"
			 "../../common/loc"
			 "../../common/init")
		       "realgud-")

(defvar realgud-pat-hash)
(declare-function make-realgud-loc-pat (realgud-loc))

(defvar realgud-gub-pat-hash (make-hash-table :test 'equal)
  "Hash key is the what kind of pattern we want to match:
backtrace, prompt, etc.  The values of a hash entry is a
realgud-loc-pat struct")

;; Regular expression that describes a gub location generally shown
;; before a command prompt.
;; For example:
;; interp/testdata/square.go:16:2-17
(setf (gethash "loc" realgud-gub-pat-hash)
      (make-realgud-loc-pat
       :regexp
       "\\(?:^\\|\n\\)\\(\\(?:[a-zA-Z]:\\)?[a-zA-Z0-9_/.\\\\][-a-zA-Z0-9_/.\\\\ ]*\\.go\\):\\([0-9]+\\)"
       :file-group 1
       :line-group 2))

;; Regular expression that describes a gub location generally shown
;; before a command prompt.
;; For example:
;;   gub[1]
(setf (gethash "prompt" realgud-gub-pat-hash)
      (make-realgud-loc-pat
       :regexp   "^gub\\[\\([0-9]+\\)\\]: "
       :num 1
       ))

;;  Regular expression that describes a "breakpoint set" line
(setf (gethash "brkpt-set" realgud-gub-pat-hash)
      (make-realgud-loc-pat
       :regexp "^Breakpoint \\([0-9]+\\) set\\(?:in function \\) at \\([a-zA-Z0-9_/.\\\\][-a-zA-Z0-9_/.\\\\ ]*\\.go\\):\\([0-9]+\\)"
       :num 1
       :file-group 2
       :line-group 3))

;; Regular expression that describes a debugger "delete" (breakpoint) response.
;; For example:
;;   Deleted breakpoint 1.
(setf (gethash "brkpt-del" realgud-gub-pat-hash)
      (make-realgud-loc-pat
       :regexp "^Deleted breakpoint \\([0-9]+\\)\n"
       :num 1))

;; Regular expression describes general location. In contrast to loc
;; which triggers automatically, we bind this to a key like C-c !s
;; For example:
;;               interp/testdata/square.go:16:2-17
;  ^^^^^^ spaces
(setf (gethash "general-location" realgud-gub-pat-hash)
      (make-realgud-loc-pat
       :regexp
       "\\(?:^\\|\n\\)[ \t]*\\(\\(?:[a-zA-Z]:\\)?[a-zA-Z0-9_/.\\\\][-a-zA-Z0-9_/.\\\\ ]*\\.go\\):\\([0-9]+\\)"
       :file-group 1
       :line-group 2))

(defconst realgud-gub-selected-frame-arrow "=>"
"String that describes which frame is selected in a debugger
backtrace listing.")
(defconst realgud-gub-frame-arrow (format "\\(%s\\|  \\)"
					  realgud-gub-selected-frame-arrow))
(defconst realgud-gub-frame-num-regexp " #\\([0-9]+\\) ")

(defconst realgud-gub-frame-file-regexp " at \\(.*\\):\\([0-9]+\\)")


;; Regular expression that describes a debugger "backtrace" command line.
;; For example:
;; => #0 square(n)
;;    #1 main()
(setf (gethash "debugger-backtrace" realgud-gub-pat-hash)
      (make-realgud-loc-pat
       :regexp 	(concat "^"
			realgud-gub-frame-arrow
			realgud-gub-frame-num-regexp
			"\\(.*\\)"
			realgud-gub-frame-file-regexp
			)
       :num 2
       :file-group 4
       :line-group 5)
      )

;; Regular expression that describes which frame is selected in
;; a debugger backtrace listing.
(setf (gethash "selected-frame-indicator" realgud-gub-pat-hash)
      realgud-gub-selected-frame-arrow)

;; Regular expression for a termination message.
(setf (gethash "termination" realgud-gub-pat-hash)
       "^gub: That's all, folks...\n")

(setf (gethash "font-lock-keywords" realgud-gub-pat-hash)
      '(
	;; ;; File name and line number
	;; ;; E.g. =>#0  Makefile.in at /tmp/Makefile:216
	;; ;;                       ----^^^^^^^^^^^^^^^^^
	(" at \\(.*\\):\\([0-9]+\\)"
	 (1 realgud-file-name-face)
	 (2 realgud-line-number-face))

	;; The frame number and first type name, if present.
	;; E.g. =>#0  Makefile.in at /tmp/Makefile:216
	;;      ---^
	("#\\([0-9]+\\)  "
	 (1 realgud-backtrace-number-face))
	))

(setf (gethash "gub" realgud-pat-hash) realgud-gub-pat-hash)

(defvar realgud-gub-command-hash (make-hash-table :test 'equal)
  "Hash key is command name like 'quit' and the value is
  the gub command to use, like 'q'")

(setf (gethash "backtrace" realgud-gub-command-hash) "backtrace")
(setf (gethash "break"     realgud-gub-command-hash) "break %l")
(setf (gethash "continue"  realgud-gub-command-hash) "continue")
;;(setf (gethash "eval"      realgud-gub-command-hash) "x %s")
(setf (gethash "quit"      realgud-gub-command-hash) "quit")
(setf (gethash "restart"   realgud-gub-command-hash) "R")
(setf (gethash "run"       realgud-gub-command-hash) "R")
(setf (gethash "step"      realgud-gub-command-hash) "step")
(setf (gethash "next"      realgud-gub-command-hash) "next")
(setf (gethash "gub" realgud-command-hash) realgud-gub-command-hash)


(provide-me "realgud-gub-")

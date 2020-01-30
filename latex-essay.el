;;; -*- lexical-binding; t; -*-

(defvar essay-mode-map nil  
  "testing a keymap for essay-mode")

(progn
  (setq essay-mode-map (make-sparse-keymap))
  (define-key essay-mode-map (kbd "C-RET") 'insert-latex-enumeration)
  (define-key essay-mode-map (kbd "C-ø") 'insert-latex-enumeration)
  (define-key essay-mode-map (kbd "C-c C-b") 'insert-latex-bold)
  (define-key essay-mode-map (kbd "C-c C-i") 'insert-latex-italic)
  (define-key essay-mode-map (kbd "C-c C-u") 'insert-latex-underline)
  (define-key essay-mode-map (kbd "C-9") 'sp-forward-slurp-sexp)
  (define-key essay-mode-map (kbd "C-8") 'sp-backward-slurp-sexp)
  (define-key essay-mode-map (kbd "\"") 'insert-regular-quote-essay-mode))

(define-derived-mode essay-mode latex-mode "laTeX essay"
  "a major mode for writing my essays, it takes the text of a buffer and places it into my essay template"
  (use-local-map essay-mode-map))

(defun essay-latex-mode ()
  (essay-mode))

(defvar *essay-latex-heading* "" "holds the beginning of the latex file.")

(defvar *essay-latex-author* ""
  "This variable holds the name of the author")
(defvar *esssay-latex-title* ""
  "this variable holds the title of the document in question")
(defvar *esssay-latex-subtitle* ""
  "this variable holds the title of the document in question")
(defvar *essay-latex-wrap-text* '()
  "this holds begin/end information that will be wrapped around the essay text. an example would be:
'((\"\begin{doublespace}\" . \"\end{doublespace}\"))")

;; (defvar *essay-latex-class* "scrartcl")
(defvar *essay-latex-class* "scrartcl")
(defvar *essay-latex-fontsize* 9)

(defvar *essay-latex-add-topmargin* 0
  "adds to top margin in centimeters")
(defvar *essay-latex-add-textheight* 0
  "adds to text height, in centimeters")
(defvar *essay-latex-margins* ""
  "holds the margins in centimeters")

(setq *essay-latex-heading*
"\\usepackage[utf8]{inputenc}
\\usepackage[T1]{fontenc}
\\usepackage{graphicx}
\\usepackage{grffile}
\\usepackage{longtable}
\\usepackage{wrapfig}
\\usepackage{rotating}
\\usepackage[normalem]{ulem}
\\usepackage{amsmath}
\\usepackage{textcomp}
\\usepackage{amssymb}
\\usepackage{capt-of}
\\usepackage{hyperref}
\\usepackage[margin=%scm]{geometry}
\\usepackage{setspace}
\\usepackage[ddmmyyyy]{datetime}
\\renewcommand{\\dateseparator}{.}

\\addtolength{\\topmargin}{%scm}
\\addtolength{\\textheight}{%scm}
\\setcounter{secnumdepth}{0}
\\author{%s}
\\date{\\today}
\\title{%s}
\\subtitle{%s}
")

(setq *essay-latex-title* "Stil Tre"
      *essay-latex-subtitle* "Hvilken årstid liker du best? Hvorfor?"
      *essay-latex-author* "Nathan Shostek"
      *essay-latex-margins* 2
      *essay-latex-add-topmargin* -1.5
      *essay-latex-add-textheight* 1.5
      *essay-latex-wrap-text* '(("\\begin{doublespace}" . "\\end{doublespace}") ("\\Large" . "\\normalsize")))

(defun essay-latex-format-heading (&optional author title subtitle heading margins topmargin textheight)
  (or heading (setq heading *essay-latex-heading*))
  (or margins (setq margins *essay-latex-margins*))
  (or topmargin (setq topmargin *essay-latex-add-topmargin*))
  (or textheight (setq textheight *essay-latex-add-textheight*))
  (or author (setq author *essay-latex-author*))
  (or title (setq title *essay-latex-title*))
  (or subtitle (setq subtitle *essay-latex-subtitle*))
  (format heading margins topmargin textheight author title subtitle))

(defun essay-latex-format-class (&optional fontsize class)
  (or fontsize (setq fontsize *essay-latex-fontsize*))
  (or class (setq class *essay-latex-class*))
  (format "\\documentclass[%s]{%s}\n" fontsize class))

(defun test-stuff (&optional tester)
  (interactive "cOutput as [T]ex, [P]df, or [B]oth: ")
  (print tester))

(defun essay-latex-set-title-subtitle-body (arg)
  "just pass 1 as arg"
  (interactive "p")
  (save-excursion
    (beginning-of-buffer)
    (let ((beg (line-beginning-position))
	  (end (line-end-position arg))
	  (line nil))
      (when mark-active
	(if (> (point) (mark))
	    (setq beg (save-excursion (goto-char (mark)) (line-beginning-position)))
	  (setq end (save-excursion (goto-char (mark)) (line-end-position)))))
      (setq *essay-latex-title* (buffer-substring beg end)))
    (next-line)
    (let ((beg (line-beginning-position))
	  (end (line-end-position arg)))
      (when mark-active
	(if (> (point) (mark))
	    (setq beg (save-excursion (goto-char (mark)) (line-beginning-position)))
	  (setq end (save-excursion (goto-char (mark)) (line-end-position)))))
      (setq *essay-latex-subtitle* (buffer-substring beg end)))
    (next-line)
    (setq essay-latex-body (buffer-substring (point) (point-max)))))

(defvar *essay-latex-window-register* 0)

(defun essay-latex-test-export (&optional as-pdf)
  (interactive "cOutput as [T]ex, [P]df, or [B]oth: ")
  (winner-mode)
  (window-configuration-to-register *essay-latex-window-register*)
  (save-excursion
    (let  ((tex-filename (concat (file-name-sans-extension (buffer-file-name)) ".tex"))
	   (gen-pdf (or (= as-pdf 80) (= as-pdf 112)
			(= as-pdf 66) (= as-pdf 98)))
	   (no-tex (or (= as-pdf 80) (= as-pdf 112)))
	   (tex-only (or (= as-pdf 84) (= as-pdf 116))))
      (if (not (or tex-only no-tex gen-pdf))
	  (message "Invalid character entered, try again")
	(progn
	  (essay-latex-set-title-subtitle-body 1)
	  (with-temp-buffer
	    (insert (essay-latex-format-class))
	    (insert (essay-latex-format-heading))
	    (insert "\\begin{document}\n\\maketitle")
	    (mapcar (lambda (elcons)
		      (insert (car elcons))
		      (insert "\n"))
		    *essay-latex-wrap-text*)
            (insert essay-latex-body)
	    (mapcar (lambda (elcons)
		      (insert (cdr elcons))
		      (insert "\n"))
		    *essay-latex-wrap-text*)
	    (insert "\\end{document}")
	    (write-region (point-min) (point-max) tex-filename)
	    (when gen-pdf
	      (let ((pdf-buf-o (generate-new-buffer-name "pdflatex-output"))
		    (pdf-buf-e (generate-new-buffer-name "pdflatex-errors")))
		(shell-command (format "pdflatex %s" tex-filename) pdf-buf-o pdf-buf-e)
		(when no-tex
		  (let ((rm-buf-o (generate-new-buffer-name "rm-output"))
			(rm-buf-e (generate-new-buffer-name "rm-errors")))
		    (shell-command (format "rm %s" tex-filename))
                    (when (get-buffer rm-buf-o) (kill-buffer rm-buf-o))
		    (when (get-buffer rm-buf-e) (kill-buffer rm-buf-e))))
                (when (get-buffer pdf-buf-o) (kill-buffer pdf-buf-o))
                (when (get-buffer pdf-buf-e) (kill-buffer pdf-buf-e)))))))))
  (jump-to-register *essay-latex-window-register* t)
  )

;; (defun modify-heading (&optional margin add-topmargin add-textheight point-size ))

(defun export-essay-to-pdf ()
  (interactive)
  (let ((tex-filename (concat (file-name-sans-extension (buffer-file-name)) ".tex"))
	(pdf-filename (concat (file-name-sans-extension (buffer-file-name)) ".pdf"))
	(buffer-name-tex nil))
    (export-essay-to-latex)
    (kill-buffer tex-filename)
    (find-file tex-filename)
    (setq buffer-name-tex (buffer-name))
    (shell-command (format "pdflatex %s" tex-filename) (generate-new-buffer-name "pdflatex output"))
    ;; (switch-to-buffer buffer-name-tex)
    (kill-buffer buffer-name-tex)
    (kill-buffer "pdflatex output")))

(defun export-essay-to-latex ()
  (interactive)
  (let ((tex-filename (concat (file-name-sans-extension (buffer-file-name)) ".tex"))
	(title *essay-latex-subtitle*)
	(subtitle *essay-latex-subtitle*)
	(author *essay-latex-author*)
	(margins *essay-latex-margins*)
	(topmargin *essay-latex-add-topmargin*)
	(textheight *essay-latex-add-textheight*)
	(wraptext *essay-latex-wrap-text*))
    (save-excursion
      (beginning-of-buffer)
      (mark-whole-buffer)
      (kill-ring-save (region-beginning) (region-end))
      (generate-new-buffer tex-filename)
      ;; (find-file tex-filename)
      ;; (write-file tex-filename)
      (switch-to-buffer tex-filename)
      (latex-mode)
      (insert (format
"\\documentclass[10pt]{scrartcl}
\\usepackage[utf8]{inputenc}
\\usepackage[T1]{fontenc}
\\usepackage{graphicx}
\\usepackage{grffile}
\\usepackage{longtable}
\\usepackage{wrapfig}
\\usepackage{rotating}
\\usepackage[normalem]{ulem}
\\usepackage{amsmath}
\\usepackage{textcomp}
\\usepackage{amssymb}
\\usepackage{capt-of}
\\usepackage{hyperref}
\\usepackage[margin=%scm]{geometry}
\\usepackage{setspace}
\\addtolength{\\topmargin}{%scm}
\\addtolength{\\textheight}{%scm}

\\setcounter{secnumdepth}{0}
\\author{%s}
\\date{\\today}
\\title{%s}
\\subtitle{%s}"
margins topmargin textheight author title subtitle))
      (insert "
\\begin{document}
\\maketitle")
      (mapcar (lambda (elcons)
		(insert (car elcons))
		(insert "\n"))
	      *essay-latex-wrap-text*)
      (yank)
      (mapcar (lambda (elcons)
		(insert (cdr elcons))
		(insert "\n"))
	      *essay-latex-wrap-text*)
      (insert "\\end{document}")
      (write-region (point-min) (point-max) tex-filename))))

(defun echo-major-mode ()
  (interactive)
  (print major-mode))

(defun echo-file-name ()
  (interactive)
  (print (file-name-sans-extension (buffer-file-name))))

(defun insert-latex-enumeration ()
  (interactive)
  (save-excursion
    (insert "\n\\begin{enumerate}\n\\item \n\\end{enumerate}")
    (set-mark (point))
    (previous-line)
    (previous-line)
    (beginning-of-line)
    (indent-for-tab-command))
  (next-line)
  (end-of-line))

(defun insert-latex-bold ()
  (interactive)
  (insert "\\textbf{} ")
  (backward-char)
  (backward-char))

(defun insert-latex-italic ()
  (interactive)
  (insert "\\textit{} ")
  (backward-char)
  (backward-char))

(defun insert-regular-quote-essay-mode ()
  (interactive)
  (insert "\""))

(defun insert-latex-underline ()
  (interactive)
  (insert "\\underline{} ")
  (backward-char)
  (backward-char))

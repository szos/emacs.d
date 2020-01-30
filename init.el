;;; -*- lexical-binding: t; -*-
(require 'package)
(package-initialize)

(unless (assoc-default "melpa" package-archives)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))
(unless (assoc-default "org" package-archives)
  (add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t))
(unless (assoc-default "gnu" package-archives)
  (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t))

(defvar *packages-refreshed* nil)

(defmacro install-unless-installed (package)
  `(unless (package-installed-p ,package)
     (unless *packages-refreshed*
       (setq *packages-refreshed* t)
       (package-refresh-contents))
     (package-install ,package)))

(defmacro install-unless-installed-and-require (package)
  `(progn (unless (package-installed-p ,package)
	    (unless *packages-refreshed*
	      (setq *packages-refreshed* t)
	      (package-refresh-contents))
	    (package-install ,package))
	  (require ,package)))

;; (load "~/.emacs.d/edinit.el")
(org-babel-load-file "~/.emacs.d/config.org")
(load "~/.emacs.d/mailinit.el")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(beacon-color "#d54e53")
 '(doc-view-continuous t)
 '(fci-rule-color "#424242")
 '(flycheck-color-mode-line-face-to-color (quote mode-line-buffer-id))
 '(frame-background-mode (quote dark))
 '(package-selected-packages
   (quote
    (aggressive-indent per-buffer-theme color-theme-buffer-local org-bullets color-theme-modern load-theme-buffer-local spacemacs-theme writeroom-mode visual-fill-column smartparens auctex-latexmk auctex company color-theme-sanityinc-tomorrow)))
 '(send-mail-function (quote smtpmail-send-it))
 '(smtpmail-smtp-server "posteo.net")
 '(smtpmail-smtp-service 587)
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
   (quote
    ((20 . "#d54e53")
     (40 . "#e78c45")
     (60 . "#e7c547")
     (80 . "#b9ca4a")
     (100 . "#70c0b1")
     (120 . "#7aa6da")
     (140 . "#c397d8")
     (160 . "#d54e53")
     (180 . "#e78c45")
     (200 . "#e7c547")
     (220 . "#b9ca4a")
     (240 . "#70c0b1")
     (260 . "#7aa6da")
     (280 . "#c397d8")
     (300 . "#d54e53")
     (320 . "#e78c45")
     (340 . "#e7c547")
     (360 . "#b9ca4a"))))
 '(vc-annotate-very-old-color nil)
 '(window-divider-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(fixed-pitch ((t (:height 0.8 :family "DejaVu Sans Mono"))))
 '(org-block ((t (:inherit fixed-pitch :background "#2f2b33" :foreground "#cbc1d5"))))
 '(org-table ((t (:inherit fixed-pitch :background "#293239" :foreground "#b2b2b2"))))
 '(variable-pitch ((t (:height 130 :family "ETBembo")))))

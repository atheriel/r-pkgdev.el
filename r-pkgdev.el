;;; r-pkgdev.el --- Emulating RStudio's package development environment.

;; Copyright (C) 2016 Aaron Jacobs

;; Author: Aaron Jacobs <atheriel@gmail.com>
;; Version: 0.1
;; Keywords: ess
;; URL: https://github.com/atheriel/r-pkgdev.el

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; https://github.com/atheriel/r-pkgdev.el

;;; Code:

(defcustom r-pkgdev-roxygen-defaults "rd,collate,namespace"
  "The default roclets to pass to roxygen2."
  :type 'str)

(defvar-local r-pkgdev-proj-dir nil
  "The directory of this buffer's R package (if it has one).")

(defun r-pkgdev--find-rproj-dir ()
  "Finds the R package's base directory by looking for an
*.[Rr]proj file nearby this buffer."
  (let ((start (or (and buffer-file-name
			(file-name-directory buffer-file-name))
		   default-directory)))
    (unless start
      (error "could not locate the buffer's directory"))
    (locate-dominating-file
     start
     (lambda (dir) (directory-files dir nil ".+\\.[Rr]proj")))))

(define-minor-mode r-pkgdev-mode
  "Minor mode for emulating RStudio's package development
environment."
  :lighter "RPkgDev"
  (setq r-pkgdev-proj-dir (r-pkgdev--find-rproj-dir)))

(defun r-pkgdev-build ()
  "Builds the R package associated with the current buffer."
  (interactive)
  (when r-pkgdev-proj-dir
    (let ((default-directory r-pkgdev-proj-dir)
	  (options "--no-multiarch --with-keep.source")
	  (pkg r-pkgdev-proj-dir))
      (compilation-start (format "R CMD INSTALL %s %s"
				 options pkg)))))

(defun r-pkgdev-document ()
  "Builds the R documentation for the package associated with the
current buffer."
  (interactive)
  (when r-pkgdev-proj-dir
    (let* ((default-directory r-pkgdev-proj-dir)
	   (options "--slave --vanilla --no-readline")
	   (roclets r-pkgdev-roxygen-defaults)
	   (doc-cmd (concat "devtools::document(roclets = c("
			    (mapconcat (lambda (s) (concat "'" s "'"))
				       (split-string roclets ",")
				       ", ")
			    "))")))
      (compilation-start (format "R %s -e \"%s\""
				 options doc-cmd)))))

(provide 'r-pkgdev)

;; Local Variables:
;; coding: utf-8
;; End:

;;; r-pkgdev.el ends here

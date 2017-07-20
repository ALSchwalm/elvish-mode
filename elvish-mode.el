;;; elvish-mode.el --- Defines a major mode for Elvish

;; Copyright (c) 2017 Adam Schwalm

;; Author: Adam Schwalm <adamschwalm@gmail.com>
;; Version: 0.1.0
;; URL: https://github.com/ALSchwalm/elvish-mode

;; This program is free software: you can redistribute it and/or modify
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

;; Defines a major mode for the elvish language: http://elvish.io

;;; Code:

(defgroup elvish-mode nil
  "A mode for elvish"
  :prefix "elvish-mode-"
  :group 'applications)

(defvar elvish-mode-map
  (let ((map (make-keymap)))
    map))

(defvar elvish-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; Words can contain '-', '_', ':' and '&'
    (modify-syntax-entry ?- "w" table)
    (modify-syntax-entry ?_ "w" table)
    (modify-syntax-entry ?: "w" table)
    (modify-syntax-entry ?& "w" table)

    ;; Comments start with a '#' and end with a newline
    (modify-syntax-entry ?# "<" table)
    (modify-syntax-entry ?\n ">" table)

    ;; Strings can be single-quoted
    (modify-syntax-entry ?' "\"" table)
    table))

(defcustom elvish-keywords
  '("fn" "elif" "if" "else" "try" "except" "finally" "use" "return"
    "while" "for" "break" "continue")
  "Elvish keyword list"
  :type 'list
  :group 'elvish-mode)

(defconst elvish-keyword-pattern
  (let ((keywords (cons 'or elvish-keywords)))
    (eval `(rx (group ,keywords) (not word))))
  "The regex to identify elvish keywords")

(defconst elvish-function-pattern
  (rx "fn" (one-or-more space) (group (one-or-more word)))
  "The regex to identify elvish function names")

(defconst elvish-variable-pattern
  (rx "$" (optional "@") (one-or-more word))
  "The regex to identify elvish variables")

(defconst elvish-numeric-pattern
  (rx (optional "-") (one-or-more digit))
  "The regex to identify elvish numbers")

(defconst elvish-highlights
  `((,elvish-function-pattern . (1 font-lock-function-name-face))
    (,elvish-keyword-pattern . (1 font-lock-keyword-face))
    (,elvish-variable-pattern . font-lock-variable-name-face)
    (,elvish-numeric-pattern . font-lock-constant-face)))

(defcustom elvish-indent 2
  "The number of spaces to add per indentation level"
  :type 'integer
  :group 'elvish-mode)

(defun elvish-current-line-empty-p ()
 (save-excursion
   (beginning-of-line)
   (looking-at (rx (zero-or-more space) eol))))

(defun elvish-lowest-indent-in-line ()
  (save-excursion
    (beginning-of-line)
    (let ((lowest (car (syntax-ppss)))
          (loop t))
      (while (and (not (eolp)) loop)
        (forward-char)
        (when (< (car (syntax-ppss)) lowest)
          (setq lowest (car (syntax-ppss))))
        (if (eolp)
            (setq loop nil)))
      lowest)))

(defun elvish-indent-function ()
  "This function is normally the value of 'indent-line-function' in Elvish.
The indent is currently calculated via 'syntax-ppss'. Once the grammar is more
stable, this should probably be switched to using SMIE."
  (indent-line-to (* elvish-indent (elvish-lowest-indent-in-line)))
  (if (elvish-current-line-empty-p)
      (end-of-line)))

(define-derived-mode elvish-mode fundamental-mode "elvish"
  "Major mode for the elvish language"
  :syntax-table elvish-mode-syntax-table
  (setq-local font-lock-defaults '(elvish-highlights))
  (setq-local indent-line-function #'elvish-indent-function)
  (setq-local comment-start "#")
  (setq-local comment-end ""))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.elv\\'" . elvish-mode))

(provide 'elvish-mode)
;;; elvish-mode.el ends here

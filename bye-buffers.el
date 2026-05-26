;;; bye-buffers.el --- Hide buffers from buffer cycling -*- lexical-binding: t; -*-
;;; Code:

(require 'seq)

(defgroup bye-buffers nil
  "Hide buffers from buffer cycling."
  :group 'convenience)

;; Early declarations
(defvar bye-buffers-list nil)
(defvar bye-buffers-show-list nil)

(defvar bye-buffers--regexp nil
  "Cached combined regexp built from `bye-buffers-list'.")

(defvar bye-buffers-show--regexp nil
  "Cached combined regexp built from `bye-buffers-show-list'.")

(defun bye-buffers-build-regexp (patterns)
  "Build a combined regexp from PATTERNS."
  (when patterns
    (concat "\\(?:"
            (mapconcat #'identity patterns "\\|")
            "\\)")))

(defun bye-buffers-refresh ()
  "Rebuild internal regexp caches."
  (setq bye-buffers--regexp
        (bye-buffers-build-regexp bye-buffers-list)
        bye-buffers-show--regexp
        (bye-buffers-build-regexp bye-buffers-show-list)))

(defun bye-buffers--set-and-refresh (symbol value)
  "Set SYMBOL to VALUE and refresh regexp caches."
  (set-default symbol value)
  (bye-buffers-refresh))

(defcustom bye-buffers-list nil
  "List of regexps matching buffers to hide.
Each entry must be a valid regexp string."
  :set #'bye-buffers--set-and-refresh
  :type '(repeat string)
  :group 'bye-buffers)

(defcustom bye-buffers-show-list nil
  "List of regexps matching buffers that should always be shown.
Each entry must be a valid regexp string."
  :set #'bye-buffers--set-and-refresh
  :type '(repeat string)
  :group 'bye-buffers)

(defcustom bye-buffers-predicates nil
  "List of predicate functions used to decide whether a buffer should be hidden."
  :type '(repeat function)
  :group 'bye-buffers)

(defun bye-buffers-hide-re (patterns)
  "Add PATTERNS to `bye-buffers-list`.

PATTERNS must be a list of regexp strings."
  (setq bye-buffers-list
        (append bye-buffers-list patterns))
  (bye-buffers-refresh))

(defun bye-buffers-show-re (patterns)
  "Add PATTERNS to `bye-buffers-show-list`.

PATTERNS must be a list of regexp strings."
  (setq bye-buffers-show-list
        (append bye-buffers-show-list patterns))
  (bye-buffers-refresh))

(defun bye-buffers-hide (patterns)
  "Add substring matching PATTERNS to `bye-buffers-list`."
  (bye-buffers-hide-re (mapcar #'regexp-quote patterns)))

(defun bye-buffers-show (patterns)
  "Add substring matching PATTERNS to `bye-buffers-show-list`."
  (bye-buffers-show-re (mapcar #'regexp-quote patterns)))

(defun bye-buffers-match-p (buffer-name regexp)
  "Return non-nil if BUFFER-NAME matches REGEXP."
  (and regexp
       (string-match-p regexp
                       buffer-name)))

(defun bye-buffers-should-hide-p (buffer)
  "Return non-nil if BUFFER should be hidden."
  (let ((buffer-name (buffer-name buffer)))
    (unless
     ;; whitelist
     (bye-buffers-match-p
      buffer-name
      bye-buffers-show--regexp)
     ;; hide by predicates
     (or (seq-some
          (lambda (predicate)
            (funcall predicate buffer))
          bye-buffers-predicates)
         ;; blacklist
         (bye-buffers-match-p
          buffer-name
          bye-buffers--regexp)))))

(defun bye-buffers-skip-method (_window buffer _bury-or-kill)
  "Return non-nil if BUFFER should be skipped."
  (bye-buffers-should-hide-p buffer))

;;;###autoload
(define-minor-mode bye-buffers-mode
  "Hide unwanted buffers from buffer cycling."
  :global t
  :group 'bye-buffers

  (if bye-buffers-mode
      (progn
        (bye-buffers-refresh)

        (setq switch-to-prev-buffer-skip
              #'bye-buffers-skip-method))

    (setq switch-to-prev-buffer-skip nil)))

(provide 'bye-buffers)

;;; bye-buffers.el ends here

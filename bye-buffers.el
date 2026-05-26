;;; bye-buffers.el --- Hide buffers from buffer cycling -*- lexical-binding: t; -*-

(defgroup bye-buffers nil
  "Hide buffers from buffer cycling."
  :group 'convenience)

(defcustom bye-buffers-list nil
  "List of regexps matching buffers to hide.

Each entry must be a valid regexp string."
  :type '(repeat string)
  :group 'bye-buffers)

(defvar bye-buffers--regexp nil
  "Cached combined regexp built from `bye-buffers-list`.")

(defun bye-buffers-refresh ()
  "Rebuild internal regexp cache."
  (setq bye-buffers--regexp
        (when bye-buffers-list
          (concat
           "\\(?:"
           (mapconcat #'identity bye-buffers-list "\\|")
           "\\)"))))

(defun bye-buffers-add (patterns)
  "Add PATTERNS to `bye-buffers-list`.

PATTERNS must be a list of regexp strings."
  (setq bye-buffers-list
        (nconc bye-buffers-list patterns))

  (bye-buffers-refresh))

(defun bye-buffers-wrap-word (keyword)
  "Convert KEYWORD into a regexp matching anywhere in a buffer name."
  (format ".*%s.*" (regexp-quote keyword)))

(defun bye-buffers-add-inbetween (patterns)
  "Add substring matching PATTERNS to `bye-buffers-list`.

Each pattern is escaped with `regexp-quote` and wrapped to match
anywhere inside the buffer name."
  (bye-buffers-add
   (mapcar #'bye-buffers-wrap-word patterns)))

(defun bye-buffers-match-p (buffer-name)
  "Return non-nil if BUFFER-NAME should be hidden."
  (and bye-buffers--regexp
       (string-match-p bye-buffers--regexp
                       buffer-name)))

(defun bye-buffers-skip-method (_window buffer _bury-or-kill)
  "Return non-nil if BUFFER should be skipped."
  (bye-buffers-match-p
   (buffer-name buffer)))

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

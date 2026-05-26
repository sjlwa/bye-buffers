# bye-buffers
Hide buffers from buffer cycling  

Usable in buffer cycling commands such as  
- switch-to-prev-buffer  
- next-buffer  
- previous-buffer  

Uses `switch-to-prev-buffer-skip`, which is the intended API for buffer navigation behavior.  

Hide.
```elisp
(require 'bye-buffers)

;; Exact regexp matches
(bye-buffers-hide-re
  '("\\*Messages\\*"
    "\\*Warnings\\*"))
    
;; Match substring anywhere
(bye-buffers-hide
  '("magit"
    "clangd]"))
```

Ignore hide and show.
```elisp
(bye-buffers-show-re '("\\*Messages\\*"))
(bye-buffers-show '("magit"))
```

Predicates.
```elisp
(defun hide-long-named-buffers (buffer)
  (length> (buffer-name buffer) 15))
  
(add-to-list 'bye-buffers-predicates #'hide-long-named-buffers)
```

```elisp
(bye-buffers-mode 1)
```


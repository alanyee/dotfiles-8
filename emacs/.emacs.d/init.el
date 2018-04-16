;;; init.el --- pull in the world, mold it to my liking.
;;; commentary:
;;; code:

(load "~/.emacs.d/lisp/theworld.el")

;; (init-use-package)
(init-straight)

(defun neeasade/core()
  (neeasade/load
   '(
     helpers
     sanity
     evil
     interface
     editing
     shell
     eshell
     interactive
     )))

(defun neeasade/extra()
  (neeasade/load
   '(
     org
     git
     company
     projectile
     flycheck
     ;; window-management
     emms
     jump
     ;; treemacs
     target-process
     dashdocs
     restclient
     pdf
     ledger
     )))

(defun neeasade/communication()
  (neeasade/load '(irc slack twitter email)))

(defun neeasade/development()
  (neeasade/load
   '(
     clojure
     csharp
     elisp
     nix
     javascript
     typescript
     terraform
     markdown
     sql
     ;; jekyll
     ;; plantuml
     )))

(defun neeasade/windows()
  ;; TODO: windows-scripts layer from spacemacs
  (if sys/windows? (neeasade/load '(autohotkey))))

(neeasade/load '(core extra communication development style))

(provide 'init)
;;; init.el ends here

(defgroup sfdx nil
  "Tools for running SFDX commands from Emacs."
  :group 'tools)

(defcustom sfdx-path "/usr/local/bin/sfdx"
  "The SFDX executable path to run."
  :type 'string
  :group 'sfdx)

(defun sfdx-deploy-current-buffer (alias)
  "Run force:source:deploy with the current buffer and deploys it to ALIAS."
  (interactive (list (completing-read "Choose an alias" (sfdx-get-alias-list))))
  (let ((component-type (get-sfdx-component-type (buffer-file-name))))
    (cond
     ((eq component-type nil) (message "This is not a valid SFDX file"))
     (t (let ((deploy-command (get-deploy-command component-type (file-name-nondirectory (file-name-sans-extension (buffer-file-name))) alias)))
          (message "running: %s" deploy-command)
          (shell-command deploy-command))))))

(defun get-sfdx-component-type (path)
  (cond
   ((string-match-p "lwc" path) "LightningComponentBundle")
   ((string-match-p "aura" path) "AuraDefinitionBundle")
   ((string-match-p "classes" path) "ApexClass")
   ((string-match-p "trigger" path) "ApexTrigger")
   ((string-match-p "page" path) "ApexPage")
   (t nil)))

(defun get-sfdx-deploy-format-for-file (path)
  (concat (get-sfdx-component-type path) ":" (file-name-nondirectory (file-name-sans-extension path))))

(defun sfdx-get-alias-list ()
  (split-string (shell-command-to-string "sfdx force:alias:list | awk 'NR>3 { print $1 }'")))

(defun get-deploy-command (type name alias)
  (format "sfdx force:source:deploy -m %s:%s -u %s" type name alias))

(provide 'sfdx)
;;; sfdx.el ends here

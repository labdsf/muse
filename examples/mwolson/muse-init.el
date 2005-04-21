;;; muse-init.el --- Initialize muse-mode.

;; Hacked on by Michael Olson

;; In order to see the scripts that I use to publish my website to a
;; remote webserver, check out
;; http://www.mwolson.org/projects/SiteScripts.html.

;;; Setup

;; Add to load path
(when (fboundp 'debian-pkg-add-load-path-item)
  (debian-pkg-add-load-path-item "/stuff/proj/emacs/muse/mwolson"))

;; Initialize
(require 'muse)          ; load generic module
(require 'muse-colors)   ; load coloring/font-lock module
(require 'muse-mode)     ; load authoring mode
(require 'muse-blosxom)  ; load blosxom module
(require 'muse-html)     ; load (X)HTML publishing style

;; Setup projects

;; Here is an example of making a customized version of your favorite
;; publisher.  All this does is run `my-muse-blosoxm-finalize' on the
;; published file immediately after saving it.

(unless (assoc "my-blosxom" muse-publishing-styles)
  (muse-derive-style "my-blosxom" "blosxom-xhtml"
		     :final 'my-muse-blosxom-finalize))

;; Here is my master project listing.
;;
;; Note that I not do anything useful with the ProjectsWiki and
;; WebWiki projects; only the BlogWiki project is published.

(setq muse-project-alist
      '(("ProjectsWiki"
         ("~/proj/wiki/projects/" :default "WelcomePage")
         (:base "xhtml"
                :path "~/personal-site/site/projects-muse"))

        ("BlogWiki"
         ("~/proj/wiki/blog/francais/"
          "~/proj/wiki/blog/personal/"
          "~/proj/wiki/blog/projects/"
          "~/proj/wiki/blog/website/"
          :default "personal")

         (:base "my-blosxom"
                :path "~/personal-site/site/blog/francais"
                :include "/francais/")
         (:base "my-blosxom"
                :path "~/personal-site/site/blog/personal"
                :include "/personal/")
         (:base "my-blosxom"
                :path "~/personal-site/site/blog/projects"
                :include "/projects/")
         (:base "my-blosxom"
                :path "~/personal-site/site/blog/website"
                :include "/website/"))

        ("WebWiki"
         ("~/proj/wiki/web/" :default "WelcomePage")
         (:base "xhtml" :path "~/personal-site/site/web-muse"))))

;;; Functions

;; Make other modes a bit less intrusive

(defun my-muse-mode-affect-p ()
  "Indicate whether this text should be messed with.
If nil is returned, it means that we should not fill here or
spell-check here.  If non-nil, it is safe to do both of these
things."
  (save-excursion
    (save-match-data
      (null (and (re-search-backward "\\[\\[\\|\\]\\]"
                                     (line-beginning-position) t)
                 (string= (or (match-string 0) "")
                          "[["))))))

;; Make flyspell not mess with links
(put 'muse-mode
     'flyspell-mode-predicate
     'my-muse-mode-affect-p)

;; Make fill not split up links
(eval-after-load "fill"
  (add-to-list 'fill-nobreak-predicate
               (lambda nil (null (my-muse-mode-affect-p)))))

;; Start a new blog entry

(defvar my-muse-blosxom-base-directory "~/proj/wiki/blog"
  "Base directory of blog entries.")

(defun my-muse-blosxom-get-categories ()
  "Retrieve all of the categories from a Blosxom project.
Currently it is hard-coded to get the base directory from
`my-muse-blosxom-base-directory'.

Directories starting with \".\" will be ignored."
  (let (list)
    (dolist (file (directory-files my-muse-blosxom-base-directory
                                   t "^[^.]"))
      (when (file-directory-p file)     ; must be a directory
        (push (file-name-nondirectory file) list)))
    list))

(defun my-muse-blosxom-title-to-file (title)
  "Derive a file name from the given TITLE."
  (replace-regexp-in-string " " "_"
                            (downcase title)))

(defun my-muse-blosxom-new-entry (category title)
  "Start a new blog entry with given CATEGORY.
The filename of the blog entry is derived from TITLE.
The page will be initialized with the current date and TITLE."
  (interactive
   (list
    (completing-read "Category: " (my-muse-blosxom-get-categories)
                     nil nil nil nil "personal")
    (read-string "Title: ")))
  (let ((file (my-muse-blosxom-title-to-file title)))
    (muse-project-find-file
     file "blosxom" nil
     (concat (directory-file-name my-muse-blosxom-base-directory)
             "/" category))
    (goto-char (point-min))
    (insert "#date " (format-time-string "%4Y-%2m-%2d-%2H-%2M")
            "\n#title " title
            "\n\n")
    (forward-line 2)))

;; Make the current file display correctly in Xanga

(defun my-muse-blosxom-finalize (file output-path target)
  (my-muse-prepare-entry-for-xanga output-path))

(defun my-muse-prepare-entry-for-xanga (file)
  "Mangle FILE so that Xanga doesn't bug out, saving to X clipboard.
This is called on a generated BLOSXOM output file whenever
something is published with the \"my-blosxom\" style.

If FILE is not specified, use the current file."
  (interactive (list buffer-file-name))
  (with-temp-buffer
    (insert-file-contents file t)
    ;; Surround first line in <h3></h3>
    (goto-char (point-min))
    (insert "<h3>")
    (end-of-line)
    (insert "</h3>")
    ;; Get rid of 2 spaces together and merge lines
    (goto-char (point-min))
    (while (re-search-forward (concat "["
                                      emacs-wiki-regexp-space
                                      "]+") nil t)
      (replace-match " "))
    ;; Remove trailing space
    (goto-char (point-min))
    (while (re-search-forward " *</p> *" nil t)
      (replace-match "</p>"))
    ;; Make relative links work
    (goto-char (point-min))
    (while (re-search-forward "href=\"/" nil t)
      (replace-match "href=\"http://www.mwolson.org/" nil t))
    ;; Copy entry to clipboard
    (clipboard-kill-ring-save (point-min) (point-max))
    ;; Don't prompt me about killing the buffer
    (set-buffer-modified-p nil)))

;;; Key customizations

(global-set-key "\C-cpl" 'my-muse-blosxom-new-entry)

;;; Custom variables

(custom-set-variables
 '(muse-blosxom-publishing-directory "~/personal-site/site/blog")
 '(muse-html-charset-default "utf-8")
 '(muse-html-encoding-default (quote utf-8))
 '(muse-html-meta-content-encoding (quote utf-8))
 '(muse-html-style-sheet "<link rel=\"stylesheet\" type=\"text/css\" charset=\"utf-8\" media=\"all\" href=\"/common.css\" />
<link rel=\"stylesheet\" type=\"text/css\" charset=\"utf-8\" media=\"screen\" href=\"/screen.css\" />
<link rel=\"stylesheet\" type=\"text/css\" charset=\"utf-8\" media=\"print\" href=\"/print.css\" />")
 '(muse-xhtml-footer "~/personal-site/muse/footer.html")
 '(muse-xhtml-header "~/personal-site/muse/header.html"))
(custom-set-faces
 '(muse-link-face ((t (:foreground "blue" :underline "blue" :weight bold)))))

;;; muse-init.el ends here
;;; muse-regexps-test.el --- Tests for muse-regexps

(require 'muse-regexps)

(ert-deftest muse-regexps-test/ol-item ()
  "Test ordered list item regexp"
  (should     (string-match-p muse-ol-item-regexp " 1. Item"))
  (should-not (string-match-p muse-ol-item-regexp "1. Item"))
  (should     (string-match-p muse-ol-item-regexp " 20. Item"))
  (should     (string-match-p muse-ol-item-regexp "\t1. Item"))
  (should     (string-match-p muse-ol-item-regexp "\t 1. Item")))

(ert-deftest muse-regexps-test/ul-item ()
  "Test unordered list item regexp"
  (should     (string-match-p muse-ul-item-regexp " - Item"))
  (should     (string-match-p muse-ul-item-regexp "\t- Item"))
  (should-not (string-match-p muse-ul-item-regexp "- Item")))

(ert-deftest muse-regexps-test/dl-term ()
  "Test definition list term regexp"
  (dolist (elt '((" foo ::" . "foo")
                 ("foo :: " . "foo")
                 ("foo :: bar" . "foo")))
    (should (string-match muse-dl-term-regexp (car elt)))
    (should (equal (match-string 1 (car elt)) (cdr elt))))

  ; No whitespace after "::"
  (should-not (string-match-p muse-dl-term-regexp "foo ::bar")))

(ert-deftest muse-regexps-test/dl-entry ()
  "Test definition list entry regexp"
  (should     (string-match-p muse-dl-entry-regexp ":: content"))
  (should     (string-match-p muse-dl-entry-regexp " :: content"))
  (should-not (string-match-p muse-dl-entry-regexp "term :: content")))

(ert-deftest muse-regexps-test/table-field ()
  "Test table field separator regexp"
  (should     (string-match-p muse-table-field-regexp " | "))
  (should     (string-match-p muse-table-field-regexp "\t| "))
  (should     (string-match-p muse-table-field-regexp " || "))
  (should     (string-match-p muse-table-field-regexp " ||| "))
  (should     (string-match-p muse-table-field-regexp " |"))
  (should     (string-match-p muse-table-field-regexp " ||"))
  (should     (string-match-p muse-table-field-regexp " |||"))

  ; No blank before separator
  (should-not (string-match-p muse-table-field-regexp "| "))
  (should-not (string-match-p muse-table-field-regexp "|| "))

  ; Letters before separator
  (should-not (string-match-p muse-table-field-regexp "foo| "))
  (should-not (string-match-p muse-table-field-regexp "foo|| "))

  ; Letters after separator
  (should-not (string-match-p muse-table-field-regexp "|bar"))
  (should-not (string-match-p muse-table-field-regexp "||bar")))

(ert-deftest muse-regexps-test/table-line ()
  "Test table line regexp"
  (should     (string-match-p muse-table-line-regexp "foo | bar"))
  (should     (string-match-p muse-table-line-regexp " foo | bar "))
  (should     (string-match-p muse-table-line-regexp " foo | bar"))
  (should     (string-match-p muse-table-line-regexp "foo | bar"))
  (should     (string-match-p muse-table-line-regexp "foo | bar | baz"))
  (should     (string-match-p muse-table-line-regexp "foo || bar || baz")))

(ert-deftest muse-regexps-test/table-hline ()
  "Test table hline regexp"
  (should     (string-match-p muse-table-hline-regexp "|-----------|"))
  (should     (string-match-p muse-table-hline-regexp "|-|"))
  (should     (string-match-p muse-table-hline-regexp "|-----+-----|"))
  (should     (string-match-p muse-table-hline-regexp "  |-----|  "))
  (should-not (string-match-p muse-table-hline-regexp "||")))

(ert-deftest muse-regexps-test/table-el-border ()
  "Test table.el border regexp"
  (should (string-match-p muse-table-el-border-regexp "+-----+"))
  (should (string-match-p muse-table-el-border-regexp "  +-----+"))
  (should (string-match-p muse-table-el-border-regexp "+-----+ "))
  (should-not (string-match-p muse-table-el-border-regexp "+----"))
  (should-not (string-match-p muse-table-el-border-regexp "+---|---+")))

(ert-deftest muse-regexps-test/table-el-line ()
  "Test table.el line regexp"
  (should (string-match-p muse-table-el-line-regexp "| Foo   | bar | baz |"))
  (should (string-match-p muse-table-el-line-regexp "| Foo |"))
  (should-not (string-match-p muse-table-el-line-regexp "Foo")))

(ert-deftest muse-regexps-test/tag ()
  "Test tag regexp."
  (dolist (elt '("<code>"
                 "<br/>"
                 "<a>"
                 "<class name=\"foo\">"))
    (should (string-match-p muse-tag-regexp elt)))

  (dolist (elt '("foo"
                 "<br/"
                 "br/>"
                 "<br"
                 "br>"
                 "</code>")) ; Only opening tags are accepted
    (should-not (string-match-p muse-tag-regexp elt)))

  (let ((tag "<class name=\"foo\">"))
    (string-match muse-tag-regexp tag)
    (should (equal (match-string 1 tag) "class"))
    (should (equal (match-string 2 tag) " name=\"foo\""))
    (should (equal (match-string 3 tag) nil)))

  (let ((tag "<br/>"))
    (string-match muse-tag-regexp tag)
    (should (equal (match-string 1 tag) "br"))
    (should (equal (match-string 2 tag) nil))
    (should (equal (match-string 3 tag) "/"))))

(ert-deftest muse-regexps-test/file ()
  "Test file regexp."
  (should (string-match-p muse-file-regexp "~/.emacs")) ; Starts with "~"
  (should (string-match-p muse-file-regexp "/etc/emacs/site-start.el")) ; Starts with "/"
  (should (string-match-p muse-file-regexp "foo?bar")) ; Anything containing "?" is a file link
  (should (string-match-p muse-file-regexp "lisp/")) ; Ends in "/"
  (should (string-match-p muse-file-regexp "manual.pdf")) ; Ends in ".pdf"
  (should (string-match-p muse-file-regexp "muse.tar.gz")) ; Ends in ".tar.gz"
  (should-not (string-match-p muse-file-regexp "foobar"))
  (should-not (string-match-p muse-file-regexp "image.png")))

(ert-deftest muse-regexps-test/image ()
  "Test image regexp."
  (dolist (elt '("photo.jpg" "photo.jpeg" "image.png" "gif.gif"))
    (should (string-match-p muse-image-regexp elt)))

  (dolist (elt '("readme.txt" "a.out" "image.jpg "))
    (should-not (string-match-p muse-image-regexp elt))))

;;; muse-regexps-test.el ends here

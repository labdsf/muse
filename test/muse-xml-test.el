;;; muse-xml-test.el --- Tests for muse-xml

(require 'muse-xml)

(muse-derive-style "testxml" "xml"
                   :header ""
                   :footer "")

(defun muse-xml-testcase (from to)
  (with-temp-buffer
    (insert from)
    (muse-publish-markup-buffer "title" "testxml")
    (should (equal (buffer-string) to))))

(ert-deftest muse-xml-test/emphasis ()
  "Test XML emphasis"
  (muse-xml-testcase
    "*foo*"
    "<p><format type=\"emphasis\" level=\"1\">foo</format></p>\n")
  (muse-xml-testcase
    "**bar**"
    "<p><format type=\"emphasis\" level=\"2\">bar</format></p>\n")
  (muse-xml-testcase
    "***baz***"
    "<p><format type=\"emphasis\" level=\"3\">baz</format></p>\n")

  ; Comma after emphasized word
  (muse-xml-testcase
    "*foo*, *bar*"
    "<p><format type=\"emphasis\" level=\"1\">foo</format>, <format type=\"emphasis\" level=\"1\">bar</format></p>\n"))

(ert-deftest muse-xml-test/sections ()
  "Test XML sections"
  (muse-xml-testcase
    "* Section"
    "<section level=\"1\"><title>Section</title>\n\n</section>\n")
  (muse-xml-testcase
    "** Subsection"
    "<section level=\"2\"><title>Subsection</title>\n\n</section>\n")
  (muse-xml-testcase
    "*** Subsubsection"
    "<section level=\"3\"><title>Subsubsection</title>\n\n</section>\n")
  (muse-xml-testcase
    "**** Level 4 section"
    "<section level=\"4\"><title>Level 4 section</title>\n\n</section>\n")
  (muse-xml-testcase
    "***** Level 5 section"
    "<section level=\"5\"><title>Level 5 section</title>\n\n</section>\n"))

;;; muse-xml-test.el ends here

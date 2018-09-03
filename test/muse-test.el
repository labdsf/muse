;;; muse-test.el --- Tests for muse

(require 'muse)

(ert-deftest muse-test/goto-tag-end ()
  "Should go to the end of tag."
  (with-temp-buffer
    (insert "foo<tag>bar</tag>baz")
    (goto-char 1)
    (should (equal (point) 1))
    (muse-goto-tag-end "tag" nil)
    (should (equal (point) 18))))

(ert-deftest muse-test/goto-tag-end-nested ()
  "Should go to the end of nested tag."
  (with-temp-buffer
    (insert "foo<tag>bar<tag>baz</tag>foo</tag>bar")
    (goto-char 1)
    (should (equal (point) 1))
    (muse-goto-tag-end "tag" nil)
    (should (equal (point) 26))
    (goto-char 1)
    (should (equal (point) 1))
    (muse-goto-tag-end "tag" t)
    (should (equal (point) 35))))

;;; muse-test.el ends here

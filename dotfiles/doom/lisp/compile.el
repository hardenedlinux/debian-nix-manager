;;; compile.el --- description -*- lexical-binding: t; -*-
(require 'org)
(org-babel-tangle-file "init.org")
(org-babel-tangle-file "meow.org")
(setq byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))

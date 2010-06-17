# coding: utf-8

EXTRA_UTF   = "\xC3\x80-\xC3\x96\xC3\x98-\xC3\xB6\xC3\xB8-\xE1\xBF\xBE"
ALPHA_G     = /^[#{EXTRA_UTF}a-zA-Z][-#{EXTRA_UTF}a-zA-Z ]*$/u
ALNUM_G     = /^[#{EXTRA_UTF}a-zA-Z0-9][-#{EXTRA_UTF}a-zA-Z0-9 ]*$/u
ALNUM       = /\A[a-zA-Z0-9][-a-zA-Z0-9\s]+\z/
IDENTIFIER  = /\A[a-zA-Z][-a-zA-Z0-9]+\z/
PHONE       = /^[-0-9()+*#]+$/
URL         = /^https?:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix

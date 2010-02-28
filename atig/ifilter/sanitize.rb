#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module IFilter
    class Sanitize
      WSP_REGEX  = Regexp.new("\\r\\n|[\\r\\n\\t#{"\\u00A0\\u1680\\u180E\\u2002-\\u200D\\u202F\\u205F\\u2060\\uFEFF" if "\u0000" == "\000"}]")

      def initialize(*_); end

      def call(status)
        text = status.text.
          delete("\000\001").
          gsub("&gt;", ">").
          gsub("&lt;", "<").
          gsub(WSP_REGEX, " ")
        status.merge :text => text
      end
    end
  end
end
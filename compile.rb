#! /usr/bin/env ruby

require 'rubygems'
require 'jbundler'
require 'fileutils'

classpath = JBUNDLER_CLASSPATH.join(':')

FileUtils.mkdir_p('classes')
exec "javac -classpath '#{classpath}' -d classes src/*"

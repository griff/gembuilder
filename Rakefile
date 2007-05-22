# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/gembuilder.rb'

Hoe.new('gembuilder', GemBuilder::VERSION) do |p|
  p.rubyforge_name = 'gembuilder'
  p.author = 'Patrick Hurley'
  p.email = 'phurley@gmail.com'

  p.summary = 'Create a binary gem, for the current platform.'
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
end

# vim: syntax=Ruby
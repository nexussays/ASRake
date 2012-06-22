# (The MIT License)
# 
# Copyright (c) 2010-2010 Stephen Touset
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Version::Component
	attr_accessor :digits
	attr_accessor :letter
	
	#
	# Creates a single Component of a version, consisting of digits and
	# possibly a letter. For example, +1+, +3a+, +12+, or +0+.
	#
	def initialize(component)
		parts = component.split /(?=\D)/
		
		self.digits = parts[0].to_i
		self.letter = parts[1].to_s.strip
	end
	
	def initialize_copy(other)
		self.digits = other.digits
		self.letter = other.letter.dup
	end
	
	def prerelease?
		not self.letter.empty?
	end
	
	def unprerelease!
		self.next! if self.prerelease?
	end
	
	def next(pre = false)
		self.dup.next!(pre)
	end
	
	def next!(pre = false)
		case
			when (	  pre and	  self.prerelease?) then self.letter.next!
			when (    pre and not self.prerelease?) then self.letter = 'a'
			when (not pre and	  self.prerelease?) then self.letter = ''
			when (not pre and not self.prerelease?) then self.digits = self.digits.next
		end
		
		self
	end
	
	def <=>(other)
		self.to_sortable_a <=> other.to_sortable_a
	end
	
	def to_sortable_a
		[ self.digits, self.prerelease? ? 0 : 1, self.letter ]
	end
	
	def to_a
		[ self.digits, self.letter ]
	end
	
	def to_i
		self.digits
	end
	
	def to_s
		self.to_a.join
	end
	
	def inspect
		self.to_s.inspect
	end
end

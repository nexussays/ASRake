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

require 'pathname'

#
# Encodes version-numbering logic into a convenient class.
#
class Version
	include Comparable
	autoload :Component, 'asrake/version/component'
	#
	# Searches through the parent directories of the calling method and looks
	# for a VERSION or VERSION.yml file to parse out the current version. Pass
	#
	# Pass a filename to +path+ to override autodetection, or pass a directory
	# name as +path+ to autodetect within a given directory
	#
	def self.current(path = nil)
		# if path is nil, detect automatically; if path is a directory, detect
		# automatically in the directory; if path is a filename, use it directly
		path = path ? Pathname.new(path) : self.version_file(caller.first)
		path = self.version_file(path) unless path.nil? or path.file?
		
		return nil unless path
		
		case path.extname
			when ''		then Version.to_version(path.read.strip)
			when '.yml'	then Version.to_version(YAML::load(path.read))
		end
	end
	
	#
	# Attempts to detect the version file for the passed +filename+. Looks up
	# the directory hierarchy for a file named VERSION or VERSION.yml. Returns
	# a Pathname for the file if found, otherwise nil.
	#
	def self.version_file(filename)
		Pathname(filename).dirname.expand_path.ascend do |d|
			break d.join('VERSION')		 if d.join('VERSION').file?
			break d.join('VERSION.yml') if d.join('VERSION.yml').file?
		end
	end

	# 
	# Converts a String, Hash, or Array into a Version instance
	#
	def self.to_version(obj)
		if obj.kind_of? String
			Version.new *obj.split(%r{\.})
		elsif obj.kind_of? Hash
			Version.new *obj.values_at(:major, :minor, :revision, :rest)
		elsif obj.kind_of? Array
			Version.new *obj
		end
	end
	
	#
	# Creates a new version number, with a +major+ version number, +minor+
	# revision number, +revision+ number, and optionally more (unnamed)
	# version components.
	#
	def initialize(major, minor = 0, revision = nil, *rest)
		self.components = [ major, minor, revision, *rest ]
	end
	
	#
	# For +major+, +minor+, and +revision+, make a helper method that gets and
	# sets each based on accessing indexes.
	#--
	# TODO: make these rdoc-capable
	#++
	#
	[ :major, :minor, :revision ].to_enum.each.with_index do |component, i|
		define_method(:"#{component}")	{ self.components[i] ? self.components[i].to_s : nil }
		define_method(:"#{component}=") {|v| self[i] = v	}
	end
	
	#
	# Set the component of the Version at +index+ to +value+. Zeroes out any
	# trailing components.
	#
	# If +index+ is greater than the length of the version number, pads the
	# version number with zeroes until +index+.
	#
	def []=(index, value)
		return self.resize!(index)							 if value.nil? || value.to_s.empty?
		return self[self.length + index] = value if index < 0
		
		length = self.length - index
		zeroes = Array.new length.abs, Version::Component.new('0')
		value	= Version::Component.new(value.to_s)
		
		if length >= 0
			self.components[index, length] = zeroes
			self.components[index]				 = value
		else
			self.components += zeroes
			self.components << value
		end
	end
	
	def prerelease?
		self.components.any? {|c| c.prerelease? }
	end
	
	#
	# Resizes the Version to +length+, removing any trailing components. Is a
	# no-op if +length+ is greater than its current length.
	#
	def resize!(length)
		self.components = self.components.take(length)
		self
	end
	
	#
	# Bumps the version number. Pass +component+ to bump a component other than
	# the least-significant part. Set +pre+ to true if you want to bump the
	# component to a prerelease version. Set +trim+ to true if you want the
	# version to be resized to only large enough to contain the component set.
	#
	#		"1.0.4a".bump!											 # => '1.0.4'
	#		"1.0.4a".bump!(:pre)								 # => '1.0.4b'
	#		"1.0.4a".bump!(:minor, false, true)	# => '1.1'
	#		"1.0.4a".bump!(:minor, true, true)	 # => '1.1a
	#		"1.0.4a".bump!(:minor, true, false)	# => '1.1.0a'
	#
	def bump!(component = -1, pre = false, trim = false)
		case component
			when :major		then self.bump!(0,	pre,	trim)
			when :minor		then self.bump!(1,	pre,	trim)
			when :revision	then self.bump!(2,	pre,	trim)
			when :pre		then self.bump!(-1,	true,	trim)
			else
				# resize to match the new length, if applicable
				self.resize!(component + 1) if (trim or component >= self.length)
				
				# mark all but the changed bit as non-prerelease
				self[0...component].each(&:unprerelease!)
				
				# I don't even understand this part any more; god help you
				self[component] = self[component].next	if		pre and self.prerelease? and component == self.length - 1
				self[component] = self[component].next	unless	pre and self.prerelease? and component == -1
				self[-1]		= self[-1].next(true)	if		pre
				self
		end
	end

	def bump(component = -1, pre = false, trim = false)
		return (Version.to_version(self.to_hash)).bump!(component, pre, trim)
	end
		
	#
	# Returns the current length of the version number.
	#
	def length
		self.components.length
	end
	
	#
	# Compares a Version against any +other+ object that responds to
	# +to_version+.
	#
	def <=>(other)
		self.components <=> other.to_version.components
	end
	
	#
	# Converts the version number into an array of its components.
	#
	def to_a
		self.components.map {|c| c.to_s }
	end
	
	#
	# Converts the version number into a hash of its components.
	#
	def to_hash
		{ :major		=> self.major,
			:minor		=> self.minor,
			:revision => self.revision,
			:rest		 => self.length > 3 ? self.to_a.drop(3) : nil }.
			delete_if {|k,v| v.nil? }
	end
	
	#
	# The canonical representation of a version number.
	#
	def to_s
		self.to_a.join('.')
	end
	
	#
	# Returns +self+.
	#
	def to_version
		self
	end
	
	#
	# Returns a YAML representation of the version number.
	#
	def to_yaml
		YAML::dump(self.to_hash)
	end
	
	#
	# Returns a human-friendly version format.
	#
	def inspect
		self.to_s.inspect
	end
	
	protected
	
	#
	# Retrieves the component of the Version at +index+.
	#
	def [](index)
		self.components[index] || Component.new('0')
	end
	
	def components
		@components ||= []
	end
	
	def components=(components)
		components.each_with_index {|c, i| self[i] = c }
	end
end
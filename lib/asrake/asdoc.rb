require 'rake/tasklib'
require 'nokogiri'

# http://help.adobe.com/en_US/flex/using/WSd0ded3821e0d52fe1e63e3d11c2f44bc36-7ffa.html

module ASRake
class Asdoc

	attr_accessor :output

	attr_accessor :doc_sources
	attr_accessor :doc_classes
	attr_accessor :doc_namespaces
	attr_accessor :source_path
	attr_accessor :library_path

	attr_accessor :load_config
	#
	# The path to the ASDoc template directory. The default is the asdoc/templates directory in the ASDoc
	# installation directory. This directory contains all the HTML, CSS, XSL, and image files used for
	# generating the output. 
	#
	attr_accessor :templates_path

	attr_accessor :additional_args

	@@compiler_args = [
		[:output, :dir],
		#
		# When true, retain the intermediate XML files created by the ASDoc tool. The default value is false. 
		#
		[:keep_xml, :bool],
		#
		# When true, configures the ASDoc tool to generate the intermediate XML files only, and not perform
		# the final conversion to HTML. The default value is false. 
		#
		[:skip_xsl, :bool],
		#
		# Whether all dependencies found by the compiler are documented. If true, the dependencies of
		# the input classes are not documented. The default value is false.
		#
		[:exclude_dependencies, :bool],
		#
		# Ignore XHTML errors (such as a missing </p> tag) and produce the ASDoc output.
		# All errors are written to the validation_errors.log file. 
		#
		[:lenient, :bool],
		[:source_path, :array],
		[:load_config, :array],
		[:library_path, :array],
		[:doc_classes, :array],
		[:doc_namespaces, :array],
	]

	@@compiler_args.each do |name, type|
		attr_accessor name
	end

	def initialize

		# set all defaults
		@@compiler_args.each do |name, type|
			instance_variable_set("@#{name}", []) if type == :array
		end

		@doc_sources = []

		yield self if block_given?
		
	end

	def execute
		command = "#{FlexSDK::asdoc}"

		@@compiler_args.each do |name, type|
			arg = name.to_s.gsub('_','-')
			value = instance_variable_get("@#{name}")
			case type
			when :bool
				command << " -#{arg}=#{value}" if value
			when :array
				value.flatten!
				value = value.map{|s| s.index(' ') != nil ? "'#{s}'" : s} if value.length > 1
				command << " -#{arg} #{cf value.join(' ')}" if !value.empty?
			when :dir
				command << " -#{arg}=#{cf value}" if value != nil
			else
				fail "unknown type #{type}"
			end
		end
		
		# Use doc-sources argument if it has been assigned (duh) or if neither doc-classes or doc-namespaces have
		# been assigned and source-path has
		if !self.doc_sources.empty?
			command << " -doc-sources #{cf doc_sources.join(' ')}"
		elsif !self.source_path.empty? && self.doc_classes.empty? && self.doc_namespaces.empty?
			command << " -doc-sources #{cf source_path.join(' ')}" if !self.source_path.empty?
		end

		command << " #{additional_args}" if self.additional_args != nil
		
		run command
	end

end
end
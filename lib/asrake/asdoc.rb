require 'rake/tasklib'
require 'nokogiri'

# http://help.adobe.com/en_US/flex/using/WSd0ded3821e0d52fe1e63e3d11c2f44bc36-7ffa.html

module ASRake
class Asdoc

	attr_accessor :additional_args

	# we have some special handling of this
	attr_accessor :doc_sources

	@@compiler_args = [
		[:source_path, :dirs],
		[:load_config, :dirs],
		[:library_path, :dirs],
		[:namespace, :string],
		#
		# The output directory for the generated documentation. The default value is "asdoc-output".
		#
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
		#
		# The path to the ASDoc template directory. The default is the asdoc/templates directory in the ASDoc
		# installation directory. This directory contains all the HTML, CSS, XSL, and image files used for
		# generating the output. 
		#
		[:templates_path, :dir],
		#
		# A list of classes to document. These classes must be in the source path. This is the default option.
		# This option works the same way as does the -include-classes option for the compc component compiler.
		#
		[:doc_classes, :array],
		# 
		# A list of classes not documented. You must specify individual class names.
		# Alternatively, if the ASDoc comment for the class contains the @private tag, is not documented. 
		#
		[:exclude_classes, :array],
		#
		# A list of URIs to document. The classes must be in the source path.
		# You must include a URI and the location of the manifest file that defines the contents of this namespace.
		# This option works the same way as does the -include-namespaces option for the compc component compiler.
		#
		[:doc_namespaces, :array],
		#
		# Specifies the location of the include examples used by the @includeExample tag. This option specifies the
		# root directory. The examples must be located under this directory in subdirectories that correspond to the
		# package name of the class. For example, you specify the examples-path as c:\myExamples. For a class in the
		# package myComp.myClass, the example must be in the directory c:\myExamples\myComp.myClass.
		#
		[:examples_path, :dir],
		#
		# The text that appears at the bottom of the HTML pages in the output documentation.
		#
		[:footer, :string],
		#
		# The text that appears in the browser window in the output documentation.
		# The default value is "API Documentation".
		#
		[:window_title, :string],
		#
		# An integer that changes the width of the left frameset of the documentation. You can change this
		# size to accommodate the length of your package names.
		# The default value is 210 pixels.
		#
		[:left_frameset_width, :string],
		#
		# The text that appears at the top of the HTML pages in the output documentation.
		# The default value is "API Documentation".
		#
		[:main_title, :string],
		#
		# The descriptions to use when describing a package in the documentation.
		# You can specify more than one package option.
		# The following example adds two package descriptions to the output:
		# asdoc = ASRake::Asdoc.new
		# asdoc.package << 'com.my.business "Contains business classes and interfaces"'
		# asdoc.package << 'com.my.commands "Contains command base classes and interfaces"'
		[:package, :array],
		#
		# Specifies an XML file containing the package descriptions. 
		#
		[:package_description_file, :dir],
		#
		# Disable strict compilation mode. By default, classes that do not define constructors, or contain methods
		# that do not define return values cause compiler failures. If necessary, set strict to false to override
		# this default and continue compilation.
		#
		[:strict, :bool]
	]

	@@compiler_args.each do |name, type|
		attr_accessor name
	end

	def initialize
		# set all defaults
		@@compiler_args.each do |name, type|
			instance_variable_set("@#{name}", []) if type == :array || type == :dirs
		end

		@doc_sources = []

		yield self if block_given?
	end

	def add(args)
		self.source_path << args.source_path
		self.library_path << args.library_path
		self.library_path << args.include_libraries
		self.library_path << args.external_library_path
		args.source_path.each { |p| self.doc_classes << ASRake::get_classes(p) } if args.kind_of? CompcArguments
	end

	def execute(&block)
		command = "#{FlexSDK::asdoc}"

		@@compiler_args.each do |name, type|
			arg = name.to_s.gsub('_','-')
			value = instance_variable_get("@#{name}")
			case type
			when :bool
				command << " -#{arg}=#{value}" if value
			when :dirs
				value.flatten!
				value.uniq!
				value = value.map{|s| s.index(' ') != nil ? "\"#{s}\"" : s} if value.length > 1
				command << " -#{arg} #{cf value.join(' ')}" if !value.empty?
			when :dir
				command << " -#{arg}=#{cf value}" if value != nil
			when :array
				value.flatten!
				value.uniq!
				command << " -#{arg} #{value.join(' ')}" if !value.empty?
			when :string
				command << " -#{arg} #{value}" if value != nil
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
		
		puts if !block_given?
		run(command, true, &block)
	end

end
end
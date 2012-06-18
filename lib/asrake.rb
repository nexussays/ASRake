require 'rake/tasklib'

#ASRake
require 'host'
require 'flexsdk'

module ASRake

	class SWC < Rake::TaskLib

		attr_accessor :output

		attr_accessor :source_path
		attr_accessor :library_path
		attr_accessor :external_library_path
		attr_accessor :include_libraries

		attr_accessor :load_config

		attr_accessor :target_player
		attr_accessor :swf_version

		attr_reader :output_file
		attr_reader :output_dir

		def initialize(name)

			@library_path = []
			@external_library_path = []
			@include_libraries = []
			@source_path = []

			#http://fpdownload.macromedia.com/get/flashplayer/updaters/11/playerglobal11_2.swc
			#frameworks\libs\player

			##fill config with the default flex_config options
			#if @use_default_flex_config
			#	#initialize with default values from flex-config
			#	flex_config = Nokogiri::XML(File.read(FlexSDK::flex_config))
			#
			#	@target_player = flex_config.css('target-player').children.to_s
			#	@swf_version = flex_config.css('swf-version').children.to_s
			#	
			#	flex_config.css('compiler external-library-path path-element').each { |ext|
			#		puts ext.children
			#	}
			#end

			#include default flex-config
			@load_config = [ FlexSDK::flex_config ]

			yield(self) if block_given?

			#TODO: iterate over all non-default config files provided and look for target-player
			if @target_player == nil
				fail "You must define 'target_player' for this task"
			end

			#TODO: iterate over all non-default config files provided and look for source-path entries
			if @source_path.empty?
				fail "You must add at least one path to 'source_path' for this task"
			end

			#TODO: iterate over all non-default config files provided and look for output
			if @output == nil
				fail "You must define 'output' for this task"
			end

			#output is directory
			if @output =~ /[\/\\]$/
				@output_dir = @output
			else
				#forward-slashes required for File methods
				@output.gsub!('\\', '/')
				@output_dir = File.dirname(@output)
				@output_file = File.basename(@output)
			end			

			#I can't see this occuring outside of my testing, but if the output already exists as a directory when
			#we want a file or as a file when we want a directory, be sure to delete it first
			if output_is_dir? != File.directory?(@output)
				rm_rf @output.sub(/[\/\\]$/, '') rescue nil
			end

			#create named task first so it gets the desc if one is added
			#the dependency to actually build the swc is added later
			Rake::Task.define_task name do
				result = c @output
				result << " (#{File.size(@output)} bytes)" unless output_is_dir?
				puts result
			end

			#set dependencies on all .as and .mxml files in the source paths
			dependencies = FileList.new
			@source_path.each do |path|
				path.gsub!("\\", "/")
				dependencies.include(path/"*.as")
				dependencies.include(path/"**"/"*.as")
				dependencies.include(path/"*.mxml")
				dependencies.include(path/"**"/"*.mxml")
			end

			#create directory task for output
			directory @output_dir

			#set dependencies for output
			file @output => @output_dir
			if !dependencies.empty?
				file @output => dependencies
			end

			#add output file task as a dependency to the named task created
			task name => @output

			#create the task to compile the swc
			file @output do
				compc = "#{c FlexSDK::compc_path}"
				
				#set output as directory if it ends in a trailing slash
				compc << " -directory=true" if output_is_dir?
				compc << " -output=#{c @output}"

				compc << " -target-player=#{@target_player}"
				compc << " -swf-version=#{@swf_version}" if @swf_version != nil

				compc << " -source-path=#{c @source_path.join(',')}" if !@source_path.empty?
				compc << " -include-sources=#{c @source_path.join(',')}" if !@source_path.empty?
				
				#add the -load-config option if it is anything other than the default
				unless @load_config.length == 1 && @load_config[0] == FlexSDK::flex_config
					compc << " -load-config=#{c @load_config.join(',')}"
				end

				compc << " -library-path+=#{c @library_path.join(',')}" if !@library_path.empty?
				compc << " -external-library-path+=#{c @external_library_path.join(',')}" if !@external_library_path.empty?
				compc << " -include-libraries+=#{c @include_libraries.join(',')}" if !@include_libraries.empty?

				#compc << ' -include-file images\core_logo.png ..\nexuslib\code\etc\core_logo.png'
				
				#compc << " -include-classes #{classes(@source_path).join(' ')}"
				
				run compc do |line|
					generate_error_message_tips(line)
				end
			end

		end #def initialize()

		def output_is_dir?
			return @output_file == nil
		end

		#provide a more understandable alias 
		def statically_link_only_referenced_classes
			@library_path
		end

		def statically_link
			@include_libraries
		end

		def dynamically_link
			@external_library_path
		end

	end #class ASRake::SWC < Rake::TaskLib

end

def classes(path)
	arr = []
	Dir.chdir(path) do
		FileList["**/*.as"].pathmap('%X').each do |f|
			name = f.gsub(/^\.[\/\\]/, '').gsub(/[\/\\]/, '.')
			if block_given?
				yield name
			end
			arr << name
		end
	end
	return arr
end

#Try to include helpful information about specific errors
def generate_error_message_tips(line)
	advice = []
	if Integer(@target_player) < 11 && line.include?("Error: Access of undefined property JSON")
		advice << "Be sure you are compiling with 'target_player' set to 11.0 or higher"
		advice << "to have access to the native JSON parser. It is currently set to #{@target_player}"
	elsif line.include?("Error: The definition of base class Object was not found")
		advice << "If you have removed the default flex-config by setting 'load_config' to"
		advice << "an empty or alternate value (i.e., not appended to it) you must be sure to"
		advice << "still reference the necessary core Flash files, especially playerglobal.swc"
	end

	if !advice.empty?
		puts "*********************************"
		puts "ASRake Note: " + advice.join("\n")
		puts "*********************************"
	end
end
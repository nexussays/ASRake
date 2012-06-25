require 'asrake/flexsdk'

module ASRake

	module CompcArguments

		@@args = [
			:output,

			:source_path,
			:library_path,
			:external_library_path,
			:include_libraries,

			:load_config,
			:target_player,
			:swf_version,

			:debug,

			:dump_config
		]
		attr_accessor *@@args

		#
		# non-compiler arguments
		#
		
		attr_reader :output_file
		attr_reader :output_dir

		def initialize
			super
			@library_path = []
			@external_library_path = []
			@include_libraries = []
			@source_path = []
			@debug = false
			#include default flex-config
			@load_config = [ FlexSDK::flex_config ]
		end

		def output
			@output
		end

		def output= value
			@output = value
			# if the output path ends in a path separator, it is a directory
			if @output =~ /[\/\\]$/
				@output_dir = @output
			else
				# forward-slashes required for File methods
				@output = cf @output
				@output_dir = File.dirname(@output)
				@output_file = File.basename(@output)
			end
		end

		def output_is_dir?
			output_file == nil
		end

		# provide a more understandable alias 
		def statically_link_only_referenced_classes
			library_path
		end

		def statically_link
			include_libraries
		end

		def dynamically_link
			external_library_path
		end

		def command
			compc = "#{FlexSDK::compc_path}"
			
			# set output as directory if it ends in a trailing slash
			compc << " -directory=true" if output_is_dir?
			compc << " -output=#{cf output}"

			compc << " -target-player=#{target_player}"
			compc << " -swf-version=#{swf_version}" if swf_version != nil

			compc << " -debug=#{debug}"
			compc << " -source-path=#{cf source_path.join(',')}" if !source_path.empty?
			
			#compc << " -include-sources=#{cf source_path.join(',')}" if !source_path.empty?
			source_path.each do |path|
				compc << " -include-classes #{get_classes(path).join(' ')}"
			end

			# add the -load-config option if it is anything other than the default
			unless load_config.length == 1 && load_config[0] == FlexSDK::flex_config
				compc << " -load-config=#{cf load_config.join(',')}"
			end

			compc << " -library-path=#{cf library_path.join(',')}" if !library_path.empty?
			compc << " -external-library-path=#{cf external_library_path.join(',')}" if !external_library_path.empty?
			compc << " -include-libraries=#{cf include_libraries.join(',')}" if !include_libraries.empty?

			compc << " -dump-config=#{cf dump_config}" if dump_config != nil
			#compc << ' -include-file images\core_logo.png ..\nexuslib\code\etc\core_logo.png'
			
			return compc
		end

		def merge_in(compc)
			@@args.each do |arg|
				# TODO: This needs to concat arrays not overwite them
				self.send("#{arg}=", compc.send(arg))
			end
		end

	end

	class Compc
		include CompcArguments
	end

end
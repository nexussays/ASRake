require 'asrake/util'

class FlexSDK

SDK_PATHS = [] unless const_defined?(:SDK_PATHS)
SDK_PATHS << ENV["FLEX_HOME"].dup if defined?(ENV) && ENV["FLEX_HOME"] != nil

class << self
	
	include ASRake
	
	@@initialized = false

	# dynamically create getters for the executables and config files
	@@executables = %w[adt adl asdoc mxmlc compc]
	@@configs = %w[flex-config air-config]
	
	def root
		init()
		return @root
	end

	[].concat(@@configs).concat(@@executables).each do |name|
		name = name.gsub('-','_')
		define_method name do
			init()
			instance_variable_get "@#{name}"
		end
	end

	private

	def init()
		if @@initialized
			return
		end
		@@initialized = true
		@@root = nil
		missing = {}

		# clean up paths
		SDK_PATHS.map do |path|
			path.strip!
			#remove /bin/ fom the end of the path if it exists
			path.sub!(/[\/\\]bin[\/\\]?$/,'')
		end

		# Find where the flex sdk is installed
		SDK_PATHS.each do |path|
			if File.exists?(path)
				missing[SDK_PATHS] = []

				@@configs.each do |name|
					config = Path::env File.join(path, 'frameworks', "#{name}.xml")
					missing[SDK_PATHS] << config if !File.exists?(config)
					config = "\"#{config}\"" if config =~ /\s/
					instance_variable_set "@#{name.gsub('-','_')}", config
					(instance_variable_get "@#{name.gsub('-','_')}").freeze
				end

				@@executables.each do |name|
					exec = Path::env File.join(path, 'bin', name)
					missing[SDK_PATHS] << exec if !File.exists?(exec)
					exec = "\"#{exec}\"" if exec =~ /\s/
					instance_variable_set "@#{name}", exec
					(instance_variable_get "@#{name}").freeze
				end
				
				if missing[SDK_PATHS].empty?
					@@root = path
					break
				end
			end
		end

		if @@root == nil
			str = ""
			if !SDK_PATHS.empty?
				str << "Could not find a valid Flex SDK at any of the paths in FlexSDK::SDK_PATHS\n=> "
				# TODO: output which paths are invalid and which are missing a particular binary from missing[] above
				str << SDK_PATHS.join("\n=> ")
				str << "\n"
			end
			str << "Append a valid SDK path in your rakefile, e.g.:\n"
			str << "FlexSDK::SDK_PATHS << 'C:\\develop\\sdk\\flex_sdk_4.6.0.23201'\n"
			str << "or add an environment variable FLEX_HOME"
			#str << "\nFor more information, see: http://adobe.com/go/flex_sdk/"
			fail str
		end
	end
end

end

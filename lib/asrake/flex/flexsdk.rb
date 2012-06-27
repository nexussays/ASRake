require 'asrake/host'

class FlexSDK
	SDK_PATHS = []
	
	class << self

		@@initialized = false
		
		@@executables = %w[adt adl asdoc mxmlc compc]
		@@configs = %w[flex-config air-config]
		
		def root
			init()
			return @root
		end

		@@configs.each do |name|
			method = name.gsub('-','_')
			define_method method do
				init()
				instance_variable_get "@#{method}"
			end
		end

		@@executables.each do |name|
			define_method name do
				init()
				instance_variable_get "@#{name}"
			end
		end

		private

		def init()
			if !@@initialized
				@@root = nil
				
				# Find where the flex sdk is installed
				SDK_PATHS.each do |path|
					#remove /bin/ fom the end of the path if it exists
					path.sub!(/[\/\\]bin[\/\\]?$/,'')
					if File.exists?(path)
						allValid = true

						@@configs.each do |name|
							config = c File.join(path, 'frameworks', "#{name}.xml")
							allValid = false if !File.exists?(config)
							instance_variable_set "@#{name.gsub('-','_')}", config
						end

						@@executables.each do |name|
							exec = c File.join(path, 'bin', name)
							allValid = false if !File.exists?(exec)
							instance_variable_set "@#{name}", exec
						end
						
						if allValid
							@@root = path
							break
						end
					end
				end

				if @@root == nil
					str = ""
					if !SDK_PATHS.empty?
						str << "Could not find a valid Flex SDK at any of the paths in FlexSDK::SDK_PATHS\n=> "
						str << SDK_PATHS.join("\n=> ")
						str << "\n"
					end
					str << "Append a valid SDK path in your rakefile, e.g.:\nFlexSDK::SDK_PATHS << 'C:\\develop\\sdk\\flex_sdk_4.6.0.23201'"
					str << "\nFor more information, see: http://adobe.com/go/flex_sdk/"
					fail str
				end
			end
			@@initialized = true
		end
	end

end
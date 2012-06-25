require 'asrake/host'

class FlexSDK
	SDK_PATHS = []
	
	class << self

		@initialized = false

		def flex_root
			init()
			return @flex_root
		end

		def adt_path
			init()
			return @adt_path
		end

		def adl_path
			init()
			return @adl_path
		end

		def asdoc_path
			init()
			return @asdoc_path
		end

		def mxmlc_path
			init()
			return @mxmlc_path
		end

		def compc_path
			init()
			return @compc_path
		end

		def flex_config
			init()
			return @flex_config
		end

		private

		def init()
			if !@initialized
				@flex_root = nil
				
				# Find where the flex sdk is installed
				SDK_PATHS.each do |path|
					#remove /bin/ fom the end of the path if it exists
					path.sub!(/[\/\\]bin[\/\\]?$/,'')
					if File.exists?(path)
						@flex_config = c File.join(path, 'frameworks', 'flex-config.xml')
						# TODO: figure out some method to use reflection to derive these
						@adt_path = c File.join(path, 'bin', 'adt')
						@adl_path = c File.join(path, 'bin', 'adl')
						@mxmlc_path = c File.join(path, 'bin', 'mxmlc')
						@compc_path = c File.join(path, 'bin', 'compc')
						@asdoc_path = c File.join(path, 'bin', 'asdoc')
						# if all the commands exist in the proper locations, set flex_root and break
						if 	File.exists?(@adt_path) && File.exists?(@adl_path) && File.exists?(@mxmlc_path) &&
							File.exists?(@compc_path) && File.exists?(@flex_config) && File.exists?(@asdoc_path)
							@flex_root = path
							break
						end
					end
				end

				if @flex_root == nil
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
			@initialized = true
		end
	end

end
require 'host'

class FlexSDK
	SDK_PATHS = []

	@@initialized = false

	def self.flex_root
		init()
		return @@flex_root
	end

	def self.adt_path
		init()
		return @@adt_path
	end

	def self.adl_path
		init()
		return @@adl_path
	end

	def self.mxmlc_path
		init()
		return @@mxmlc_path
	end

	def self.compc_path
		init()
		return @@compc_path
	end

	def self.flex_config
		init()
		return @@flex_config
	end

	private

	def self.init()
		if !@@initialized
			@@flex_root = nil
			
			# Find where the flex sdk is installed
			SDK_PATHS.each do |path|
				#remove /bin/ fom the end of the path if it exists
				path.sub!(/[\/\\]bin[\/\\]?$/,'')
				if File.exists?(path)
					@@flex_config = path/'frameworks'/'flex-config.xml'
					# TODO: figure out some method to use reflection to derive these
					@@adt_path = path/'bin'/'adt'
					@@adl_path = path/'bin'/'adl'
					@@mxmlc_path = path/'bin'/'mxmlc'
					@@compc_path = path/'bin'/'compc'
					#if all the commands exist in the proper locations, set flex_root and break
					if 	File.exists?(@@adt_path) && File.exists?(@@adl_path) && File.exists?(@@mxmlc_path) &&
						File.exists?(@@compc_path) && File.exists?(@@flex_config)
						@@flex_root = path
						break
					end
				end
			end

			if @@flex_root == nil
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
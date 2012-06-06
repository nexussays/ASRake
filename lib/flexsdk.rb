class FlexSDK
	SDK_PATHS = []

	@initialized = false

	def sdk_path
		init()
		return @sdk_path
	end

	def adt_path
		init()
		return @adt_path
	end

	def adl_path
		init()
		return @adl_path
	end

	def mxmlc_path
		init()
		return @mxmlc_path
	end

	def compc_path
		init()
		return @compc_path
	end

	private

	def init()
		if !@initialized
			# Find where the flex sdk is installed
			SDK_PATHS.each do |path|
				path.sub!(/[\/\\]bin[\/\\]?$/,'')
				if File.exists?(path)
					# TODO: figure out some method to use reflection to derive these
					@adt_path = File.join(path, 'bin', 'adt')
					@adl_path = File.join(path, 'bin', 'adl')
					@mxmlc_path = File.join(path, 'bin', 'mxmlc')
					@compc_path = File.join(path, 'bin', 'compc')
					#if all the commands exist in the proper locations, set sdk_path and break
					if File.exists?(@adt_path) && File.exists?(@adl_path) && File.exists?(@mxmlc_path) && File.exists?(@compc_path)
						@sdk_path = path
						break
					end
				end
			end

			if @sdk_path == nil
				str = "\nrake aborted!\n"
				if !SDK_PATHS.empty?
					str << "Could not find a valid Flex SDK at any of the paths in FlexSDK::SDK_PATHS\n=> "
					str << SDK_PATHS.join("\n=> ")
					str << "\n\n"
				end
				str << "Append a valid SDK path in your rakefile, e.g.:\nFlexSDK::SDK_PATHS << '/my/path/flex4.6'"
				abort str
			end
		end
		@initialized = true
	end
end
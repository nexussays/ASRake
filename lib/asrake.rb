require 'rake/tasklib'
require 'flexsdk'

module ASRake

	class SWC < Rake::TaskLib

		attr_accessor :source_path
		attr_accessor :output
		attr_accessor :library_path
		attr_accessor :external_library_path

		def initialize()
			@source_path = "src"
			@output = "bin/#{@source_path}.swc"
			@library_path = []

			yield(self) if block_given?
			
			sdk = FlexSDK.new
			namespace :swc do
				task :build do
					rm_rf @output
					rm_rf @output + ".tmp"

					cmd = "#{sdk.compc_path}"
					
					#set output as directory if it ends in a trailing slash
					cmd << " -directory=true" if @output =~ /[\/\\]$/
					cmd << " -output=#{@output}"

					cmd << " -source-path #{@source_path}"
					cmd << " -include-sources #{@source_path}"
					
					cmd << " -library-path #{@library_path.join(' ')}"

					#cmd << ' -include-file images\core_logo.png C:\Users\nexus\Development\Projects\Personal\nexuslib\code\etc\core_logo.png'
					
					#cmd << " -include-classes #{classes(@source_path).join(' ')}"
					
					puts cmd.gsub!("/", '\\')
					
					#puts `#{cmd}`
				end
			end
		end#def initialize()

		def statically_link_referenced=(value)
			library_path << value
			puts library_path
		end

	end#class ASRake::SWC < Rake::TaskLib

end

def classes(path)
	arr = []
	Dir.chdir(path) do
		FileList["**/*.as"].pathmap('%d/%n').each do |f|
			name = f.gsub(/^\.\//, '').gsub('/', '.')
			if block_given?
				yield name
			end
			arr << name
		end
	end
	return arr
end
module ASRake
class << self

	def get_classes(path)
		arr = []
		Dir.chdir(path) do
			FileList["**/*.as"].pathmap('%X').each do |file|
				name = file.gsub(/^\.[\/\\]/, "").gsub(/[\/\\]/, ".")
				yield name if block_given?
				arr << name
			end
		end
		return arr
	end

end
end

module ASRake::OS
class << self
	def is_mac?
		RUBY_PLATFORM.downcase.include?("darwin")
	end

	def is_windows?
		require 'rbconfig'
		RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
	end

	def is_linux?
		RUBY_PLATFORM.downcase.include?("linux")
	end
end
end

module ASRake::Path
class << self
	def env(str)
		ASRake::OS::is_windows? ? back(str) : forward(str)
	end

	def back(str)
		str.gsub("/", "\\")
	end

	def forward(str)
		str.gsub("\\", "/")
	end
end
end

def run(command, abort_on_failure = true)
	command.strip!

	puts "> #{command}" if !block_given?
	IO.popen("#{command} 2>&1") do |proc|
		while !proc.closed? && (line = proc.gets)
			if block_given?
				yield line
			else
				puts ">    #{line}"
			end
		end
	end

	if $?.exitstatus != 0
		msg = "Operation exited with status #{$?.exitstatus}"
		raise msg if abort_on_failure
		#puts msg
	end

	return $?
end
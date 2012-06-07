module OS
	def self.is_mac?
		RUBY_PLATFORM.downcase.include?("darwin")
	end

	def self.is_windows?
		require 'rbconfig'
		RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
	end

	def self.is_linux?
		RUBY_PLATFORM.downcase.include?("linux")
	end
end

def run(command, abort_on_failure = true)
	output = ""

	command.strip!

	puts "> #{command}"
	IO.popen("#{command} 2>&1") do |proc|
		while !proc.closed? && (line = proc.gets)
			puts ">    #{line}"
			output << line
			yield line if block_given?
		end
	end

	if $?.exitstatus != 0
		msg = "Operation exited with status #{$?.exitstatus}"
		fail msg if abort_on_failure
		puts msg
	end

	return output
end

def c(str)
	if OS::is_windows?
		str.gsub("/", "\\")
	else
		str.gsub("\\", "/")
	end
end

class String
	def /(join)
		File.join(self, join)
	end
end
module OS
	def OS.is_mac?
		RUBY_PLATFORM.downcase.include?("darwin")
	end

	def OS.is_windows?
		require 'rbconfig'
		RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
	end

	def OS.is_linux?
		RUBY_PLATFORM.downcase.include?("linux")
	end
end

def run(command, abort_on_failure = true)
	command.strip!

	puts "> #{command}"
	IO.popen("#{command} 2>&1") do |proc|
		while !proc.closed? && (line = proc.gets)
			puts ">    #{line}"
			yield line if block_given?
		end
	end

	if $?.exitstatus != 0
		msg = "Operation exited with status #{$?.exitstatus}"
		fail msg if abort_on_failure
		puts msg
	end

	return $?
end

def c(str)
	OS::is_windows? ? cb(str) : cf(str)
end

def cb(str)
	str.gsub("/", "\\")
end

def cf(str)
	str.gsub("\\", "/")
end
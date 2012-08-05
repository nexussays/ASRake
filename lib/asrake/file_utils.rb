require 'fileutils'

module ASRake
module FileUtilsExt

	#
	# Copies files recursivly only if they don't exist at the destination or the destination
	# files are older.
	# 
	# There are two possible ways to copy, multiple files, or a single file
	#
	# 1. Copying multiple files
	#    Examples:
	#    * `cp_u FileList["/path/*.ext"], "/dest"`
	#    * `cp_u %w{src1 /path/src2}, "/dest"`
	#    * `cp_u /path/to/src/, "/dest"`
	#    An error will be thrown if the destination already exists and is not a directory.
	# 2. Copying a single file
	#    For example, copying file "src"
	#    1. If destination is, or is infered to be, a directory, the src file is copied to 
	#       an identically named file at the destination directory
	#       `cp_u /path/src, /path/dest/`
	#       `cp_u /path/src, /path/dest` <- dest is an existing directory
	#    2. If destination is, or is infered to be, a file, the src file is copied and renamed
	#       to the destination file
	#       `cp_u /path/src, /path/dest` <- dest does not exist or is a file
	#
	def cp_u(src, dest, options = {})
		if tmp = Array.try_convert(src)
			tmp.each do |s|
				copy_files(s, File.join(dest, File.basename(s)), options)
			end
		else
			copy_files(src, dest, options)
		end
		#puts "Files copied. #{src} => #{dest}"
	end

	private

	def copy_files(src, dest, options)
		if File.directory?(src)
			#recurse the "src" dir tree, appending the path to dest
			Dir.foreach(src) do |src_file|
				if src_file != ".." && src_file != "."
					#puts src_file + "|" + File.join(src, src_file) + "|" + File.join(dest, src_file)
					copy_files(File.join(src, src_file), File.join(dest, src_file), options)
				end
			end
		else
			# If the destination is an existing directory, or ends in a path separator, then
			# append the source file name to it
			dest = File.join(dest, File.basename(src)) if File.directory?(dest) || dest =~ /[\\\/]$/

			if !File.exist?(dest) || (File.mtime(dest) < File.mtime(src))
				puts "cp -u #{[src,dest].flatten.join ' '}" if options[:verbose]
				return if options[:noop]
				begin
					dir = File.dirname(dest)
					mkdir_p(dir, :verbose => false) if !File.exist?(dir)
				rescue
					fail "Error copying #{src} to #{dest}. Cannot create directory. #{$!}"
				end
				begin
					FileUtils::copy_file src, dest
				rescue
					fail "Error copying #{src} to #{dest}. #{$!}"
				end
			end
		end
	end
end
end

module FileUtils
	include ASRake::FileUtilsExt
	module_function :cp_u
	module_function :copy_files
end

self.extend ASRake::FileUtilsExt
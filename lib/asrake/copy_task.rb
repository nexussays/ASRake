require 'rake/tasklib'

module ASRake
class CopyTask < Rake::TaskLib

	attr_accessor :copy_list

	def initialize(name = :copy)
		self.copy_list = Hash.new

		yield self if block_given?

		#define named task first so if desc was called it will be attached to it instead of the file task
		Rake::Task.define_task name do
			# use longest source path to space the output. yup, seriously that OCD
			len = self.copy_list.keys.group_by(&:size).max.last[0].length
			self.copy_list.each do |from, to|
				copy_files from, to
				puts "Files copied. %#{len}s => %s" % [from, to]
			end
		end
	end

	def copy(from_path, to_path=nil)
		if from_path == nil
			fail puts "Cannot copy files. No source provided."
		end

		# special case getting a hash as an argument
		if from_path.is_a? Hash
			from_path.each {|from, to| copy from, to}
			return
		end

		if to_path == nil
			fail puts "Cannot copy files from #{from_path}. No destination provided."
		end

		self.copy_list[from_path] = to_path
	end
	alias_method :add, :copy

	private

	def copy_files(from_path, to_path, times=0)
		from = FileList[from_path]
		unless from.length == 0
			from.each do |from|
				if File.directory?(from)
					#recurse the "from" dir tree, appending the path to to_path
					Dir.foreach(from) do |fr|
						if fr != ".." && fr != "."
							#puts fr + "|" + File.join(from, fr) + "|" + File.join(to_path, fr)
							copy_files(File.join(from, fr), File.join(to_path, fr), times+1)
						end
					end
				else
					# if this is the first iteration, we haven't gotten to join the "to" path in the directory loop above, so
					# append it to the file here if either the to or from path are a directory
					if times == 0 && (File.directory?(to_path) || File.directory?(from_path) || from_path =~ /\*/)
						to = File.join(to_path, File.basename(from)) 
					else
						to = to_path
					end

					if !File.exists?(to) || (File.mtime(to.to_s) < File.mtime(from.to_s))
						begin
							dir = File.dirname(to)
							mkdir_p(dir, :verbose => false) if !File.exist?(dir)
						rescue
							fail "Error copying #{from} to #{to}. Cannot create directory. #{$!}"
						end
						begin
							cp_r from, to#, :verbose => false
						rescue
							fail "Error copying #{from} to #{to}. #{$!}"
						end
					end
				end
			end
		else
			puts "Error copying to #{to_path}. No files exist at source #{from_path}."
		end
	end

end
end
require 'rake/tasklib'
require 'zip/zip'

module ASRake
	class Package < Rake::TaskLib

		attr_accessor :output
		attr_accessor :files

		attr_reader :output_file
		attr_reader :output_dir

		def initialize(name)

			yield self if block_given?

			fail "You must define the output 'output' for task #{name}" if output == nil
			fail "You must define 'files' to include for task #{name}" if files == nil

			#define named task first so if desc was called it will be attached to it instead of the file task
			Rake::Task.define_task name do
				puts "#{c output} (#{File.size(output)} bytes)"
			end

			#if the task name is a hash (ie, has dependencies defined) make sure we pull out the task name from it
			name, _ = name.first if name.is_a? Hash

			@output_dir = File.dirname(output)
			@output_file = File.basename(output)

			directory output_dir

			# setup file dependencies
			file output => output_dir
			files.each do |to, from|
				file output => [cf(from)]
			end
			
			#add output file task as a dependency to the named task created
			task name => output

			#create the zip task
			file output do
				rm_r output rescue nil
				Zip::ZipFile.open(output, Zip::ZipFile::CREATE) do |zipfile|
					files.each do |to, from|
						zipfile.add(cf(to), cf(from))
					end
				end
			end

		end

	end
end
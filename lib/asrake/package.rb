require 'asrake/util'
require 'asrake/base_task'
require 'zip/zip'

module ASRake
class Package < BaseTask

	include Rake::DSL
	
	attr_accessor :files

	def initialize(file=nil)
		super(file)
	end

	def files
		@files
	end
	def files= value
		@files = value
		files.each do |to, from|
			file output => [Path::forward(from)]
		end
	end

	def to_s
		@output
	end

	def execute
		rm_r output rescue nil
		Zip::ZipFile.open(output, Zip::ZipFile::CREATE) do |zipfile|
			files.each do |to, from|
				zipfile.add(Path::forward(to), Path::forward(from))
			end
		end
	end
end
end
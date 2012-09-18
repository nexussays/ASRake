=begin MIT-LICENSE
Copyright (c) 2012 Malachi Griffie <malachi@nexussays.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
=end

# require all the task files so users can create them just by requiring asrake
Dir.glob(File.join(File.expand_path(File.dirname(__FILE__)), "asrake/*_task.rb")).each {|f| require f }
Dir.glob(File.join(File.expand_path(File.dirname(__FILE__)), "asrake/*_args.rb")).each {|f| require f }

require 'asrake/file_utils'

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
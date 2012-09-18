ASRake
======

**A Rake library for Actionscript 3, Flex, and AIR projects.**

### `gem install asrake`


Overview
--------

Add the path(s) to your Flex SDK for all systems that will need to run the Rake tasks.
```ruby
FlexSDK::SDK_PATHS << 'C:\develop\sdk\flex_sdk_4.6.0.23201'
FlexSDK::SDK_PATHS << "C:/develop/sdk/flex_sdk_4.5.1"
FlexSDK::SDK_PATHS << "/opt/lib/adobe/flex_4.6"
```

### Compiler Arguments

Arguments match those passed to the compiler (mxmlc, compc, adt, etc) with hyphens `-` replaced by underscores `_` (e.g., to set the `target-player` compiler argument assign to the `target_player` property)

> Since this is still in development, not all compiler arguments have a property mapped to them. Use `additional_args` to pass whatever text you want into the compiler.

Convenience methods are provided for `include_libraries`, `external_library_path`, and `library_path`; you can instead use `statically_link`, `dynamically_link`, and `statically_link_only_referenced_classes` respectively.


How to Tasks
------------

### Build a SWF or SWC

```
ASRake::MxmlcTask(task_name = :build, compiler_args = nil) |self|
```
```
ASRake::CompcTask(task_name = :build, compiler_args = nil) |self|
```

You can define the compile arguments elsewhere and pass it to the task, or set them inside the task block, or a combination of both. It is purely preference.

The following snippets produce identical tasks.

```ruby
desc "Build swc"
ASRake::CompcTask.new :build do |build|
# You can store the compiler arguments for later
# For example, maybe we need to know the output_dir later on
#compc = ASRake::CompcTask.new :build do |build|
	build.target_player = 11.0
	build.output = "bin/bin/my_project.swc"
	build.debug = true
	build.source_path << "bin/src"
	build.statically_link_only_referenced_classes << "lib/lib_used_in_project.swc"
end
```

```ruby
args = ASRake::CompcArguments.new
args.target_player = 11.0
args.output = "bin/bin/my_project.swc"
args.debug = true
args.source_path << "bin/src"
args.statically_link_only_referenced_classes << "lib/lib_used_in_project.swc"

desc "Build swc"
ASRake::CompcTask.new :build, args
```

```ruby
args = ASRake::CompcArguments.new
args.target_player = 11.0
args.output = "bin/bin/my_project.swc"
args.debug = false
args.source_path << "bin/src"

desc "Build swc"
ASRake::CompcTask.new :build, args do |compc|
	compc.debug = true
	compc.statically_link_only_referenced_classes << "lib/lib_used_in_project.swc"
end
```

### Include ASDoc in a SWC

If you are compiling with `CompcArgs` or a `CompcTask`, you can set the field `include_asdoc` to have documentation added to your swc

```ruby
desc "Build swc"
ASRake::CompcTask.new :build do |build|
	build.target_player = 11.0
	build.output = "bin/bin/my_project.swc"
	build.debug = true
	build.source_path << "bin/src"
	build.statically_link_only_referenced_classes << "lib/lib_used_in_project.swc"
	build.include_asdoc = true
end
```

### Build an AIR

Compile your SWF file as normal, but set the `isAIR` property to true

```ruby
desc "Build app"
ASRake::MxmlcTask.new :build do |build|
	build.load_config << "mxmlc_config.xml"
	build.output = "bin/my_app.swf"
	build.isAIR = true
end
```

Provide the package task with the AIR and keystore information. If the key doesn't exist, it will be created.

> Be sure that the swf file is included in the package (eg, it is included here by packaging everything in the bin directory with `-C bin .`)

```ruby
ASRake::AdtTask.new :package => :build do |package|
	package.output = "bin/my_app.air"
	package.keystore = "my_app_cert.p12"
	package.keystore_name = "my_app"
	package.storepass = "my_app"
	package.tsa = "none"
	package.additional_args = "-C bin ."
end
```

### Version

```
ASRake::VersionTask(task_name = :version, file_name = "VERSION")
```

No additional arguments are needed to create a version task. Once added to your Rakefile, you can run `rake version:help` for information on how versioning works.

If you are fine with the defaults, you can just add:

```ruby
ASRake::VersionTask.new
```

Otherwise you can define the task name and filename as you wish

```ruby
ASRake::VersionTask.new :v, "./config/version.txt"
```

#### Version Sync

There is a task `version:sync` that is run every time the version changes. This can be useful for things like updating configuration files automatically. To use, add a block to the task:

```ruby
# replace :version with whatever you provided to ASRake::VersionTask.new 
namespace :version do
	task :sync do
		#update application.xml
	end
end
```

### Clean

```
ASRake::CleanTask.new(*compiler_args)
```

Provide your compiler arguments to `ASRake::CleanTask` and it will automatically create clean and clobber tasks.

```ruby
swf = ASRake::MxmlcTask.new :build do |build|
	build.load_config << "mxmlc_config.xml"
	build.output = "bin/my_app.swf"
	build.isAIR = true
end

ASRake::CleanTask.new swf
```

Additional Functionality
------------------------

### New copy method

ASRake introduces a new copy method `cp_u` on FileUtils and in the global namespace.

This copies all files from the source that do not exist or are older at the destination

```ruby
# copy a single file to a destination folder
cp_u "path/to/file.xml", "/dest/"

# copy a single file to a differently named file
cp_u "path/to/file.xml", "/dest/dest.xml"

# copy an array of files
cp_u %w{application.xml my_app.swf config.json}, "/dest"

# use FileList, Dir.glob(), or othr methods to copy groups of files
cp_u FileList["lib/**/*.swc"], "bin/lib"
```

### Build without a task

You don't need to create a rake task to build a swf or swc. Just call `build()` on an instance of CompcArguments or MxmlcArguments.

> Note that this will not do any dependency checks, so the build will run even if it is unnecessary

```ruby
args = ASRake::CompcArguments.new
args.target_player = 11.0
args.output = "bin/bin/my_project.swc"
args.source_path << "bin/src"
args.statically_link_only_referenced_classes << "lib/lib_used_in_project.swc"
args.build()

ASRake::MxmlcArguments.new do |mxmlc|
	mxmlc.target_player = 11.0
	mxmlc.output = "bin/bin/my_project.swf"
	mxmlc.debug = true
	mxmlc.source_path << "bin/src"
	mxmlc.build()
end
```
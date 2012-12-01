# ASRake

**Quickly and easily create build scripts for Actionscript 3, Flex, and AIR projects.**

## Installation

### `gem install asrake`

## Usage

Add the path(s) to your Flex SDK for all systems that will need to run the Rake tasks. If set, the value of the environment variable `FLEX_HOME` is added by default.

```ruby
FlexSDK::SDK_PATHS << 'C:\develop\sdk\flex_sdk_4.6.0.23201'
FlexSDK::SDK_PATHS << "C:/develop/sdk/flex_sdk 4.5.1"
FlexSDK::SDK_PATHS << "/opt/lib/adobe/flex_4.6"
```

### Compiler Arguments

Arguments match those passed to the compiler (mxmlc, compc, adt, etc) with hyphens `-` replaced by underscores `_` (e.g., to set the `target-player` compiler argument assign to the `target_player` property)

> Since this is still in development, not all compiler arguments have a property mapped to them. Use `additional_args` to pass whatever text you want into the compiler.

Convenience methods are provided for `include_libraries`, `external_library_path`, and `library_path`; you can instead use `statically_link`, `dynamically_link`, and `statically_link_only_referenced_classes` respectively.

### Build a SWF or SWC

```
ASRake::Mxmlc.new(output)
```
```
ASRake::Compc.new(output)
```

Assign arguments for your build and optionally run it with a friendlier-named task:

```ruby
args = ASRake::Compc.new "bin/my_project.swc"
args.target_player = 11.0
args.debug = true
args.source_path << "src"
args.statically_link_only_referenced_classes << "lib/lib_used_in_project.swc"

desc "Build swc"
task :build => args
```

You can chain together complex builds and the dependencies will be properly handled:

```ruby
bar = ASRake::Compc.new "lib/other_project/bin/proj.swc"
bar.target_player = 11.0
bar.source_path << "lib/other_project/src"

foo = ASRake::Compc.new "bin/my_project.swc"
foo.target_player = 11.0
foo.debug = true
foo.source_path << "src"
foo.library_path << bar

desc "Build swc"
task :build => foo
```

### Include ASDoc in a SWC

If you are compiling with `Compc`, you can set the field `include_asdoc` to have documentation added to your swc

```ruby
desc "Build swc"
swc = ASRake::Compc.new "bin/bin/my_project.swc"
swc.target_player = 11.0
swc.source_path << "bin/src"
swc.include_asdoc = true
```

### Build an AIR

Compile your SWF file as normal, but set the `isAIR` property to true

```ruby
desc "Build app"
my_app = ASRake::Mxmlc.new "bin/my_app.swf"
my_app.load_config << "mxmlc_config.xml"
my_app.isAIR = true
```

Provide the package task with the AIR and keystore information. If the key doesn't exist, it will be created.

> Be sure that the swf file is included in the package (eg, it is included here by packaging everything in the bin directory with `-C bin .`)

```ruby
air = ASRake::Adt.new "deploy/my_app.air"
air.keystore = "cert.p12"
air.keystore_name = "my_app"
air.storepass = "my_app"
air.tsa = "none"
air.include_files << "bin ."
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

## Additional Functionality

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

# use FileList, Dir.glob(), or other methods to copy groups of files
cp_u FileList["lib/**/*.swc"], "bin/lib"
```

### Build without a task

You don't need to create a rake task to build a swf or swc. Just call `execute()` on an instance of Compc or Mxmlc.

> Note that this will not do any dependency checks, so the build will run even if it is unnecessary

```ruby
args = ASRake::Compc.new "bin/my_project.swc"
args.target_player = 11.0
args.source_path << "src"
args.statically_link_only_referenced_classes << "lib/lib_used_in_project.swc"
args.execute()
```

## Contributing

1. Fork this project
2. Create a feature branch
3. Make your changes
4. Create a Pull Request
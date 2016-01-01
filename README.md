# linter-kotlin
This linter package lints **.kt** files using kotlinc  
This package requires the `language-kotlin` package to be present

## Package installation
This package can be installed from the package settings page by searching for and
installing the `linter-kotlin` package.  
It can also be installed using `apm` from the command line:  

```shell
$ apm install linter-kotlin
```

## Configuration
The package can be configured from the settings page or by editing `config.cson` directly.  
Available configuration options are:
- `executablePath` - The path to the kotlin compiler executable  
*default: 'kotlinc'*  
- `classpath` - extra classpath to be compile with  
*default: ''*
- `compilerOutputDir` - The directory to put generated class files  
*default: 'bin'*

An example configuration (in config.cson):
```cson
"linter-kotlin":
	executablePath: "/usr/bin/kotlinc"
	classpath: "/usr/local/lib/java/somelibrary.jar:/home/user/classdir"
	compilerOutputDir: "build"
```

Project specific classpath can be defined in a file called `.atom_jvm_classpath`  

**NOTE**: The kotlin compiler does not support classpath wildcards  
If you define classpaths that have wildcards in them, they will be ignored

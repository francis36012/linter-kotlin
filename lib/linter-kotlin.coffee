fs = require 'fs'
path = require 'path'
{BufferedProcess} = require 'atom'
cpConfigFileName = '.atom_jvm_classpath'


class LinterKotlin
	errorPattern: /^(\w+\.kt):(\d*):(\d*):\s(error|warning):\s(.*)$/

	lint: (textEditor) =>
		helpers = require 'atom-linter'
		filePath = textEditor.getPath()

		projRootDir = @getProjectRootDir()
		cpConfig = @findClasspathConfig(projRootDir)

		wd = path.dirname filePath
		cp = null
		files = @getFilesEndingWith(projRootDir, '.kt')

		if cpConfig?
			wd = cpConfig.cfgDir
			cp = cpConfig.cfgCp
			files = @getFilesEndingWith(wd, ".kt")

		cp += path.delimeter + @classpath if @classpath
		cp += path.delimeter + process.env.CLASSPATH if process.env.CLASSPATH

		args = []
		args = args.concat(['-cp', cp]) if cp?
		args.push.apply(args, files)

		coutdir = atom.config.get "linter-kotlin.compilerOutputDir"
		outputdir = path.join projRootDir, coutdir
		try
			fs.lstatSync outputdir
			args.push.apply(args, ['-d', outputdir])
		catch error
			try
				fs.mkdir outputdir, 0o755
				args.push.apply(args, ['-d', outputdir])
			catch error

		command = atom.config.get "linter-kotlin.executablePath"
		helpers.exec(command, args, {stream: 'both', cwd: wd})
			.then (output) => return @parse(output, textEditor)

	parse: (kotlincOutput, textEditor) =>
		lines = kotlincOutput.stderr.split(/\r?\n/)
		lines.push.apply(lines, kotlincOutput.stdout.split(/\r?\n/))
		msgs = []

		for line in lines
			if line.match @errorPattern
				[file, lineNum, lineCol, msgType, msg] = line.match(@errorPattern)[1..5]
				msgs.push
					type: msgType
					text: msg
					range: [[lineNum - 1, lineCol - 1], [lineNum - 1, lineCol]]
					filePath: file
		return msgs

	getFilesEndingWith: (startPath, endsWith) =>
		try
			fs.accessSync startPath, fs.R_OK | fs.W_OK
			foundFiles = []
			files = fs.readdirSync startPath
			for file in files
				filename = path.join startPath, file
				stat = fs.lstatSync filename
				if stat.isDirectory()
					foundFiles.push.apply(foundFiles, @getFilesEndingWith(filename, endsWith))
				else if filename.indexOf(endsWith, filename.length - (endsWith.length)) > 0
					foundFiles.push.apply(foundFiles, [filename])
			return foundFiles
		catch
			return []

	# from linter-javac
	getProjectRootDir: (textEditor) =>
		textEditor = atom.workspace.getActiveTextEditor()
		if !textEditor or !textEditor.getPath()
			# default to building the first one if no editor is active
			if (0 == atom.project.getPaths().length)
				return false

			return atom.project.getPaths()[0]

		# otherwise, build the one in the root of the active editor
		return atom.project.getPaths().sort((a, b) => (b.length - a.length)).find (p) =>
			realpath = fs.realpathSync(p)
			return textEditor.getPath().substr(0, realpath.length) == realpath

	findClasspathConfig: (d) ->
		while atom.project.contains(d) or (d in atom.project.getPaths())
			try
				result =
					cfgCp: fs.readFileSync(path.join(d, cpConfigFileName), {encoding: 'utf-8'})
					cfgDir: d
				result.cfgCp = result.cfgCp.trim()
				return result
			catch error
				d = path.dirname(d)
		return null


module.exports = LinterKotlin

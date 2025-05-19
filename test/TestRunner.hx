import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

using StringTools;

class TestRunner {
	public static function main() {
        var args=Sys.args();
		var folderPath = args[0];
		if (folderPath == null) {
			Sys.println("Please provide the folder path as an argument.");
			return;
		}

        var results = new Array<TestResult>();
        var test=args[1];
        if (test!=null){
            var t=runTest(test,test,folderPath + "/"+test+".txt");
            results.push(t);
            printResults(results);
            return;
        }

		var files = FileSystem.readDirectory(folderPath);
		for (file in files) {
			if (file.endsWith(".hx")) {
				var baseName = file.substr(0, file.length - 3);
				trace(baseName);
				var hxFile = folderPath + "/" + file;
				var txtFile = folderPath + "/" + baseName + ".txt";

				if (FileSystem.exists(txtFile)) {
					trace("Running...");
					var result = runTest(baseName, hxFile, txtFile);
                    //Sys.stdin().readLine();
					results.push(result);
				}
			}
		}

		printResults(results);
	}

	private static function runTest(baseName:String, hxFile:String, txtFile:String):TestResult {
		// Compile the Haxe file
		var cmd = "haxe";
		var args = [
			"-main",
			"tests." + baseName,
			"-D",
			"go_output=haxe_out",
			"-L",
			"reflaxe_go",
		];
		var compileProcess = new Process(cmd, args);
		var compileResult = compileProcess.exitCode(true);
		compileProcess.stdout.readAll();
		// compileProcess.stderr.close();
		// compileProcess.close();

		if (compileResult != 0 && compileResult!=2) {
			return new TestResult(baseName, false, 'Compilation failed $compileResult ' + compileProcess.stderr.readAll()+cmd+" "+args.join(" "));
		}

		trace("Compilation succeeded");
		Sys.putEnv("GO111MODULE", "off");
		// Run the compiled program
		var runProcess = new Process("go", ["run","main.go"]);
		runProcess.exitCode(true);
		var output = runProcess.stdout.readAll().toString() + runProcess.stderr.readAll().toString();
		trace(output);
        if (output==""){
            return new TestResult(baseName, false, "go output was empty, likely some error is GO111MODULE off?");
        }
		runProcess.close();

		// Read the expected output
		var expectedOutput = File.getContent(txtFile);

		// Compare outputs
		var success = output.trim() == expectedOutput.trim();
		var message = success ? "Passed" : "Fail: Output doesn't match,"+output+","+expectedOutput;

		return new TestResult(baseName, success, message);
	}

	private static function printResults(results:Array<TestResult>) {
		Sys.println("Test Results:");
		Sys.println("-------------------------------------------------------------------");
		Sys.println("| File Name | Status | Message                                    |");
		Sys.println("-------------------------------------------------------------------");
		var hasFailResult = false;
		for (result in results) {
			if (!result.success) {
				hasFailResult = true;
			}
			var status = result.success ? "Pass" : "Fail";
			Sys.println('| ${result.fileName.rpad(" ", 9)} | ${status.rpad(" ", 6)} | ${result.message.rpad(" ", 45)} |');
		}
		Sys.println("-------------------------------------------------------------------");
		if (hasFailResult) {
			Sys.exit(1); // signal to CI that this is a failed exit
		}
	}
}

class TestResult {
	public var fileName:String;
	public var success:Bool;
	public var message:String;

	public function new(fileName:String, success:Bool, message:String) {
		this.fileName = fileName;
		this.success = success;
		this.message = message;
	}
}

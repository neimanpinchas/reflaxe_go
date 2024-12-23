import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
using StringTools;

class TestRunner {
    public static function main() {
        var folderPath = Sys.args()[0];
        if (folderPath == null) {
            Sys.println("Please provide the folder path as an argument.");
            return;
        }

        var files = FileSystem.readDirectory(folderPath);
        var results = new Array<TestResult>();
        for (file in files) {
            if (file.endsWith(".hx")) {
                var baseName = file.substr(0, file.length - 3);
                trace(baseName);
                var hxFile = folderPath + "/" + file;
                var txtFile = folderPath + "/" + baseName + ".txt";
                
                if (FileSystem.exists(txtFile)) {
                    trace("Running...");
                    var result = runTest(baseName, hxFile, txtFile);
                    results.push(result);
                }
            }
        }

        printResults(results);
    }

    private static function runTest(baseName:String, hxFile:String, txtFile:String):TestResult {
        // Compile the Haxe file
        var compileProcess = new Process("C:/HaxeToolkit/haxe/haxe.exe", ["-main", "tests."+baseName, "--neko",baseName+".n"]);
        var compileResult = compileProcess.exitCode();
        //compileProcess.close();

        if (compileResult != 0) {
            return new TestResult(baseName, false, "Compilation failed "+compileProcess.stderr.readAll());
        }

        // Run the compiled program
        var runProcess = new Process("neko", [baseName + ".n"]);
        var output = runProcess.stdout.readAll().toString();
        runProcess.close();

        // Read the expected output
        var expectedOutput = File.getContent(txtFile);

        // Compare outputs
        var success = output.trim() == expectedOutput.trim();
        var message = success ? "Passed" : "Failed: Output doesn't match";

        return new TestResult(baseName, success, message);
    }

    private static function printResults(results:Array<TestResult>) {
        Sys.println("Test Results:");
        Sys.println("------------------------------------------------------------");
        Sys.println("| File Name | Status | Message                              |");
        Sys.println("------------------------------------------------------------");

        for (result in results) {
            var status = result.success ? "Pass" : "Fail";
            Sys.println('| ${result.fileName.rpad(" ",9)} | ${status.rpad(" ",6)} | ${result.message.rpad(" ",36)} |');
        }

        Sys.println("------------------------------------------------------------");
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


package gocompiler;

#if (macro || go_runtime)

import reflaxe.ReflectCompiler;
import reflaxe.preprocessors.ExpressionPreprocessor;

class CompilerInit {
	public static function Start() {
		#if !eval
		Sys.println("CompilerInit.Start can only be called from a macro context.");
		return;
		#end

		#if (haxe_ver < "4.3.0")
		Sys.println("Reflaxe/Golang requires Haxe version 4.3.0 or greater.");
		return;
		#end
		buildGoImporter();
		if (Generator.goimports == "")
			Generator.goimports = haxe.macro.Context.definedValue("goimports") ?? "C:/Users/ps/Desktop/haxe_projects/tests/tools/cmd/goimports/goimports.exe";

		ReflectCompiler.AddCompiler(new Compiler(), {
			expressionPreprocessors: [
				SanitizeEverythingIsExpression({}),
				PreventRepeatVariables({}),
				RemoveSingleExpressionBlocks,
				RemoveConstantBoolIfs,
				RemoveUnnecessaryBlocks,
				RemoveReassignedVariableDeclarations,
				RemoveLocalVariableAliases,
				MarkUnusedVariables,
			],
			fileOutputExtension: ".go",
			outputDirDefineName: "go-output",
			fileOutputType: FilePerClass,
			reservedVarNames: reservedNames(),
			targetCodeInjectionName: "__go__",
			smartDCE: true,
			trackUsedTypes: true
		});
	}

	static function reservedNames() {
		return ["map"];
	}

	static function buildGoImporter() {
		if (haxe.macro.Context.definedValue("goimports") == null) {
			final cmd = "go install golang.org/x/tools/cmd/goimports@latest";
			final proc = new sys.io.Process("goimports -help");
			final code = proc.exitCode(true);
			if (code != 0 && code != 2) {
				Sys.println(cmd);
				if (Sys.command(cmd) == 0) {
					trace("set define");
					Generator.goimports = "goimports";
				}
			}
		}
	}
}

#end

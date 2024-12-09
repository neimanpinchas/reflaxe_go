package go;

/**
	Use this class to provide special features for your target's syntax.
	The implementations for these functions can be implemented in your compiler.

	For more info, visit:
		src/gocompiler/Compiler.hx
**/
extern class Syntax {
	public extern static function code(code: String): Dynamic;
}

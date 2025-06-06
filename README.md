# Reflaxe/Golang

A compiler that compiles Haxe code into Golang using [Reflaxe](https://github.com/RobertBorghese/reflaxe).

## Alternative Name
- **Go-sharp**: Once mature enough and easier to write than ancient Golang. (likely already eaiser but incomplete)

## Why Target GoLang?
- Great Performance vs. GC Balance
- Excellent Solid Tooling
- Faster Compilation than C++
- Truly Cross-Platform (Windows, Linux, BSD, WASM, AVR, etc.)
- Numerous Backend Libraries
- Collaboration with `go2hx`
- Static Binaries Easily Portable Between Distributions (Hardware Match Needed)
- Go Routines (Supports Haxe's Sync Nature)
- High-Speed Web Frameworks
- Real Readable Output
- Null Safety https://haxe.org/manual/cr-null-safety.html#:~:text=Enabling%20Null%20Safety,package%22)%20initialization%20macro.
- More (https://github.com/neimanpinchas/reflaxe_go/blob/main/MOTIVATION.md)

## How to Use
1. Ensure go 1.20 is installed (1.18 for generics, 1.20 for random generator)
2. Clone the repository using `haxelib`, or download locally and use with `haxelib/lix dev`.
3. Add a reference to the library: `-L reflaxe_go`.
4. Update the path to `go_imports.exe` in `Generator.hx` or define `-D goimports` in your HXML. (This is no longer required, it will install automatically, thanks to [commit](https://github.com/neimanpinchas/reflaxe_go/pull/2)) 
5. Add `-D go-output=haxe_out` (or any subfolder you like).
6. Add a matching `-D pkg=haxe_out`.
7. Run `haxe your.hxml`.

## Why Haxe+Golang > Golang
- Real Generics (Array Methods)
- String Interpolation
- Everything is an Expression
- Static Extensions
- Real Dynamics (When Needed)
- Pattern Matching
- Familiarity with EcmaScript (through JavaScript)
- Slim Client-Side Code Sharing (vs. Gopher/WASM)
- Enums: ADT
- Dynamic Methods
- Struct Field Initializers
## Derivations
- Support Class Blacklist via Config File
- Allow Explicit `goimports` via Meta
- `Json.parse` is Generic, Not Dynamic (Type Inferences) Currently there is aseperate class haxe.Json2, you can use it as `import haxe.Json2 as Json`
- Lang.go(()->{}) `to call as go routine`
- Supporting Multi-Return Like Lua

## Roadmap
### Syntax support
- [ ] Full Reflection Support (Record-Macros and Typed JSON)
- [ ] Support context aware expression generation https://github.com/SomeRanDev/reflaxe/issues/28
- [ ] Support Enums Reusing Same Parameter Name with Other Types [(most common issue so far)](https://github.com/neimanpinchas/reflaxe_go/issues/4)
### Std
- [ ] Implement enough for go_imports to work with go2hx (https://github.com/go2hx/go2hx)
- [ ] Implement full non sys std
- [ ] Implement full full sys.io.File and sys.FileSystem
- [ ] Implement full sys.net
- [ ] Implement full sys.db
- [ ] Implement full sys
### Correctness
- [ ] Unit tests
- [ ] Document usage
- [ ] Document metas
- [ ] Document defines
### Beginner friendly
- [x] Automatic `go_imports` installation
- [x] Automatic `main.go` creation
- [ ] Build a Beginner-Friendly Website for Golang Experts
- [ ] go extern creator.
- [ ] naive go class translator.

## License
CC-BY-NC-ND

Creative Commons, Not commercial use, Must Attribute, ND

## Why
### Problem
Creating a successful compiler project is challenging due to the need for stability and widespread adoption. The complexity often leads to abandonment before reaching a usable state.

### Solution
Offer early commercial users the ability to advance the roadmap by contributing code or donations. In exchange, feature their names and corporations prominently on the project front page for future generations. Provide binary exponential leverage to early contributors (e.g., the first milestone finishers' names in 64pt font, the next in 32pt, etc.). Developers receive a commercial non-distributing usage license. Proposals for new milestones can be voted on by all current developers, and resolving 10 issues counts as a milestone. Once complete, the work will be released under a common open-source license (MIT, GPL, or similar) based on a developer vote and legal options.

## Credits
- [Reflaxe Project](https://github.com/RobertBorghese/reflaxe)
- Pinchas Neiman (Go Target)
- Great Commentors in prototype project https://github.com/neimanpinchas/haxego/issues/3

## Contributors
### We are grateful to the following people for their contributions:
---
### Gold Contributors
Joey (PXShadow) https://github.com/PXshadow
- https://github.com/neimanpinchas/reflaxe_go/pull/1
- https://github.com/neimanpinchas/reflaxe_go/pull/2
- https://github.com/neimanpinchas/reflaxe_go/pull/3

#### Silver Contributors
[Your Name Here]

##### Bronze Contributors
[Your Name Here]

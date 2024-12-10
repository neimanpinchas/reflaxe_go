# Reflaxe/Golang

A compiler that compiles Haxe code into Golang. using reflaxe (link needed)

# Alternative name
Once mature enough and eaisier to write then ancient golang: Go-sharp, I think the go world (at least myself) is more thirsty for additional syntax, than haxe for a better targets.

## Why GoLang targer
* Great Performance vs GC Balance
* Great Solid Tooling
* Faster compilation then CPP
* Truly cross platform (win, lin, bsd, wasm, avr, ++)
* Bunch of backend libraries
* Together with go2hx, we could work with both together.
* Static binaries easy portable between distributions as long as the hardware match
* GO routines, allowing to stay with haxe sync nature instead of waiting for asys.
* Hi speed web frameworks
* Real readable output

# How to use
* clone repo using haxelib, or download locally and use with haxelib/lix dev.
* add reference to library `-L reflaxe_go`
* Update the path to go_imports.exe in Generator.hx
* add `-D go-output haxe_out` Or whatever subfolder you like, currently it will not generate a go main function, and you must create a main.go in you haxe root directory, and call watever main function needed.
* run haxe your.hxml

## Why Haxe+Golang > Golang (|| why haxe!=0 even in presence of Golang)
* Real generics (Array methods)
* String interpolation
* Everything is an expression
* Static extensions
* Real Dynamics (when needed)
* Pattern Matching
* We all know EcmaScript (torough JavaScript).
* Slim client side code sharing (vs gopher/wasm).
* Enums: ADT
* Dynamic methods
* Struct field initializers

## Deriviations
* support class blacklist via config file
* allow explicit goimports via meta
* Json.parse is generic not dynamic (not bad with type infersions all the way)
* supporting muti return like lua

## Roadmap
[ ] Full reflection support record-macros and typed Json
[ ] Full port of networking library
[ ] Support enums reusing same parameter name with other types
[ ] Make easier to use, update doumentation, automatic installation of go_imports, automatic main creation, use defines for package name.
[ ] Build a beginner (golang expert) website for it to make it easy for beginners to use.

## Minor bugs
[ ] smartDCE removes the Timer class even when used.


# License
CC-BY-NC-ND
## Why
### Problem
It is very hard to get a sucessful project when it comes to a compiler, to make a project successfull you need to get lots of people using it and sticking with it, compilers need to be very stable for people to stick with it, and that's incredibly hard when you are still working on it.
The scale is insane for compilers, so it's easy to give up before anyone would even think of using it, and that's a really shame but it is a risk taken for such a huge undertaking.
 ### Solution
 I want to try a solution by giving the first few commerical users the ability to advance the roadmap by commiting code or donating, and in exchange hardstamp their names and corperations in the project front page for generations, Also the plan is to give binary exponantial leverage to earlier contributers, for example the pair of developer who will finish the first milstone will get their name in font size 64pt, next 4 will get 32pt, next 8 will get 16pt etc.
 Also all of these developers will get a commercial but non-distirbuting usage license (go code compiled by the compiler may be shared, also he may obviously share it with the creative commons terms)
 Every proposeal for a new milestone can be voted by all current developers
 resolving 10 issues count as  a milstone.
 Once the roadmap is complete the work will opened to the public with a common open source license such as MIT or GPL or similar based on a developer vote, and legal options.
 

$files=gci *.hx -Recurse
foreach ($file in $files){
    dos2unix.exe $file
}
#echo $files


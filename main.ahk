
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

var_n:=%0%
if var_n<1
{
	MsgBox, DROP binary file on exe please.
	ExitApp
}

path=%1%
FileGetSize, size, %path%, M
if size>16
{
	MsgBox, TOO LARGE FILE.(larger than 16Mb)
	ExitApp
}
hFile:=FileOpen(path,"r")
hFile.RawRead(file_bin,hFile.Length)

header:="`r`n#define BIN_SIZE (" hFile.Length ")`r`n`r`n"
header.="extern unsigned char bin_array[BIN_SIZE];`r`n"

source:="`r`n#include ""bin_array.h""`r`n`r`n"
source.="unsigned char bin_array[]={`r`n"

loop, % hFile.Length
{
	if A_Index&0xF=1
	{
		source.="`t"
	}
	source.=bin2hex(NumGet(file_bin, A_Index-1, "UChar")) ","
	if A_Index&0xF=0
	{
		source.="`r`n"
	}
}

source.="};`r`n"
FileDelete, bin_array.c
FileDelete, bin_array.h
FileAppend, % source, bin_array.c
FileAppend, % header, bin_array.h


bin2hex(bin)
{
	oldFormat:=A_FormatInteger
	SetFormat, Integer, H
	bin+=0
	output:="0x" SubStr("00" SubStr(bin, 3),-1)
	SetFormat, Integer, % oldFormat
	return output
}

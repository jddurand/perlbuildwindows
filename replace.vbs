Const ForReading = 1    
Const ForWriting = 2

strFileName = Wscript.Arguments(0)
strOldText = Wscript.Arguments(1)
strNewText = Wscript.Arguments(2)

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.OpenTextFile(strFileName, ForReading)
strText = objFile.ReadAll
objFile.Close

'Set regEx = New RegExp
'regEx.Pattern = strOldText
'regEx.Global = False
'strNewText = regEx.Replace(strOldText, strNewText)

Function RegexReplace(src, pattern, replacement)
  Dim regEx
  Set regEx = New RegExp
  regEx.Pattern = pattern
  RegexReplace = regEx.Replace(src, replacement)   ' Make replacement.
End Function

strNewText = RegexReplace(strText, strOldText, strNewText)
'With (New RegExp): strNewText = .Replace(strText, strOldText, strNewText): End With
'strNewText = Replace(strText, strOldText, strNewText)
Set objFile = objFSO.OpenTextFile(strFileName, ForWriting)
objFile.Write strNewText  'WriteLine adds extra CR/LF
objFile.Close

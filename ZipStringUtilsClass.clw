           MEMBER
           MAP
           END
INCLUDE('ZipStringUtilsClass.inc'),ONCE

ZipStringUtilsClass.Construct PROCEDURE()
  CODE
  SELF.Buffer &= NULL
  SELF.Capacity = 0
  SELF.Length   = 0

ZipStringUtilsClass.Destruct PROCEDURE()
  CODE
  IF ~SELF.Buffer &= NULL
    DISPOSE(SELF.Buffer)
  END
  SELF.Buffer &= NULL
  SELF.Capacity = 0
  SELF.Length   = 0

ZipStringUtilsClass.EnsureCap PROCEDURE(LONG required)
oldBuf &STRING
  CODE
  IF required > SELF.Capacity
    oldBuf &= SELF.Buffer
    SELF.Buffer &= NEW STRING(required)
    IF NOT oldBuf &= NULL
      SELF.Buffer[1 : SELF.Length] = oldBuf[1 : SELF.Length]
      DISPOSE(oldBuf)
    END
    SELF.Capacity = required
  END


ZipStringUtilsClass.SetValue PROCEDURE(STRING s)
len LONG
  CODE
  len = LEN(CLIP(s))
  SELF.EnsureCap(len)
  SELF.Buffer[1 : len] = s
  SELF.Length = len

ZipStringUtilsClass.GetValue PROCEDURE()
result STRING(SELF.Length)
  CODE
  IF SELF.Buffer &= NULL
    RETURN ''
  ELSE
    result = SELF.Buffer[1 : SELF.Length]
    RETURN result
  END

ZipStringUtilsClass.Start PROCEDURE()
  CODE
  SELF.Length = 0
  IF ~SELF.Buffer &= NULL
    SELF.Buffer[1 : SELF.Capacity] = ''
  END

ZipStringUtilsClass.Append PROCEDURE(STRING s)
len LONG
newLen LONG
  CODE
  len = LEN(CLIP(s))
  newLen = SELF.Length + len
  SELF.EnsureCap(newLen)
  SELF.Buffer[SELF.Length+1 : newLen] = s
  SELF.Length = newLen


ZipStringUtilsClass.ReplaceAt PROCEDURE(LONG pos, LONG skip, STRING replacement)
sourceLen   LONG
replaceLen  LONG
newLen      LONG
temp        &STRING
  CODE
  IF pos < 1 OR pos > SELF.Length
    RETURN
  END
  sourceLen = SELF.Length
  replaceLen = LEN(CLIP(replacement))
  newLen = sourceLen - skip + replaceLen
  SELF.EnsureCap(newLen)

  temp &= NEW STRING(newLen)
  temp = SUB(SELF.Buffer,1,pos-1) & replacement & |
         SUB(SELF.Buffer,pos+skip,sourceLen-(pos+skip)+1)

  SELF.SetValue(temp)
  DISPOSE(temp)

ZipStringUtilsClass.ReplaceAll PROCEDURE(STRING find, STRING replacement)
pos    LONG
skip   LONG
  CODE
  skip = LEN(CLIP(find))
  IF skip = 0 THEN RETURN.
  LOOP
    pos = INSTRING(find, SELF.Buffer[1:SELF.Length], 1, 1)
    IF ~pos THEN BREAK.
    SELF.ReplaceAt(pos, skip, replacement)
  END

ZipStringUtilsClass.GetFileExtension PROCEDURE(STRING fileName)
pos   LONG
ext   STRING(32)
  CODE
  pos = INSTRING('.', fileName, -1, LEN(CLIP(fileName)))
  IF pos > 1
    ext = SUB(fileName, pos+1, LEN(CLIP(fileName)) - pos)
    RETURN UPPER(ext)
  ELSE
    RETURN ''
  END

ZipStringUtilsClass.NormalizePath PROCEDURE(STRING path)
FilePath STRING(FILE:MaxFilePath)
  CODE
  ! Handle empty path
  IF ~path
    RETURN ''
  END

  ! Load the string into our dynamic string class
  SELF.Start()
  SELF.SetValue(CLIP(path))

  ! Normalize path: forward slashes to backslashes
  SELF.ReplaceAll('/', '\')

  ! Collapse double backslashes
  SELF.ReplaceAll('\\', '\')

  RETURN SELF.GetValue()

ZipStringUtilsClass.EnsureTrailingSlash PROCEDURE(STRING path)
NormalizedPath STRING(FILE:MaxFilePath)

  CODE
  ! First normalize the path
  NormalizedPath = SELF.NormalizePath(path)

  ! Handle empty path
  IF ~NormalizedPath
    RETURN ''
  END

  ! Check if path already ends with a backslash
  IF NormalizedPath[LEN(CLIP(NormalizedPath))] <> '\'
    RETURN CLIP(NormalizedPath) & '\'
  END
  RETURN CLIP(NormalizedPath)
  



ZipStringUtilsClass.GetFileNameOnly PROCEDURE(STRING path)
i        LONG
pLen     LONG
FilePath STRING(FILE:MaxFilePath)
  CODE
  ! Handle empty path
  IF ~path
    RETURN ''
  END

  ! First normalize the path
  FilePath = SELF.NormalizePath(path)
  pLen = LEN(FilePath)

  ! Walk backwards for the last backslash
  LOOP i = pLen TO 1 BY -1
    IF FilePath[i] = '\'
      RETURN SUB(FilePath, i+1, pLen-i)
    END
  END

  ! No backslash found - whole thing is the file name
  RETURN FilePath

ZipStringUtilsClass.GetPathOnly PROCEDURE(STRING path)
i        LONG
pLen     LONG
FilePath STRING(FILE:MaxFilePath)
  CODE
  ! Handle empty path
  IF ~path
    RETURN ''
  END

  ! First normalize the path
  FilePath = SELF.NormalizePath(path)
  pLen = LEN(FilePath)

  ! Check for last backslash
  LOOP i = pLen TO 1 BY -1
    IF FilePath[i] = '\'
      ! Return up to (but not including) the last '\'
      RETURN SUB(FilePath, 1, i-1)
    END
  END

  ! No path separator found
  RETURN ''
  
ZipStringUtilsClass.EndsWith PROCEDURE(STRING suffix)
sLen   LONG
bLen   LONG
start  LONG
  CODE
  IF SELF.Buffer &= NULL OR SELF.Length = 0
    RETURN 0
  END

  sLen = LEN(CLIP(suffix))
  IF sLen = 0
    RETURN 1   ! Empty suffix always matches
  END

  bLen = LEN(CLIP(SELF.GetValue()))
  IF sLen > bLen
    RETURN 0   ! Suffix longer than string
  END

  start = bLen - sLen + 1
  IF SUB(SELF.GetValue(), start, sLen) = CLIP(suffix)
    RETURN 1
  ELSE
    RETURN 0
  END
  

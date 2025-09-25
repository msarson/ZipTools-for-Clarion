ZipStringUtilsClass   CLASS,TYPE,MODULE('ZipStringUtilsClass.CLW'),LINK('ZipStringUtilsClass.CLW')

! Public interface
Construct               PROCEDURE()
Destruct                PROCEDURE()
EndsWith                PROCEDURE(STRING suffix),BYTE
SetValue                PROCEDURE(STRING s)
GetValue                PROCEDURE(),STRING
Append                  PROCEDURE(STRING s)
ReplaceAt               PROCEDURE(LONG pos, LONG skip, STRING replacement)
ReplaceAll              PROCEDURE(STRING find, STRING replacement)
GetFileExtension        PROCEDURE(STRING fName),STRING
Start                   PROCEDURE()

! Path handling utilities
NormalizePath           PROCEDURE(STRING path),STRING
EnsureTrailingSlash     PROCEDURE(STRING path),STRING
GetFileNameOnly         PROCEDURE(STRING path),STRING
GetPathOnly             PROCEDURE(STRING path),STRING

! Private state
Buffer                  &STRING,PRIVATE
Capacity                LONG,PRIVATE
Length                  LONG,PRIVATE

! Private helpers
EnsureCap               PROCEDURE(LONG newCap),PRIVATE

                      END

/*
Visual Basic Ç©ÇÁÇ®égÇ¢ÇÃÇ∆Ç´ÇÕéüÇÃDeclareï∂ÇégÇ¡ÇƒÇ≠ÇæÇ≥Ç¢ÅB
Private Declare Function Match Lib "bregexp" _
      (szRegstr As String, szTarget As String) As String


Private Declare Function Replace Lib "bregexp" _
      (szRegstr As String, szTarget As String) As String

Private Declare Function Translate Lib "bregexp" _
      (szRegstr As String, szTarget As String, ret As String) As Long

Private Declare Function Split Lib "bregexp" _
      (szRegstr As String, szTarget As String, limit As Long) As Variant

Private Declare Function MatchEx Lib "bregexp" _
      (szRegstr As String, szTarget As String, mode As Long) As Variant

*/


#ifdef _BREGEXP_
#define BREGEXPAPI __declspec(dllexport) 
#else
#define BREGEXPAPI __declspec(dllimport) 
#endif

typedef struct bregexp {
	const char *outp;			/* result string start ptr   */
	const char *outendp;		/* result string end ptr     */ 
	const int  splitctr;		/* split result counter     */ 
	const char **splitp;		/* split result pointer ptr     */ 
	int     rsv1;				/* reserved for external use    */ 
} BREGEXP;

#if defined(__cplusplus)
extern "C"
{
#endif

BREGEXPAPI
int BMatch(char* str,char *target,char *targetendp,
								BREGEXP **rxp,char *msg) ;
BREGEXPAPI
int BSubst(char* str,char *target,char *targetendp,
								BREGEXP **rxp,char *msg) ;
BREGEXPAPI
int BTrans(char* str,char *target,char *targetendp,
								BREGEXP **rxp,char *msg) ;
BREGEXPAPI
int BSplit(char* str,char *target,char *targetendp,
						int limit,BREGEXP **rxp,char *msg);
BREGEXPAPI
void BRegfree(BREGEXP* rx);

BREGEXPAPI
char* BRegexpVersion(void);

#if defined(__cplusplus)
}
#endif


#undef BREGEXPAPI

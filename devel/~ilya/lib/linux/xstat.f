\ xstat.f


0x1 CONSTANT _STAT_VER 
0x4000 CONSTANT S_IFDIR  
0xF000 CONSTANT __S_IFMT		\ These bits determine file type.


0
               CELL --		st_dev			\ ID of device containing file */
	       \ 2 CHARS --			__pad1
               CELL --		st_ino			\ * inode number */
               2 CHARS --	st_mode			\ * protection */
               2 CHARS --	st_nlink		\ number of hard links */
               2 CHARS --	st_uid			\ user ID of owner */
               2 CHARS --	st_gid			\ group ID of owner */
               CELL --		st_rdev			\ device ID (if special file) */
               \ CELL --		__pad2		\ 
               CELL --		st_size			\ total size, in bytes */
               CELL --		st_blksize		\ blocksize for file system I/O */
               CELL --		st_blocks		\ number of 512B blocks allocated */
               CELL --		st_atime		\ time of last access */
               CELL --		st_atime_nsec   \ time of last access */
               CELL --		st_mtime		\ time of last modification */
               CELL --		st_mtime_nsec   \ time of last access */
               CELL --		st_ctime		\ time of last status change */
               CELL --		st_ctime_nsec   \ time of last access */
               CELL --		__unused4		\ time of last status change */
               CELL --		__unused5		\ time of last status change */
	CONSTANT /stat

	
CREATE _statbuf /stat ALLOT
: XSTAT ( adr n -- adr ) 
DROP 1 <( _STAT_VER SWAP _statbuf )) __xstat DROP _statbuf 
;


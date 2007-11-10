DECIMAL
CREATE low-buf  0 C,  1 C,  2 C,  3 C,  4 C,  5 C,  6 C,  7 C,  8 C,  9 C,
               10 C, 11 C, 12 C, 13 C, 14 C, 15 C, 16 C, 17 C, 18 C, 19 C, 
               20 C, 21 C, 22 C, 23 C, 24 C, 25 C, 26 C, 27 C, 28 C, 29 C,
               30 C, 31 C, 32 C, 33 C, 34 C, 35 C, 36 C, 37 C, 38 C, 39 C,
               40 C, 41 C, 42 C, 43 C, 44 C, 45 C, 46 C, 47 C, 48 C, 49 C,
               50 C, 51 C, 52 C, 53 C, 54 C, 55 C, 56 C, 57 C, 58 C, 59 C,
               60 C, 61 C, 62 C, 63 C,
               C" abcdefghijklmnopqrstuvwxyz[\]^_`abcdefghijklmnopqrstuvwxyz{|}~" ",
               CHAR @ low-buf CHAR @ + C!
               128 C, 129 C, 
               130 C, 131 C, 132 C, 133 C, 134 C, 135 C, 136 C, 137 C, 138 C, 139 C,
               140 C, 141 C, 142 C, 143 C, 144 C, 145 C, 146 C, 147 C, 148 C, 149 C,
               150 C, 151 C, 152 C, 153 C, 154 C, 155 C, 156 C, 157 C, 158 C, 159 C,
               160 C, 161 C, 162 C, 163 C, 164 C, 165 C, 166 C, 167 C, 184 C, 169 C,
               170 C, 171 C, 172 C, 173 C, 174 C, 175 C, 176 C, 177 C, 178 C, 179 C,
               180 C, 181 C, 182 C, 183 C, 184 C, 185 C, 186 C, 187 C, 188 C, 189 C,
               190 C, 191 C,
               C" בגדהוזחטיךכלםמןנסעףפץצקרשתûü‎‏ÿאבגדהוזחטיךכלםמןנסעףפץצקרשתûü‎‏ÿ" ",
               CHAR א low-buf CHAR À + C!

: LOWER-CHAR ( c1 -- c2 ) low-buf + C@ ;    
: LOWER ( a u --)
    OVER + SWAP
    ?DO
        I C@ LOWER-CHAR I C!
    LOOP
;
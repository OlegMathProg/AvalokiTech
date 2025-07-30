unit Fast_SIMD;

{This file contains some SIMD instructions}

{$mode objfpc}{$H+ INLINE+}{$asmmode intel}

interface

type

  TColor  = LongWord;
  PInteger=PLongWord;

  TRGBA04 =record {$region -fold}
    r00,r01,r02,r03: TColor;
  end; {$endregion}
  PRGBA04 =^TRGBA04;

  TRGBA08 =record {$region -fold}
    r00,r01,r02,r03,r04,r05,r06,r07: TColor;
  end; {$endregion}
  PRGBA08 =^TRGBA08;



const

  MSK0_128: TRGBA04=
    (r00:%00000010000000100000001000000010;
     r01:%00000010000000100000001000000010;
     r02:%00000010000000100000001000000010;
     r03:%00000010000000100000001000000010);
  MSK1_128: TRGBA04=
    (r00:%00000001000000010000000100000001;
     r01:%00000001000000010000000100000001;
     r02:%00000001000000010000000100000001;
     r03:%00000001000000010000000100000001);
  MSK2_128: TRGBA04=
    (r00:$0C080400;
     r01:$07060501;
     r02:$0B0A0902;
     r03:$0F0E0D03);
  MSK3_128: TRGBA04=
    (r00:%00000000111111111111111111111111;
     r01:%00000000111111111111111111111111;
     r02:%00000000111111111111111111111111;
     r03:%00000000111111111111111111111111);
  MSK4_128: TRGBA04=
    (r00:%00000000000000000000000000000001;
     r01:%00000000000000000000000100000000;
     r02:%00000000000000010000000000000000;
     r03:%00000000000000000000000000000000);
  MSK5_128: TRGBA04=
    (r00:$0E0C0A08;
     r01:$07060504;
     r02:$0B010900;
     r03:$0F030D02);
  MSK6_128: TRGBA04=
    (r00:$0E0C0A08;
     r01:$07060504;
     r02:$0B010900;
     r03:$0F030D02);
  MSK7_128: TRGBA04=
    (r00:$00FF00FF;
     r01:$00FF00FF;
     r02:$00FF00FF;
     r03:$00FF00FF);
  MSK8_128: TRGBA04=
    (r00:%00000000000000010000000000000001;
     r01:%00000000000000000000000000000001;
     r02:%00000000000000010000000000000001;
     r03:%00000000000000000000000000000001);
  MSK0_256: TRGBA08=
    (r00:%00000010000000100000001000000010;
     r01:%00000010000000100000001000000010;
     r02:%00000010000000100000001000000010;
     r03:%00000010000000100000001000000010;
     r04:%00000010000000100000001000000010;
     r05:%00000010000000100000001000000010;
     r06:%00000010000000100000001000000010;
     r07:%00000010000000100000001000000010);
  MSK1_256: TRGBA08=
    (r00:%00000001000000010000000100000001;
     r01:%00000001000000010000000100000001;
     r02:%00000001000000010000000100000001;
     r03:%00000001000000010000000100000001;
     r04:%00000001000000010000000100000001;
     r05:%00000001000000010000000100000001;
     r06:%00000001000000010000000100000001;
     r07:%00000001000000010000000100000001);



procedure FloodFillAdd256(const src,       msk1:TRGBA08);               assembler; inline;
function  NZByteCnt128   (const src,{msk0,}msk1:TRGBA04): dword{qword}; assembler; inline;
function  NZByteCnt256   (const src,{msk0,}msk1:TRGBA08): qword;        assembler; inline;
procedure ScalePix128A   (const msk0           :TRGBA04;
                          var   dst,src        :TColor;
                          const s0,s1          :TColor;
                          const b              :boolean);               assembler; inline;
procedure ScalePix128B   (const msk0           :TRGBA04;
                          var   dst,src        :TColor;
                          const s0,s1          :TColor;
                          const arr_width      :TColor);                assembler; inline;
procedure ScalePix128C   (const msk0,msk1      :TRGBA04;
                          var   dst,src        :TColor;
                          const s0,s1,s2       :TColor;
                          const b              :boolean);               assembler; inline;
procedure ScalePix128D   (const msk0,msk1      :TRGBA04;
                          var   dst,src        :TColor;
                          const s0,s1,s2       :TColor;
                          const arr_width      :TColor);                assembler; inline;
procedure ScalePix128E   (const msk0           :TRGBA04;
                          var   dst            :qword;
                          const src            :TColor;
                          const s0,s1          :TColor;
                          const b              :boolean);               assembler; inline;
procedure ScalePix128F   (const msk0           :TRGBA04;
                          var   dst            :qword;
                          const src            :TColor;
                          const s0,s1,s2,s3    :TColor;
                          const b              :boolean;
                          const arr_width      :TColor);                assembler; inline;
procedure AlphaBlend128P0(const msk0           :TRGBA04;
                          var   dst            :TColor;
                          const src            :TColor;
                          const s0,s1          :TColor;
                          const arr_width      :TColor);                assembler; inline;



implementation

procedure FloodFillAdd256(const src ,msk1:TRGBA08                                                                                                         );        assembler; inline; nostackframe;                {$region -fold}
asm
  vmovdqu ymm0 ,[msk1]
  vpaddd  ymm1 ,ymm0  ,[src]
  vmovdqu [src],ymm1
end; {$endregion}
function  NZByteCnt128   (const src ,msk1:TRGBA04                                                                                                         ): dword; assembler; inline; nostackframe;                {$region -fold}
asm
  pxor    xmm3    ,xmm3
  movdqu  xmm0    ,[src]
  pcmpeqb xmm0    ,xmm3

  paddb   xmm0    ,[msk1]
 {paddb   xmm0    ,[msk0]
  psubb   xmm0    ,[msk1]}

  movq    r8      ,xmm0
  popcnt  r8      ,r8
  psrldq  xmm0    ,08
  movq    r9      ,xmm0
  popcnt  r9      ,r9
  add     r8      ,r9
  mov     [Result],r8
end; {$endregion}
function  NZByteCnt256   (const src ,msk1:TRGBA08                                                                                                         ): qword; assembler; inline; nostackframe; unimplemented; {$region -fold}
asm
  {
  vpxor        ymm3    ,ymm3,ymm3      // Zero out ymm3
  vmovdqu      ymm0    ,[src]          // Load 32 bytes (entire TRGBA08) into ymm0
  vpcmpeqb     ymm0    ,ymm0,ymm3      // Compare each byte with zero (result is 0xFF if zero, 0x00 if nonzero)
  vpaddb       ymm0    ,ymm0,[msk1]    // Apply mask (msk1) to convert 0xFF to 1 (0x01), and keep 0x00 unchanged
  vextracti128 xmm1    ,ymm0,1         // Extract upper 128 bits into xmm1
  vmovq        r8      ,xmm0           // Move lower 64 bits to r8
  popcnt       r8      ,r8             // Count set bits in lower half
  vmovq        r9      ,xmm1           // Move upper 64 bits to r9
  popcnt       r9      ,r9             // Count set bits in upper half
  add          r8      ,r9             // Sum up the counts
  mov          [Result],r8             // Store the result
  }
end; {$endregion}
procedure ScalePix128A   (const msk0     :TRGBA04; var dst,src:TColor;                   const s0,s1      :TColor; const b:boolean                        );        assembler; inline;                              {$region -fold}
asm

    {load mask for shuffling}
    movdqu xmm0   ,[msk0]

    {load src to xmm1 and xmm2}
    movd   xmm1   ,[src]
    pshufb xmm1   ,xmm0
    movdqu xmm2   ,xmm1

    {load s0 to each 32-bit integer of xmm3}
    movd   xmm3   ,s0
    pshufd xmm3   ,xmm3,00

    {load each byte of PColor(@dst+0)^ into each appropriate 32-bit integer of xmm4}
    movd   xmm4   ,[dst]
    pshufb xmm4   ,xmm0

    {PColor(@dst+0)^ processing}
    psubd  xmm1   ,xmm4
    pmulld xmm1   ,xmm3
    psrad  xmm1   ,16
    paddd  xmm1   ,xmm4

    {pack result and store in PColor(@dst+0)^}
    pshufb xmm1   ,xmm0
    movd   [dst+0],xmm1

    {check whether it is necessary to calculate the neighboring pixel}
    cmp    b      ,0
    je     @Exit

    {load s1 to each 32-bit integer of xmm3}
    movd   xmm3   ,s1
    pshufd xmm3   ,xmm3,00

    {load each byte of PColor(@dst+1)^ into each appropriate 32-bit integer of xmm4}
    movd   xmm4   ,[dst+4]
    pshufb xmm4   ,xmm0

    {PColor(@dst+1)^ processing}
    psubd  xmm2   ,xmm4
    pmulld xmm2   ,xmm3
    psrad  xmm2   ,16
    paddd  xmm2   ,xmm4

    {pack result and store in PColor(@dst+1)^}
    pshufb xmm2   ,xmm0
    movd   [dst+4],xmm2

  @Exit:

end; {$endregion}
procedure ScalePix128B   (const msk0     :TRGBA04; var dst,src:TColor;                   const s0,s1      :TColor;                  const arr_width:TColor);        assembler; inline;                              {$region -fold}
asm

  {load mask for shuffling}
  movdqu xmm0       ,[msk0]

  {load src to xmm1,xmm2}
  movd   xmm1       ,[src]
  pshufb xmm1       ,xmm0
  movdqu xmm2       ,xmm1

  {load arr_width}
  mov    eax        ,[arr_width]

  {load s0 to each 32-bit integer of xmm3}
  movd   xmm3       ,s0
  pshufd xmm3       ,xmm3,00

  {load each byte of PColor(@dst+000000000)^ into each appropriate 32-bit integer of xmm4}
  movd   xmm4       ,[dst]
  pshufb xmm4       ,xmm0

  {PColor(@dst+000000000)^ processing}
  psubd  xmm1       ,xmm4
  pmulld xmm1       ,xmm3
  psrad  xmm1       ,16
  paddd  xmm1       ,xmm4

  {pack result and store in PColor(@dst+000000000)^}
  pshufb xmm1       ,xmm0
  movd   [dst]      ,xmm1

  {load s1 to each 32-bit integer of xmm3}
  movd   xmm3       ,s1
  pshufd xmm3       ,xmm3,00

  {load each byte of PColor(@dst+arr_width)^ into each appropriate 32-bit integer of xmm4}
  movd   xmm4       ,[dst+4*eax]
  pshufb xmm4       ,xmm0

  {PColor(@dst+arr_width)^ processing}
  psubd  xmm2       ,xmm4
  pmulld xmm2       ,xmm3
  psrad  xmm2       ,16
  paddd  xmm2       ,xmm4

  {pack result and store in PColor(@dst+arr_width)^}
  pshufb xmm2       ,xmm0
  movd   [dst+4*eax],xmm2

end; {$endregion}
procedure ScalePix128C   (const msk0,msk1:TRGBA04; var dst,src:TColor;                   const s0,s1,s2   :TColor; const b:boolean                        );        assembler; inline;                              {$region -fold}
asm

    {load mask for shuffling}
    movdqu xmm0   ,[msk0]

    {load src to xmm1}
    movd   xmm1   ,[src]

    {extract alpha-channel(s2) from src into xmm5}
    movd   xmm5   ,s2//movdqu xmm5     ,xmm1
  //psrad  xmm5   ,24
    pshufd xmm5   ,xmm5,0

    {clear alpha-channel in xmm1(src)}
    pand   xmm1   ,[msk1]
    pshufb xmm1   ,xmm0
    movdqu xmm2   ,xmm1

    {load s0 to each 32-bit integer of xmm3}
    movd   xmm3   ,s0
    pshufd xmm3   ,xmm3,0

    {load each byte of PColor(@dst+0)^ into each appropriate 32-bit integer of xmm4, having previously cleared the alpha channel}
    movd   xmm4   ,[dst]
  //pand   xmm4   ,[msk1]
    pshufb xmm4   ,xmm0

    {PColor(@dst+0)^ processing}
    psubd  xmm1   ,xmm4
    pmulld xmm1   ,xmm3
    psrad  xmm1   ,16
    pmulld xmm1   ,xmm5
    psrad  xmm1   ,8
    paddd  xmm1   ,xmm4

    {pack result and store in PColor(@dst+0)^}
    pshufb xmm1   ,xmm0
    movd   [dst+0],xmm1

    {check whether it is necessary to calculate the neighboring pixel}
    cmp    b      ,0
    je     @Exit

    {load s1 to each 32-bit integer of xmm3}
    movd   xmm3   ,s1
    pshufd xmm3   ,xmm3,00

    {load each byte of PColor(@dst+1)^ into each appropriate 32-bit integer of xmm4, having previously cleared the alpha channel}
    movd   xmm4   ,[dst+4]
  //pand   xmm4   ,[msk1]
    pshufb xmm4   ,xmm0

    {PColor(@dst+1)^ processing}
    psubd  xmm2   ,xmm4
    pmulld xmm2   ,xmm3
    psrad  xmm2   ,16
    pmulld xmm2   ,xmm5
    psrad  xmm2   ,8
    paddd  xmm2   ,xmm4

    {pack result and store in PColor(@dst+1)^}
    pshufb xmm2   ,xmm0
    movd   [dst+4],xmm2

  @Exit:

end; {$endregion}
procedure ScalePix128D   (const msk0,msk1:TRGBA04; var dst,src:TColor;                   const s0,s1,s2   :TColor;                  const arr_width:TColor);        assembler; inline;                              {$region -fold}
asm

  {load mask for shuffling}
  movdqu xmm0       ,[msk0]

  {load src to xmm1}
  movd   xmm1       ,[src]

  {extract alpha-channel(s2) from src into xmm5}
  movd   xmm5       ,s2//movdqu xmm5     ,xmm1
//psrad  xmm5       ,24
  pshufd xmm5       ,xmm5,0

  {clear alpha-channel in xmm1(src)}
  pand   xmm1       ,[msk1]
  pshufb xmm1       ,xmm0
  movdqu xmm2       ,xmm1

  {load arr_width}
  mov    eax        ,[arr_width]

  {load s0 to each 32-bit integer of xmm3}
  movd   xmm3       ,s0
  pshufd xmm3       ,xmm3,00

  {load each byte of PColor(@dst+000000000)^ into each appropriate 32-bit integer of xmm4, having previously cleared the alpha channel}
  movd   xmm4       ,[dst]
//pand   xmm4       ,[msk1]
  pshufb xmm4       ,xmm0

  {PColor(@dst+000000000)^ processing}
  psubd  xmm1       ,xmm4
  pmulld xmm1       ,xmm3
  psrad  xmm1       ,16
  pmulld xmm1       ,xmm5
  psrad  xmm1       ,8
  paddd  xmm1       ,xmm4

  {pack result and store in PColor(@dst+000000000)^}
  pshufb xmm1       ,xmm0
  movd   [dst]      ,xmm1

  {load s1 to each 32-bit integer of xmm3}
  movd   xmm3       ,s1
  pshufd xmm3       ,xmm3,00

  {load each byte of PColor(@dst+arr_width)^ into each appropriate 32-bit integer of xmm4, having previously cleared the alpha channel}
  movd   xmm4       ,[dst+4*eax]
//pand   xmm4       ,[msk1]
  pshufb xmm4       ,xmm0

  {PColor(@dst+arr_width)^ processing}
  psubd  xmm2       ,xmm4
  pmulld xmm2       ,xmm3
  psrad  xmm2       ,16
  pmulld xmm2       ,xmm5
  psrad  xmm2       ,8
  paddd  xmm2       ,xmm4

  {pack result and store in PColor(@dst+arr_width)^}
  pshufb xmm2       ,xmm0
  movd   [dst+4*eax],xmm2

end; {$endregion}
procedure ScalePix128E   (const msk0     :TRGBA04; var dst    :qword;  const src:TColor; const s0,s1      :TColor; const b:boolean                        );        assembler; inline;               deprecated;    {$region -fold}
asm

    {load mask for bitwise AND}
    movdqu    xmm0 ,[msk0]

    {load mask for bitwise AND}
  //movdqu    xmm4 ,[msk1]

    {load and stretch src by 4 32-bit integers(whole xmm1-register)}
    mov       eax  ,src
    movd      xmm1 ,eax
    pinsrd    xmm1 ,eax,1
    punpcklbw xmm1 ,xmm1
    pand      xmm1 ,xmm0

    {load s0 to xmm2 as 2 first  32-bit integers}
    movd      xmm2 ,s0
    pshuflw   xmm2 ,xmm2,0
   {pinsrw    xmm2 ,edi,0
    pinsrw    xmm2 ,edi,1
    pinsrw    xmm2 ,edi,2
    pinsrw    xmm2 ,edi,3}

    {check whether it is necessary to calculate the neighboring pixel}
    cmp       b    ,0
    je        @Continue

    {load s1 to xmm2 as 2 second 32-bit integers}
    movd      xmm3 ,s1
    pshuflw   xmm3 ,xmm3,0
    movq      rax  ,xmm3
    pinsrq    xmm2 ,rax ,1
  //pxor      xmm3 ,xmm3
   {pinsrw    xmm2 ,esi,4
    pinsrw    xmm2 ,esi,5
    pinsrw    xmm2 ,esi,6
    pinsrw    xmm2 ,esi,7}

  @Continue:

    {load and stretch two pixels(PColor(@dst+0)^ and PColor(@dst+1)^) by 4 32-bit integers(whole xmm3-register)}
    movq      xmm3 ,[dst]
    punpcklbw xmm3 ,xmm3
    pand      xmm3 ,xmm0

    {PQWord(@dst)^ mass-processing}
  //movdqu    xmm5 ,xmm1
  //pcmpgtw   xmm5 ,xmm3
    psubw     xmm1 ,xmm3
    pmulhw    xmm1 ,xmm2
    paddw     xmm1 ,xmm3
  //paddw     xmm1 ,xmm5
  //paddw     xmm1 ,xmm4

    {pack result and store in PQWord(@dst)^}
    packuswb  xmm1 ,xmm1
    movq      [dst],xmm1

end; {$endregion}
procedure ScalePix128F   (const msk0     :TRGBA04; var dst    :qword;  const src:TColor; const s0,s1,s2,s3:TColor; const b:boolean; const arr_width:TColor);        assembler; inline;               deprecated;    {$region -fold}
asm

    {load mask for bitwise AND}
    movdqu    xmm0 ,[msk0]

    {load and stretch src by 4 32-bit integers(whole xmm1-register)}
    mov       eax  ,src
    movd      xmm1 ,eax
    pinsrd    xmm1 ,eax,1
    punpcklbw xmm1 ,xmm1
    pand      xmm1 ,xmm0
    movdqu    xmm4 ,xmm1

    {load s0 to xmm2 as 2 first  32-bit integers}
    movd      xmm2 ,s0
    pshuflw   xmm2 ,xmm2,0

    {check whether it is necessary to calculate the neighboring pixel}
    cmp       b    ,0
    je        @Continue0

    {load s1 to xmm2 as 2 second 32-bit integers}
    movd      xmm3 ,s1
    pshuflw   xmm3 ,xmm3,0
    movq      rax  ,xmm3
    pinsrq    xmm2 ,rax ,1

  @Continue0:

    {load and stretch two pixels(PColor(@dst+0)^ and PColor(@dst+1)^) by 4 32-bit integers(whole xmm3-register)}
    movq      xmm3 ,[dst]
    punpcklbw xmm3 ,xmm3
    pand      xmm3 ,xmm0

    {PQWord(@dst)^ mass-processing}
    psubw     xmm1 ,xmm3
    pmulhw    xmm1 ,xmm2
    paddw     xmm1 ,xmm3

    {pack result and store in PQWord(@dst)^}
    packuswb  xmm1 ,xmm1
    movq      [dst],xmm1

    {restore src}
    movdqu    xmm1 ,xmm4

    {load s2 to xmm2 as 2 first  32-bit integers}
    movd      xmm2 ,s2
    pshuflw   xmm2 ,xmm2,0

    {check whether it is necessary to calculate the neighboring pixel}
    je        @Continue1

    {load s3 to xmm2 as 2 second 32-bit integers}
    movd      xmm3 ,s3
    pshuflw   xmm3 ,xmm3,0
    movq      rax  ,xmm3
    pinsrq    xmm2 ,rax ,1

  @Continue1:

    {load arr_width}
    mov       eax  ,[arr_width]

    {load and stretch two pixels(PColor(@dst+arr_width+0)^ and PColor(@dst+arr_width+1)^) by 4 32-bit integers(whole xmm3-register)}
    movq      xmm3 ,[dst+4*eax]
    punpcklbw xmm3 ,xmm3
    pand      xmm3 ,xmm0

    {PQWord(@dst)^ mass-processing}
    psubw     xmm1 ,xmm3
    pmulhw    xmm1 ,xmm2
    paddw     xmm1 ,xmm3

    {pack result and store in PQWord(@dst+arr_width)^}
    packuswb  xmm1 ,xmm1
    movq      [dst+4*eax],xmm1

end; {$endregion}
procedure ScalePix256    (const msk0,msk1:TRGBA08; var dst,src:TColor;                   const s0,s1,s2,s3:TColor;                  const arr_width:TColor);        assembler; inline;               unimplemented; {$region -fold}
asm
  {TODO}
end; {$endregion}
procedure AlphaBlend128P0(const msk0     :TRGBA04; var dst    :TColor; const src:TColor; const s0,s1      :TColor;                  const arr_width:TColor);        assembler; inline;               experimental;  {$region -fold}
asm

  {load mask for bitwise AND}
  movdqu    xmm0              ,[msk0]

  {load arr_width}
  mov       ecx               ,arr_width

  {load and stretch src by 4 32-bit integers(whole xmm1-register)}
  mov       eax               ,src
  movd      xmm1              ,eax
  pinsrd    xmm1              ,eax               ,1
  punpcklbw xmm1              ,xmm1
  pand      xmm1              ,xmm0

  {load s0 to xmm2 into 2 first  32-bit integers}
  movd      xmm2              ,s0
  pshuflw   xmm2              ,xmm2              ,0

  {save s0(s1 will be in xmm3)}
  //movq      xmm4              ,xmm2

  {load s1 to xmm2 into 2 second 32-bit integers}
  movd      xmm3              ,s1
  pshuflw   xmm3              ,xmm3              ,0
  movq      rax               ,xmm3
  pinsrq    xmm2              ,rax               ,1

  //PColor(@dst+0)^ and PColor(@dst+1)^:

  {load pixel PColor(@dst+0)^            as first  32-bit integer into xmm5}
  movd      xmm5              ,dword[dst+0      ]

  {load pixel PColor(@dst+1)^ and insert as second 32-bit integer into xmm5}
  mov       eax               ,dword[dst+4      ]
  movd      xmm5              ,eax
  pinsrd    xmm5              ,eax               ,1

  {stretch xmm5}
  punpcklbw xmm5              ,xmm5
  pand      xmm5              ,xmm0

  {PColor(@dst+0)^ and PColor(@dst+1)^ mass-processing}
  psubsw    xmm5              ,xmm1
  pmullw    xmm5              ,xmm2
  psraw     xmm5              ,8
  paddsw    xmm5              ,xmm1
  pand      xmm5              ,xmm0

  {pack result and store in PColor(@dst+0)^ and PColor(@dst+1)^}
  packuswb  xmm5              ,xmm5
  movd      dword[dst+0      ],xmm5
  pextrd    eax               ,xmm5              ,1
  mov       dword[dst+4      ],eax

  //PColor(@dst+2)^ and PColor(@dst+arr_width)^:

  {load pixel PColor(@dst+2        )^            as first  32-bit integer into xmm5}
  movd      xmm5              ,dword[dst+8      ]

  {load pixel PColor(@dst+arr_width)^ and insert as second 32-bit integer into xmm5}
  mov       eax               ,dword[dst+4*ecx  ]
  movd      xmm5              ,eax
  pinsrd    xmm5              ,eax               ,1

  {stretch xmm5}
  punpcklbw xmm5              ,xmm5
  pand      xmm5              ,xmm0

  {PColor(@dst+2)^ and PColor(@dst+arr_width)^ mass-processing}
  psubsw    xmm5              ,xmm1
  pmullw    xmm5              ,xmm2
  psraw     xmm5              ,8
  paddsw    xmm5              ,xmm1
  pand      xmm5              ,xmm0

  {pack result and store in PColor(@dst+2)^ and PColor(@dst+arr_width)^}
  packuswb  xmm5              ,xmm5
  movd      dword[dst+8      ],xmm5
  pextrd    eax               ,xmm5              ,1
  mov       dword[dst+4*ecx  ],eax

  //PColor(@dst+2*arr_width)^ and PColor(@dst+arr_width+2)^:

  {load pixel PColor(@dst+2*arr_width)^            as first  32-bit integer into xmm5}
  movd      xmm5              ,dword[dst+8*ecx  ]

  {load pixel PColor(@dst+arr_width+2)^ and insert as second 32-bit integer into xmm5}
  mov       eax               ,dword[dst+4*ecx+8]
  movd      xmm5              ,eax
  pinsrd    xmm5              ,eax               ,1

  {stretch xmm5}
  punpcklbw xmm5              ,xmm5
  pand      xmm5              ,xmm0

  {PColor(@dst+2*arr_width)^ and PColor(@dst+arr_width+2)^ mass-processing}
  psubsw    xmm5              ,xmm1
  pmullw    xmm5              ,xmm2
  psraw     xmm5              ,8
  paddsw    xmm5              ,xmm1
  pand      xmm5              ,xmm0

  {pack result and store in PColor(@dst+2*arr_width)^ and PColor(@dst+arr_width+2)^}
  packuswb  xmm5              ,xmm5
  movd      dword[dst+8*ecx  ],xmm5
  pextrd    eax               ,xmm5              ,1
  mov       dword[dst+4*ecx+8],eax

  //PColor(@dst+2*arr_width+2)^ and PColor(@dst+2*arr_width+1)^:

  {load pixel PColor(@dst+2*arr_width+2)^            as first  32-bit integer into xmm5}
  movd      xmm5              ,dword[dst+8*ecx+8]

  {load pixel PColor(@dst+2*arr_width+1)^ and insert as second 32-bit integer into xmm5}
  mov       eax               ,dword[dst+8*ecx+4]
  movd      xmm5              ,eax
  pinsrd    xmm5              ,eax               ,1

  {stretch xmm5}
  punpcklbw xmm5              ,xmm5
  pand      xmm5              ,xmm0

  {PColor(@dst+2*arr_width+2)^ and PColor(@dst+2*arr_width+1)^ mass-processing}
  psubsw    xmm5              ,xmm1
  pmullw    xmm5              ,xmm2
  psraw     xmm5              ,8
  paddsw    xmm5              ,xmm1
  pand      xmm5              ,xmm0

  {pack result and store in PColor(@dst+2*arr_width+2)^ and PColor(@dst+2*arr_width+1)^}
  packuswb  xmm5              ,xmm5
  movd      dword[dst+8*ecx+8],xmm5
  pextrd    eax               ,xmm5              ,1
  mov       dword[dst+8*ecx+4],eax

end; {$endregion}



end.

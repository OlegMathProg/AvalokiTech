(****************************** Edge Antialiasing *****************************)
// This file contains some routines for simple contour anti-aliasing.



// Forward Definitions:
type
TPtRect           =packed record {$region -fold}
    left  : integer;
    top   : integer;
    width : integer;
    height: integer;
    right : integer;
    bottom: integer;
  end; {$endregion}
PPtRect           =^TPtRect;

T1ByteArr         =array of byte;
P1ByteArr         =^T1ByteArr;

T1IntrArr         =array of integer;
P1IntrArr         =^T1IntrArr;

TFunc2            =function (         pixel        :integer;
                             constref r,g,b        :byte;
                                      alpha,d_alpha:byte;
                             constref alpha_fade   :byte;
                             constref pow          :byte;
                             constref d            :smallint): integer;
PFunc2            =^TFunc2;

PPDec2Proc : array[0..09] of TFunc2;

TFunc0Args        =packed record {$region -fold}
    r      :byte;
    g      :byte;
    b      :byte;
    alpha  :byte;
    d_alpha:byte;
    pow    :byte;
    d      :smallint;
  end; {$endregion}
PFunc0Args        =^TFunc0Args;

TFastAALine       =packed record {$region -fold}
    first_pt_x: integer;
    first_pt_y: integer;
    line_shift: integer;
    line_kind : byte;
    // 00 - horizontal line: 2 points from left to right;
    // 01 - horizontal line: 2 points from right to left;
    // 02 - horizontal line: outer line from ends to middle;
    // 03 - horizontal line: inner line from middle to ends;
    // 04 - horizontal line: const fill;

    // 05 - vertical   line: 2 points from top to bottom;
    // 06 - vertical   line: 2 points from bottom to top;
    // 07 - vertical   line: inner line from ends to middle;
    // 08 - vertical   line: outer line from middle to ends;
    // 09 - vertical   line: const fill;

    // 10 - 1 point;
  end; {$endregion}
PFastAALine       =^TFastAALine;

T1AALnArr         =array of TFastAALine;
P1AALnArr         =^T1AALnArr;



// Initialization of gradient effects:
procedure PPDec2ProcInit;  {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPDec2Proc[000]:=Unaligned(@AlphablendDec2);
  PPDec2Proc[001]:=Unaligned(@AdditiveDec2  );
  PPDec2Proc[002]:=Unaligned(@AlphablendDec2);
  PPDec2Proc[003]:=Unaligned(@InverseDec2   );
  PPDec2Proc[004]:=Unaligned(@HighlightDec2 );
  PPDec2Proc[005]:=Unaligned(@DarkenDec2    );
  PPDec2Proc[006]:=Unaligned(@GrayscaleRDec2);
  PPDec2Proc[007]:=Unaligned(@GrayscaleGDec2);
  PPDec2Proc[008]:=Unaligned(@GrayscaleBDec2);
  PPDec2Proc[009]:=Unaligned(@AlphablendDec2);
end; {$endregion}



// Calculation of all border pixels:
procedure BorderCalc1(constref arr_src_ptr:PInteger; var arr_dst:T1ByteArr; constref arr_src_width,arr_dst_width:integer; constref rct_dst:TPtRect; var aa_nz_arr_it_cnt:integer); {$ifdef Linux}[local];{$endif} {$region -fold}
var
  arr_src_ptr2         : PInteger;
  arr_dst_ptr          : PByte;
  d_width1,d_width2,x,y: integer;
begin
  aa_nz_arr_it_cnt     :=0;
  d_width1             :=                                    arr_src_width- rct_dst.width   ;
  d_width2             :=                                    arr_dst_width- rct_dst.width   ;
  arr_src_ptr2         :=Unaligned( arr_src_ptr+rct_dst.left+arr_src_width*(rct_dst.top+1) );
  arr_dst_ptr          :=Unaligned(@arr_dst    [rct_dst.left+arr_dst_width*(rct_dst.top+1)]);
  Prefetch(arr_src_ptr2);
  Prefetch(arr_dst_ptr );
  for y:=0 to rct_dst.height-3 do
    begin
      for x:=0 to rct_dst.width-1 do
        begin
          if (arr_src_ptr2^<>0) then
            begin
              if ((arr_src_ptr2-arr_src_width)^=0) then
                begin
                  (arr_dst_ptr-arr_dst_width)^:=1;
                  //Inc(aa_nz_arr_it_cnt);
                end;
              if ((arr_src_ptr2+arr_src_width)^=0) then
                begin
                  (arr_dst_ptr+arr_dst_width)^:=1;
                  //Inc(aa_nz_arr_it_cnt);
                end;
              if ((arr_src_ptr2-1)^=0) then
                begin
                  (arr_dst_ptr-1)^:=1;
                  //Inc(aa_nz_arr_it_cnt);
                end;
              if ((arr_src_ptr2+1)^=0) then
                begin
                  (arr_dst_ptr+1)^:=1;
                  //Inc(aa_nz_arr_it_cnt);
                end;
            end;
          Inc(arr_src_ptr2);
          Inc(arr_dst_ptr );
        end;
      Inc(arr_src_ptr2,d_width1);
      Inc(arr_dst_ptr ,d_width2);
    end;
end; {$endregion}

// Calculation of border line gradients directions: 
procedure BorderCalc2(constref arr_src_ptr:PInteger; var arr_dst:T1ByteArr; var arr_alpha:T1AALnArr; constref arr_src_width,arr_dst_width:integer; constref rct_dst:TPtRect; out line_count:integer); {$ifdef Linux}[local];{$endif} {$region -fold}
var
  line_kind_arr         : array[0..7] of boolean;
  line_kind             : qword absolute line_kind_arr;
  arr_alpha_ptr         : PFastAALine;
  arr_dst_ptr           : PByte;
  arr_dst_left_ptr      : PByte;
  arr_dst_rect_right_ptr: PByte;
  line_first_pt_ptr     : PByte;
  y_,i,d0,d1,d2         : integer;
begin
  {Fill Borders} {$region -fold}
  arr_dst_ptr:=@arr_dst[rct_dst.left+arr_dst_width*rct_dst.top];
  // Top Line
  FillByte(arr_dst_ptr^,rct_dst.width,0);
  // Left Line
  for i:=0 to rct_dst.height-1 do
    begin
      arr_dst_ptr^:=0;
      Inc(arr_dst_ptr,arr_dst_width);
    end;
  // Right Line
  arr_dst_ptr:=@arr_dst[rct_dst.left+rct_dst.width-1+arr_dst_width*rct_dst.top];
  for i:=0 to rct_dst.height-1 do
    begin
      arr_dst_ptr^:=0;
      Inc(arr_dst_ptr,arr_dst_width);
    end;
  // Bottom Line
  arr_dst_ptr:=@arr_dst[rct_dst.left+arr_dst_width*(rct_dst.top+rct_dst.height-1)];
  FillByte(arr_dst_ptr^,rct_dst.width,0); {$endregion}
  arr_dst_ptr     :=Unaligned(@arr_dst  [rct_dst.left+arr_dst_width*(rct_dst.top+1)]);
  arr_alpha_ptr   :=Unaligned(@arr_alpha[000000000000000000000000000000000000000000]);
  arr_dst_left_ptr:=Unaligned(@arr_dst  [arr_dst_width*rct_dst.top                 ]);
  d0              :=                     arr_src_width*rct_dst.top;
  for y_:=0 to rct_dst.height-2 do
    begin
      arr_dst_rect_right_ptr:=arr_dst_left_ptr+rct_dst.left+rct_dst.width-1;
      repeat
        begin
          if (arr_dst_ptr^=1) then
            begin
              {Fill Horizontal Line-} {$region -fold}
              if ((arr_dst_ptr+1)^=1) then
                begin
                  line_first_pt_ptr:=arr_dst_ptr;
                  while (arr_dst_ptr^=1) do
                    begin
                      arr_dst_ptr^:=2;
                      Inc(arr_dst_ptr);
                    end;
                  arr_alpha_ptr^.line_shift:=arr_dst_ptr-line_first_pt_ptr;
                  d1                       :=line_first_pt_ptr-arr_dst_left_ptr+d0;
                  d2                       :=arr_dst_ptr      -arr_dst_left_ptr+d0;
                  line_kind_arr[3]         :=((arr_src_ptr+d1-1)^<>0);
                  line_kind_arr[4]         :=((arr_src_ptr+d2  )^<>0);
                  {line_kind=2----} {$region -fold}
                  if (line_kind_arr[3] and line_kind_arr[4]) then
                    begin
                      arr_alpha_ptr^.line_kind :=2;
                      arr_alpha_ptr^.first_pt_x:=line_first_pt_ptr-arr_dst_left_ptr;
                      arr_alpha_ptr^.first_pt_y:=rct_dst.top+y_;
                      Inc(arr_alpha_ptr);
                    end {$endregion}
                  else
                  {line_kind=0,1,3} {$region -fold}
                    begin
                      line_kind_arr[0]:=((arr_src_ptr+d1-1-arr_src_width)^<>0);
                      line_kind_arr[1]:=((arr_src_ptr+d1  -arr_src_width)^<>0);
                      line_kind_arr[2]:=((arr_src_ptr+d2  -arr_src_width)^<>0);
                      line_kind_arr[5]:=((arr_src_ptr+d1-1+arr_src_width)^<>0);
                      line_kind_arr[6]:=((arr_src_ptr+d1  +arr_src_width)^<>0);
                      line_kind_arr[7]:=((arr_src_ptr+d2  +arr_src_width)^<>0);
                      case line_kind of
                        {line_kind=0} {$region -fold}
                        {can be rolled to line_kind=1}
                        {l.b - last bit:              l.b     l.b     l.b     l.b     l.b     l.b     l.b     l.b    }
                        {00000011}{257              }%0000000000000000000000000000000000000000000000000000000100000001,
                        {00001110}{16843008         }%0000000000000000000000000000000000000001000000010000000100000000,
                        {00001010}{16777472         }%0000000000000000000000000000000000000001000000000000000100000000,
                        {00001011}{16777473         }%0000000000000000000000000000000000000001000000000000000100000001,
                        {00101010}{1099528405248    }%0000000000000000000000010000000000000001000000000000000100000000,
                        {00101011}{1099528405249    }%0000000000000000000000010000000000000001000000000000000100000001,
                        {01001010}{281474993488128  }%0000000000000001000000000000000000000001000000000000000100000000,
                        {01001011}{281474993488129  }%0000000000000001000000000000000000000001000000000000000100000001,
                        {01001101}{281474993553409  }%0000000000000001000000000000000000000001000000010000000000000001,
                        {01100000}{282574488338432  }%0000000000000001000000010000000000000000000000000000000000000000,
                        {01101000}{282574505115648  }%0000000000000001000000010000000000000001000000000000000000000000,
                        {01101001}{282574505115649  }%0000000000000001000000010000000000000001000000000000000000000001,
                        {01001000}{281474993487872  }%0000000000000001000000000000000000000001000000000000000000000000,
                        {01001001}{281474993487873  }%0000000000000001000000000000000000000001000000000000000000000001,
                        {01101010}{282574505115904  }%0000000000000001000000010000000000000001000000000000000100000000,
                        {11101100}{72340168543109120}%0000000100000001000000010000000000000001000000010000000000000000,
                        {10101010}{72058693566333184}%0000000100000000000000010000000000000001000000000000000100000000,
                        {11001000}{72339069031415808}%0000000100000001000000000000000000000001000000000000000000000000,
                        {10001111}{72057594054770945}%0000000100000000000000000000000000000001000000010000000100000001:
                          begin
                            arr_alpha_ptr^.line_kind :=0;
                            arr_alpha_ptr^.first_pt_x:=line_first_pt_ptr-arr_dst_left_ptr;
                            arr_alpha_ptr^.first_pt_y:=rct_dst.top+y_;
                            Inc(arr_alpha_ptr);
                          end; {$endregion}
                        {line_kind=1} {$region -fold}
                        {can be rolled to line_kind=0}
                        {l.b - last bit:              l.b     l.b     l.b     l.b     l.b     l.b     l.b     l.b    }
                        {11000000}{72339069014638592}%0000000100000001000000000000000000000000000000000000000000000000,
                        {01110000}{282578783305728  }%0000000000000001000000010000000100000000000000000000000000000000,
                        {01010000}{281479271677952  }%0000000000000001000000000000000100000000000000000000000000000000,
                        {11010000}{72339073309605888}%0000000100000001000000000000000100000000000000000000000000000000,
                        {01010100}{281479271743488  }%0000000000000001000000000000000100000000000000010000000000000000,
                        {11010100}{72339073309671424}%0000000100000001000000000000000100000000000000010000000000000000,
                        {01010010}{281479271678208  }%0000000000000001000000000000000100000000000000000000000100000000,
                        {11010010}{72339073309606144}%0000000100000001000000000000000100000000000000000000000100000000,
                        {10110010}{72058697844523264}%0000000100000000000000010000000100000000000000000000000100000000,
                        {00000110}{65792            }%0000000000000000000000000000000000000000000000010000000100000000,
                        {00010110}{4295033088       }%0000000000000000000000000000000100000000000000010000000100000000,
                        {10010110}{72057598332961024}%0000000100000000000000000000000100000000000000010000000100000000,
                        {00010010}{4294967552       }%0000000000000000000000000000000100000000000000000000000100000000,
                        {10010010}{72057598332895488}%0000000100000000000000000000000100000000000000000000000100000000,
                        {01010110}{281479271743744  }%0000000000000001000000000000000100000000000000010000000100000000,
                        {00110111}{1103806660865    }%0000000000000000000000010000000100000000000000010000000100000001,
                        {01010101}{281479271743489  }%0000000000000001000000000000000100000000000000010000000000000001,
                        {00010011}{4294967553       }%0000000000000000000000000000000100000000000000000000000100000001,
                        {11110001}{72340172821233665}%0000000100000001000000010000000100000000000000000000000000000001:
                          begin
                            arr_alpha_ptr^.line_kind :=1;
                            arr_alpha_ptr^.first_pt_x:=line_first_pt_ptr-arr_dst_left_ptr;
                            arr_alpha_ptr^.first_pt_y:=rct_dst.top+y_;
                            Inc(arr_alpha_ptr);
                          end; {$endregion}
                        {line_kind=3} {$region -fold}
                        {l.b - last bit:              l.b     l.b     l.b     l.b     l.b     l.b     l.b     l.b    }
                        {00000010}{256              }%0000000000000000000000000000000000000000000000000000000100000000:
                        if ((arr_src_ptr+d2-arr_src_width-1)^<>0) then
                          begin
                            arr_alpha_ptr^.line_kind :=3;
                            arr_alpha_ptr^.first_pt_x:=line_first_pt_ptr-arr_dst_left_ptr;
                            arr_alpha_ptr^.first_pt_y:=rct_dst.top+y_;
                            Inc(arr_alpha_ptr);
                          end;
                        {l.b - last bit:              l.b     l.b     l.b     l.b     l.b     l.b     l.b     l.b    }
                        {01000000}{281474976710656  }%0000000000000001000000000000000000000000000000000000000000000000:
                        if ((arr_src_ptr+d2+arr_src_width-1)^<>0) then
                          begin
                            arr_alpha_ptr^.line_kind :=3;
                            arr_alpha_ptr^.first_pt_x:=line_first_pt_ptr-arr_dst_left_ptr;
                            arr_alpha_ptr^.first_pt_y:=rct_dst.top+y_;
                            Inc(arr_alpha_ptr);
                          end; {$endregion}
                      end;
                    end; {$endregion}
                end {$endregion}
              {Fill Vertical Line---} {$region -fold}
              else
              if ((arr_dst_ptr+arr_dst_width)^=1) then
                begin
                  line_first_pt_ptr:=arr_dst_ptr;
                  while (arr_dst_ptr^=1) do
                    begin
                      arr_dst_ptr^:=2;
                      Inc(arr_dst_ptr,arr_dst_width);
                    end;
                  arr_alpha_ptr^.line_shift:=Trunc((arr_dst_ptr-line_first_pt_ptr)/arr_dst_width);
                  Dec(arr_dst_ptr,arr_dst_ptr-line_first_pt_ptr);
                  d1                       :=line_first_pt_ptr-arr_dst_left_ptr+d0;
                  d2                       :=d1+arr_src_width*arr_alpha_ptr^.line_shift;
                  line_kind_arr[3]         :=((arr_src_ptr+d1 -arr_src_width)^<>0);
                  line_kind_arr[4]         :=((arr_src_ptr+d2               )^<>0);
                  {line_kind=7----} {$region -fold}
                  if (line_kind_arr[3] and line_kind_arr[4]) then
                    begin
                      arr_alpha_ptr^.line_kind :=7;
                      arr_alpha_ptr^.first_pt_x:=line_first_pt_ptr-arr_dst_left_ptr;
                      arr_alpha_ptr^.first_pt_y:=rct_dst.top+y_;
                      Inc(arr_alpha_ptr);
                    end {$endregion}
                  else
                  {line_kind=5,6,8} {$region -fold}
                    begin
                      line_kind_arr[0]:=((arr_src_ptr+d1+1-arr_src_width)^<>0);
                      line_kind_arr[1]:=((arr_src_ptr+d1+1              )^<>0);
                      line_kind_arr[2]:=((arr_src_ptr+d2+1              )^<>0);
                      line_kind_arr[5]:=((arr_src_ptr+d1-1-arr_src_width)^<>0);
                      line_kind_arr[6]:=((arr_src_ptr+d1-1              )^<>0);
                      line_kind_arr[7]:=((arr_src_ptr+d2-1              )^<>0);
                      case line_kind of
                        {line_kind=5} {$region -fold}
                        {can be rolled to line_kind=6}
                        {l.b - last bit:              l.b     l.b     l.b     l.b     l.b     l.b     l.b     l.b    }
                        {00000011}{257              }%0000000000000000000000000000000000000000000000000000000100000001,
                        {00001110}{16843008         }%0000000000000000000000000000000000000001000000010000000100000000,
                        {00001010}{16777472         }%0000000000000000000000000000000000000001000000000000000100000000,
                        {00001011}{16777473         }%0000000000000000000000000000000000000001000000000000000100000001,
                        {00101010}{1099528405248    }%0000000000000000000000010000000000000001000000000000000100000000,
                        {00101011}{1099528405249    }%0000000000000000000000010000000000000001000000000000000100000001,
                        {01001010}{281474993488128  }%0000000000000001000000000000000000000001000000000000000100000000,
                        {01001011}{281474993488129  }%0000000000000001000000000000000000000001000000000000000100000001,
                        {01001101}{281474993553409  }%0000000000000001000000000000000000000001000000010000000000000001,
                        {01100000}{282574488338432  }%0000000000000001000000010000000000000000000000000000000000000000,
                        {01101000}{282574505115648  }%0000000000000001000000010000000000000001000000000000000000000000,
                        {01101001}{282574505115649  }%0000000000000001000000010000000000000001000000000000000000000001,
                        {01001000}{281474993487872  }%0000000000000001000000000000000000000001000000000000000000000000,
                        {01001001}{281474993487873  }%0000000000000001000000000000000000000001000000000000000000000001,
                        {01101010}{282574505115904  }%0000000000000001000000010000000000000001000000000000000100000000,
                        {11101100}{72340168543109120}%0000000100000001000000010000000000000001000000010000000000000000,
                        {10101010}{72058693566333184}%0000000100000000000000010000000000000001000000000000000100000000,
                        {11001000}{72339069031415808}%0000000100000001000000000000000000000001000000000000000000000000,
                        {10001111}{72057594054770945}%0000000100000000000000000000000000000001000000010000000100000001:
                          begin
                            arr_alpha_ptr^.line_kind :=5;
                            arr_alpha_ptr^.first_pt_x:=line_first_pt_ptr-arr_dst_left_ptr;
                            arr_alpha_ptr^.first_pt_y:=rct_dst.top+y_;
                            Inc(arr_alpha_ptr);
                          end; {$endregion}
                        {line_kind=6} {$region -fold}
                        {can be rolled to line_kind=5}
                        {l.b - last bit:              l.b     l.b     l.b     l.b     l.b     l.b     l.b     l.b    }
                        {11000000}{72339069014638592}%0000000100000001000000000000000000000000000000000000000000000000,
                        {01110000}{282578783305728  }%0000000000000001000000010000000100000000000000000000000000000000,
                        {01010000}{281479271677952  }%0000000000000001000000000000000100000000000000000000000000000000,
                        {11010000}{72339073309605888}%0000000100000001000000000000000100000000000000000000000000000000,
                        {01010100}{281479271743488  }%0000000000000001000000000000000100000000000000010000000000000000,
                        {11010100}{72339073309671424}%0000000100000001000000000000000100000000000000010000000000000000,
                        {01010010}{281479271678208  }%0000000000000001000000000000000100000000000000000000000100000000,
                        {11010010}{72339073309606144}%0000000100000001000000000000000100000000000000000000000100000000,
                        {10110010}{72058697844523264}%0000000100000000000000010000000100000000000000000000000100000000,
                        {00000110}{65792            }%0000000000000000000000000000000000000000000000010000000100000000,
                        {00010110}{4295033088       }%0000000000000000000000000000000100000000000000010000000100000000,
                        {10010110}{72057598332961024}%0000000100000000000000000000000100000000000000010000000100000000,
                        {00010010}{4294967552       }%0000000000000000000000000000000100000000000000000000000100000000,
                        {10010010}{72057598332895488}%0000000100000000000000000000000100000000000000000000000100000000,
                        {01010110}{281479271743744  }%0000000000000001000000000000000100000000000000010000000100000000,
                        {00110111}{1103806660865    }%0000000000000000000000010000000100000000000000010000000100000001,
                        {01010101}{281479271743489  }%0000000000000001000000000000000100000000000000010000000000000001,
                        {00010011}{4294967553       }%0000000000000000000000000000000100000000000000000000000100000001,
                        {11110001}{72340172821233665}%0000000100000001000000010000000100000000000000000000000000000001:
                          begin
                            arr_alpha_ptr^.line_kind :=6;
                            arr_alpha_ptr^.first_pt_x:=line_first_pt_ptr-arr_dst_left_ptr;
                            arr_alpha_ptr^.first_pt_y:=rct_dst.top+y_;
                            Inc(arr_alpha_ptr);
                          end; {$endregion}
                        {line_kind=8} {$region -fold}
                        {l.b - last bit:              l.b     l.b     l.b     l.b     l.b     l.b     l.b     l.b    }
                        {00000010}{256              }%0000000000000000000000000000000000000000000000000000000100000000:
                        if ((arr_src_ptr+d2+1)^<>0) then
                          begin
                            arr_alpha_ptr^.line_kind :=8;
                            arr_alpha_ptr^.first_pt_x:=line_first_pt_ptr-arr_dst_left_ptr;
                            arr_alpha_ptr^.first_pt_y:=rct_dst.top+y_;
                            Inc(arr_alpha_ptr);
                          end;
                        {l.b - last bit:              l.b     l.b     l.b     l.b     l.b     l.b     l.b     l.b    }
                        {01000000}{281474976710656  }%0000000000000001000000000000000000000000000000000000000000000000:
                        if ((arr_src_ptr+d2-1-arr_src_width)^<>0) then
                          begin
                            arr_alpha_ptr^.line_kind :=8;
                            arr_alpha_ptr^.first_pt_x:=line_first_pt_ptr-arr_dst_left_ptr;
                            arr_alpha_ptr^.first_pt_y:=rct_dst.top+y_;
                            Inc(arr_alpha_ptr);
                          end; {$endregion}
                      end;
                    end; {$endregion}
                end {$endregion}
              {Fill One Pixel-------} {$region -fold}
              else
              if (((arr_dst_ptr-arr_dst_width)^<>1) and ((arr_dst_ptr-1)^<>1)) or
                 (((arr_dst_ptr+arr_dst_width)^<>1) and ((arr_dst_ptr+1)^<>1)) then
                begin
                  arr_dst_ptr^             :=2;
                  arr_alpha_ptr^.line_kind :=10;
                  arr_alpha_ptr^.first_pt_x:=arr_dst_ptr-arr_dst_left_ptr;
                  arr_alpha_ptr^.first_pt_y:=rct_dst.top+y_;
                  Inc(arr_alpha_ptr);
                end; {$endregion}
            end;
          Inc(arr_dst_ptr);
        end;
      until (arr_dst_ptr>arr_dst_rect_right_ptr);
      Inc(arr_dst_ptr);
      Inc(arr_dst_left_ptr,arr_dst_width);
      Inc(d0              ,arr_src_width);
    end;
  line_count:=PFastAALine(arr_alpha_ptr)-PFastAALine(@arr_alpha[0]);
end; {$endregion}

// Fill borders with gradient effect:
procedure BorderFill (constref arr_src:T1AALnArr; constref rct_dst_left,rct_dst_top:integer; constref bmp_ptr:PInteger; constref bmp_width:integer; constref line_count:integer; constref col:TColor; args:TFunc0Args; Func2:TFunc2); {$region -fold}
var
  arr_src_ptr : PFastAALine;
  pixel_ptr   : Pinteger;
  i,j         : integer;
  alpha_shift3: integer;
  alpha_shift2: integer;
  alpha_shift1: byte;
    alpha1    : byte;
  d_alpha1    : byte;
    alpha2    : byte;
  d_alpha2    : byte;
begin
  if (line_count=0) then
    Exit;
  with args do
    begin
      r           :=Red  (col);
      g           :=Green(col);
      b           :=Blue (col);
      alpha1      :=alpha;
      d_alpha1    :=255-alpha1;
      alpha_shift1:=255-alpha;
      arr_src_ptr :=Unaligned(@arr_src[0]);
      Prefetch(arr_src_ptr);
      for i:=0 to line_count-1 do
        begin
          pixel_ptr:=Unaligned(bmp_ptr+arr_src_ptr^.first_pt_x+rct_dst_left+bmp_width*(arr_src_ptr^.first_pt_y+rct_dst_top));
          case arr_src_ptr^.line_kind of
            00{00 - horizontal line: 2 points from left to right---}: {$region -fold}
              begin
                alpha_shift2:=arr_src_ptr^.line_shift;
                alpha_shift3:=Trunc(alpha_shift1/alpha_shift2);
                alpha2      :=alpha1;
                for j:=0 to alpha_shift2-1 do
                  begin
                    //alpha2  :=alpha1+j*alpha_shift3;
                    d_alpha2  :=255-alpha2;
                    pixel_ptr^:=
                    //SetColorInv({clGreen}clFuchsia);
                    Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
                    Inc  (pixel_ptr);
                    Inc  (alpha2,alpha_shift3);
                  end;
              end; {$endregion}
            01{01 - horizontal line: 2 points from right to left---}: {$region -fold}
              begin
                alpha_shift2:=arr_src_ptr^.line_shift;
                alpha_shift3:=Trunc(alpha_shift1/alpha_shift2);
                alpha2      :=255-alpha_shift3;
                for j:=0 to alpha_shift2-1 do
                  begin
                    //alpha2  :=255-alpha_shift3-j*alpha_shift3;
                    d_alpha2  :=255-alpha2;
                    pixel_ptr^:=
                    //SetColorInv({clGreen}clBlue);
                    Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
                    Inc  (pixel_ptr);
                    Dec  (alpha2,alpha_shift3);
                  end;
              end; {$endregion}
            02{02 - horizontal line: outer line from ends to middle}: {$region -fold}
              begin
                alpha_shift2:=Trunc((arr_src_ptr^.line_shift)/2);
                alpha_shift3:=Trunc(alpha_shift1/alpha_shift2);
                alpha2      :=alpha1;
                for j:=0 to alpha_shift2-1 do
                  begin
                    //alpha2  :=alpha1+j*alpha_shift3;
                    d_alpha2  :=255-alpha2;
                    pixel_ptr^:=
                    //SetColorInv({clGreen}clPurple);
                    Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
                    Inc  (pixel_ptr);
                    Inc  (alpha2,alpha_shift3);
                  end;
                if Odd(arr_src_ptr^.line_shift) then
                  begin
                    alpha2    :=255-alpha_shift3;
                    d_alpha2  :=    alpha_shift3;
                    pixel_ptr^:=
                    //SetColorInv({clGreen}clPurple);
                    Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
                    Inc  (pixel_ptr);
                  end;
                alpha2:=255-alpha_shift3;
                for j:=0 to alpha_shift2-1 do
                  begin
                    //alpha2  :=255-j*alpha_shift3;
                    d_alpha2  :=255-alpha2;
                    pixel_ptr^:=
                    //SetColorInv({clGreen}clPurple);
                    Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
                    Inc  (pixel_ptr);
                    Dec  (alpha2,alpha_shift3);
                  end;
                if Odd(arr_src_ptr^.line_shift) then
                  pixel_ptr^:=
                  //SetColorInv({clGreen}clPurple);
                  Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
              end; {$endregion}
            03{03 - horizontal line: inner line from middle to ends}: {$region -fold}
              begin
                alpha_shift2:=Trunc((arr_src_ptr^.line_shift)/2);
                alpha_shift3:=Trunc(alpha_shift1/alpha_shift2);
                alpha2      :=255-alpha_shift3;
                for j:=0 to alpha_shift2-1 do
                  begin
                    //alpha2  :=255-j*alpha_shift3;
                    d_alpha2  :=255-alpha2;
                    pixel_ptr^:=
                    //SetColorInv({clGreen}clWhite);
                    Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
                    Inc  (pixel_ptr);
                    Dec  (alpha2,alpha_shift3);
                  end;
                if Odd(arr_src_ptr^.line_shift) then
                  begin
                    alpha2    :=255+alpha_shift3;
                    d_alpha2  :=   -alpha_shift3;
                    pixel_ptr^:=
                    //SetColorInv({clGreen}clPurple);
                    Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
                    Inc  (pixel_ptr);
                  end;
                alpha2      :=alpha1;
                for j:=0 to alpha_shift2-1 do
                  begin
                    //alpha2  :=alpha1+j*alpha_shift3;
                    d_alpha2  :=255-alpha2;
                    pixel_ptr^:=
                    //SetColorInv({clGreen}clWhite);
                    Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
                    Inc  (pixel_ptr);
                    Inc  (alpha2,alpha_shift3);
                  end;
                if Odd(arr_src_ptr^.line_shift) then
                  pixel_ptr^:=
                  //SetColorInv({clGreen}clWhite);
                  Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
              end; {$endregion}
            04{04 - horizontal line: const fill--------------------}: {$region -fold}
              begin

              end; {$endregion}
            05{05 - vertical   line: 2 points from top to bottom---}: {$region -fold}
              begin
                alpha_shift2:=arr_src_ptr^.line_shift;
                alpha_shift3:=Trunc(alpha_shift1/alpha_shift2);
                alpha2      :=alpha1;
                for j:=0 to alpha_shift2-1 do
                  begin
                    //alpha2  :=alpha1+j*alpha_shift3;
                    d_alpha2  :=255-alpha2;
                    pixel_ptr^:=
                    //SetColorInv({clGreen}clFuchsia);
                    Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
                    Inc  (pixel_ptr,bmp_width);
                    Inc  (alpha2,alpha_shift3);
                  end;
              end; {$endregion}
            06{06 - vertical   line: 2 points from bottom to top---}: {$region -fold}
              begin
                alpha_shift2:=arr_src_ptr^.line_shift;
                alpha_shift3:=Trunc(alpha_shift1/alpha_shift2);
                alpha2      :=255-alpha_shift3;
                for j:=0 to alpha_shift2-1 do
                  begin
                    //alpha2  :=255-alpha_shift3-j*alpha_shift3;
                    d_alpha2  :=255-alpha2;
                    pixel_ptr^:=
                    //SetColorInv({clGreen}clBlue);
                    Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
                    Inc  (pixel_ptr,bmp_width);
                    Dec  (alpha2,alpha_shift3);
                  end;
              end; {$endregion}
            07{07 - vertical   line: inner line from ends to middle}: {$region -fold}
              begin
                alpha_shift2:=Trunc((arr_src_ptr^.line_shift)/2);
                alpha_shift3:=Trunc(alpha_shift1/alpha_shift2);
                alpha2      :=alpha1;
                for j:=0 to alpha_shift2-1 do
                  begin
                    //alpha2  :=alpha1+j*alpha_shift3;
                    d_alpha2  :=255-alpha2;
                    pixel_ptr^:=
                    //SetColorInv({clGreen}clPurple);
                    Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
                    Inc  (pixel_ptr,bmp_width);
                    Inc  (alpha2,alpha_shift3);
                  end;
                if Odd(arr_src_ptr^.line_shift) then
                  begin
                    alpha2    :=255-alpha_shift3;
                    d_alpha2  :=    alpha_shift3;
                    pixel_ptr^:=
                    //SetColorInv({clGreen}clPurple);
                    Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
                    Inc  (pixel_ptr,bmp_width);
                  end;
                alpha2:=255-alpha_shift3;
                for j:=0 to alpha_shift2-1 do
                  begin
                    //alpha2  :=255-j*alpha_shift3;
                    d_alpha2  :=255-alpha2;
                    pixel_ptr^:=
                    //SetColorInv({clGreen}clPurple);
                    Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
                    Inc  (pixel_ptr,bmp_width);
                    Dec  (alpha2,alpha_shift3);
                  end;
                if Odd(arr_src_ptr^.line_shift) then
                  pixel_ptr^:=
                  //SetColorInv({clGreen}clPurple);
                  Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
              end; {$endregion}
            08{08 - vertical   line: outer line from middle to ends}: {$region -fold}
              begin
                alpha_shift2:=Trunc((arr_src_ptr^.line_shift)/2);
                alpha_shift3:=Trunc(alpha_shift1/alpha_shift2);
                alpha2      :=255-alpha_shift3;
                for j:=0 to alpha_shift2-1 do
                  begin
                    //alpha2  :=255-j*alpha_shift3;
                    d_alpha2  :=255-alpha2;
                    pixel_ptr^:=
                    //SetColorInv({clGreen}clWhite);
                    Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
                    Inc  (pixel_ptr,bmp_width);
                    Dec  (alpha2,alpha_shift3);
                  end;
                if Odd(arr_src_ptr^.line_shift) then
                  begin
                    alpha2    :=255+alpha_shift3;
                    d_alpha2  :=   -alpha_shift3;
                    pixel_ptr^:=
                    //SetColorInv({clGreen}clPurple);
                    Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
                    Inc  (pixel_ptr,bmp_width);
                  end;
                alpha2      :=alpha1;
                for j:=0 to alpha_shift2-1 do
                  begin
                    //alpha2    :=alpha1+j*alpha_shift3;
                    d_alpha2  :=255-alpha2;
                    pixel_ptr^:=
                    //SetColorInv({clGreen}clWhite);
                    Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
                    Inc  (pixel_ptr,bmp_width);
                    Inc  (alpha2,alpha_shift3);
                  end;
                if Odd(arr_src_ptr^.line_shift) then
                  pixel_ptr^:=
                  //SetColorInv({clGreen}clWhite);
                  Func2(pixel_ptr^,r,g,b,d_alpha2,alpha2,alpha2,pow,d);
              end; {$endregion}
            09{09 - vertical   line: const fill--------------------}: {$region -fold}
              begin

              end; {$endregion}
            10{10 - 1 point----------------------------------------}: {$region -fold}
              begin
                pixel_ptr^:=
                //SetColorInv(clRed);
                Func2(pixel_ptr^,r,g,b,d_alpha1,alpha1,alpha1,pow,d);
              end; {$endregion}
          end;
          Inc(arr_src_ptr);
        end;
    end;
end; {$endregion}



// Usage Example:
BorderCalc1(ln_arr0,
            aa_arr1,
            ln_arr_width,
            ln_arr_width,
            rct_clp,
            aa_nz_arr_items_count);
BorderCalc2(ln_arr0,
            aa_arr1,
            aa_arr2,
            ln_arr_width,
            ln_arr_width,
            rct_clp,
            aa_line_count);
BorderFill (aa_arr2,
            0,
            0,
            bmp_dst_ptr,
            ln_arr_width,
            aa_line_count,
            eds_col,
            args,
            PPDec2Proc[pp_dec_2_proc_ind]);
            
            
            
// Gradient effects:
// AlphaBlend:
function AlphaBlendDec2(pixel:integer; constref r,g,b:byte; alpha,d_alpha:byte; constref alpha_fade:byte; constref pow:byte; constref d:smallint): integer; inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  alpha  :=Max(alpha-Byte(d){alpha_fade},0);
  d_alpha:=255-alpha;
  Result:=(((Blue (pixel)-r)*d_alpha)>>8+r)<<16+
          (((Green(pixel)-g)*d_alpha)>>8+g)<<08+
          (((Red  (pixel)-b)*d_alpha)>>8+b)<<00;
       {RGB((b*alpha+d_alpha*Red  (pixel))>>8,
            (g*alpha+d_alpha*Green(pixel))>>8,
            (r*alpha+d_alpha*Blue (pixel))>>8);}
end; {$endregion}

// Additive:
function AdditiveDec2  (pixel:integer; constref r,g,b:byte; alpha,d_alpha:byte; constref alpha_fade:byte; constref pow:byte; constref d:smallint): integer; inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  r_,g_,b_: byte;
begin

  if   (Min(Red  (pixel)+b,255)>Red(pixel)) then
    r_:=Min(Red  (pixel)+b,255)-((alpha_fade*(Abs(Min(Red  (pixel)+b,255)-Red  (pixel))))>>8)
  else
    r_:=Min(Red  (pixel)+b,255)+((alpha_fade*(Abs(Min(Red  (pixel)+b,255)-Red  (pixel))))>>8);

  if   (Min(Green(pixel)+g,255)>Green(pixel)) then
    g_:=Min(Green(pixel)+g,255)-((alpha_fade*(Abs(Min(Green(pixel)+g,255)-Green(pixel))))>>8)
  else
    g_:=Min(Green(pixel)+g,255)+((alpha_fade*(Abs(Min(Green(pixel)+g,255)-Green(pixel))))>>8);

  if   (Min(Blue (pixel)+r,255)>Blue (pixel)) then
    b_:=Min(Blue (pixel)+r,255)-((alpha_fade*(Abs(Min(Blue (pixel)+r,255)-Blue (pixel))))>>8)
  else
    b_:=Min(Blue (pixel)+r,255)+((alpha_fade*(Abs(Min(Blue (pixel)+r,255)-Blue (pixel))))>>8);

  Result:=RGBToColor(r_,g_,b_);

end; {$endregion}

// Inverse:
function InverseDec2   (pixel:integer; constref r,g,b:byte; alpha,d_alpha:byte; constref alpha_fade:byte; constref pow:byte; constref d:smallint): integer; inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  r_,g_,b_: byte;
begin

  if   (255>Red  (pixel)<<1) then
    r_:=255-Red  (pixel)-((alpha_fade*(Abs(255-Red  (pixel)<<1)))>>8)
  else
    r_:=255-Red  (pixel)+((alpha_fade*(Abs(255-Red  (pixel)<<1)))>>8);

  if   (255>Green(pixel)<<1) then
    g_:=255-Green(pixel)-((alpha_fade*(Abs(255-Green(pixel)<<1)))>>8)
  else
    g_:=255-Green(pixel)+((alpha_fade*(Abs(255-Green(pixel)<<1)))>>8);

  if   (255>Blue (pixel)<<1) then
    b_:=255-Blue (pixel)-((alpha_fade*(Abs(255-Blue (pixel)<<1)))>>8)
  else
    b_:=255-Blue (pixel)+((alpha_fade*(Abs(255-Blue (pixel)<<1)))>>8);

  Result:=RGB(r_,g_,b_);

end; {$endregion}

// Highlight:
function HighlightDec2 (pixel:integer; constref r,g,b:byte; alpha,d_alpha:byte; constref alpha_fade:byte; constref pow:byte; constref d:smallint): integer; inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  r_,g_,b_: byte;
begin

  if   (Min(Red  (pixel)+pow,255)>Red(pixel)) then
    r_:=Min(Red  (pixel)+pow,255)-((alpha_fade*(Abs(Min(Red  (pixel)+pow,255)-Red  (pixel))))>>8)
  else
    r_:=Min(Red  (pixel)+pow,255)+((alpha_fade*(Abs(Min(Red  (pixel)+pow,255)-Red  (pixel))))>>8);

  if   (Min(Green(pixel)+pow,255)>Green(pixel)) then
    g_:=Min(Green(pixel)+pow,255)-((alpha_fade*(Abs(Min(Green(pixel)+pow,255)-Green(pixel))))>>8)
  else
    g_:=Min(Green(pixel)+pow,255)+((alpha_fade*(Abs(Min(Green(pixel)+pow,255)-Green(pixel))))>>8);

  if   (Min(Blue (pixel)+pow,255)>Blue (pixel)) then
    b_:=Min(Blue (pixel)+pow,255)-((alpha_fade*(Abs(Min(Blue (pixel)+pow,255)-Blue (pixel))))>>8)
  else
    b_:=Min(Blue (pixel)+pow,255)+((alpha_fade*(Abs(Min(Blue (pixel)+pow,255)-Blue (pixel))))>>8);

  Result:=RGB(r_,g_,b_);

end; {$endregion}

// Highlight:
function HighlightDec2 (pixel:integer; constref r,g,b:byte; alpha,d_alpha:byte; constref alpha_fade:byte; constref pow:byte; constref d:smallint): integer; inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  r_,g_,b_: byte;
begin

  if   (Min(Red  (pixel)+pow,255)>Red(pixel)) then
    r_:=Min(Red  (pixel)+pow,255)-((alpha_fade*(Abs(Min(Red  (pixel)+pow,255)-Red  (pixel))))>>8)
  else
    r_:=Min(Red  (pixel)+pow,255)+((alpha_fade*(Abs(Min(Red  (pixel)+pow,255)-Red  (pixel))))>>8);

  if   (Min(Green(pixel)+pow,255)>Green(pixel)) then
    g_:=Min(Green(pixel)+pow,255)-((alpha_fade*(Abs(Min(Green(pixel)+pow,255)-Green(pixel))))>>8)
  else
    g_:=Min(Green(pixel)+pow,255)+((alpha_fade*(Abs(Min(Green(pixel)+pow,255)-Green(pixel))))>>8);

  if   (Min(Blue (pixel)+pow,255)>Blue (pixel)) then
    b_:=Min(Blue (pixel)+pow,255)-((alpha_fade*(Abs(Min(Blue (pixel)+pow,255)-Blue (pixel))))>>8)
  else
    b_:=Min(Blue (pixel)+pow,255)+((alpha_fade*(Abs(Min(Blue (pixel)+pow,255)-Blue (pixel))))>>8);

  Result:=RGB(r_,g_,b_);

end; {$endregion}

// Darken:
function DarkenDec2    (pixel:integer; constref r,g,b:byte; alpha,d_alpha:byte; constref alpha_fade:byte; constref pow:byte; constref d:smallint): integer; inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  r_,g_,b_: byte;
begin

  if   (Max(Red  (pixel)-pow,0)>Red(pixel)) then
    r_:=Max(Red  (pixel)-pow,0)-((alpha_fade*(Abs(Max(Red  (pixel)-pow,0)-Red  (pixel))))>>8)
  else
    r_:=Max(Red  (pixel)-pow,0)+((alpha_fade*(Abs(Max(Red  (pixel)-pow,0)-Red  (pixel))))>>8);

  if   (Max(Green(pixel)-pow,0)>Green(pixel)) then
    g_:=Max(Green(pixel)-pow,0)-((alpha_fade*(Abs(Max(Green(pixel)-pow,0)-Green(pixel))))>>8)
  else
    g_:=Max(Green(pixel)-pow,0)+((alpha_fade*(Abs(Max(Green(pixel)-pow,0)-Green(pixel))))>>8);

  if   (Max(Blue (pixel)-pow,0)>Blue (pixel)) then
    b_:=Max(Blue (pixel)-pow,0)-((alpha_fade*(Abs(Max(Blue (pixel)-pow,0)-Blue (pixel))))>>8)
  else
    b_:=Max(Blue (pixel)-pow,0)+((alpha_fade*(Abs(Max(Blue (pixel)-pow,0)-Blue (pixel))))>>8);

  Result:=RGB(r_,g_,b_);

end; {$endregion}

// Grayscale(red channel);
function GrayscaleRDec2(pixel:integer; constref r,g,b:byte; alpha,d_alpha:byte; constref alpha_fade:byte; constref pow:byte; constref d:smallint): integer; inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  r_,g_,b_: byte;
begin

    r_:=Red  (pixel);

  if   (Green(pixel)>Red(pixel)) then
    g_:=Green(pixel)-((d*(Abs(Green(pixel)-Red(pixel))))>>8)
  else
    g_:=Green(pixel)+((d*(Abs(Green(pixel)-Red(pixel))))>>8);

  if   (Blue (pixel)>Red(pixel)) then
    b_:=Blue (pixel)-((d*(Abs(Blue (pixel)-Red(pixel))))>>8)
  else
    b_:=Blue (pixel)+((d*(Abs(Blue (pixel)-Red(pixel))))>>8);

  Result:=RGB(r_,g_,b_);

end; {$endregion}

// Grayscale(green channel);
function GrayscaleGDec2(pixel:integer; constref r,g,b:byte; alpha,d_alpha:byte; constref alpha_fade:byte; constref pow:byte; constref d:smallint): integer; inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  r_,g_,b_: byte;
begin

  if   (Red  (pixel)>Green(pixel)) then
    r_:=Red  (pixel)-((alpha_fade*(Abs(Red  (pixel)-Green(pixel))))>>8)
  else
    r_:=Red  (pixel)+((alpha_fade*(Abs(Red  (pixel)-Green(pixel))))>>8);

    g_:=Green(pixel);

  if   (Blue (pixel)>Green(pixel)) then
    b_:=Blue (pixel)-((alpha_fade*(Abs(Blue (pixel)-Green(pixel))))>>8)
  else
    b_:=Blue (pixel)+((alpha_fade*(Abs(Blue (pixel)-Green(pixel))))>>8);

  Result:=RGB(r_,g_,b_);

end; {$endregion}

// Grayscale(blue channel);
function GrayscaleBDec2(pixel:integer; constref r,g,b:byte; alpha,d_alpha:byte; constref alpha_fade:byte; constref pow:byte; constref d:smallint): integer; inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  r_,g_,b_: byte;
begin

  if   (Red  (pixel)>Blue(pixel)) then
    r_:=Red  (pixel)-((alpha_fade*(Abs(Red  (pixel)-Blue(pixel))))>>8)
  else
    r_:=Red  (pixel)+((alpha_fade*(Abs(Red  (pixel)-Blue(pixel))))>>8);

  if   (Green(pixel)>Blue(pixel)) then
    g_:=Green(pixel)-((alpha_fade*(Abs(Green(pixel)-Blue(pixel))))>>8)
  else
    g_:=Green(pixel)+((alpha_fade*(Abs(Green(pixel)-Blue(pixel))))>>8);

    b_:=Blue (pixel);

  Result:=RGB(r_,g_,b_);

end; {$endregion}




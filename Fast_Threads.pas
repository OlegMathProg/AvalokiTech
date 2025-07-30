unit Fast_Threads;

{$mode objfpc}{$H+}

interface

uses

  Classes, SysUtils, MTProcs, PasMP, Fast_Scene_Tree, Fast_Graphics;



const

  MAXBYTE=255;



type

  TThreadObj    =class(TThread)                      {$region -fold}
    public // private
      thread_ind       : integer;
      bmp_dst_ptr      : PInteger;
      bmp_dst_width    : TColor;
      bmp_dst_height   : TColor;
      rct_dst          : TPtRect;
      class var
        color_info     : TColorInfo;
        PPRandNoiseProc: TProc23;
        PPBlurProc     : TProc8;
        thread_cnt     : byte;
        proc_ind       : byte;
    public
      {Thread Init.-}
      constructor Create(thread_cnt_    : integer;
                         thread_ind_    : integer;
                         proc_ind_      : byte;
                         bmp_dst_ptr_   : PInteger;
                         bmp_dst_width_ : TColor;
                         bmp_dst_height_: TColor;
                         rct_dst_       : TPtRect);
      {MT AlphaBlend}
      procedure   ThreadWork;
      {Thread Work--}
      procedure   Execute; override;
  end; {$endregion}

  TFastImageProc=class(Fast_Graphics.TFastImageProc) {$region -fold}
    constructor Create;
    procedure   FastImageDataMTInit;                                override; {$ifdef Linux}[local];{$endif}
    procedure   UberShader8         (const pt_arr_ptr  :PPtPosF;
                                     const sprites_cnt,
                                           w_a_s_x,
                                           w_a_s_y     :integer;
                                     const block_count :integer=1); override; {$ifdef Linux}[local];{$endif}
    procedure   UberShader9         (const pt_arr_ptr  :PPtPosF;
                                     const sprites_cnt,
                                           w_a_s_x,
                                           w_a_s_y     :integer;
                                     const block_count :integer=1); override; {$ifdef Linux}[local];{$endif}
  end; {$endregion}

{
  TSceneTree    =class(Fast_Scene_Tree.TSceneTree) {$region -fold}
    constructor Create;
    procedure   MovSceneMT(rct_dst    : TPtRect;
                           start_ind,
                           end_ind    : TColor;
                           block_count: integer=1); override; deprecated;
  end; {$endregion}
}



var
  max_physical_threads_cnt: integer=64{      CPUCount     };
  max_virtual_threads_cnt : integer=64{      CPUCount     };
  usable_threads_cnt      : integer=04{Trunc(CPUCount/1.5)};
  thread_obj_arr          : array of TThreadObj;



function  SetRct          (      index        :PtrInt;
                           const rct_dst      :TPtRect;
                           const block_count  :integer): TPtRect; inline;
procedure ThreadObjArrInit(      thread_cnt   :integer);
// MT FloodFill:
procedure PPFloodFillMT   (const bmp_dst_ptr  :PInteger;
                           const bmp_dst_width:TColor;
                           const rct_dst      :TPtRect;
                           const col          :TColor;
                           const block_count  :integer=1);
// MT Additive:
procedure PPAdditiveMT    (const bmp_dst_ptr    :PInteger;
                           const bmp_dst_width:TColor;
                           const rct_dst      :TPtRect;
                           const col          :TColor;
                           const block_count  :integer=1);
// MT AlphaBlend:
procedure PPAlphaBlendMT  (const bmp_dst_ptr  :PInteger;
                           const bmp_dst_width:TColor;
                           const rct_dst      :TPtRect;
                           const col          :TColor;
                           const pow          :byte=64;
                           const block_count  :integer=1);
// MT Inverse:
procedure PPInverseMT     (const bmp_dst_ptr  :PInteger;
                           const bmp_dst_width:TColor;
                           const rct_dst      :TPtRect;
                           const block_count  :integer=1);
// MT Highlight:
procedure PPHighlightMT   (const bmp_dst_ptr  :PInteger;
                           const bmp_dst_width:TColor;
                           const rct_dst      :TPtRect;
                           const pow          :byte=64;
                           const block_count  :integer=1);
// MT Darken:
procedure PPDarkenMT      (const bmp_dst_ptr  :PInteger;
                           const bmp_dst_width:TColor;
                           const rct_dst      :TPtRect;
                           const pow          :byte=64;
                           const block_count  :integer=1);
// MT GrayscaleR:
procedure PPGrayscaleRMT  (const bmp_dst_ptr  :PInteger;
                           const bmp_dst_width:TColor;
                           const rct_dst      :TPtRect;
                           const block_count  :integer=1);
// MT GrayscaleG:
procedure PPGrayscaleGMT  (const bmp_dst_ptr  :PInteger;
                           const bmp_dst_width:TColor;
                           const rct_dst      :TPtRect;
                           const block_count  :integer=1);
// MT GrayscaleB:
procedure PPGrayscaleBMT  (const bmp_dst_ptr  :PInteger;
                           const bmp_dst_width:TColor;
                           const rct_dst      :TPtRect;
                           const block_count  :integer=1);
// MT MonoNoise:
procedure PPMonoNoiseMT   (const bmp_dst_ptr  :PInteger;
                           const bmp_dst_width:TColor;
                           const rct_dst      :TPtRect;
                           const col          :TColor;
                           const block_count  :integer=1);
{// MT RandNoise:
procedure PPRandNoiseMT   (const bmp_dst_ptr  :PInteger;
                           const bmp_dst_width:TColor;
                           const rct_dst      :TPtRect;
                           const col          :TColor;
                           const pow          :byte=64;
                           const block_count  :integer=1);
// MT Blur:
procedure PPBlurMT        (const bmp_dst_ptr  :PInteger;
                           const bmp_dst_width:TColor;
                           const rct_dst      :TPtRect;
                           const col          :TColor;
                           const pow          :byte=64;
                           const block_count  :integer=1);}



implementation

function  SetRct(index:PtrInt; const rct_dst:TPtRect; const block_count:integer): TPtRect; inline; {$region -fold}
var
  pixels_per_block_y0: integer;
  pixels_per_block_y1: integer;
begin
  pixels_per_block_y0:=Round(rct_dst.height/block_count);
  if (index<block_count-1) then
    pixels_per_block_y1:=pixels_per_block_y0
  else
    pixels_per_block_y1:=      rct_dst.height   -pixels_per_block_y0*(block_count-1);
  Result               :=PtRct(rct_dst.left,
                               rct_dst.top+index*pixels_per_block_y0,
                               rct_dst.right,
                               rct_dst.top+index*pixels_per_block_y0+
                                                 pixels_per_block_y1);
end; {$endregion}

procedure   ThreadObjArrInit (thread_cnt :integer); {$region -fold}
begin
  SetLength(thread_obj_arr,thread_cnt);
end; {$endregion}
constructor TThreadObj.Create(thread_cnt_:integer; thread_ind_:integer; proc_ind_:byte; bmp_dst_ptr_:PInteger; bmp_dst_width_:TColor; bmp_dst_height_:TColor; rct_dst_:TPtRect); {$region -fold}
begin

  {Init.Thread---} {$region -fold}
  inherited Create(False);
  FreeOnTerminate:=False; {$endregion}

  {Fill Some Data} {$region -fold}
  thread_cnt     :=thread_cnt_;
  thread_ind     :=thread_ind_;
  proc_ind       :=proc_ind_;
  bmp_dst_ptr    :=bmp_dst_ptr_;
  bmp_dst_width  :=bmp_dst_width_;
  bmp_dst_height :=bmp_dst_height_;
  rct_dst        :=SetRct(thread_ind,rct_dst_,thread_cnt); {$endregion}

end; {$endregion}
procedure   TThreadObj.ThreadWork; {$region -fold}
{var
  x,y: integer;}
begin

   case proc_ind of
   //00: Empty;
     01: PPFloodFill (bmp_dst_ptr,bmp_dst_width,rct_dst,                color_info.pix_col                                    );
     02: PPAdditive  (bmp_dst_ptr,bmp_dst_width,rct_dst,                color_info.pix_col                                    );
     03: PPAlphaBlend(bmp_dst_ptr,bmp_dst_width,rct_dst,                color_info.pix_col,color_info.alpha1                  );
     04: PPInverse   (bmp_dst_ptr,bmp_dst_width,rct_dst                                                                       );
     05: PPHighlight (bmp_dst_ptr,bmp_dst_width,rct_dst,                                   color_info.alpha1                  );
     06: PPDarken    (bmp_dst_ptr,bmp_dst_width,rct_dst,                                   color_info.alpha1                  );
     07: PPGrayscaleR(bmp_dst_ptr,bmp_dst_width,rct_dst                                                                       );
     08: PPGrayscaleG(bmp_dst_ptr,bmp_dst_width,rct_dst                                                                       );
     09: PPGrayscaleB(bmp_dst_ptr,bmp_dst_width,rct_dst                                                                       );
     10: PPMonoNoise (bmp_dst_ptr,bmp_dst_width,rct_dst,                color_info.pix_col                                    );
     11: PPRandNoise (bmp_dst_ptr,bmp_dst_width,rct_dst,PPRandNoiseProc,                   color_info.alpha1,color_info.alpha2);
     12: PPBlur      (bmp_dst_ptr,bmp_dst_width,rct_dst,PPBlurProc                                                            );
   // ...
   end;

  {Debug} {$region -fold}
  {if (rct_dst.width<=0) or (rct_dst.height<=0) then
    Exit;
  bmp_dst_ptr+=rct_dst.left+bmp_dst_width*rct_dst.top;
  for y:=0 to rct_dst.height-1 do
    begin
      for x:=0 to rct_dst.width-1 do
        AlphaBlend1(bmp_dst_ptr+x,color_info.pix_col,color_info.d_alpha1);
      Inc(bmp_dst_ptr,bmp_dst_width);
    end;} {$endregion}

end; {$endregion}
procedure   TThreadObj.Execute; {$region -fold}
begin
  //inherited CurrentThread;
  {TThread.Synchronize(TThread.CurrentThread,@ThreadWork);//}{Synchronize(@}ThreadWork{)};
end; {$endregion}

constructor TFastImageProc.Create; {$region -fold}
begin
  inherited Create;
  FastImageDataMTInit;
end; {$endregion}
procedure TFastImageProc.FastImageDataMTInit; {$region -fold}
var
  i: integer;
begin
  SetLength(fast_image_data_arr,max_virtual_threads_cnt);
  for i:=0 to max_virtual_threads_cnt-1 do
    fast_image_data_arr[i].scl_mul:=PtPosF(1.0,1.0);
end; {$endregion}
procedure TFastimageProc.UberShader8(const pt_arr_ptr:PPtPosF; const sprites_cnt,w_a_s_x,w_a_s_y:integer; const block_count:integer=1); {$ifdef Linux}[local];{$endif} {$region -fold}

  procedure DrawCallMT(index:PtrInt); {$region -fold}
  var
    i: integer;
  begin
    with fast_image_data_ptr0^ do
      for i:=0 to sprites_cnt-1 do
        begin
          //fast_image_data_arr[i].img_inv_type:=Byte(Odd(i));
          SdrProc[sdr_proc_ind+0](Trunc(pt_arr_ptr[i].x)+w_a_s_x,
                                  Trunc(pt_arr_ptr[i].y)+w_a_s_y,
                                  fast_image_data_ptr0,
                                  index,
                                  block_count);

        end;
  end; {$endregion}

begin
  ProcThreadPool.DoParallelLocalProc(@DrawCallMT,0,block_count-1);
end; {$endregion}
procedure TFastimageProc.UberShader9(const pt_arr_ptr:PPtPosF; const sprites_cnt,w_a_s_x,w_a_s_y:integer; const block_count:integer=1); {$ifdef Linux}[local];{$endif} {$region -fold}

  procedure DrawCallMT(index:PtrInt); {$region -fold}
  var
    i: integer;
  begin

    {with fast_image_data_arr[index] do
      begin
        with fx_arr[0] do
          begin
            nt_fx_prop.is_fx_animate:=True;
            pt_fx_prop.is_fx_animate:=True;
            nt_fx_prop.pix_cfx_type :=2;
            pt_fx_prop.pix_cfx_type :=2;
            nt_fx_prop.pix_cng_type :=1;
            pt_fx_prop.pix_cng_type :=1;
            //nt_fx_prop.cfx_pow0     :=100;
            //pt_fx_prop.cfx_pow0     :=100;
            Inc(nt_fx_prop.cfx_pow0);
            Inc(pt_fx_prop.cfx_pow0);
          end;
        with fx_arr[1] do
          begin
            nt_fx_prop.is_fx_animate:=True;
            pt_fx_prop.is_fx_animate:=True;
            nt_fx_prop.pix_cfx_type :=2;
            pt_fx_prop.pix_cfx_type :=2;
            nt_fx_prop.pix_cng_type :=1;
            pt_fx_prop.pix_cng_type :=1;
            //nt_fx_prop.cfx_pow0     :=100;
            //pt_fx_prop.cfx_pow0     :=100;
            Inc(nt_fx_prop.cfx_pow0);
            Inc(pt_fx_prop.cfx_pow0);
          end;
      end;}

    with fast_image_data_ptr0^ do
      for i:=0 to sprites_cnt-1 do
        SdrProc[sdr_proc_ind+4](Trunc(pt_arr_ptr[i].x)+w_a_s_x,
                                Trunc(pt_arr_ptr[i].y)+w_a_s_y,
                                fast_image_data_ptr0,
                                index,
                                block_count);
  end; {$endregion}

begin
  ProcThreadPool.DoParallelLocalProc(@DrawCallMT,0,block_count-1);
end; {$endregion}

// MT FloodFill:
procedure PPFloodFillMT (const bmp_dst_ptr:PInteger; const bmp_dst_width:TColor; const rct_dst:TPtRect; const col:TColor;                    const block_count:integer=1); {$region -fold}

  procedure PPFloodFillMTParallel(index:PtrInt; data:pointer; item:TMultiThreadProcItem); {$region -fold}
  begin
    PPFloodFill(bmp_dst_ptr,bmp_dst_width,SetRct(index,rct_dst,block_count),col);
  end; {$endregion}

begin
  ProcThreadPool.DoParallelLocalProc(@PPFloodFillMTParallel,0,block_count-1);
end; {$endregion}
// MT Additive:
procedure PPAdditiveMT  (const bmp_dst_ptr:PInteger; const bmp_dst_width:TColor; const rct_dst:TPtRect; const col:TColor;                    const block_count:integer=1); {$region -fold}

  procedure PPAdditiveMTParallel(index:PtrInt; data:pointer; item:TMultiThreadProcItem); {$region -fold}
  begin
    PPAdditive(bmp_dst_ptr,bmp_dst_width,SetRct(index,rct_dst,block_count),col);
  end; {$endregion}

begin
  ProcThreadPool.DoParallelLocalProc(@PPAdditiveMTParallel,0,block_count-1);
end; {$endregion}
// MT AlphaBlend:
procedure PPAlphaBlendMT(const bmp_dst_ptr:PInteger; const bmp_dst_width:TColor; const rct_dst:TPtRect; const col:TColor; const pow:byte=64; const block_count:integer=1); {$region -fold}

  procedure PPAlphaBlendMTParallel(index:PtrInt; data:pointer; item:TMultiThreadProcItem); {$region -fold}
  begin
    PPAlphaBlend(bmp_dst_ptr,bmp_dst_width,SetRct(index,rct_dst,block_count),col,pow);
  end; {$endregion}

begin
  ProcThreadPool.DoParallelLocalProc(@PPAlphaBlendMTParallel,0,block_count-1);
end; {$endregion}
// MT Inverse:
procedure PPInverseMT   (const bmp_dst_ptr:PInteger; const bmp_dst_width:TColor; const rct_dst:TPtRect;                                      const block_count:integer=1); {$region -fold}

  procedure PPInverseMTParallel(index:PtrInt; data:pointer; item:TMultiThreadProcItem); {$region -fold}
  begin
    PPInverse(bmp_dst_ptr,bmp_dst_width,SetRct(index,rct_dst,block_count));
  end; {$endregion}

begin
  ProcThreadPool.DoParallelLocalProc(@PPInverseMTParallel,0,block_count-1);
end; {$endregion}
// MT Highlight:
procedure PPHighlightMT (const bmp_dst_ptr:PInteger; const bmp_dst_width:TColor; const rct_dst:TPtRect;                   const pow:byte=64; const block_count:integer=1); {$region -fold}

  procedure PPHighlightMTParallel(index:PtrInt; data:pointer; item:TMultiThreadProcItem); {$region -fold}
  begin
    PPHighlight(bmp_dst_ptr,bmp_dst_width,SetRct(index,rct_dst,block_count),pow);
  end; {$endregion}

begin
  ProcThreadPool.DoParallelLocalProc(@PPHighlightMTParallel,0,block_count-1);
end; {$endregion}
// MT Darken:
procedure PPDarkenMT    (const bmp_dst_ptr:PInteger; const bmp_dst_width:TColor; const rct_dst:TPtRect;                   const pow:byte=64; const block_count:integer=1); {$region -fold}

  procedure PPDarkenMTParallel(index:PtrInt; data:pointer; item:TMultiThreadProcItem); {$region -fold}
  begin
    PPDarken(bmp_dst_ptr,bmp_dst_width,SetRct(index,rct_dst,block_count),pow);
  end; {$endregion}

begin
  ProcThreadPool.DoParallelLocalProc(@PPDarkenMTParallel,0,block_count-1);
end; {$endregion}
// MT GrayscaleR:
procedure PPGrayscaleRMT(const bmp_dst_ptr:PInteger; const bmp_dst_width:TColor; const rct_dst:TPtRect;                                      const block_count:integer=1); {$region -fold}

  procedure PPGrayscaleRMTParallel(index:PtrInt; data:pointer; item:TMultiThreadProcItem); {$region -fold}
  begin
    PPGrayscaleR(bmp_dst_ptr,bmp_dst_width,SetRct(index,rct_dst,block_count));
  end; {$endregion}

begin
  ProcThreadPool.DoParallelLocalProc(@PPGrayscaleRMTParallel,0,block_count-1);
end; {$endregion}
// MT GrayscaleG:
procedure PPGrayscaleGMT(const bmp_dst_ptr:PInteger; const bmp_dst_width:TColor; const rct_dst:TPtRect;                                      const block_count:integer=1); {$region -fold}

  procedure PPGrayscaleGMTParallel(index:PtrInt; data:pointer; item:TMultiThreadProcItem); {$region -fold}
  begin
    PPGrayscaleG(bmp_dst_ptr,bmp_dst_width,SetRct(index,rct_dst,block_count));
  end; {$endregion}

begin
  ProcThreadPool.DoParallelLocalProc(@PPGrayscaleGMTParallel,0,block_count-1);
end; {$endregion}
// MT GrayscaleB:
procedure PPGrayscaleBMT(const bmp_dst_ptr:PInteger; const bmp_dst_width:TColor; const rct_dst:TPtRect;                                      const block_count:integer=1); {$region -fold}

  procedure PPGrayscaleBMTParallel(index:PtrInt; data:pointer; item:TMultiThreadProcItem); {$region -fold}
  begin
    PPGrayscaleB(bmp_dst_ptr,bmp_dst_width,SetRct(index,rct_dst,block_count));
  end; {$endregion}

begin
  ProcThreadPool.DoParallelLocalProc(@PPGrayscaleBMTParallel,0,block_count-1);
end; {$endregion}
// MT MonoNoise:
procedure PPMonoNoiseMT (const bmp_dst_ptr:PInteger; const bmp_dst_width:TColor; const rct_dst:TPtRect; const col:TColor;                    const block_count:integer=1); {$region -fold}

  procedure PPMonoNoiseMTParallel(index:PtrInt; data:pointer; item:TMultiThreadProcItem); {$region -fold}
  begin
    PPMonoNoise(bmp_dst_ptr,bmp_dst_width,SetRct(index,rct_dst,block_count),col);
  end; {$endregion}

begin
  ProcThreadPool.DoParallelLocalProc(@PPMonoNoiseMTParallel,0,block_count-1);
end; {$endregion}


// MT Scene Tree: deprecated;
{
constructor TSceneTree.Create; {$region -fold}
begin
  inherited Create;
end; {$endregion}
procedure   TSceneTree.MovSceneMT(rct_dst:TPtRect; start_ind,end_ind:TColor; block_count:integer=1); deprecated; {$region -fold}
var
  rct_dst_    : TPtRect;
  block_count_: integer;
  cpu_count   : integer;
  i           : integer;

  procedure MovSceneMTParallel(ind:integer); {$region -fold}
  var
    pixels_per_block_y0: integer;
    pixels_per_block_y1: integer;
  begin
    pixels_per_block_y0:=Round(rct_dst.height/block_count_);
    if (ind<block_count_-1) then
      pixels_per_block_y1:=pixels_per_block_y0
    else
      pixels_per_block_y1:=      rct_dst.height -pixels_per_block_y0*(block_count_-1);
    rct_dst_             :=PtRct(rct_dst.left,
                                 rct_dst.top+ind*pixels_per_block_y0,
                                 rct_dst.right,
                                 rct_dst.top+ind*pixels_per_block_y0+
                                                 pixels_per_block_y1);
    SetRctDstPtr(@rct_dst_,start_ind,end_ind);
    MovScene    (          start_ind,end_ind);
  end; {$endregion}

begin
  {$ifndef FPC_HAS_GETCPUCOUNT}
  cpu_count:=CPUCount;
  {$endif}
  block_count_                 :=Min0(cpu_count,block_count);
 {ProcThreadPool.MaxThreadCount:=block_count_;
  ProcThreadPool.DoParallelLocalProc(@MovSceneMTParallel,0,block_count_-1);}
  for i:=0 to block_count_-1 do
    MovSceneMTParallel(i);
end; {$endregion}
}



end.

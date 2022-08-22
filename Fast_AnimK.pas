unit Fast_AnimK;

{This file contains some routines for animation(particles,physics,hair,fluid effects etc.)}

{$mode objfpc}{$H+}

interface

uses

  Classes, Math, Fast_Primitives;

const

  GRAVITY         =9.80665;
  TIME_DELTA      =0.2;
  GRAVITY_DIV_BY_2=4.90333;

type

  TCollider  =class;
  TFluid     =class;

  {Projectile Motion **********************************************************}
  TProjectile=record {$region -fold}
    {start position}
    pt_0      : TPtPosF;
    {previous position}
    pt_p      : TPtPosF;
    {next  position}
    pt_n      : TPtPosF;
    {collision point}
    pt_c      : TPtPosF;
    {distaance of pushing}
    push_dist : double ;
    {angle between horizon and speed vector}
    angle     : double ;
    {time counter}
    time      : double ;
    {speed}
    v_0       : double ;
    {radius of bounding circle}
    c_rad     : integer;
    {line segment index}
    pt_ind    : integer;
    {collision detect}
    coll_det  : boolean;
    {sticky}
    sticky    : boolean;
    {checking out of window}
    out_of_wnd: boolean;
  end; {$endregion}
  PProjectile=^TProjectile;
  {****************************************************************************}



  {Collision Detection System *************************************************}
  TCollider  =class {$region -fold}
    coll_box_arr: T1Byte1Arr;
    width,height: integer;
    max_coll_pix: integer;
    constructor Create(w,h:integer); {$ifdef Linux}[local];{$endif}
    destructor  Destroy;   override; {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PCollider  =^TCollider;
  {****************************************************************************}



  {Fluid Physics **************************************************************}
  TFluid     =class {$region -fold}
    rect_dst_f  : TPTRectB;
    a0          : integer;
    a1          : integer;
    a2          : integer;
    a3          : double;
    a4          : integer;
    r_x         : integer;
    r_y         : integer;
    // distance between points water surface(spline);
    pts_dist    : longword;
    // accumulator or partial sums of pts_dens;
    pts_dist_acc: longword;
    constructor Create           (         w,h          :integer);         {$ifdef Linux}[local];{$endif}
    destructor  Destroy;                                 override;         {$ifdef Linux}[local];{$endif}
    procedure   WaterWaveParamChg(var      param        :integer;
                                           val1,
                                           val2,
                                           val3         :integer); inline; {$ifdef Linux}[local];{$endif}
    procedure   WaterWaveParamChg(var      param        :double;
                                           val1,
                                           val2,
                                           val3         :double);  inline; {$ifdef Linux}[local];{$endif}
    procedure   WaterWaveInit1;                                            {$ifdef Linux}[local];{$endif}
    procedure   WaterWaveInit2   (var      pts          :TPtPosFArr;
                                  constref start_ind,
                                           end_ind      :integer);         {$ifdef Linux}[local];{$endif}
    procedure   WaterWaveInit3   (         pt_pos       :TPtPosF);         {$ifdef Linux}[local];{$endif}
    procedure   WaterWave1       (var      pts          :TPtPosFArr;
                                  constref start_ind,
                                           end_ind      :integer);         {$ifdef Linux}[local];{$endif}
    procedure   WaterWave2       (         pt_pos,
                                           shift        :TPtPosF;
                                  constref step_x,
                                           angle        :double;
                                  constref cnt          :integer;
                                  constref bmp_dst_ptr  :PInteger;
                                  constref bmp_dst_width:TColor;
                                  constref color_info   :TColorInfo;
                                  constref rct_clp      :TPtRect);         {$ifdef Linux}[local];{$endif}
    procedure   WaterWave3       (         pt_pos,
                                           shift        :TPtPosF;
                                  constref step_x,
                                           angle        :double;
                                  constref cnt          :integer;
                                  constref bmp_dst_ptr  :PInteger;
                                  constref bmp_dst_width:TColor;
                                  constref color_info   :TColorInfo;
                                  constref rct_clp      :TPtRect);         {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PFluid     =^TFluid;



  (******************************** Misc. Routines ******************************)

  procedure UpdateTickCounter(var      frame_skip       :integer;
                                       frame_step       :integer);            inline; {$ifdef Linux}[local];{$endif}



  {Screen Space Collision}
  // Find Collision Point:
  function SetCollPt         (         x0,y0,x1,y1      :integer;
                              constref bmp_dst_ptr      :PInteger;
                              constref bmp_dst_width    :integer;
                              constref val              :integer): TPtPos;    inline; {$ifdef Linux}[local];{$endif}
  function SetCollPt         (         x0,y0,x1,y1      :integer;
                              constref bmp_dst_ptr      :PByte;
                              constref bmp_dst_width    :integer;
                              constref val              :byte   ): TPtPos;    inline; {$ifdef Linux}[local];{$endif}
  // Get Line Segment Index:
  procedure GetPtInd         (         x_coll,y_coll    :integer;
                              constref bmp_dst_ptr      :PInteger;
                              constref bmp_dst_width    :integer;
                              var      projectile_      :TProjectile);        inline; {$ifdef Linux}[local];{$endif}
  // Get Collision Angle:
  function GetAngle          (constref x0,y0,x1,y1      :double;
                              constref projectile_      :TProjectile;
                              constref pts              :TPtPosFArr): double; inline; {$ifdef Linux}[local];{$endif}

  {****************************************************************************}



  {Hair Physics ***************************************************************}

  {****************************************************************************}



  (******************************* Fading Effects *******************************)
  procedure FadeTemplate0    (constref time_interval1,
                                       time_interval2,
                                       time_interval3   :integer;
                              var      col_trans_arr_val:byte;
                              var      time_interval    :integer);          inline; {$ifdef Linux}[local];{$endif}
  procedure FadeTemplate1    (constref time_interval1,
                                       time_interval2,
                                       time_interval3   :integer;
                              var      col_trans_arr_val:byte;
                              var      time_interval    :integer);          inline; {$ifdef Linux}[local];{$endif}
  // Ping-Pong(Linear Interpolation):
  procedure FXAnimPingPong   (var      fx_inc_check     :boolean;
                              constref fx_inc_val,
                                       fx_dec_val       :single;
                              var      fx               :single;
                              constref fx_min_val,
                                       fx_max_val       :single);           inline; {$ifdef Linux}[local];{$endif}



  (***************************** Projectile Motion ****************************)

  procedure GetNextPos       (constref v_0,
                                       angle,
                                       time             :double;
                              constref pt_0             :TPtPosF;
                              var      pt_n             :TPtPosF);          inline; {$ifdef Linux}[local];{$endif}
  function  GetNextPos       (constref v_0,
                                       angle,
                                       time             :double;
                              constref pt_0             :TPtPosF): TPtPosF; inline; {$ifdef Linux}[local];{$endif}
  procedure GetNextPos       (var      projectile       :TProjectile);      inline; {$ifdef Linux}[local];{$endif}
  procedure TimeChange       (var      projectile       :TProjectile);      inline; {$ifdef Linux}[local];{$endif}
  procedure CRadChange       (var      projectile       :TProjectile;
                              constref c_rad_delta      :integer=1);        inline; {$ifdef Linux}[local];{$endif}
  // Full Projectile Calc.:
  procedure Projectile       (var      projectile_      :TProjectile;
                              constref arr_dst_ptr      :PInteger;
                              constref arr_dst_width    :integer;
                              constref rct_dst          :TPtRect;
                              constref pts              :TPtPosFArr);               {$ifdef Linux}[local];{$endif}

var

  projectile_default: TProjectile={$region -fold}
  (
    {start position}
    pt_0      : (x:000; y:000);
    {previous position}
    pt_p      : (x:000; y:000);
    {next  position}
    pt_n      : (x:000; y:000);
    {collision point}
    pt_c      : (x:000; y:000);
    {distaance of pushing}
    push_dist : -4;
    {angle between horizon and speed vector}
    angle     : {92.0}{((pi/2)-(pi/10))}{pi-(pi/4)+pi}pi/3;
    {time counter}
    time      : 00.0;
    {speed}
    v_0       : 64.0;
    {radius of bounding circle}
    c_rad     : {6}16{70}{40};
    {line segment index}
    pt_ind    : 0;
    {collision detect}
    coll_det  : False;
    {sticky}
    sticky    : False;
    {checking out of window}
    out_of_wnd: True;
  ); {$endregion}

implementation

(******************************** Misc. Routines ******************************) {$region -fold}
procedure UpdateTickCounter(var frame_skip:integer; frame_step:integer); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  if (frame_skip<>frame_step) then
    Inc(frame_skip)
  else
    frame_skip:=0;
  {frame_skip                  : byte;
   frame_step                  : byte=1;
  if (frame_skip<>frame_step) then
    begin
      Inc(frame_skip);
      Exit;
    end
  else
    frame_skip:=0;}
end; {$endregion}
{$endregion}



(***************************** Projectile Motion ******************************)

procedure GetNextPos(constref v_0,angle,time:double; constref pt_0:TPtPosF; var pt_n:TPtPosF);          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sin_,cos_: double;
begin
  SinCos(angle,sin_,cos_);
  pt_n.x:=pt_0.x                           +v_0*cos_ *time;
  pt_n.y:=pt_0.y{+}-(-GRAVITY_DIV_BY_2*time+v_0*sin_)*time;
end; {$endregion}
function  GetNextPos(constref v_0,angle,time:double; constref pt_0:TPtPosF                  ): TPtPosF; inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sin_,cos_: double;
begin
  SinCos(angle,sin_,cos_);
  Result.x:=pt_0.x                           +v_0*cos_ *time;
  Result.y:=pt_0.y{+}-(-GRAVITY_DIV_BY_2*time+v_0*sin_)*time;
end; {$endregion}
procedure GetNextPos(var projectile:TProjectile                                             );          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sin_,cos_: double;
begin
  with projectile do
    begin
      SinCos(angle,sin_,cos_);
      pt_n.x:=pt_0.x                           +v_0*cos_ *time;
      pt_n.y:=pt_0.y{+}-(-GRAVITY_DIV_BY_2*time+v_0*sin_)*time;
    end;
end; {$endregion}
procedure TimeChange(var projectile:TProjectile                                             );          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  projectile.time+=TIME_DELTA;
end; {$endregion}
procedure CRadChange(var projectile:TProjectile; constref c_rad_delta:integer=1             );          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  projectile.c_rad+=c_rad_delta;
end; {$endregion}
// Full Projectile Calc.:
procedure Projectile(var projectile_:TProjectile; constref arr_dst_ptr:PInteger; constref arr_dst_width:integer; constref rct_dst:TPtRect; constref pts:TPtPosFArr); {$ifdef Linux}[local];{$endif} {$region -fold}
var
  pt_c_pix: TPtPos  ;
  pts_ptr : PPtPosF ;
  ln_pt0  : TPtPosF ;
  ln_pt1  : TPtPosF ;
  cr_pt   : TLnPosF ;
  eq_ln   : TLnPosF ;
  cr0,cr1 : TCrPosF ;
  m1,m2,m3: double  ;
  dir_x   : shortint;
  dir_y   : shortint;
begin
  with projectile_ do
    if (c_rad>0) and out_of_wnd then
      begin
        if (not coll_det) then
          begin

            pt_p:=pt_n;

            {Next Status Calc.} {$region -fold}
            TimeChange(projectile_);
            GetNextPos(projectile_);
            {CRadChange(projectile_,-4);} {$endregion}

            if IsPtInRct(pt_p,rct_dst) and
               IsPtInRct(pt_n,rct_dst) then
              begin

                {Find Collision Point} {$region -fold}
                pt_c_pix:=SetCollPt(Trunc(pt_p.x),
                                    Trunc(pt_p.y),
                                    Trunc(pt_n.x),
                                    Trunc(pt_n.y),
                                    arr_dst_ptr  ,
                                    arr_dst_width,
                                    0);
                GetPtInd(pt_c_pix.x,
                         pt_c_pix.y,
                         arr_dst_ptr,
                         arr_dst_width,
                         projectile_); {$endregion}

                {Check Collision-----} {$region -fold}
                if (pt_ind<>-1) then
                  begin
                    pts_ptr:=Unaligned(@pts[pt_ind]);
                    cr0    :=crcPosF
                    (
                      (pts_ptr+0)^.x,
                      (pts_ptr+0)^.y,
                      c_rad
                    );
                    cr1    :=crcPosF
                    (
                      (pts_ptr+1)^.x,
                      (pts_ptr+1)^.y,
                      c_rad
                    );
                    if IsPtInCrc(pt_c.x,pt_c.y,cr0,1) then
                      begin
                        cr_pt:=LineCrcIntPt
                        (
                          pt_p.x,
                          pt_p.y,
                          pt_n.x,
                          pt_n.y,
                          cr0
                        );
                        m1:=PtDistSqr
                        (
                          cr_pt.x0,
                          cr_pt.y0,
                          pt_p.x,
                          pt_p.y
                        );
                        m2:=PtDistSqr
                        (
                          cr_pt.x1,
                          cr_pt.y1,
                          pt_p.x,
                          pt_p.y
                        );
                        m3:=Min(m1,m2);
                        if (m3=m1) then
                          begin
                            pt_c.x:=cr_pt.x0;
                            pt_c.y:=cr_pt.y0;
                          end
                        else
                          begin
                            pt_c.x:=cr_pt.x1;
                            pt_c.y:=cr_pt.y1;
                          end;
                      end
                    else
                    if IsPtInCrc(pt_c.x,pt_c.y,cr1,1) then
                      begin
                        cr_pt:=LineCrcIntPt
                        (
                          pt_p.x,
                          pt_p.y,
                          pt_n.x,
                          pt_n.y,
                          cr1
                        );
                        m1:=PtDistSqr
                        (
                          cr_pt.x0,
                          cr_pt.y0,
                          pt_p.x,
                          pt_p.y
                        );
                        m2:=PtDistSqr
                        (
                          cr_pt.x1,
                          cr_pt.y1,
                          pt_p.x,
                          pt_p.y
                        );
                        m3:=Min(m1,m2);
                        if (m3=m1) then
                          begin
                            pt_c.x:=cr_pt.x0;
                            pt_c.y:=cr_pt.y0;
                          end
                        else
                          begin
                            pt_c.x:=cr_pt.x1;
                            pt_c.y:=cr_pt.y1;
                          end;
                      end
                    else
                      begin
                        eq_ln:=LineE1
                        (
                          (pts_ptr+0)^.x,
                          (pts_ptr+0)^.y,
                          (pts_ptr+1)^.x,
                          (pts_ptr+1)^.y,
                          c_rad
                        );
                        ln_pt0:=LineLineIntPt
                        (
                          pt_p .x,
                          pt_p .y,
                          pt_n .x,
                          pt_n .y,
                          eq_ln.x0,
                          eq_ln.y0,
                          eq_ln.x1,
                          eq_ln.y1
                        );
                        m1:=PtDistSqr
                        (
                          ln_pt0.x,
                          ln_pt0.y,
                          pt_p.x,
                          pt_p.y
                        );
                        eq_ln:=LineE2
                        (
                          (pts_ptr+0)^.x,
                          (pts_ptr+0)^.y,
                          (pts_ptr+1)^.x,
                          (pts_ptr+1)^.y,
                          c_rad
                        );
                        ln_pt1:=LineLineIntPt
                        (
                          pt_p .x,
                          pt_p .y,
                          pt_n .x,
                          pt_n .y,
                          eq_ln.x0,
                          eq_ln.y0,
                          eq_ln.x1,
                          eq_ln.y1
                        );
                        m2:=PtDistSqr
                        (
                          ln_pt1.x,
                          ln_pt1.y,
                          pt_p.x,
                          pt_p.y
                        );
                        m3:=Min(m1,m2);
                        if (m3=m1) then
                          begin
                            pt_c.x:=ln_pt0.x;
                            pt_c.y:=ln_pt0.y;
                          end
                        else
                          begin
                            pt_c.x:=ln_pt1.x;
                            pt_c.y:=ln_pt1.y;
                          end;
                      end;
                    LineD
                    (
                      pt_p.x,
                      pt_p.y,
                      pt_c.x,
                      pt_c.y,
                      dir_x,
                      dir_y
                    );
                    pt_c:=LineS
                    (
                      pt_p.x,
                      pt_p.y,
                      pt_c.x,
                      pt_c.y,
                      push_dist,
                      dir_x,
                      dir_y
                    );
                    pt_n    :=pt_c;
                    coll_det:=True;
                  end; {$endregion}

              end
            else
              coll_det:=False;

          end
        else
          begin

            {Set Collision Angle} {$region -fold}
            angle:=GetAngle(pt_p.x,
                            pt_p.y,
                            pt_n.x,
                            pt_n.y,
                            projectile_,
                            pts); {$endregion}

            {Set Default Prop.--} {$region -fold}
            pt_ind  :=-1;
            pt_0    :=pt_c;
            pt_p    :=pt_0;
            time    :=00.0;
            v_0     -={sqrt}ln(v_0);{v_0:=64.0;}
            coll_det:=False; {$endregion}

            {Next Status Calc.--} {$region -fold}
            TimeChange(projectile_);
            GetNextPos(projectile_);
            {CRadChange(projectile_,-4);} {$endregion}

          end;
      end;
end; {$endregion}



(************************* Collision Detection System *************************)

constructor TCollider.Create(w,h:integer); {$region -fold}
begin
  width :=w;
  height:=h;
  SetLength(coll_box_arr,w*h);
end; {$endregion}
destructor  TCollider.Destroy;             {$region -fold}
begin
  self.Free;
  inherited Destroy;
end; {$endregion}
{Screen Space Collision}
// Find Collision Point:
function SetCollPt(         x0,y0,x1,y1:integer; constref bmp_dst_ptr:PInteger; constref bmp_dst_width:integer; constref val:integer): TPtPos; inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  y0_shift                        : integer;
  i,short_len,long_len,swp,dec_inc: integer;
  yLonger                         : boolean;
begin
  yLonger  :=False;
  short_len:=y1-y0;
  long_len :=x1-x0;
  if (Abs(short_len)>Abs(long_len)) then
    begin
      swp      :=short_len;
      short_len:=long_len;
      long_len :=swp;
      yLonger  :=True;
    end;
  if (long_len=0) then
    dec_inc:=0
  else
    dec_inc:=Trunc((short_len<<16)/long_len);
  if (yLonger) then
    begin
      if (long_len>0) then
        begin
          long_len+=y0;
          i:=$8000+(x0<<16);
          y0_shift:=y0*bmp_dst_width;
          while (y0<{=}long_len) and ((bmp_dst_ptr+(i>>16)+y0_shift)^=val) do
            begin
              i+=dec_inc;
              Inc(y0);
              Inc(y0_shift,bmp_dst_width);
            end;
          Result.x:=i>>16;
          Result.y:=Trunc(y0_shift/bmp_dst_width);
          Exit;
        end;
      long_len+=y0;
      i:=$8000+(x0<<16);
      y0_shift:=y0*bmp_dst_width;
      while (y0>{=}long_len) and ((bmp_dst_ptr+(i>>16)+y0_shift)^=val) do
        begin
          i-=dec_inc;
          Dec(y0);
          Dec(y0_shift,bmp_dst_width);
        end;
      Result.x:=i>>16;
      Result.y:=Trunc(y0_shift/bmp_dst_width);
      Exit;
    end;
  if (long_len>0) then
    begin
      long_len+=x0;
      i:=$8000+(y0<<16);
      while (x0<{=}long_len) and ((bmp_dst_ptr+x0+(i>>16)*bmp_dst_width)^=val) do
        begin
          i+=dec_inc;
          Inc(x0);
        end;
      Result.x:=x0;
      Result.y:=i>>16;
      Exit;
    end;
  long_len+=x0;
  i:=$8000+(y0<<16);
  while (x0>{=}long_len) and ((bmp_dst_ptr+x0+(i>>16)*bmp_dst_width)^=val) do
    begin
      i-=dec_inc;
      Dec(x0);
    end;
  Result.x:=x0;
  Result.y:=i>>16;
end; {$endregion}
function SetCollPt(         x0,y0,x1,y1:integer; constref bmp_dst_ptr:PByte   ; constref bmp_dst_width:integer; constref val:byte   ): TPtPos; inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  y0_shift                        : integer;
  i,short_len,long_len,swp,dec_inc: integer;
  yLonger                         : boolean;
begin
  yLonger  :=False;
  short_len:=y1-y0;
  long_len :=x1-x0;
  if (Abs(short_len)>Abs(long_len)) then
    begin
      swp      :=short_len;
      short_len:=long_len;
      long_len :=swp;
      yLonger  :=True;
    end;
  if (long_len=0) then
    dec_inc:=0
  else
    dec_inc:=Trunc((short_len<<16)/long_len);
  if (yLonger) then
    begin
      if (long_len>0) then
        begin
          long_len+=y0;
          i:=$8000+(x0<<16);
          y0_shift:=y0*bmp_dst_width;
          while (y0<{=}long_len) and ((bmp_dst_ptr+(i>>16)+y0_shift)^<>val) do
            begin
              i+=dec_inc;
              Inc(y0);
              Inc(y0_shift,bmp_dst_width);
            end;
          Result.x:=i>>16;
          Result.y:=Trunc(y0_shift/bmp_dst_width);
          Exit;
        end;
      long_len+=y0;
      i:=$8000+(x0<<16);
      y0_shift:=y0*bmp_dst_width;
      while (y0>{=}long_len) and ((bmp_dst_ptr+(i>>16)+y0_shift)^<>val) do
        begin
          i-=dec_inc;
          Dec(y0);
          Dec(y0_shift,bmp_dst_width);
        end;
      Result.x:=i>>16;
      Result.y:=Trunc(y0_shift/bmp_dst_width);
      Exit;
    end;
  if (long_len>0) then
    begin
      long_len+=x0;
      i:=$8000+(y0<<16);
      while (x0<{=}long_len) and ((bmp_dst_ptr+x0+(i>>16)*bmp_dst_width)^<>val) do
        begin
          i+=dec_inc;
          Inc(x0);
        end;
      Result.x:=x0;
      Result.y:=i>>16;
      Exit;
    end;
  long_len+=x0;
  i:=$8000+(y0<<16);
  while (x0>{=}long_len) and ((bmp_dst_ptr+x0+(i>>16)*bmp_dst_width)^<>val) do
    begin
      i-=dec_inc;
      Dec(x0);
    end;
  Result.x:=x0;
  Result.y:=i>>16;
end; {$endregion}
// Get Line Segment Index:
procedure GetPtInd(x_coll,y_coll:integer; constref bmp_dst_ptr:PInteger; constref bmp_dst_width:integer; var projectile_:TProjectile);         inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  projectile_.pt_ind:=(bmp_dst_ptr+x_coll+y_coll*bmp_dst_width)^-1;
end; {$endregion}
// Get Collision Angle:
function GetAngle (constref x0,y0,x1,y1:double; constref projectile_:TProjectile; constref pts:TPtPosFArr): double;                            inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  pts_ptr: PPtPosF;
begin
  //if (projectile_.pt_ind>0) then
    begin
      pts_ptr:=@pts[projectile_.pt_ind];
      Result :=pi-(pi+2*ArcTan4(pts_ptr^.x,pts_ptr^.y,(pts_ptr+1)^.x,(pts_ptr+1)^.y)-ArcTan4(x0,y0,x1,y1));
      {if ((y1>y0) and (x1>x0)) or
         ((y1>y0) and (x1<x0)) then
        begin
          Result+=pi;
          Exit;
        end;
      if ((y1<y0) and (x1>x0)) {or
         ((y1<y0) and (x1<x0))} then
        begin
          Result+=2*pi;
          Exit;
        end;}
      {if ((y1>y0) and (x1>x0)) then
        begin
          Result:=pi-Result;
          Exit;
        end;}
      {if ((y1>y0) and (x1>x0)) or
         ((y1>y0) and (x1<x0)) then
        begin
          Result+=pi;
          Exit;
        end;
      if ((y1<y0) and (x1>x0)) {or
         ((y1<y0) and (x1<x0))} then
        begin
          Result-=2*pi;
          Exit;
        end;}
    end
  {else
    begin

    end}
end; {$endregion}



(******************************* Fluid Physics ********************************)

constructor TFluid.Create(w,h:integer);                                                                                    {$region -fold}
begin
  pts_dist:=4;
  //
end; {$endregion}
destructor  TFluid.Destroy;                                                                                                {$region -fold}
begin
  self.Free;
  inherited Destroy;
end; {$endregion}
procedure TFluid.WaterWaveParamChg(var param:integer; val1,val2,val3:integer);      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  Dec(param, val1);
  if (param<=val2) then
      param:=val3;
end; {$endregion}
procedure TFluid.WaterWaveParamChg(var param:double;  val1,val2,val3:double );      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  param-=val1;
  if (param<=val2) then
      param:=val3;
end; {$endregion}
procedure TFluid.WaterWaveInit1;                                                            {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  a0 :=256;
  a1 :=128{064};
  a2 :=128;
  a3 :=001;
  a4 :=008;
end; {$endregion}
procedure TFluid.WaterWaveInit2   (var pts:TPtPosFArr; constref start_ind,end_ind:integer); {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  r_x     :=Trunc(pts[start_ind].x);
  r_y     :=Trunc(pts[start_ind].y);
  pts_dist:=Trunc((pts[end_ind-1].x-pts[start_ind].x)/(end_ind-1-start_ind));
  PtsRawH(pts,start_ind,end_ind,pts_dist);
end; {$endregion}
procedure TFluid.WaterWaveInit3   (pt_pos:TPtPosF);                                         {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  r_x:=Trunc(pt_pos.x);
  r_y:=Trunc(pt_pos.y);
end; {$endregion}
procedure TFluid.WaterWave1       (var pts:TPtPosFArr; constref start_ind,end_ind:integer); {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  for i:=start_ind to end_ind-1 do
    pts[i].y:=(a0/a1)*exp((r_x-pts[i].x)/a2)*sin(a3-a4*(r_x-pts[i].x))+r_y;
end; {$endregion}
procedure TFluid.WaterWave2       (pt_pos,shift:TPtPosF; constref step_x,angle:double; constref cnt:integer; constref bmp_dst_ptr:PInteger; constref bmp_dst_width:TColor; constref color_info:TColorInfo; constref rct_clp:TPtRect); {$ifdef Linux}[local];{$endif} {$region -fold}
var
  pt_inc  : TPtPosF;
  pt_rot  : TPtPosF;
  distance: double;
  c       : double =0.0;
  s       : double =0.0;
  v       : double =0.0;
  w       : double =0.0;
  i       : integer=000;
begin
  //distance:=cnt*step_x;
  GetRot(pt_pos,-angle,c,s,v,w);
  pt_inc:=pt_pos;

  Point(Trunc(pt_pos.x{)}+{Trunc(}shift.x),
        Trunc(pt_pos.y{)}+{Trunc(}shift.y),
        bmp_dst_ptr,
        bmp_dst_width,
        color_info,
        rct_clp);

  for i:=1 to cnt-1 do
    begin
      pt_inc.x +=step_x;
      pt_inc.y :=(a0/a1)*exp((r_x-{+}pt_inc.x)/a2)*sin(a3+a4*(r_x-{+}pt_inc.x))+r_y;
      pt_rot.x :=-pt_inc.x*c+pt_inc.y*s+v;
      pt_rot.y :=-pt_inc.y*c-pt_inc.x*s+w;
      Point(Trunc(pt_rot.x{)}+{Trunc(}shift.x),
            Trunc(pt_rot.y{)}+{Trunc(}shift.y),
            bmp_dst_ptr,
            bmp_dst_width,
            color_info,
            rct_clp);
    end;
end; {$endregion}
procedure TFluid.WaterWave3       (pt_pos,shift:TPtPosF; constref step_x,angle:double; constref cnt:integer; constref bmp_dst_ptr:PInteger; constref bmp_dst_width:TColor; constref color_info:TColorInfo; constref rct_clp:TPtRect); {$ifdef Linux}[local];{$endif} {$region -fold}
var
  pt_inc   : TPtPosF;
  pt_rot   : TPtPosF;
  distance : double;
  c        : double =0.0;
  s        : double =0.0;
  v        : double =0.0;
  w        : double =0.0;
  i        : integer=000;
  fade     : byte   =000;
  fade_step: byte   =000;
begin
  fade_step:=Trunc(255/cnt);

  //distance:=cnt*step_x;
  GetRot(pt_pos,-angle,c,s,v,w);
  pt_inc:=pt_pos;

  Inc(fade,fade_step);
  Point(Trunc(pt_pos.x{)}+{Trunc(}shift.x),
        Trunc(pt_pos.y{)}+{Trunc(}shift.y),
        bmp_dst_ptr,
        bmp_dst_width,
        color_info,
        rct_clp,
        fade);

  for i:=1 to cnt-1 do
    begin
      Inc(fade,fade_step);
      pt_inc.x +=step_x;
      pt_inc.y :=(a0/a1)*exp((r_x-{+}pt_inc.x)/a2)*sin(a3+a4*(r_x-{+}pt_inc.x))+r_y;
      pt_rot.x :=-pt_inc.x*c+pt_inc.y*s+v;
      pt_rot.y :=-pt_inc.y*c-pt_inc.x*s+w;
      Point(Trunc(pt_rot.x{)}+{Trunc(}shift.x),
            Trunc(pt_rot.y{)}+{Trunc(}shift.y),
            bmp_dst_ptr,
            bmp_dst_width,
            color_info,
            rct_clp,
            fade);
    end;
end; {$endregion}



(******************************** Hair Physics ********************************)

{TODO}



(********************************** Particles *********************************)

// Simple Particle Spline Emitter:
procedure PtlEmitterSln(constref pt_cnt:integer; constref pt_pos:TPtPos; constref pos_shift_rad:integer; constref sln_pts_:TPtPosFArr; var ind:integer; constref start_ind,end_ind:integer; constref bckgd_stngs:TBckgdStngs; constref color_info:TColorInfo; constref start_rad,start_pow:integer); {$region -fold}
var
  i: integer;
begin
  for i:=0 to pt_cnt-1 do
    CircleHighlight(pt_pos.x+Random(pos_shift_rad),
                    pt_pos.y+Random(pos_shift_rad),
                    bckgd_stngs.bmp_dst_ptr,
                    bckgd_stngs.rct_clp,
                    bckgd_stngs.bmp_dst_width,
                    color_info,
                    start_rad,
                    start_pow);
  if (ind=end_ind) then
    ind:=start_ind
  else
    Inc(ind);
end; {$endregion}



(******************************* Fading Effects *******************************)

procedure CngGrad(var pos0,pos1,grad_rng_val_curr,grad_rng_val_next:TColor; var time_inc,time_shift:double; grad_prop:TGradProp); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  y_grad_rng_div_vec: TColor3RGB;
begin
  with grad_prop do
    begin
          y_grad_rng_div_vec.r:=r0<<16;
          y_grad_rng_div_vec.g:=g0<<16;
          y_grad_rng_div_vec.b:=b0<<16;
            grad_rng_val_curr :=RGB(
          y_grad_rng_div_vec.b>>16,
          y_grad_rng_div_vec.g>>16,
          y_grad_rng_div_vec.r>>16);
      Inc(y_grad_rng_div_vec.r,
            grad_rng_div_vec_r);
      Inc(y_grad_rng_div_vec.g,
            grad_rng_div_vec_g);
      Inc(y_grad_rng_div_vec.b,
            grad_rng_div_vec_b);
    end;
  {if time_inc
    SetGradProp(grad_prop,pos0,pos1,grad_rng_val_curr,grad_rng_val_next);}
end; {$endregion}
procedure FadeTemplate0(constref time_interval1,time_interval2,time_interval3:integer; var col_trans_arr_val:byte; var time_interval:integer); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  time_interval+=1;
  if (time_interval< time_interval1                   )                                                                      then
    col_trans_arr_val:=255
  else
  if (time_interval>=time_interval1                   ) and (time_interval<time_interval1+127                              ) then
    col_trans_arr_val-=2
  else
  if (time_interval>=time_interval1+127               ) and (time_interval<time_interval1+127+time_interval2               ) then
    col_trans_arr_val:=0
  else
  if (time_interval>=time_interval1+127+time_interval2) and (time_interval<time_interval1+254+time_interval2               ) then
    col_trans_arr_val+=2
  else
  if (time_interval>=time_interval1+254+time_interval2) and (time_interval<time_interval1+254+time_interval2+time_interval3) then
    col_trans_arr_val:=255
  else
    time_interval:=0;
end; {$endregion}
procedure FadeTemplate1(constref time_interval1,time_interval2,time_interval3:integer; var col_trans_arr_val:byte; var time_interval:integer); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  time_interval+=1;
  if (time_interval< time_interval1                   )                                                                      then
    col_trans_arr_val:=0
  else
  if (time_interval>=time_interval1                   ) and (time_interval<time_interval1+127                              ) then
    col_trans_arr_val+=2
  else
  if (time_interval>=time_interval1+127               ) and (time_interval<time_interval1+127+time_interval2               ) then
    col_trans_arr_val:=255
  else
  if (time_interval>=time_interval1+127+time_interval2) and (time_interval<time_interval1+254+time_interval2               ) then
    col_trans_arr_val-=2
  else
  if (time_interval>=time_interval1+254+time_interval2) and (time_interval<time_interval1+254+time_interval2+time_interval3) then
    col_trans_arr_val:=0
  else
    time_interval:=0;
end; {$endregion}
// Ping-Pong(Linear Interpolation):
procedure FXAnimPingPong(var fx_inc_check:boolean; constref fx_inc_val,fx_dec_val:single; var fx:single; constref fx_min_val,fx_max_val:single); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  if fx_inc_check then
    fx+=fx_inc_val
  else
    fx-=fx_dec_val;
  if (fx<=fx_min_val) then
    begin
      fx_inc_check:=True;
      fx          :=fx_min_val;
    end
  else
  if (fx>=fx_max_val) then
    begin
      fx_inc_check:=False;
      fx          :=fx_max_val;
    end;
end; {$endregion}

end.


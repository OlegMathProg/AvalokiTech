unit Scene_Tree;

{This file contains some routines for scene object manager}

{$mode objfpc}{$H+}

interface

uses

  Classes, Fast_Primitives;

type

  TSceneTree   =class;

  TLayerType   =(ltStatic,ltDynamic);
  PLayerType   =^TLayerType;

  TKindOfObject=(kooBckgd,kooBkTex,kooRGrid,kooSGrid,kooGroup,kooTlMap,kooActor,kooPrtcl,kooCurve);
  PKindOfObject=^TKindOfObject;

  TPosShiftType=(pstAll,pstChildren);
  PPosShiftType=^TPosShiftType;

  TBckgdProp   =packed record {$region -fold}
    bckgd_obj_ind: integer;
  end; {$endregion}
  PBckgdProp   =^TBckgdProp;

  TBkTexProp   =packed record {$region -fold}
    bktex_obj_ind: integer;
  end; {$endregion}
  PBkTexProp   =^TBkTexProp;

  TRGridProp   =packed record {$region -fold}
    rgrid_obj_ind: integer;
  end; {$endregion}
  PRGridProp   =^TRGridProp;

  TSGridProp   =packed record {$region -fold}
    sgrid_obj_ind: integer;
  end; {$endregion}
  PSGridProp   =^TSGridProp;

  TGroupProp   =packed record {$region -fold}
    group_obj_ind: integer;
    children_cnt : integer;
  end; {$endregion}
  PGroupProp   =^TGroupProp;

  TTlMapProp   =packed record {$region -fold}
    tlmap_obj_ind: integer;
  end; {$endregion}
  PTlMapProp   =^TTlMapProp;

  TActorProp   =packed record {$region -fold}
    actor_obj_ind: integer;
  end; {$endregion}
  PActorProp   =^TActorProp;

  TPrtclProp   =packed record {$region -fold}
    prtcl_obj_ind: integer;
  end; {$endregion}
  PPrtclProp   =^TPrtclProp;

  TNodeData    =packed record {$region -fold}
    kind_of_object: TKindOfObject;
    case TKindOfObject of
      kooBckgd: (bckgd_prop: TBckgdProp);
      kooBkTex: (bktex_prop: TBkTexProp);
      kooRGrid: (rgrid_prop: TRGridProp);
      kooSGrid: (sgrid_prop: TSGridProp);
      kooGroup: (group_prop: TGroupProp);
      kooTlMap: (tlmap_prop: TTlMapProp);
      kooActor: (actor_prop: TActorProp);
      kooPrtcl: (prtcl_prop: TPrtclProp);
      kooCurve: (curve_prop: TCurveProp);
  end; {$endregion}
  PNodeData    =^TNodeData;

  TObjInfo     =packed record {$region -fold}
    // background (bitmap destination) handle:
    bckgd_ptr                : PInteger;
    // background (bitmap destination) width:
    bckgd_width              : integer;
    // background (bitmap destination) height:
    bckgd_height             : integer;
    // (local)  position of an object inside kind of object:
    k_ind                    : integer;
    // animation type of object:
    anim_type                : TLayerType;
    // kind of object: spline, actor,...etc.:
    koo                      : TKindOfObject;
    // show object in scene:
    obj_show                 : boolean;
    // is object abstract or drawable in scene:
    abstract                 : boolean;
    // is another  kind of object is available after current object:
    is_another_obj_kind_after: boolean;
    // is abstract kind of object is available after current object:
    is_an_abst_obj_kind_after: boolean;
  end; {$endregion}
  PObjInfo     =^TObjInfo;

  TSceneTree   =class {$region -fold}
    public
      //
      obj_arr       : array of TObjInfo;
      //
      FilProc       : array of TProc0;
      //
      MovProc       : array of TProc0;
      //
      group_inds_arr: array of integer;
      //
      tlmap_inds_arr: array of integer;
      //
      actor_inds_arr: array of integer;
      //
      prtcl_inds_arr: array of integer;
      //
      curve_inds_arr: array of integer;
      //
      group_cnt     : integer;
      //
      tlmap_cnt     : integer;
      //
      actor_cnt     : integer;
      //
      prtcl_cnt     : integer;
      //
      curve_cnt     : integer;
      //
      group_inds_cnt: integer;
      //
      tlmap_inds_cnt: integer;
      //
      actor_inds_cnt: integer;
      //
      prtcl_inds_cnt: integer;
      //
      curve_inds_cnt: integer;
      // current object index:
      curr_obj_ind  : integer;
      // count of all objects in scene:
      obj_cnt       : integer;
      //
      group_selected: boolean;
      //
      tlmap_selected: boolean;
      //
      actor_selected: boolean;
      //
      prtcl_selected: boolean;
      //
      curve_selected: boolean;
      //
      constructor Create;                                                                 {$ifdef Linux}[local];{$endif}
      destructor  Destroy;                                                      override; {$ifdef Linux}[local];{$endif}
      procedure FilEmpty;                                                         inline; {$ifdef Linux}[local];{$endif}
      procedure FilBckgd;                                                         inline; {$ifdef Linux}[local];{$endif}
      procedure FilBkTex;                                                         inline; {$ifdef Linux}[local];{$endif}
      procedure FilRGrid;                                                         inline; {$ifdef Linux}[local];{$endif}
      procedure FilSGrid;                                                         inline; {$ifdef Linux}[local];{$endif}
      procedure FilGroup;                                                         inline; {$ifdef Linux}[local];{$endif}
      procedure FilTlMap;                                                         inline; {$ifdef Linux}[local];{$endif}
      procedure FilActor;                                                         inline; {$ifdef Linux}[local];{$endif}
      procedure FilPrtcl;                                                         inline; {$ifdef Linux}[local];{$endif}
      procedure FilCurve;                                                         inline; {$ifdef Linux}[local];{$endif}
      procedure MovCurve;                                                         inline; {$ifdef Linux}[local];{$endif}
      procedure FilScene;                                                         inline; {$ifdef Linux}[local];{$endif}
      procedure Add                  (constref koo          :TKindOfObject;
                                      constref k_ind        :integer;
                                      constref obj_show     :boolean=True);       inline; {$ifdef Linux}[local];{$endif}
      procedure SetObjBckgd          (constref obj_arr_ptr  :PObjInfo;
                                      constref bckgd_ptr    :PInteger;
                                      constref bckgd_width,
                                               bckgd_height :integer;
                                      constref rct_clp      :TPtRect);            inline; {$ifdef Linux}[local];{$endif}
      function  ObjIndByKInd         (constref koo          :TKindOfObject;
                                      constref k_ind        :integer): integer;   inline; {$ifdef Linux}[local];{$endif}
      function  IsAnotherObjKindAfter(constref koo          :TKindOfObject;
                                      constref start_ind    :integer=0): boolean; inline; {$ifdef Linux}[local];{$endif}
      function  IsNotAbstObjKindAfter(constref koo          :TKindOfObject;
                                      constref start_ind    :integer=0): boolean; inline; {$ifdef Linux}[local];{$endif}
      // check equality of two objects by kind:
      function  AreTwoObjKindEqual   (constref obj_ind1,
                                               obj_ind2     :integer)  : boolean; inline; {$ifdef Linux}[local];{$endif}
      // check equality of all objects with current object by kind:
      procedure CmpAllObjKindEqual   (constref obj_ind      :integer);            inline; {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PSceneTree   =^TSceneTree;

var

  {Object Properties}
  bckgd_prop: TBckgdProp;
  bktex_prop: TBkTexProp;
  rgrid_prop: TRGridProp;
  sgrid_prop: TSGridProp;
  group_prop: TGroupProp;
  tlmap_prop: TTlMapProp;
  actor_prop: TActorProp;
  prtcl_prop: TPrtclProp;
  curve_prop: TCurveProp;

  {Object Default Properties}
  bckgd_default_prop: TBckgdProp={$region -fold}
  (
    bckgd_obj_ind: 0;
  ); {$endregion}
  bktex_default_prop: TBkTexProp={$region -fold}
  (
    bktex_obj_ind: 0;
  ); {$endregion}
  rgrid_default_prop: TRGridProp={$region -fold}
  (
    rgrid_obj_ind: 0;
  ); {$endregion}
  sgrid_default_prop: TSGridProp={$region -fold}
  (
    sgrid_obj_ind: 0;
  ); {$endregion}
  group_default_prop: TGroupProp={$region -fold}
  (
    group_obj_ind: 0;
    children_cnt : 0;
  ); {$endregion}
  tlmap_default_prop: TTlMapProp={$region -fold}
  (
    tlmap_obj_ind: 0
  ); {$endregion}
  actor_default_prop: TActorProp={$region -fold}
  (
    actor_obj_ind: 0
  ); {$endregion}
  prtcl_default_prop: TPrtclProp={$region -fold}
  (
    prtcl_obj_ind: 0
  ); {$endregion}
  curve_default_prop: TCurveProp={$region -fold}
  (
    dup_pts_id            : (arr:(0,0,0,0,0,0); obj_ind:-1; dup_pts_cnt:0; weight:0);
    curve_obj_ind         : 0;
    pts_cnt               : 0;
    pts_cnt_val           : 1;
    eds_smpl_angle        : 2.0;

    eds_col_ptr           : Nil;
    eds_col               : $00BF923E;
    eds_col_inv           : $00998F77{SetColorInv(eds_col)};
    eds_col_rnd           : False;
    eds_col_fall_off      : False;
    eds_col_fall_off_inc  : 1;
    eds_width             : 1;
    eds_width_half        : 0;
    eds_width_odd         : 0;
    eds_aa                : True;

    pts_col_ptr           : Nil;
    pts_col               : $004B3918;
    pts_col_inv           : $00998F77{SetColorInv(pts_col)};
    pts_col_rnd           : False;
    pts_col_fall_off      : False;
    pts_col_fall_off_inc  : 1;

    pts_width             : 5;
    pts_width__half       : 2;
    pts_width__odd        : 0;
    pts_height            : 5;
    pts_height_half       : 2;
    pts_height_odd        : 0;

    {rectangle}
    rct_val_arr           : (-2,-2,2,-1,2);
    pts_rct_width         : 5;
    pts_rct_width__half   : 2;
    pts_rct_width__odd    : 0;
    pts_rct_height        : 5;
    pts_rct_height_half   : 2;
    pts_rct_height_odd    : 0;
    pts_rct_tns_left      : 1;
    pts_rct_tns_top       : 1;
    pts_rct_tns_right     : 1;
    pts_rct_tns_bottom    : 1;
    pts_rct_inn_width     : 3;
    pts_rct_inn_width__odd: 1;
    pts_rct_inn_height    : 3;
    pts_rct_inn_height_odd: 1;

    {circle}
    pts_crc_diam_inn      : 5;
    pts_crc_diam_inn_half : 2;
    pts_crc_diam_out      : 5;
    pts_crc_diam_out_half : 2;

    {polygon}
    pts_plg_diam          : 5;
    pts_plg_diam_half     : 2;
    pts_plg_ang_cnt       : 3;

    {sprite}
    pts_srt_width         : 5;
    pts_srt_height        : 5;

    sln_pts_frq           : 12;
    sln_type              : stLinear;
    sln_mode              : smContinuous;
    eds_bld_stl           : dsMonochrome;
    pts_bld_stl           : dsAlphaBlend;
    clp_stl               : csClippedEdges1;
    eds_lod               : False;
    hid_ln_elim           : True;
    lazy_repaint          : True;
    lazy_repaint_prev     : False;
    rct_eds_show          : False;
    rct_pts_show          : False;
    eds_show              : False;
    pts_show              : False;
    cnc_ends              : False;
    pts_ord_inv           : False;
    is_out_of_wnd         : False;

    fml_type              : sfCycloid;

    {Cycloid}
    cycloid_loop_rad      : 64;
    cycloid_loop_cnt      : 3;
    cycloid_pts_cnt       : 256;
    cycloid_curvature     : 1.0;
    cycloid_dir_x         : mdRight;
    cycloid_dir_y         : mdUp;

    {Epicycloid}
    epicycloid_angle      : 360.0;
    epicycloid_rot        : 000.0;
    epicycloid_rad        : 256;
    epicycloid_petals_cnt : 8;
    epicycloid_pts_cnt    : 256;

    {Rose}

    {Spiral}

    {Superellipse}

  ); {$endregion}

implementation

uses

  Main;

constructor TSceneTree.Create;                                                                                                                                                         {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
destructor  TSceneTree.Destroy;                                                                                                                                                        {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  self.Free;
  inherited Destroy;
end; {$endregion}
procedure   TSceneTree.FilEmpty;                                                                                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.FilBckgd;                                                                                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  srf_var_inst_ptr: PSurf=Nil;
begin
  srf_var_inst_ptr:=@srf_var;
  srf_var_inst_ptr^.FilBckgdObj;
end; {$endregion}
procedure   TSceneTree.FilBkTex;                                                                                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  tex_var_inst_ptr: PTex=Nil;
begin
  tex_var_inst_ptr:=@tex_var;
  tex_var_inst_ptr^.FilBkTexObj;
end; {$endregion}
procedure   TSceneTree.FilRGrid;                                                                                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rgrd_var_inst_ptr: PRGrid=Nil;
begin
  rgrd_var_inst_ptr:=@rgr_var;
  rgrd_var_inst_ptr^.FilRGridObj;
end; {$endregion}
procedure   TSceneTree.FilSGrid;                                                                                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sgrd_var_inst_ptr: PSGrid=Nil;
begin
  sgrd_var_inst_ptr:=@sgr_var;
  sgrd_var_inst_ptr^.FilSGridObj;
end; {$endregion}
procedure   TSceneTree.FilGroup;                                                                                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.FilTlMap;                                                                                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.FilActor;                                                                                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.FilPrtcl;                                                                                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.FilCurve;                                                                                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sln_var_inst_ptr: PCurve=Nil;
begin
  sln_var_inst_ptr:=Unaligned(@sln_var);
  sln_var_inst_ptr^.FilSplineObj(obj_arr[curr_obj_ind].k_ind);
end; {$endregion}
procedure   TSceneTree.MovCurve;                                                                                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sln_var_inst_ptr: PCurve=Nil;
begin
  {sln_var_inst_ptr:=@sln_var;
  sln_var_inst_ptr^.MovSplineObj(obj_arr[curr_obj_ind].k_ind,...);}
end; {$endregion}
procedure   TSceneTree.FilScene;                                                                                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  FilProcPtr: PProc0;
  i         : integer;
begin
  if (obj_cnt=0) then
    Exit;
  FilProcPtr:=Unaligned(@FilProc[0]);
  curr_obj_ind:=0;
  for i:=0 to obj_cnt-1 do
    begin
      FilProcPtr^;
      Inc(FilProcPtr);
      Inc(curr_obj_ind);
    end;
end; {$endregion}
procedure   TSceneTree.Add                  (constref koo:TKindOfObject; constref k_ind:integer; constref obj_show:boolean=True);                                              inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  Inc(obj_cnt);
  //Inc(curr_obj_ind);
  SetLength(obj_arr,obj_cnt);
  SetLength(FilProc,obj_cnt);
  obj_arr[obj_cnt-1].k_ind   :=k_ind;
  obj_arr[obj_cnt-1].koo     :=koo;
  obj_arr[obj_cnt-1].obj_show:=obj_show;
  case koo of
    kooBckgd: FilProc[obj_cnt-1]:=Unaligned(@FilBckgd);
    kooBkTex: FilProc[obj_cnt-1]:=Unaligned(@FilBkTex);
    kooRGrid: FilProc[obj_cnt-1]:=Unaligned(@FilRGrid);
    kooSGrid: FilProc[obj_cnt-1]:=Unaligned(@FilSGrid);
    kooGroup:
      begin
        obj_arr[obj_cnt-1].abstract:=True;
        FilProc[obj_cnt-1]:=Unaligned(@FilGroup);
        Inc(group_cnt);
        SetLength(group_inds_arr,group_cnt);
      end;
    kooTlMap:
      begin
        obj_arr[obj_cnt-1].abstract:=False;
        FilProc[obj_cnt-1]:=Unaligned(@FilTlMap);
        Inc(tlmap_cnt);
        SetLength(tlmap_inds_arr,tlmap_cnt);
      end;
    kooActor:
      begin
        obj_arr[obj_cnt-1].abstract:=False;
        FilProc[obj_cnt-1]:=Unaligned(@FilActor);
        Inc(actor_cnt);
        SetLength(actor_inds_arr,actor_cnt);
      end;
    kooPrtcl:
      begin
        obj_arr[obj_cnt-1].abstract:=False;
        FilProc[obj_cnt-1]:=Unaligned(@FilPrtcl);
        Inc(prtcl_cnt);
        SetLength(prtcl_inds_arr,prtcl_cnt);
      end;
    kooCurve:
      begin
        obj_arr[obj_cnt-1].abstract:=False;
        FilProc[obj_cnt-1]:=Unaligned(@FilCurve);
        Inc(curve_cnt);
        SetLength(curve_inds_arr,curve_cnt);
      end;
  end;
  CmpAllObjKindEqual(obj_cnt-1);
end; {$endregion}
procedure   TSceneTree.SetObjBckgd          (constref obj_arr_ptr:PObjInfo; constref bckgd_ptr:PInteger; constref bckgd_width,bckgd_height:integer; constref rct_clp:TPtRect); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  obj_arr_ptr^.bckgd_ptr   :=bckgd_ptr   ;
  obj_arr_ptr^.bckgd_width :=bckgd_width ;
  obj_arr_ptr^.bckgd_height:=bckgd_height;
//obj_arr_ptr.rct_clp      :=rct_clp     ;
end; {$endregion}
// (Find An Object Index by Position(k_ind) in Object Group) Найти индекс обьекта по позиции(k_ind) в группе обьектов:
function    TSceneTree.ObjIndByKInd         (constref koo:TKindOfObject; constref k_ind:integer): integer;                                                                     inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
  i          : integer;
begin
  Result     :=0;
  obj_arr_ptr:=Unaligned(@obj_arr[0]);
  for i:=0 to obj_cnt-1 do
    if ((obj_arr_ptr+i)^.koo  =koo  ) and
       ((obj_arr_ptr+i)^.k_ind=k_ind) then
      begin
        Result:=i;
        Break;
      end;
end; {$endregion}
// (Checks If Another Kind Of Object Is Available After Selected Object(From start_ind) In Objects array(obj_arr)) Проверяет есть ли другой вид обьектов после выбранного(начиная с start_ind) в массиве обьектов(obj_arr):
function    TSceneTree.IsAnotherObjKindAfter(constref koo:TKindOfObject; constref start_ind:integer=0): boolean;                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
  i          : integer;
begin
  Result     :=False;
  obj_arr_ptr:=Unaligned(@obj_arr[0]);
  for i:=start_ind to Length(obj_arr)-1 do
    if ((obj_arr_ptr+i)^.koo<>koo) then
      begin
        Result:=True;
        Break;
      end;
end; {$endregion}
function    TSceneTree.IsNotAbstObjKindAfter(constref koo:TKindOfObject; constref start_ind:integer=0): boolean;                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr: PObjInfo;
  i          : integer;
begin
  Result     :=False;
  obj_arr_ptr:=Unaligned(@obj_arr[0]);
  for i:=start_ind to Length(obj_arr)-1 do
    if ((obj_arr_ptr+i)^.koo<>koo) and (not (obj_arr_ptr+i)^.abstract) then
        begin
          Result:=True;
          Break;
        end;
end; {$endregion}
// (Check Equality Of Two Objects By Kind) Проверка на равенство двух обьектов по виду:
function    TSceneTree.AreTwoObjKindEqual   (constref obj_ind1,obj_ind2:integer): boolean;                                                                                     inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  Result:=(obj_arr[obj_ind1].koo=obj_arr[obj_ind2].koo);
end; {$endregion}
// (Check Equality Of All Objects With Current Object By Kind) Проверка на равенство всех обьектов c текущим обьектом по виду:
procedure   TSceneTree.CmpAllObjKindEqual   (constref obj_ind          :integer);                                                                                              inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr2: PObjInfo;
  obj_arr_ptr : PObjInfo;
  i           : integer;
begin
  if (obj_ind=0) and (obj_cnt=1) then
    begin
      obj_arr[0].is_another_obj_kind_after:=False;
      obj_arr[0].is_an_abst_obj_kind_after:=False;
      Exit;
    end;
  obj_arr_ptr2:=Unaligned(@obj_arr[obj_ind]);
  obj_arr_ptr :=Unaligned(@obj_arr[0000000]);
  for i:=0 to obj_ind-2 do
    begin
      (obj_arr_ptr+i)^.is_another_obj_kind_after:=((obj_arr_ptr+i)^.koo     =obj_arr_ptr2^.koo);
      (obj_arr_ptr+i)^.is_an_abst_obj_kind_after:=((obj_arr_ptr+i)^.abstract=True);
    end;
end; {$endregion}


end.

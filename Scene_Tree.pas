unit Scene_Tree;

{This file contains some routines for scene object manager}

{$mode objfpc}{$H+}

interface

uses

  Classes, Fast_Primitives;

type

  TSceneTree    =class;

  TLayerType    =(ltStatic,ltDynamic);
  PLayerType    =^TLayerType;

  TKindOfObject =(kooEmpty,kooBkgnd,kooBkTex,kooRGrid,kooSGrid,kooGroup,kooTlMap,kooActor,kooPrtcl,kooCurve,kooFText,kooMiscellaneous);
  PKindOfObject =^TKindOfObject;

  TObjShow      =(osfInvisible,osfOnlyEditorVisible,osfOnlyRenderVisible,osfEditorRenderVisible);
  PObjShow      =^TObjShow;

  TPosShiftType =(pstAll,pstChildren);
  PPosShiftType =^TPosShiftType;

  TBkgndProp    =packed record {$region -fold}
    bckgd_obj_ind: TColor;
  end; {$endregion}
  PBkgndProp    =^TBkgndProp;

  TBkTexProp    =packed record {$region -fold}
    bktex_obj_ind: TColor;
  end; {$endregion}
  PBkTexProp    =^TBkTexProp;

  TRGridProp    =packed record {$region -fold}
    rgrid_obj_ind: TColor;
  end; {$endregion}
  PRGridProp    =^TRGridProp;

  TSGridProp    =packed record {$region -fold}
    sgrid_obj_ind: TColor;
  end; {$endregion}
  PSGridProp    =^TSGridProp;

  TGroupProp    =packed record {$region -fold}
    group_obj_ind: TColor;
    children_cnt : TColor;
  end; {$endregion}
  PGroupProp    =^TGroupProp;

  TTlMapProp    =packed record {$region -fold}
    tlmap_obj_ind: TColor;
  end; {$endregion}
  PTlMapProp    =^TTlMapProp;

  TActorProp    =packed record {$region -fold}
    actor_obj_ind: TColor;
  end; {$endregion}
  PActorProp    =^TActorProp;

  TPrtclProp    =packed record {$region -fold}
    prtcl_obj_ind: TColor;
  end; {$endregion}
  PPrtclProp    =^TPrtclProp;

  TObjInfo      =       record {$region -fold} {must be unpacked - its important!!!}
    // background (bitmap destination) handle:
    bkgnd_ptr                : PInteger;
    // background (bitmap destination) width:
    bkgnd_width              : TColor;
    // background (bitmap destination) height:
    bkgnd_height             : TColor;
    // outter clipping rectangle:
    rct_clp_ptr              : PPtRect;
    // destination(clipped by outter clipping rectangle) rectangle:
    rct_dst_ptr              : PPtRect;
    // (global) position of an object inside object array:
    g_ind                    : TColor;
    // (local ) position of an object inside kind of object:
    k_ind                    : TColor;
    // (global) position of an object inside scene tree:
    t_ind                    : TColor;
    // animation type of object:
    anim_type                : TLayerType;
    // kind of object: spline, actor,...etc.:
    koo                      : TKindOfObject;
    // is object visible:
    // 0 -   visible in editor,   visible in game;
    // 1 -   visible in editor, invisible in game;
    // 2 - invisible in editor,   visible in game;
    // 3 - invisible in editor, invisible in game;
    // 4 - 0 or 1;
    // 5 - 0 or 2;
    obj_show                 : byte;
    // is object abstract(for example prefab/null/group) or drawable in scene:
    abstract                 : boolean;
    // is object in low(static) layer:
    is_low_lr_obj            : boolean;
    // does object allow to move itself:
    movable                  : boolean;
    // does object allow to scale itself:
    scalable                 : boolean;
    // does object allow to rotate itself:
    rotatable                : boolean;
    // is another  kind of object is available after current object:
    is_another_obj_kind_after: boolean;
    // is abstract kind of object is available after current object:
    is_an_abst_obj_kind_after: boolean;
    // forced repaint:
    forced_repaint           : boolean;
    // local axis:
    local_axis               : TPtPos;
    // parallax:
    world_axis_shift         : TPtPos;
    parallax_shift           : TPtPos;
    // distance between world axis and local axis:
    obj_dist1                : TColor;
    // distance between camera and current object:
    obj_dist2                : TColor;
  end; {$endregion}
  PObjInfo      =^TObjInfo;

  TSceneTree    =class         {$region -fold}
    public
      global_prop       : TObjInfo;
      //
      obj_arr           : array of TObjInfo;
      //
      FilProc           : array of TProc0;
      //
      MovProc           : array of TProc0;
      // array of objects indices inside of object array:
      obj_inds_arr      : TColorArr;
      // array of selected objects indices inside of scene tree:
      sel_inds_arr      : TColorArr;

      {array of indices inside of object array} {$region -fold}
      empty_inds_obj_arr: TColorArr;
      bkgnd_inds_obj_arr: TColorArr;
      bktex_inds_obj_arr: TColorArr;
      rgrid_inds_obj_arr: TColorArr;
      sgrid_inds_obj_arr: TColorArr;
      group_inds_obj_arr: TColorArr;
      tlmap_inds_obj_arr: TColorArr;
      actor_inds_obj_arr: TColorArr;
      prtcl_inds_obj_arr: TColorArr;
      curve_inds_obj_arr: TColorArr;
      ftext_inds_obj_arr: TColorArr; {$endregion}

      {array of indices inside of scene tree--} {$region -fold}
      empty_inds_sct_arr: TColorArr;
      bkgnd_inds_sct_arr: TColorArr;
      bktex_inds_sct_arr: TColorArr;
      rgrid_inds_sct_arr: TColorArr;
      sgrid_inds_sct_arr: TColorArr;
      group_inds_sct_arr: TColorArr;
      tlmap_inds_sct_arr: TColorArr;
      actor_inds_sct_arr: TColorArr;
      prtcl_inds_sct_arr: TColorArr;
      curve_inds_sct_arr: TColorArr;
      ftext_inds_sct_arr: TColorArr; {$endregion}

      {count of items-------------------------} {$region -fold}
      empty_cnt         : TColor;
      bkgnd_cnt         : TColor;
      bktex_cnt         : TColor;
      rgrid_cnt         : TColor;
      sgrid_cnt         : TColor;
      group_cnt         : TColor;
      tlmap_cnt         : TColor;
      actor_cnt         : TColor;
      prtcl_cnt         : TColor;
      curve_cnt         : TColor;
      ftext_cnt         : TColor; {$endregion}

      // current object index:
      curr_obj_ind      : TColor;
      // count of all objects in scene:
      obj_cnt           : TColor;
      // kind of selected objects:
      sel_koo           : TKindOfObject;
      // count of selected objects in scene:
      sel_cnt           : TColor;
      // lower layer objects count:
      low_lr_obj_cnt    : TColor;
      // upper
      upp_lr_obj_cnt    : TColor;
      // index of first selected node in scene tree:
      first_sel_node_ind: integer;
      // is item with children in scene tree:
      has_it_with_ch    : boolean;

      // count of selected objects of "Groups":
      group_selected    : boolean;
      // count of selected objects of "Tile Map":
      tlmap_selected    : boolean;
      // count of selected objects of "Actors":
      actor_selected    : boolean;
      // count of selected objects of "Particles":
      prtcl_selected    : boolean;
      // count of selected objects of "Splines"("Curves"):
      curve_selected    : boolean;
      // count of selected objects of "FText":
      ftext_selected    : boolean;

      // reserved:
      res_var_ptr       : PBoolean;

      constructor Create;                                                                     {$ifdef Linux}[local];{$endif}
      destructor  Destroy;                                                          override; {$ifdef Linux}[local];{$endif}

      procedure FilEmpty;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure FilBkgnd;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure FilBkTex;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure FilRGrid;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure FilSGrid;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure FilGroup;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure FilTlMap;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure FilActor;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure FilPrtcl;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure FilCurve;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure FilFText;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure FilScene              (         start_ind,
                                                end_ind          :TColor);            inline; {$ifdef Linux}[local];{$endif}
      procedure MovEmpty;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure MovBkgnd;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure MovBkTex;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure MovRGrid;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure MovSGrid;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure MovGroup;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure MovTlMap;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure MovActor;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure MovPrtcl;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure MovCurve;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure MovFText;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure MovScene              (         start_ind,
                                                end_ind          :TColor);            inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftRight;                                               inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftLeft;                                                inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftDown;                                                inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftUp;                                                  inline; {$ifdef Linux}[local];{$endif}
      procedure SetWorldAxisShift     (         world_axis_shift_:TPtPos);            inline; {$ifdef Linux}[local];{$endif}
      procedure SetParallaxShift      (         parallax_shift_  :TPtPos);            inline; {$ifdef Linux}[local];{$endif}
      procedure SetRctDstPtr          (         rct_dst_ptr_     :PPtRect;
                                                start_ind,
                                                end_ind          :TColor);            inline; {$ifdef Linux}[local];{$endif}
      procedure SetFilMovProc         (         abstract_        :boolean;
                                                FilProc_,
                                                MovProc_         :TProc0;
                                       var      obj_cnt_         :TColor;
                                       var      inds_obj_arr_,
                                                inds_sct_arr_    :TColorArr);         inline; {$ifdef Linux}[local];{$endif}
      procedure Add                   (constref koo              :TKindOfObject;
                                       constref world_axis_shift_:TPtPos);            inline; {$ifdef Linux}[local];{$endif}
      procedure SetObjBkgnd           (         obj_arr_ptr      :PObjInfo;
                                       constref bkgnd_ptr        :PInteger;
                                       constref bkgnd_width,
                                                bkgnd_height     :TColor;
                                       constref rct_clp_ptr      :PPtRect);           inline; {$ifdef Linux}[local];{$endif}
      procedure SetObjBkgnd           (constref bkgnd_ptr        :PInteger;
                                       constref bkgnd_width,
                                                bkgnd_height     :TColor;
                                       constref rct_clp_ptr      :PPtRect;
                                                start_ind,
                                                end_ind          :TColor);            inline; {$ifdef Linux}[local];{$endif}
      // (Checks If Another Kind Of Object Is Available After Selected Object(From start_ind) In Objects array(obj_arr)) Проверяет есть ли другой вид обьектов после выбранного(начиная с start_ind) в массиве обьектов(obj_arr):
      function  IsAnotherObjKindAfter1(constref koo              :TKindOfObject;
                                       constref start_ind        :TColor=0): boolean; inline; {$ifdef Linux}[local];{$endif}
      function  IsAnotherObjKindAfter2(constref start_ind        :TColor=0): boolean; inline; {$ifdef Linux}[local];{$endif}
      function  IsAnotherObjKindAfter3(constref koo              :TKindOfObject;
                                       constref start_ind        :TColor=0): boolean; inline; {$ifdef Linux}[local];{$endif}
      function  IsAnotherObjKindAfter4(constref koo              :TKindOfObject;
                                       constref start_ind        :TColor=0): boolean; inline; {$ifdef Linux}[local];{$endif}
      // (Calculate Low Layer Objects Count) Подсчет количества обьектов нижнего слоя:
      function  LowLrObjCntCalc1: TColor;                                             inline; {$ifdef Linux}[local];{$endif}
      procedure LowLrObjCntCalc2;                                                     inline; {$ifdef Linux}[local];{$endif}
      // (Check Equality Of Two Objects By Kind) Проверка на равенство двух обьектов по виду:
      function  AreTwoObjKindEqual    (constref obj_ind1,
                                                obj_ind2         :TColor): boolean;   inline; {$ifdef Linux}[local];{$endif}
      //
      function  Min9                  (constref obj_inds_arr_    :TColorArr;
                                       constref arr              :TEdgeArr;
                                       constref max_item_val     :TColor;
                                       constref item_cnt         :TColor): TColor;    inline; {$ifdef Linux}[local];{$endif}
      function  Min9                  (constref obj_inds_arr_    :TColorArr;
                                       constref arr              :TSlPtArr;
                                       constref max_item_val     :TColor;
                                       constref item_cnt         :TColor): TColor;    inline; {$ifdef Linux}[local];{$endif}
      // (Bounding Rectangle of Points Set) Ограничиваюший прямоугольник множества точек:
      function  PtsRngIndsRctCalc     (constref pts              :TPtPosFArr;
                                       constref sel_pts_inds     :TColorArr;
                                       constref pts_cnt          :TColor): TPtRectF;  inline; {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PSceneTree    =^TSceneTree;

  TNodeData     =packed record {$region -fold}
    g_ind: TColor;
    {case TKindOfObject of
      kooBckgd: (bckgd_prop: TBckgdProp);
      kooBkTex: (bktex_prop: TBkTexProp);
      kooRGrid: (rgrid_prop: TRGridProp);
      kooSGrid: (sgrid_prop: TSGridProp);
      kooGroup: (group_prop: TGroupProp);
      kooTlMap: (tlmap_prop: TTlMapProp);
      kooActor: (actor_prop: TActorProp);
      kooPrtcl: (prtcl_prop: TPrtclProp);
      kooCurve: (curve_prop: TCurveProp);}
  end; {$endregion}
  PNodeData     =^TNodeData;

var

  {Object Properties}
  bkgnd_prop: TBkgndProp;
  bktex_prop: TBkTexProp;
  rgrid_prop: TRGridProp;
  sgrid_prop: TSGridProp;
  group_prop: TGroupProp;
  tlmap_prop: TTlMapProp;
  actor_prop: TActorProp;
  prtcl_prop: TPrtclProp;
  curve_prop: TCurveProp;
  ftext_prop: TFTextProp;

  {Object Default Properties}
  obj_default_prop: TObjInfo={$region -fold}
  (
    bkgnd_ptr                : Nil;
    bkgnd_width              : 0;
    bkgnd_height             : 0;
    rct_clp_ptr              : Default(PPtRect);
    rct_dst_ptr              : Default(PPtRect);
    g_ind                    : 0;
    k_ind                    : 0;
    t_ind                    : 0;
    anim_type                : TLayerType(0);
    koo                      : TKindOfObject(1);
    obj_show                 : 0;
    abstract                 : True;
    is_low_lr_obj            : True;
    movable                  : True;
    scalable                 : True;
    rotatable                : True;
    is_another_obj_kind_after: False;
    is_an_abst_obj_kind_after: False;
    forced_repaint           : False;
    local_axis               : (x:00; y:00);
    world_axis_shift         : (x:00; y:00);
    parallax_shift           : (x:16; y:16);
    obj_dist1                : 0;
    obj_dist2                : 0;
  ); {$endregion}

implementation

uses ///

  Main;

constructor TSceneTree.Create;                                                                                                                                                                              {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  global_prop :=obj_default_prop;
  curr_obj_ind:=0;
end; {$endregion}
destructor  TSceneTree.Destroy;                                                                                                                                                                             {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  self.Free;
  inherited Destroy;
end; {$endregion}
procedure   TSceneTree.FilEmpty;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
end; {$endregion}
procedure   TSceneTree.FilBkgnd;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  srf_var_inst_ptr: PSurface=Nil;
begin
  srf_var_inst_ptr:=@srf_var;
  srf_var_inst_ptr^.FilBkgndObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.FilBkTex;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  tex_var_inst_ptr: PTex=Nil;
begin
  tex_var_inst_ptr:=@tex_var;
  tex_var_inst_ptr^.FilBkTexObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.FilRGrid;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rgr_var_inst_ptr: PRGrid=Nil;
begin
  rgr_var_inst_ptr:=@rgr_var;
  rgr_var_inst_ptr^.FilRGridObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.FilSGrid;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sgr_var_inst_ptr: PSGrid=Nil;
begin
  sgr_var_inst_ptr:=@sgr_var;
  sgr_var_inst_ptr^.FilSGridObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.FilGroup;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
end; {$endregion}
procedure   TSceneTree.FilTlMap;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  tlm_var_inst_ptr: PTlMap=Nil;
begin
  tlm_var_inst_ptr:=Unaligned(@tlm_var);
  tlm_var_inst_ptr^.FilTileMapObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.FilActor;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.FilPrtcl;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.FilFText;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.FilCurve;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sln_var_inst_ptr: PCurve=Nil;
begin
  sln_var_inst_ptr:=Unaligned(@sln_var);
  sln_var_inst_ptr^.FilSplineObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.FilScene              (start_ind,end_ind:TColor);                                                                                                                            inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjInfo;
  obj_inds_arr_ptr: PColor;
  i               : integer;
  editor_or_game  : set of byte;
begin
  if (obj_cnt=0) then
    Exit;
  editor_or_game  :=[0,1+Byte(res_var_ptr^)];
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=start_ind to end_ind do
    if ((obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.obj_show in editor_or_game) then
      begin
        curr_obj_ind:=(obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.k_ind;
        FilProc[(obj_inds_arr_ptr+i)^];
      end;
end; {$endregion}
procedure   TSceneTree.MovEmpty;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
end; {$endregion}
procedure   TSceneTree.MovBkgnd;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  srf_var_inst_ptr: PSurface=Nil;
begin
  srf_var_inst_ptr:=@srf_var;
  srf_var_inst_ptr^.MovBkgndObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.MovBkTex;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.MovRGrid;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rgr_var_inst_ptr: PRGrid=Nil;
begin
  rgr_var_inst_ptr:=Unaligned(@rgr_var);
  rgr_var_inst_ptr^.MovRGridObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.MovSGrid;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sgr_var_inst_ptr: PSGrid=Nil;
begin
  sgr_var_inst_ptr:=Unaligned(@sgr_var);
  sgr_var_inst_ptr^.MovSGridObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.MovGroup;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.MovTlMap;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  tlm_var_inst_ptr: PTlMap=Nil;
begin
  tlm_var_inst_ptr:=Unaligned(@tlm_var);
  tlm_var_inst_ptr^.MovTileMapObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.MovActor;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.MovPrtcl;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.MovFText;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.MovCurve;                                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sln_var_inst_ptr: PCurve=Nil;
begin
  sln_var_inst_ptr:=Unaligned(@sln_var);
  sln_var_inst_ptr^.MovSplineObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.MovScene              (start_ind,end_ind:TColor);                                                                                                                            inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjInfo;
  obj_inds_arr_ptr: PColor;
  i               : integer;
  editor_or_game  : set of byte;
begin
  if (obj_cnt=0) then
    Exit;
  editor_or_game  :=[0,1+Byte(res_var_ptr^)];
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=start_ind to end_ind do
    if ((obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.obj_show in editor_or_game) then
      begin
        curr_obj_ind:=(obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.k_ind;
        MovProc[(obj_inds_arr_ptr+i)^];
      end;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftRight;                                                                                                                                                      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjInfo;
  obj_inds_arr_ptr: PColor;
  i               : integer;
begin
  if (obj_cnt=0) then
    Exit;
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=0 to obj_cnt-1 do
    begin
      (obj_arr_ptr+obj_inds_arr_ptr^)^.world_axis_shift.x-=(obj_arr_ptr+obj_inds_arr_ptr^)^.parallax_shift.x;
      Inc(obj_inds_arr_ptr);
    end;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftLeft ;                                                                                                                                                      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjInfo;
  obj_inds_arr_ptr: PColor;
  i               : integer;
begin
  if (obj_cnt=0) then
    Exit;
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=0 to obj_cnt-1 do
    begin
      (obj_arr_ptr+obj_inds_arr_ptr^)^.world_axis_shift.x+=(obj_arr_ptr+obj_inds_arr_ptr^)^.parallax_shift.x;
      Inc(obj_inds_arr_ptr);
    end;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftDown ;                                                                                                                                                      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjInfo;
  obj_inds_arr_ptr: PColor;
  i               : integer;
begin
  if (obj_cnt=0) then
    Exit;
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=0 to obj_cnt-1 do
    begin
      (obj_arr_ptr+obj_inds_arr_ptr^)^.world_axis_shift.y-=(obj_arr_ptr+obj_inds_arr_ptr^)^.parallax_shift.y;
      Inc(obj_inds_arr_ptr);
    end;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftUp   ;                                                                                                                                                      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjInfo;
  obj_inds_arr_ptr: PColor;
  i               : integer;
begin
  if (obj_cnt=0) then
    Exit;
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=0 to obj_cnt-1 do
    begin
      (obj_arr_ptr+obj_inds_arr_ptr^)^.world_axis_shift.y+=(obj_arr_ptr+obj_inds_arr_ptr^)^.parallax_shift.x;
      Inc(obj_inds_arr_ptr);
    end;
end; {$endregion}
procedure   TSceneTree.SetWorldAxisShift     (world_axis_shift_:TPtPos);                                                                                                                            inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjInfo;
  obj_inds_arr_ptr: PColor;
  i               : integer;
begin
  if (obj_cnt=0) then
    Exit;
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=0 to obj_cnt-1 do
    begin
      (obj_arr_ptr+obj_inds_arr_ptr^)^.world_axis_shift:=world_axis_shift_;
      Inc(obj_inds_arr_ptr);
    end;
end; {$endregion}
procedure   TSceneTree.SetParallaxShift      (parallax_shift_  :TPtPos);                                                                                                                            inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjInfo;
  obj_inds_arr_ptr: PColor;
  i               : integer;
begin
  if (obj_cnt=0) then
    Exit;
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=0 to obj_cnt-1 do
    begin
      (obj_arr_ptr+obj_inds_arr_ptr^)^.parallax_shift.x+=parallax_shift_.x;
      (obj_arr_ptr+obj_inds_arr_ptr^)^.parallax_shift.y+=parallax_shift_.y;
      Inc(obj_inds_arr_ptr);
    end;
end; {$endregion}
procedure   TSceneTree.SetRctDstPtr          (rct_dst_ptr_:PPtRect; start_ind,end_ind:TColor);                                                                                                      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjInfo;
  obj_inds_arr_ptr: PColor;
  i               : integer;
begin
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=start_ind to end_ind do
    (obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.rct_dst_ptr:=rct_dst_ptr_;
end; {$endregion}
procedure   TSceneTree.SetFilMovProc         (abstract_:boolean; FilProc_,MovProc_:TProc0; var obj_cnt_:TColor; var inds_obj_arr_,inds_sct_arr_:TColorArr);                                         inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  Inc(obj_cnt_);
  SetLength(inds_obj_arr_,obj_cnt_);
  SetLength(inds_sct_arr_,obj_cnt_);
  inds_obj_arr_[obj_cnt_-1]         :=obj_cnt -1;
  obj_arr      [obj_cnt -1].k_ind   :=obj_cnt_-1;
  obj_arr      [obj_cnt -1].abstract:=abstract_;
  FilProc      [obj_cnt -1]         :=FilProc_;
  MovProc      [obj_cnt -1]         :=MovProc_;
end; {$endregion}
procedure   TSceneTree.Add                   (constref koo:TKindOfObject; constref world_axis_shift_:TPtPos);                                                                                       inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_var_ptr: PObjInfo;
begin
  Inc(obj_cnt);
  SetLength(FilProc     ,obj_cnt);
  SetLength(MovProc     ,obj_cnt);
  SetLength(obj_arr     ,obj_cnt);
  SetLength(obj_inds_arr,obj_cnt);
  SetLength(sel_inds_arr,obj_cnt);
  obj_var_ptr:=Unaligned(@obj_arr[obj_cnt-1]);
  obj_var_ptr^                 :=global_prop;
  obj_var_ptr^.g_ind           :=obj_cnt-1;
  obj_var_ptr^.koo             :=koo;
  obj_var_ptr^.world_axis_shift:=world_axis_shift_;
  case koo of
    TKindOfObject(00){kooEmpty}: SetFilMovProc(True ,@FilEmpty,@MovEmpty,empty_cnt,empty_inds_obj_arr,empty_inds_sct_arr);
    TKindOfObject(01){kooBkgnd}: SetFilMovProc(False,@FilBkgnd,@MovBkgnd,bkgnd_cnt,bkgnd_inds_obj_arr,bkgnd_inds_sct_arr);
    TKindOfObject(02){kooBkTex}: SetFilMovProc(False,@FilBkTex,@MovBkTex,bktex_cnt,bktex_inds_obj_arr,bktex_inds_sct_arr);
    TKindOfObject(03){kooRGrid}: SetFilMovProc(False,@FilRGrid,@MovRGrid,rgrid_cnt,rgrid_inds_obj_arr,rgrid_inds_sct_arr);
    TKindOfObject(04){kooSGrid}: SetFilMovProc(False,@FilSGrid,@MovSGrid,sgrid_cnt,sgrid_inds_obj_arr,sgrid_inds_sct_arr);
    TKindOfObject(05){kooGroup}: SetFilMovProc(True ,@FilGroup,@MovGroup,group_cnt,group_inds_obj_arr,group_inds_sct_arr);
    TKindOfObject(06){kooTlMap}: SetFilMovProc(False,@FilTlMap,@MovTlMap,tlmap_cnt,tlmap_inds_obj_arr,tlmap_inds_sct_arr);
    TKindOfObject(07){kooActor}: SetFilMovProc(False,@FilActor,@MovActor,actor_cnt,actor_inds_obj_arr,actor_inds_sct_arr);
    TKindOfObject(08){kooPrtcl}: SetFilMovProc(False,@FilPrtcl,@MovPrtcl,prtcl_cnt,prtcl_inds_obj_arr,prtcl_inds_sct_arr);
    TKindOfObject(09){kooCurve}: SetFilMovProc(False,@FilCurve,@MovCurve,curve_cnt,curve_inds_obj_arr,curve_inds_sct_arr);
    TKindOfObject(10){kooFtext}: SetFilMovProc(False,@FilFText,@MovFText,ftext_cnt,ftext_inds_obj_arr,ftext_inds_sct_arr);
  end;
end; {$endregion}
procedure   TSceneTree.SetObjBkgnd           (obj_arr_ptr:PObjInfo; constref bkgnd_ptr:PInteger; constref bkgnd_width,bkgnd_height:TColor; constref rct_clp_ptr:PPtRect);                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  obj_arr_ptr^.bkgnd_ptr   :=bkgnd_ptr   ;
  obj_arr_ptr^.bkgnd_width :=bkgnd_width ;
  obj_arr_ptr^.bkgnd_height:=bkgnd_height;
  obj_arr_ptr^.rct_clp_ptr :=rct_clp_ptr ;
end; {$endregion}
procedure   TSceneTree.SetObjBkgnd           (                      constref bkgnd_ptr:PInteger; constref bkgnd_width,bkgnd_height:TColor; constref rct_clp_ptr:PPtRect; start_ind,end_ind:TColor); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjInfo;
  obj_inds_arr_ptr: PColor;
  i               : integer;
begin
  with obj_var do
    if (obj_var<>Nil) and (obj_cnt>0)  then
      begin
        obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
        obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
        for i:=start_ind to end_ind do
          SetObjBkgnd
          (
           (obj_arr_ptr+(obj_inds_arr_ptr+i)^),
            bkgnd_ptr,
            bkgnd_width,
            bkgnd_height,
            rct_clp_ptr
          );
      end;
end; {$endregion}
// (Checks If Another Kind Of Object Is Available After Selected Object(From start_ind) In Objects array(obj_arr)) Проверяет есть ли другой вид обьектов после выбранного(начиная с start_ind) в иерархии сцены(scene tree):
function    TSceneTree.IsAnotherObjKindAfter1(constref koo:TKindOfObject; constref start_ind:TColor=0): boolean;                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjInfo;
  obj_inds_arr_ptr: PColor;
  i               : integer;
begin
  Result          :=False;
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=start_ind to Length(obj_arr)-1 do
    if ((obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.koo<>koo) then
      begin
        Result:=True;
        Break;
      end;
end; {$endregion}
function    TSceneTree.IsAnotherObjKindAfter2(                            constref start_ind:TColor=0): boolean;                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjInfo;
  obj_inds_arr_ptr: PColor;
  i               : integer;
begin
  Result          :=False;
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=start_ind to Length(obj_arr)-1 do
    if (not ((obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.abstract)) then
      begin
        Result:=True;
        Break;
      end;
end; {$endregion}
function    TSceneTree.IsAnotherObjKindAfter3(constref koo:TKindOfObject; constref start_ind:TColor=0): boolean;                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjInfo;
  obj_inds_arr_ptr: PColor;
  i               : integer;
begin
  Result          :=False;
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=start_ind to Length(obj_arr)-1 do
    if ((obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.koo<>koo) and (not (obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.abstract) then
      begin
        Result:=True;
        Break;
      end;
end; {$endregion}
function    TSceneTree.IsAnotherObjKindAfter4(constref koo:TKindOfObject; constref start_ind:TColor=0): boolean;                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjInfo;
  obj_inds_arr_ptr: PColor;
  i               : integer;
begin
  Result          :=False;
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=start_ind to Length(obj_arr)-1 do
    if    (((obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.koo<>koo) and
      ((not (obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.abstract) and
           ((obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.obj_show in [0,1]))) then
      begin
        Result:=True;
        Break;
      end;
end; {$endregion}
// (Calculate Low Layer Objects Count) Подсчет количества обьектов "нижнего" слоя:
function    TSceneTree.LowLrObjCntCalc1: TColor;                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjInfo;
  obj_inds_arr_ptr: PColor;
  i               : integer;
  p_s             : TPtPos;
begin
  Result:=Length(obj_inds_arr);
  if (Result=1) then
    Exit;
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  p_s             :=obj_arr[obj_inds_arr[1]].parallax_shift;
  for i:=1 to Length(obj_arr)-1 do
    if ((obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.anim_type<>ltStatic) or (not ((obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.parallax_shift=p_s)) then
      begin
        Result:=i;
        Break;
      end;
  low_lr_obj_cnt:=Result;
  upp_lr_obj_cnt:=obj_cnt-low_lr_obj_cnt;
end; {$endregion}
procedure   TSceneTree.LowLrObjCntCalc2;                                                                                                                                                            inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  {for i:=1 to low_lr_obj_cnt do
    obj_arr[obj_inds_arr[i]].is_low_lr_obj:=True;
  for i:=low_lr_obj_cnt+1 to obj_cnt-1 do
    obj_arr[obj_inds_arr[i]].is_low_lr_obj:=False;}
end; {$endregion}
// (Check Equality Of Two Objects By Kind) Проверка на равенство двух обьектов по виду:
function    TSceneTree.AreTwoObjKindEqual    (constref obj_ind1,obj_ind2:TColor): boolean;                                                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  Result:=(obj_arr[obj_ind1].koo=obj_arr[obj_ind2].koo);
end; {$endregion}
//
function    TSceneTree.Min9(constref obj_inds_arr_:TColorArr; constref arr:TEdgeArr; constref max_item_val:TColor; constref item_cnt:TColor): TColor;                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  Result:=max_item_val;
  for i:=0 to item_cnt-1 do
    if (obj_arr[obj_inds_arr_[arr[i].obj_ind]].t_ind<=Result) then
      Result:=obj_arr[obj_inds_arr_[arr[i].obj_ind]].t_ind;
end; {$endregion}
function    TSceneTree.Min9(constref obj_inds_arr_:TColorArr; constref arr:TSlPtArr; constref max_item_val:TColor; constref item_cnt:TColor): TColor;                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var

  i: integer;
begin
  Result:=max_item_val;
  for i:=0 to item_cnt-1 do
    if (obj_arr[obj_inds_arr_[arr[i].obj_ind]].t_ind<=Result) then
      Result:=obj_arr[obj_inds_arr_[arr[i].obj_ind]].t_ind;
end; {$endregion}
// (Bounding Rectangle of Points Set) Ограничиваюший прямоугольник множества точек:
function    TSceneTree.PtsRngIndsRctCalc(constref pts:TPtPosFArr; constref sel_pts_inds:TColorArr; constref pts_cnt:TColor): TPtRectF;                                                              inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  pts_ptr                                : PPtPosF;
  sel_pts_inds_ptr                       : PInteger;
  min_x,min_y,max_x,max_y                : double;
  ind_min_x,ind_min_y,ind_max_x,ind_max_y: integer;
  i                                      : integer;
begin

  {Misc. Precalc.----} {$region -fold}
  pts_ptr         :=Unaligned(@pts         [0]);
  sel_pts_inds_ptr:=Unaligned(@sel_pts_inds[0]);
  Result          :=Default(TPtRectF);
  ind_min_x       :=0;
  ind_min_y       :=0;
  ind_max_x       :=0;
  ind_max_y       :=0;

  with pts[sel_pts_inds[0]] do
    begin
      min_x:=x+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[sel_pts_inds_ptr^]]].world_axis_shift.x;
      min_y:=y+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[sel_pts_inds_ptr^]]].world_axis_shift.y;
      max_x:=x+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[sel_pts_inds_ptr^]]].world_axis_shift.x;
      max_y:=y+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[sel_pts_inds_ptr^]]].world_axis_shift.y;
    end; {$endregion}

  {Calc. of Rectangle} {$region -fold}
  for i:=0 to pts_cnt-1 do
    begin
      if ((pts_ptr+sel_pts_inds_ptr^)^.x+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[sel_pts_inds_ptr^]]].world_axis_shift.x<=min_x) then
        begin
          min_x    :=(pts_ptr+sel_pts_inds_ptr^)^.x+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[sel_pts_inds_ptr^]]].world_axis_shift.x;
          ind_min_x:=sel_pts_inds_ptr^;
        end;
      if ((pts_ptr+sel_pts_inds_ptr^)^.y+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[sel_pts_inds_ptr^]]].world_axis_shift.y<=min_y) then
        begin
          min_y    :=(pts_ptr+sel_pts_inds_ptr^)^.y+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[sel_pts_inds_ptr^]]].world_axis_shift.y;
          ind_min_y:=sel_pts_inds_ptr^;
        end;
      if ((pts_ptr+sel_pts_inds_ptr^)^.x+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[sel_pts_inds_ptr^]]].world_axis_shift.x>=max_x) then
        begin
          max_x    :=(pts_ptr+sel_pts_inds_ptr^)^.x+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[sel_pts_inds_ptr^]]].world_axis_shift.x;
          ind_max_x:=sel_pts_inds_ptr^;
        end;
      if ((pts_ptr+sel_pts_inds_ptr^)^.y+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[sel_pts_inds_ptr^]]].world_axis_shift.y>=max_y) then
        begin
          max_y    :=(pts_ptr+sel_pts_inds_ptr^)^.y+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[sel_pts_inds_ptr^]]].world_axis_shift.y;
          ind_max_y:=sel_pts_inds_ptr^;
        end;
      Inc(sel_pts_inds_ptr);
    end; {$endregion}

  {Set Rectangle-----} {$region -fold}
  with Result do
    begin
      left  :={Trunc(}pts[ind_min_x].x{)}+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[ind_min_x]]].world_axis_shift.x+0;
      top   :={Trunc(}pts[ind_min_y].y{)}+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[ind_min_y]]].world_axis_shift.y+0;
      right :={Trunc(}pts[ind_max_x].x{)}+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[ind_max_x]]].world_axis_shift.x+1;
      bottom:={Trunc(}pts[ind_max_y].y{)}+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[ind_max_y]]].world_axis_shift.y+1;
      width :=right-left;
      height:=bottom-top;
    end; {$endregion}

end; {$endregion}

end.

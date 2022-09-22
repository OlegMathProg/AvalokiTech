unit Fast_Scene_Tree;

{This file contains some routines for scene object manager}

{$mode objfpc}{$H+}

interface

uses

  Classes, Fast_Primitives;

type

  TSceneTree   =class;

  TLayerType   =(ltStatic,ltDynamic);
  PLayerType   =^TLayerType;

  TKindOfObject=(kooEmpty,kooBkgnd,kooRGrid,kooSGrid,kooGroup,kooTlMap,kooActor,kooPrtcl,kooCurve,kooFText,kooMiscellaneous);
  PKindOfObject=^TKindOfObject;

  TObjShow     =(osfInvisible,osfOnlyEditorVisible,osfOnlyRenderVisible,osfEditorRenderVisible);
  PObjShow     =^TObjShow;

  TPosShiftType=(pstAll,pstChildren);
  PPosShiftType=^TPosShiftType;

  TBkgndProp   =packed record {$region -fold}
    bckgd_obj_ind: TColor;
  end; {$endregion}
  PBkgndProp   =^TBkgndProp;

  TRGridProp   =packed record {$region -fold}
    rgrid_obj_ind: TColor;
  end; {$endregion}
  PRGridProp   =^TRGridProp;

  TSGridProp   =packed record {$region -fold}
    sgrid_obj_ind: TColor;
  end; {$endregion}
  PSGridProp   =^TSGridProp;

  TGroupProp   =packed record {$region -fold}
    group_obj_ind: TColor;
    children_cnt : TColor;
  end; {$endregion}
  PGroupProp   =^TGroupProp;

  TTlMapProp   =packed record {$region -fold}
    tlmap_obj_ind: TColor;
  end; {$endregion}
  PTlMapProp   =^TTlMapProp;

  TActorProp   =packed record {$region -fold}
    actor_obj_ind: TColor;
  end; {$endregion}
  PActorProp   =^TActorProp;

  TPrtclProp   =packed record {$region -fold}
    prtcl_obj_ind: TColor;
  end; {$endregion}
  PPrtclProp   =^TPrtclProp;

  TObjInfo     =packed record {$region -fold}
    // Parallax:
    world_axis_shift         : TPtPosF;
    world_axis_shift_centrify: TPtPosF;
    parallax_shift           : TPtPosF;
    // Local axis:
    local_axis               : TPtPosF;
    // Outer clipping rectangle:
    rct_clp_ptr              : PPtRect;
    // Destination(clipped by outer clipping rectangle) rectangle:
    rct_dst_ptr              : PPtRect;
    // Background (bitmap destination) handle:
    bkgnd_ptr                : PInteger;
    // Background (bitmap destination) width:
    bkgnd_width              : TColor;
    // Background (bitmap destination) height:
    bkgnd_height             : TColor;
    // (Global) Position of an object inside object array:
    g_ind                    : TColor;
    // (Local ) Position of an object inside kind of object:
    k_ind                    : TColor;
    // (Global) Position of an object inside scene tree:
    t_ind                    : TColor;
    // Distance between world axis and local axis:
    obj_dist1                : TColor;
    // Distance between camera and current object:
    obj_dist2                : TColor;
    // Animation type of object:
    anim_type                : TLayerType;
    // Kind of object: spline, actor,...etc.:
    koo                      : TKindOfObject;
    // Is object visible:
    // 0 -   visible in editor,   visible in game;
    // 1 -   visible in editor, invisible in game;
    // 2 - invisible in editor,   visible in game;
    // 3 - invisible in editor, invisible in game;
    // 4 - 0 or 1;
    // 5 - 0 or 2;
    obj_show                 : byte;
    // Is object abstract(for example prefab/null/group) or drawable in scene:
    abstract                 : boolean;
    // Is object in low(static) layer:
    is_low_lr_obj            : boolean;
    // Does object allow to move itself:
    movable                  : boolean;
    // Does object allow to scale itself:
    scalable                 : boolean;
    // Does object allow to rotate itself:
    rotatable                : boolean;
    // Is another  kind of object is available after current object:
    is_another_obj_kind_after: boolean;
    // Is abstract kind of object is available after current object:
    is_an_abst_obj_kind_after: boolean;
    // Forced repaint:
    forced_repaint           : boolean;
    // Recalculate position:
    recalc_pos               : boolean;
  end; {$endregion}
  PObjInfo     =^TObjInfo;

  TSceneTree   =class         {$region -fold}
    public
      global_prop       : TObjInfo;
      // TODO:
      obj_arr           : array of TObjInfo;
      // TODO:
      FilProc           : array of TProc0;
      // TODO:
      MovProc           : array of TProc0;
      // Array of objects indices inside of object array:
      obj_inds_arr      : TColorArr;
      // Array of selected objects indices inside of scene tree:
      sel_inds_arr      : TColorArr;

      {Array of indices inside of object array} {$region -fold}
        empty_inds_obj_arr: TColorArr;
        bkgnd_inds_obj_arr: TColorArr;
        rgrid_inds_obj_arr: TColorArr;
        sgrid_inds_obj_arr: TColorArr;
        group_inds_obj_arr: TColorArr;
        tlmap_inds_obj_arr: TColorArr;
        actor_inds_obj_arr: TColorArr;
        prtcl_inds_obj_arr: TColorArr;
        curve_inds_obj_arr: TColorArr;
        ftext_inds_obj_arr: TColorArr; {$endregion}

      {Array of indices inside of scene tree--} {$region -fold}
        empty_inds_sct_arr: TColorArr;
        bkgnd_inds_sct_arr: TColorArr;
        rgrid_inds_sct_arr: TColorArr;
        sgrid_inds_sct_arr: TColorArr;
        group_inds_sct_arr: TColorArr;
        tlmap_inds_sct_arr: TColorArr;
        actor_inds_sct_arr: TColorArr;
        prtcl_inds_sct_arr: TColorArr;
        curve_inds_sct_arr: TColorArr;
        ftext_inds_sct_arr: TColorArr; {$endregion}

      {Count of items-------------------------} {$region -fold}
        empty_cnt         : TColor;
        bkgnd_cnt         : TColor;
        rgrid_cnt         : TColor;
        sgrid_cnt         : TColor;
        group_cnt         : TColor;
        tlmap_cnt         : TColor;
        actor_cnt         : TColor;
        prtcl_cnt         : TColor;
        curve_cnt         : TColor;
        ftext_cnt         : TColor; {$endregion}

      // Current object index:
      curr_obj_ind      : TColor;
      // Index of first selected node in scene tree:
      first_sel_node_ind: TColor;
      // Count of all objects in scene:
      obj_cnt           : TColor;
      // Count of selected objects in scene:
      sel_cnt           : TColor;
      // Lower layer objects count:
      low_lr_obj_cnt    : TColor;
      // Upper
      upp_lr_obj_cnt    : TColor;
      // Kind of selected objects:
      sel_koo           : TKindOfObject;
      // Is item with children in scene tree:
      has_it_with_ch    : boolean;

      // Count of selected objects of "Groups":
      group_selected    : boolean;
      // Count of selected objects of "Tile Map":
      tlmap_selected    : boolean;
      // Count of selected objects of "Actors":
      actor_selected    : boolean;
      // Count of selected objects of "Particles":
      prtcl_selected    : boolean;
      // Count of selected objects of "Splines"("Curves"):
      curve_selected    : boolean;
      // Count of selected objects of "FText":
      ftext_selected    : boolean;

      // Camera speed multiplier:
      speed_mul_ptr     : PPtPosF;
      speed_mul_prev_ptr: PPtPosF;

      // Reserved:
      res_var_ptr       : PBoolean;

      constructor Create;                                                                     {$ifdef Linux}[local];{$endif}
      destructor  Destroy;                                                          override; {$ifdef Linux}[local];{$endif}

      procedure FilEmpty;                                                             inline; {$ifdef Linux}[local];{$endif}
      procedure FilBkgnd;                                                             inline; {$ifdef Linux}[local];{$endif}
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
      procedure MovWorldAxisShiftRight2;                                              inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftLeft;                                                inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftLeft2;                                               inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftDown;                                                inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftDown2;                                               inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftUp;                                                  inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftUp2;                                                 inline; {$ifdef Linux}[local];{$endif}
      procedure SetWorldAxisShiftC                                                    inline; {$ifdef Linux}[local];{$endif}
      procedure SetWorldAxisShift     (         world_axis_shift_:TPtPosF);           inline; {$ifdef Linux}[local];{$endif}
      procedure SetParallaxShift      (         parallax_shift_  :TPtPosF);           inline; {$ifdef Linux}[local];{$endif}
      procedure SetParallaxShift      (         parallax_shift_  :TPtPosF;
                                                speed_mul        :TPtPosF);           inline; {$ifdef Linux}[local];{$endif}
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
                                       constref world_axis_shift_:TPtPosF);           inline; {$ifdef Linux}[local];{$endif}
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
      // (Checks if another kind of object is available after selected object(from start_ind) in objects array(obj_arr)) Проверяет есть ли другой вид обьектов после выбранного(начиная с start_ind) в массиве обьектов(obj_arr):
      function  IsAnotherObjKindAfter1(constref koo              :TKindOfObject;
                                       constref start_ind        :TColor=0): boolean; inline; {$ifdef Linux}[local];{$endif}
      function  IsAnotherObjKindAfter2(constref start_ind        :TColor=0): boolean; inline; {$ifdef Linux}[local];{$endif}
      function  IsAnotherObjKindAfter3(constref koo              :TKindOfObject;
                                       constref start_ind        :TColor=0): boolean; inline; {$ifdef Linux}[local];{$endif}
      function  IsAnotherObjKindAfter4(constref koo              :TKindOfObject;
                                       constref start_ind        :TColor=0): boolean; inline; {$ifdef Linux}[local];{$endif}
      // (Calculate low and upper layer objects count) Подсчет количества обьектов "нижнего" и "верхнего" слоев:
      function  LowLrObjCntCalc1: TColor;                                             inline; {$ifdef Linux}[local];{$endif}
      procedure LowLrObjCntCalc2;                                                     inline; {$ifdef Linux}[local];{$endif}
      // (Check equality of two objects by kind) Проверка на равенство двух обьектов по виду:
      function  AreTwoObjKindEqual    (constref obj_ind1,
                                                obj_ind2         :TColor): boolean;   inline; {$ifdef Linux}[local];{$endif}
      // TODO:
      function  Min9                  (constref obj_inds_arr_    :TColorArr;
                                       constref arr              :TEdgeArr;
                                       constref max_item_val     :TColor;
                                       constref item_cnt         :TColor): TColor;    inline; {$ifdef Linux}[local];{$endif}
      function  Min9                  (constref obj_inds_arr_    :TColorArr;
                                       constref arr              :TSlPtArr;
                                       constref max_item_val     :TColor;
                                       constref item_cnt         :TColor): TColor;    inline; {$ifdef Linux}[local];{$endif}
      // (Bounding rectangle of points set) Ограничиваюший прямоугольник множества точек:
      function  PtsRngIndsRctCalc     (constref pts              :TPtPosFArr;
                                       constref sel_pts_inds     :TColorArr;
                                       constref pts_cnt          :TColor): TPtRectF;  inline; {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PSceneTree   =^TSceneTree;

  TNodeData    =packed record {$region -fold}
    // TODO:
    g_ind: TColor;
    {case TKindOfObject of
      kooBckgd: (bckgd_prop: TBckgdProp);
      kooRGrid: (rgrid_prop: TRGridProp);
      kooSGrid: (sgrid_prop: TSGridProp);
      kooGroup: (group_prop: TGroupProp);
      kooTlMap: (tlmap_prop: TTlMapProp);
      kooActor: (actor_prop: TActorProp);
      kooPrtcl: (prtcl_prop: TPrtclProp);
      kooCurve: (curve_prop: TCurveProp);}
  end; {$endregion}
  PNodeData    =^TNodeData;

var

  {Object properties}
  bkgnd_prop: TBkgndProp;
  rgrid_prop: TRGridProp;
  sgrid_prop: TSGridProp;
  group_prop: TGroupProp;
  tlmap_prop: TTlMapProp;
  actor_prop: TActorProp;
  prtcl_prop: TPrtclProp;
  curve_prop: TCurveProp;
  ftext_prop: TFTextProp;

  {Object default properties}
  obj_default_prop: TObjInfo={$region -fold}
  (
    world_axis_shift         : (x:00.0; y:00.0);
    world_axis_shift_centrify: (x:00.0; y:00.0);
    parallax_shift           : (x:16.0; y:16.0);
    local_axis               : (x:0000; y:0000);
    rct_clp_ptr              : Nil;
    rct_dst_ptr              : Nil;
    bkgnd_ptr                : Nil;
    bkgnd_width              : 0;
    bkgnd_height             : 0;
    g_ind                    : 0;
    k_ind                    : 0;
    t_ind                    : 0;
    obj_dist1                : 0;
    obj_dist2                : 0;
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
    recalc_pos               : False;
  ); {$endregion}

implementation

uses //

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
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    obj_arr[i].world_axis_shift.x-=obj_arr[i].parallax_shift.x;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftRight2;                                                                                                                                                     inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    obj_arr[i].world_axis_shift.x-=speed_mul_ptr^.x*obj_arr[i].parallax_shift.x;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftLeft;                                                                                                                                                       inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    obj_arr[i].world_axis_shift.x+=obj_arr[i].parallax_shift.x;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftLeft2;                                                                                                                                                      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    obj_arr[i].world_axis_shift.x+=speed_mul_ptr^.x*obj_arr[i].parallax_shift.x;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftDown;                                                                                                                                                       inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    obj_arr[i].world_axis_shift.y-=obj_arr[i].parallax_shift.y;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftDown2;                                                                                                                                                      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    obj_arr[i].world_axis_shift.y-=speed_mul_ptr^.y*obj_arr[i].parallax_shift.y;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftUp;                                                                                                                                                         inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    obj_arr[i].world_axis_shift.y+=obj_arr[i].parallax_shift.y;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftUp2;                                                                                                                                                        inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    obj_arr[i].world_axis_shift.y+=speed_mul_ptr^.y*obj_arr[i].parallax_shift.y;
end; {$endregion}
procedure   TSceneTree.SetWorldAxisShiftC;                                                                                                                                                        inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    obj_arr[i].world_axis_shift_centrify:=obj_arr[i].world_axis_shift;
end; {$endregion}
procedure   TSceneTree.SetWorldAxisShift     (world_axis_shift_:TPtPosF);                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    obj_arr[i].world_axis_shift:=world_axis_shift_;
end; {$endregion}
procedure   TSceneTree.SetParallaxShift      (parallax_shift_  :TPtPosF);                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    begin
      obj_arr[i].parallax_shift.x+=parallax_shift_.x;
      obj_arr[i].parallax_shift.y+=parallax_shift_.y;
    end;
end; {$endregion}
procedure   TSceneTree.SetParallaxShift      (parallax_shift_  :TPtPosF; speed_mul:TPtPosF);                                                                                                        inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    begin
      obj_arr[i].parallax_shift.x*=speed_mul.x;
      obj_arr[i].parallax_shift.y*=speed_mul.y;
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
procedure   TSceneTree.Add                   (constref koo:TKindOfObject; constref world_axis_shift_:TPtPosF);                                                                                      inline; {$ifdef Linux}[local];{$endif} {$region -fold}
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
    TKindOfObject(02){kooRGrid}: SetFilMovProc(False,@FilRGrid,@MovRGrid,rgrid_cnt,rgrid_inds_obj_arr,rgrid_inds_sct_arr);
    TKindOfObject(03){kooSGrid}: SetFilMovProc(False,@FilSGrid,@MovSGrid,sgrid_cnt,sgrid_inds_obj_arr,sgrid_inds_sct_arr);
    TKindOfObject(04){kooGroup}: SetFilMovProc(True ,@FilGroup,@MovGroup,group_cnt,group_inds_obj_arr,group_inds_sct_arr);
    TKindOfObject(05){kooTlMap}: SetFilMovProc(False,@FilTlMap,@MovTlMap,tlmap_cnt,tlmap_inds_obj_arr,tlmap_inds_sct_arr);
    TKindOfObject(06){kooActor}: SetFilMovProc(False,@FilActor,@MovActor,actor_cnt,actor_inds_obj_arr,actor_inds_sct_arr);
    TKindOfObject(07){kooPrtcl}: SetFilMovProc(False,@FilPrtcl,@MovPrtcl,prtcl_cnt,prtcl_inds_obj_arr,prtcl_inds_sct_arr);
    TKindOfObject(08){kooCurve}: SetFilMovProc(False,@FilCurve,@MovCurve,curve_cnt,curve_inds_obj_arr,curve_inds_sct_arr);
    TKindOfObject(09){kooFtext}: SetFilMovProc(False,@FilFText,@MovFText,ftext_cnt,ftext_inds_obj_arr,ftext_inds_sct_arr);
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
// (Checks if another kind of object is available after selected object(from start_ind) in objects array(obj_arr)) Проверяет есть ли другой вид обьектов после выбранного(начиная с start_ind) в иерархии сцены(scene tree):
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
// (Calculate low and upper layer objects count) Подсчет количества обьектов "нижнего" и "верхнего" слоев:
function    TSceneTree.LowLrObjCntCalc1: TColor;                                                                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjInfo;
  obj_inds_arr_ptr: PColor;
  i               : integer;
  p_s             : TPtPosF;
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
{var
  i: integer;}
begin
  {if (obj_cnt=0) then
    Exit;}
  {for i:=1 to low_lr_obj_cnt do
    obj_arr[obj_inds_arr[i]].is_low_lr_obj:=True;
  for i:=low_lr_obj_cnt+1 to obj_cnt-1 do
    obj_arr[obj_inds_arr[i]].is_low_lr_obj:=False;}
end; {$endregion}
// (Check equality of two objects by kind) Проверка на равенство двух обьектов по виду:
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
// (Bounding rectangle of points set) Ограничиваюший прямоугольник множества точек:
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
      left  :=pts[ind_min_x].x+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[ind_min_x]]].world_axis_shift.x+0;
      top   :=pts[ind_min_y].y+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[ind_min_y]]].world_axis_shift.y+0;
      right :=pts[ind_max_x].x+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[ind_max_x]]].world_axis_shift.x+1;
      bottom:=pts[ind_max_y].y+obj_arr[curve_inds_obj_arr[sln_var.sln_obj_ind[ind_max_y]]].world_axis_shift.y+1;
      width :=right-left;
      height:=bottom-top;
    end; {$endregion}

end; {$endregion}

end.

unit Fast_Scene_Tree;

{This file contains some routines for scene object manager}

{$mode objfpc}{$H+}

interface

uses

  {$ifdef Windows}Windows,{$endif} Classes, Fast_Graphics, TypInfo, ComCtrls, SysUtils;



type

  TSceneTree   =class;

  TLayerType   =(ltStatic,ltDynamic);
  PLayerType   =^TLayerType;

  TKindOfObject=(kooEmpty,kooBkgnd,kooRGrid,kooSGrid,kooGroup,kooTlMap,kooActor,kooPrtcl,kooCurve,kooFText,kooMiscellaneous);
  PKindOfObject=^TKindOfObject;

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

  TObjProp     =packed record {$region -fold}
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
    // (Global) Position of object inside object array:
    g_ind                    : TColor;
    // (Local ) Position of object inside kind of object:
    k_ind                    : TColor;
    // (Global) Position of object inside scene tree:
    t_ind                    : TColor;
    // Distance between world axis and local axis:
    obj_dist1                : TColor;
    // Distance between camera and current object:
    obj_dist2                : TColor;
    // Animation type of object:
    anim_type                : TLayerType;
    // Kind of object: spline, actor,...etc.:
    koo                      : TKindOfObject;
    // Is object visible: bitpacked field:
    // {0}  obj_show and %00000000 - invisible in editor,invisible in game;
    // {1}  obj_show and %00000001 -   visible in editor,invisible in game;
    // {2}  obj_show and %00000010 - invisible in editor,  visible in game;
    // {3}  obj_show and %00000011 -   visible in editor,  visible in game;
    // Forced repaint                               : 3d  bit of obj_show;
    // Recalculate position                         : 4th bit of obj_show;
    // Movable  (Does object allow to move   itself): 5th bit of obj_show;
    // Scalable (Does object allow to scale  itself): 6th bit of obj_show;
    // Rotatable(Does object allow to rotate itself): 7th bit of obj_show;
    obj_show                 : byte;
    // Is an object abstract(for example prefab/null/group) or drawable in scene:
    abstract                 : boolean;
    // Is an object in low(static) layer:
    is_low_lr_obj            : boolean;
    // Is an another  kind of object is available after current object:
    is_another_obj_kind_after: boolean;
    // Is an abstract kind of object is available after current object:
    is_an_abst_obj_kind_after: boolean;
    // Reserved:
    res_fld                  : byte;
  end; {$endregion}
  PObjProp     =^TObjProp;

  TSceneTree   =class         {$region -fold}
    public
      global_prop        : TObjProp;
      // TODO:
      obj_arr            : array of TObjProp;
      // TODO:
      FilProc            : array of TProc0;
      // TODO:
      MovProc            : array of TProc0;
      // TODO:
      WrtNodeDataProcArr0: array of TProc21;
      // TODO:
      WrtNodeDataProcArr1: array of TProc22;
      // Array of objects indices inside of object array:
      obj_inds_arr       : TColorArr;
      // Array of selected objects indices inside of scene tree:
      sel_inds_arr       : TColorArr;

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
        empty_cnt: TColor;
        bkgnd_cnt: TColor;
        rgrid_cnt: TColor;
        sgrid_cnt: TColor;
        group_cnt: TColor;
        tlmap_cnt: TColor;
        actor_cnt: TColor;
        prtcl_cnt: TColor;
        curve_cnt: TColor;
        ftext_cnt: TColor; {$endregion}

      // Camera speed multiplier:
      spd_mul_ptr      : PPtPosF;
      spd_mul_prev_ptr : PPtPosF;

      // Reserved:
      res_var_ptr        : PBoolean;

      // Current object index:
      curr_obj_ind       : TColor;
      // Index of first selected node in scene tree:
      first_sel_node_ind : TColor;
      // Count of all objects in scene:
      obj_cnt            : TColor;
      // Count of selected objects in scene:
      sel_cnt            : TColor;
      // Lower layer objects count:
      low_lr_obj_cnt     : TColor;
      // Upper
      upp_lr_obj_cnt     : TColor;
      // Kind of selected objects:
      sel_koo            : TKindOfObject;
      // Is item with children in scene tree:
      has_it_with_ch     : boolean;

      // Count of selected objects of "Groups":
      group_selected     : boolean;
      // Count of selected objects of "Tile Map":
      tlmap_selected     : boolean;
      // Count of selected objects of "Actors":
      actor_selected     : boolean;
      // Count of selected objects of "Particles":
      prtcl_selected     : boolean;
      // Count of selected objects of "Splines"("Curves"):
      curve_selected     : boolean;
      // Count of selected objects of "FText":
      ftext_selected     : boolean;
      // Bit mask:
      bit_mask           : byte;

      constructor Create;                                                                  {$ifdef Linux}[local];{$endif}
      destructor  Destroy;                                                       override; {$ifdef Linux}[local];{$endif}

      procedure FilEmpty;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure FilBkgnd;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure FilRGrid;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure FilSGrid;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure FilGroup;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure FilTlMap;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure FilActor;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure FilPrtcl;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure FilCurve;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure FilFText;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure FilScene              (      start_ind,
                                             end_ind          :TColor);            inline; {$ifdef Linux}[local];{$endif}
      procedure MovEmpty;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure MovBkgnd;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure MovRGrid;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure MovSGrid;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure MovGroup;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure MovTlMap;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure MovActor;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure MovPrtcl;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure MovCurve;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure MovFText;                                                          inline; {$ifdef Linux}[local];{$endif}
      procedure MovScene              (      start_ind,
                                             end_ind          :TColor);            inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftRight;                                            inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftRight2;                                           inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftLeft;                                             inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftLeft2;                                            inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftDown;                                             inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftDown2;                                            inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftUp;                                               inline; {$ifdef Linux}[local];{$endif}
      procedure MovWorldAxisShiftUp2;                                              inline; {$ifdef Linux}[local];{$endif}
      procedure SetWorldAxisShift     (      world_axis_shift_:TPtPosF);           inline; {$ifdef Linux}[local];{$endif}
      procedure SetParallaxShift      (      parallax_shift_  :TPtPosF);           inline; {$ifdef Linux}[local];{$endif}
      procedure SetParallaxShift      (      parallax_shift_  :TPtPosF;
                                             speed_mul        :TPtPosF);           inline; {$ifdef Linux}[local];{$endif}
      procedure SetRctDstPtr          (      rct_dst_ptr_     :PPtRect;
                                             start_ind,
                                             end_ind          :TColor);            inline; {$ifdef Linux}[local];{$endif}
      procedure SetFilMovProc         (      abstract_        :boolean;
                                             FilProc_,
                                             MovProc_         :TProc0;
                                       var   obj_cnt_         :TColor;
                                       var   inds_obj_arr_,
                                             inds_sct_arr_    :TColorArr);         inline; {$ifdef Linux}[local];{$endif}
      procedure Add                   (const koo              :TKindOfObject;
                                       const world_axis_shift_:TPtPosF);           inline; {$ifdef Linux}[local];{$endif}
      procedure SetObjBkgnd           (      obj_arr_ptr      :PObjProp;
                                       const bkgnd_ptr        :PInteger;
                                       const bkgnd_width,
                                             bkgnd_height     :TColor;
                                       const rct_clp_ptr      :PPtRect);           inline; {$ifdef Linux}[local];{$endif}
      procedure SetObjBkgnd           (const bkgnd_ptr        :PInteger;
                                       const bkgnd_width,
                                             bkgnd_height     :TColor;
                                       const rct_clp_ptr      :PPtRect;
                                             start_ind,
                                             end_ind          :TColor);            inline; {$ifdef Linux}[local];{$endif}
      // Create node data:
      procedure CrtNodeData           (      node_with_data   :TTreeNode;
                                             g_ind            :TColor);            inline; {$ifdef Linux}[local];{$endif}
      // Clear  node data:
      procedure ClrNodeData           (      node_with_data   :TTreeNode);         inline; {$ifdef Linux}[local];{$endif}
      // Write data: proc. table:
      procedure WrtNodeDataProcArrInit;                                            inline; {$ifdef Linux}[local];{$endif}
      // Byte:
      procedure WrtNodeDataProc00     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc01     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      // Bitpacked Byte:
      procedure WrtNodeDataProc02     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc03     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      // Boolean:
      procedure WrtNodeDataProc04     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc05     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      // Word:
      procedure WrtNodeDataProc06     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc07     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      // LongWord:
      procedure WrtNodeDataProc08     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc09     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      // ShortInt:
      procedure WrtNodeDataProc10     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc11     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      // SmallInt:
      procedure WrtNodeDataProc12     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc13     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      // LongInt:
      procedure WrtNodeDataProc14     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc15     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      // Single:
      procedure WrtNodeDataProc16     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc17     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      // Double:
      procedure WrtNodeDataProc18     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc19     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      // AnsiString:
      procedure WrtNodeDataProc20     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc21     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      // TPtPosF:
      procedure WrtNodeDataProc22     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc23     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc24     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc25     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      // TPtRect:
      procedure WrtNodeDataProc26     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc27     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc28     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc29     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc30     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc31     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc32     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc33     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc34     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc35     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc36     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc37     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      // TPtPos3:
      procedure WrtNodeDataProc38     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc39     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc40     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc41     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc42     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc43     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc44     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc45     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc46     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc47     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc48     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc49     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc50     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc51     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc52     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc53     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc54     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      procedure WrtNodeDataProc55     (const data_write;
                                             data_shift       :integer;
                                             data_ptr0,
                                             data_ptr1        :pointer);           inline; {$ifdef Linux}[local];{$endif}
      // Write data:
      procedure WrtNodeData           (const data_write;
                                             data_shift       :integer;
                                             proc0            :TProc21;
                                             proc1            :TProc22);           inline; {$ifdef Linux}[local];{$endif}
      // (Checks if another kind of object is available after selected object(from start_ind) in objects array(obj_arr)) Проверяет есть ли другой вид обьектов после выбранного(начиная с start_ind) в массиве обьектов(obj_arr):
      function  IsAnotherObjKindAfter1(const koo              :TKindOfObject;
                                       const start_ind        :TColor=0): boolean; inline; {$ifdef Linux}[local];{$endif}
      function  IsAnotherObjKindAfter2(const start_ind        :TColor=0): boolean; inline; {$ifdef Linux}[local];{$endif}
      function  IsAnotherObjKindAfter3(const koo              :TKindOfObject;
                                       const start_ind        :TColor=0): boolean; inline; {$ifdef Linux}[local];{$endif}
      function  IsAnotherObjKindAfter4(const koo              :TKindOfObject;
                                       const start_ind        :TColor=0): boolean; inline; {$ifdef Linux}[local];{$endif}
      // (Calculate low and upper layer objects count) Подсчет количества обьектов "нижнего" и "верхнего" слоев:
      function  LowLrObjCntCalc1: TColor;                                          inline; {$ifdef Linux}[local];{$endif}
      procedure LowLrObjCntCalc2;                                                  inline; {$ifdef Linux}[local];{$endif}
      // (Check equality of two objects by kind) Проверка на равенство двух обьектов по виду:
      function  AreTwoObjKindEqual    (const obj_ind1,
                                             obj_ind2         :TColor): boolean;   inline; {$ifdef Linux}[local];{$endif}
      // TODO:
      function  Min9                  (const obj_inds_arr_    :TColorArr;
                                       const arr              :TEdgeArr;
                                       const max_item_val     :TColor;
                                       const item_cnt         :TColor): TColor;    inline; {$ifdef Linux}[local];{$endif}
      function  Min9                  (const obj_inds_arr_    :TColorArr;
                                       const arr              :TSlPtArr;
                                       const max_item_val     :TColor;
                                       const item_cnt         :TColor): TColor;    inline; {$ifdef Linux}[local];{$endif}
      // (Bounding rectangle of points set) Ограничиваюший прямоугольник множества точек:
      function  PtsRngIndsRctCalc     (const pts              :TPtPosFArr;
                                       const sel_pts_inds     :TColorArr;
                                       const pts_cnt          :TColor): TPtRectF;  inline; {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PSceneTree   =^TSceneTree;

  TNodeData    =packed record {$region -fold}
    // Global index of tree node:
    g_ind: TColor;
    // Insert here the required data if needed?
    // ...
  end; {$endregion}
  PNodeData    =^TNodeData;

  TRecInfo     =class  {$region -fold}
    // Record type data:
    rec_data                 : PTypeData;
    // Record type data pointer:
    rec_data_ptr             : PManagedField;
    // Pointers to source and destination instances of the same record type:
    rec_src__ptr,rec_dst__ptr: pointer;
    // Reserved:
    res_var                  : byte;
    // Rec. name:
    rec_name                 : shortstring;
    // Count of rec. fields:
    rec_flds_cnt             : integer;
    // Is type a record:
    loaded_successfully      : boolean;
    // Each array item value is equal to the size of the corresponding record field:
    fld_size_arr             : array of int64;
    // Array of record fields used(non-zero(used) items indices):
    used_fld_inds_arr        : TListItemArr;
    // Each array item value is equal to a specified value obtained by comparing two fields of two different instances(records):
    // 1 - two fields are equal;
    // 0 - otherwise;
    cmp_it_arr               : T2ByteArr;
    // Proc. table:
    proc_arr                 : array of array of procedure(pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte) of object;
    // Array of procedure indices:
    proc_ind_arr             : T1Byte1Arr;
    // Init. part:
    constructor Create;
    // Fin. part:
    destructor Destroy; override;
    // Proc. table:
    procedure Proc00 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc01 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc02 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc03 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc04 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc05 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc06 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc07 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc08 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc09 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc10 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc11 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc12 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc13 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc14 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc15 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc16 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc17 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc18 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc19 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc20 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc21 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc22 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc23 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc24 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc25 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc26 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc27 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc28 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    procedure Proc29 (      pointer0,pointer1:pointer;
                            fld_byte_size    :int64;
                            b_sh             :byte);       inline;
    // Assign record to TRecInfo instance:
    // bitp_fld_arr is a bitmask where each element corresponds to a record field starting from the top field;
    // 1 - field is bitpacked byte;
    // 0 - otherwise;
    procedure Assign (const rec_info         :PTypeInfo;
                      const bitp_fld_arr     :T1Byte1Arr); inline;
    // Each next element of mask_val corresponds to each next eight fields in the record in little endian order:
    procedure MaskTo (const mask_val         :T1Byte1Arr); inline;
    // Fill array cmp_it_arr with specified value "val":
    procedure CmpFil (const val              :byte=1);     inline;
    // Compares the fields of each of the elements of the array of records and stores in the array cmp_it_arr the index of the first record with a field that differs in value:
    procedure CmpRec0(const rec_ptr          :pointer;
                      const rec_instance_size,
                            start_ind,
                            instance_cnt,
                            arr_length       :integer);    inline;
    procedure CmpRec1(const rec_ptr          :pointer;
                      const rec_instance_size:integer;
                      const first_sel_node   :TTreeNode);  inline;

  end; {$endregion}
  PRecInfo     =^TRecInfo;



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
  obj_default_prop: TObjProp={$region -fold}
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
    anim_type                : TLayerType   (00);
    koo                      : TKindOfObject(10);
    obj_show                 : %01110011;
    abstract                 : True;
    is_low_lr_obj            : True;
    is_another_obj_kind_after: False;
    is_an_abst_obj_kind_after: False;
    res_fld                  : 0;
  ); {$endregion}



implementation



uses

  Main;



constructor TSceneTree.Create;                                                                                                                                                                     {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  global_prop :=obj_default_prop;
  curr_obj_ind:=0;
  WrtNodeDataProcArrInit;
end; {$endregion}
destructor  TSceneTree.Destroy;                                                                                                                                                                    {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  self.Free;
  inherited Destroy;
end; {$endregion}
procedure   TSceneTree.FilEmpty;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
end; {$endregion}
procedure   TSceneTree.FilBkgnd;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  srf_var_inst_ptr: PSurface=Nil;
begin
  srf_var_inst_ptr:=@srf_var;
  srf_var_inst_ptr^.FilBkgndObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.FilRGrid;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rgr_var_inst_ptr: PRGrid=Nil;
begin
  rgr_var_inst_ptr:=@rgr_var;
  rgr_var_inst_ptr^.FilRGridObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.FilSGrid;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sgr_var_inst_ptr: PSGrid=Nil;
begin
  sgr_var_inst_ptr:=@sgr_var;
  sgr_var_inst_ptr^.FilSGridObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.FilGroup;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
end; {$endregion}
procedure   TSceneTree.FilTlMap;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  tlm_var_inst_ptr: PTlMap=Nil;
begin
  tlm_var_inst_ptr:=Unaligned(@tlm_var);
  tlm_var_inst_ptr^.FilTileMapObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.FilActor;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.FilPrtcl;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.FilFText;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.FilCurve;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sln_var_inst_ptr: PCurve=Nil;
begin
  sln_var_inst_ptr:=Unaligned(@sln_var);
  sln_var_inst_ptr^.FilSplineObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.FilScene              (start_ind,end_ind:TColor);                                                                                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjProp;
  obj_inds_arr_ptr: PColor;
  i               : integer;
  editor_or_game  : set of byte;
begin
  if (obj_cnt=0) then
    Exit;
  editor_or_game  :=[1+Byte(res_var_ptr^),  3] ;
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=start_ind to end_ind do
    if (((obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.obj_show and %00000011) in editor_or_game) then
      begin
        curr_obj_ind:=(obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.k_ind;
        FilProc[(obj_inds_arr_ptr+i)^];
      end;
end; {$endregion}
procedure   TSceneTree.MovEmpty;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
end; {$endregion}
procedure   TSceneTree.MovBkgnd;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  srf_var_inst_ptr: PSurface=Nil;
begin
  srf_var_inst_ptr:=@srf_var;
  srf_var_inst_ptr^.MovBkgndObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.MovRGrid;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  rgr_var_inst_ptr: PRGrid=Nil;
begin
  rgr_var_inst_ptr:=Unaligned(@rgr_var);
  rgr_var_inst_ptr^.MovRGridObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.MovSGrid;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sgr_var_inst_ptr: PSGrid=Nil;
begin
  sgr_var_inst_ptr:=Unaligned(@sgr_var);
  sgr_var_inst_ptr^.MovSGridObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.MovGroup;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.MovTlMap;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  tlm_var_inst_ptr: PTlMap=Nil;
begin
  tlm_var_inst_ptr:=Unaligned(@tlm_var);
  tlm_var_inst_ptr^.MovTileMapObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.MovActor;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.MovPrtcl;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.MovFText;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

end; {$endregion}
procedure   TSceneTree.MovCurve;                                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  sln_var_inst_ptr: PCurve=Nil;
begin
  sln_var_inst_ptr:=Unaligned(@sln_var);
  sln_var_inst_ptr^.MovSplineObj(curr_obj_ind);
end; {$endregion}
procedure   TSceneTree.MovScene              (start_ind,end_ind:TColor);                                                                                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjProp;
  obj_inds_arr_ptr: PColor;
  i               : integer;
  editor_or_game  : set of byte;
begin
  if (obj_cnt=0) then
    Exit;
  editor_or_game  :=[1+Byte(res_var_ptr^),  3] ;
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=start_ind to end_ind do
    if (((obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.obj_show and %00000011) in editor_or_game) then
      begin
        curr_obj_ind:=(obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.k_ind;
        MovProc[(obj_inds_arr_ptr+i)^];
      end;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftRight;                                                                                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    with obj_arr[i] do
      world_axis_shift.x-=parallax_shift.x;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftRight2;                                                                                                                                            inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    with obj_arr[i] do
      world_axis_shift.x-=spd_mul_ptr^.x*parallax_shift.x;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftLeft;                                                                                                                                              inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    with obj_arr[i] do
      world_axis_shift.x+=parallax_shift.x;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftLeft2;                                                                                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    with obj_arr[i] do
      world_axis_shift.x+=spd_mul_ptr^.x*parallax_shift.x;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftDown;                                                                                                                                              inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    with obj_arr[i] do
      world_axis_shift.y-=parallax_shift.y;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftDown2;                                                                                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    with obj_arr[i] do
      world_axis_shift.y-=spd_mul_ptr^.y*parallax_shift.y;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftUp;                                                                                                                                                inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    with obj_arr[i] do
      world_axis_shift.y+=parallax_shift.y;
end; {$endregion}
procedure   TSceneTree.MovWorldAxisShiftUp2;                                                                                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    with obj_arr[i] do
      world_axis_shift.y+=spd_mul_ptr^.y*parallax_shift.y;
end; {$endregion}
procedure   TSceneTree.SetWorldAxisShift     (world_axis_shift_:TPtPosF);                                                                                                                  inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    with obj_arr[i] do
      begin
        world_axis_shift         :=world_axis_shift_;
        world_axis_shift_centrify:=world_axis_shift ;
      end;
end; {$endregion}
procedure   TSceneTree.SetParallaxShift      (parallax_shift_  :TPtPosF);                                                                                                                  inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    with obj_arr[i] do
      begin
        parallax_shift.x+=parallax_shift_.x;
        parallax_shift.y+=parallax_shift_.y;
      end;
end; {$endregion}
procedure   TSceneTree.SetParallaxShift      (parallax_shift_  :TPtPosF; speed_mul:TPtPosF);                                                                                               inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  if (obj_cnt=0) then
    Exit;
  for i:=0 to obj_cnt-1 do
    with obj_arr[i] do
      begin
        parallax_shift.x*=speed_mul.x;
        parallax_shift.y*=speed_mul.y;
      end;
end; {$endregion}
procedure   TSceneTree.SetRctDstPtr          (rct_dst_ptr_:PPtRect; start_ind,end_ind:TColor);                                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjProp;
  obj_inds_arr_ptr: PColor;
  i               : integer;
begin
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=start_ind to end_ind do
    (obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.rct_dst_ptr:=rct_dst_ptr_;
end; {$endregion}
procedure   TSceneTree.SetFilMovProc         (abstract_:boolean; FilProc_,MovProc_:TProc0; var obj_cnt_:TColor; var inds_obj_arr_,inds_sct_arr_:TColorArr);                                inline; {$ifdef Linux}[local];{$endif} {$region -fold}
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
procedure   TSceneTree.Add                   (const koo:TKindOfObject; const world_axis_shift_:TPtPosF);                                                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_var_ptr: PObjProp;
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
procedure   TSceneTree.SetObjBkgnd           (obj_arr_ptr:PObjProp; const bkgnd_ptr:PInteger; const bkgnd_width,bkgnd_height:TColor; const rct_clp_ptr:PPtRect);                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  obj_arr_ptr^.bkgnd_ptr   :=bkgnd_ptr   ;
  obj_arr_ptr^.bkgnd_width :=bkgnd_width ;
  obj_arr_ptr^.bkgnd_height:=bkgnd_height;
  obj_arr_ptr^.rct_clp_ptr :=rct_clp_ptr ;
end; {$endregion}
procedure   TSceneTree.SetObjBkgnd           (                      const bkgnd_ptr:PInteger; const bkgnd_width,bkgnd_height:TColor; const rct_clp_ptr:PPtRect; start_ind,end_ind:TColor); inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjProp;
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
procedure   TSceneTree.CrtNodeData           (node_with_data:TTreeNode; g_ind:TColor);                                                                                                     inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  node_data_pointer: PNodeData;
begin
  New(node_data_pointer);
  node_data_pointer^.g_ind:=g_ind;
  case obj_var.obj_arr[g_ind].koo of
    kooEmpty: ;
    kooBkgnd: node_with_data.ImageIndex:=15;
    kooRGrid: node_with_data.ImageIndex:=06;
    kooSGrid: node_with_data.ImageIndex:=07;
    kooGroup: node_with_data.ImageIndex:=14;
    kooTlMap: node_with_data.ImageIndex:=16;
    kooActor: node_with_data.ImageIndex:=08;
    kooPrtcl: ;
    kooCurve: node_with_data.ImageIndex:=03;
    kooFText: ;
  end;
  node_with_data.Data:=PNodeData(node_data_pointer);
end; {$endregion}
procedure   TSceneTree.ClrNodeData           (node_with_data:TTreeNode);                                                                                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  if (node_with_data.data<>Nil) then
    Dispose(PNodeData(node_with_data.data));
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProcArrInit;                                                                                                                                             inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

  SetLength(WrtNodeDataProcArr0,28);
  // Byte:
  WrtNodeDataProcArr0[00]:=@WrtNodeDataProc00;
  // Bitpacked Byte:
  WrtNodeDataProcArr0[01]:=@WrtNodeDataProc02;
  // Boolean:
  WrtNodeDataProcArr0[02]:=@WrtNodeDataProc04;
  // Word:
  WrtNodeDataProcArr0[03]:=@WrtNodeDataProc06;
  // LongWord:
  WrtNodeDataProcArr0[04]:=@WrtNodeDataProc08;
  // ShortInt:
  WrtNodeDataProcArr0[05]:=@WrtNodeDataProc10;
  // SmallInt:
  WrtNodeDataProcArr0[06]:=@WrtNodeDataProc12;
  // LongInt:
  WrtNodeDataProcArr0[07]:=@WrtNodeDataProc14;
  // Single:
  WrtNodeDataProcArr0[08]:=@WrtNodeDataProc16;
  // Double:
  WrtNodeDataProcArr0[09]:=@WrtNodeDataProc18;
  // AnsiString:
  WrtNodeDataProcArr0[10]:=@WrtNodeDataProc20;
  // TPtPosF.x:
  WrtNodeDataProcArr0[11]:=@WrtNodeDataProc22;
  // TPtPosF.y:
  WrtNodeDataProcArr0[12]:=@WrtNodeDataProc24;
  // TPtRect.left:
  WrtNodeDataProcArr0[13]:=@WrtNodeDataProc26;
  // TPtRect.top:
  WrtNodeDataProcArr0[14]:=@WrtNodeDataProc28;
  // TPtRect.width:
  WrtNodeDataProcArr0[15]:=@WrtNodeDataProc30;
  // TPtRect.height:
  WrtNodeDataProcArr0[16]:=@WrtNodeDataProc32;
  // TPtRect.right:
  WrtNodeDataProcArr0[17]:=@WrtNodeDataProc34;
  // TPtRect.bottom:
  WrtNodeDataProcArr0[18]:=@WrtNodeDataProc36;
  // TPtPos3.arr[0]:
  WrtNodeDataProcArr0[19]:=@WrtNodeDataProc38;
  // TPtPos3.arr[1]:
  WrtNodeDataProcArr0[20]:=@WrtNodeDataProc40;
  // TPtPos3.arr[2]:
  WrtNodeDataProcArr0[21]:=@WrtNodeDataProc42;
  // TPtPos3.arr[3]:
  WrtNodeDataProcArr0[22]:=@WrtNodeDataProc44;
  // TPtPos3.arr[4]:
  WrtNodeDataProcArr0[23]:=@WrtNodeDataProc46;
  // TPtPos3.arr[5]:
  WrtNodeDataProcArr0[24]:=@WrtNodeDataProc48;
  // TPtPos3.obj_ind:
  WrtNodeDataProcArr0[25]:=@WrtNodeDataProc50;
  // TPtPos3.pts_ind:
  WrtNodeDataProcArr0[26]:=@WrtNodeDataProc52;
  // TPtPos3.dup_pts_cnt:
  WrtNodeDataProcArr0[27]:=@WrtNodeDataProc54;

  SetLength(WrtNodeDataProcArr1,28);
  // Byte:
  WrtNodeDataProcArr1[00]:=@WrtNodeDataProc01;
  // Bitpacked Byte:
  WrtNodeDataProcArr1[01]:=@WrtNodeDataProc03;
  // Boolean:
  WrtNodeDataProcArr1[02]:=@WrtNodeDataProc05;
  // Word:
  WrtNodeDataProcArr1[03]:=@WrtNodeDataProc07;
  // LongWord:
  WrtNodeDataProcArr1[04]:=@WrtNodeDataProc09;
  // ShortInt:
  WrtNodeDataProcArr1[05]:=@WrtNodeDataProc11;
  // SmallInt:
  WrtNodeDataProcArr1[06]:=@WrtNodeDataProc13;
  // LongInt:
  WrtNodeDataProcArr1[07]:=@WrtNodeDataProc15;
  // Single:
  WrtNodeDataProcArr1[08]:=@WrtNodeDataProc17;
  // Double:
  WrtNodeDataProcArr1[09]:=@WrtNodeDataProc19;
  // AnsiString:
  WrtNodeDataProcArr1[10]:=@WrtNodeDataProc21;
  // TPtPosF.x:
  WrtNodeDataProcArr1[11]:=@WrtNodeDataProc23;
  // TPtPosF.y:
  WrtNodeDataProcArr1[12]:=@WrtNodeDataProc25;
  // TPtRect.left:
  WrtNodeDataProcArr1[13]:=@WrtNodeDataProc27;
  // TPtRect.top:
  WrtNodeDataProcArr1[14]:=@WrtNodeDataProc29;
  // TPtRect.width:
  WrtNodeDataProcArr1[15]:=@WrtNodeDataProc31;
  // TPtRect.height:
  WrtNodeDataProcArr1[16]:=@WrtNodeDataProc33;
  // TPtRect.right:
  WrtNodeDataProcArr1[17]:=@WrtNodeDataProc35;
  // TPtRect.bottom:
  WrtNodeDataProcArr1[18]:=@WrtNodeDataProc37;
  // TPtPos3.arr[0]:
  WrtNodeDataProcArr1[19]:=@WrtNodeDataProc39;
  // TPtPos3.arr[1]:
  WrtNodeDataProcArr1[20]:=@WrtNodeDataProc41;
  // TPtPos3.arr[2]:
  WrtNodeDataProcArr1[21]:=@WrtNodeDataProc43;
  // TPtPos3.arr[3]:
  WrtNodeDataProcArr1[22]:=@WrtNodeDataProc45;
  // TPtPos3.arr[4]:
  WrtNodeDataProcArr1[23]:=@WrtNodeDataProc47;
  // TPtPos3.arr[5]:
  WrtNodeDataProcArr1[24]:=@WrtNodeDataProc49;
  // TPtPos3.obj_ind:
  WrtNodeDataProcArr1[25]:=@WrtNodeDataProc51;
  // TPtPos3.pts_ind:
  WrtNodeDataProcArr1[26]:=@WrtNodeDataProc53;
  // TPtPos3.dup_pts_cnt:
  WrtNodeDataProcArr1[27]:=@WrtNodeDataProc55;

end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc00     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PByte(data_ptr0+data_shift)^:=Byte(data_write);
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc01     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PByte(data_ptr0+data_shift)^:=PByte(data_ptr1+data_shift)^;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc02     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PByte(data_ptr0+data_shift)^:=(PByte(data_ptr0+data_shift)^ and (not bit_mask)) or (Byte(data_write) and bit_mask);
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc03     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PByte(data_ptr0+data_shift)^:=PByte(data_ptr1+data_shift)^;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc04     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PBoolean(data_ptr0+data_shift)^:=Boolean(data_write);
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc05     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PBoolean(data_ptr0+data_shift)^:=PBoolean(data_ptr1+data_shift)^;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc06     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PWord(data_ptr0+data_shift)^:=Word(data_write);
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc07     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PWord(data_ptr0+data_shift)^:=PWord(data_ptr1+data_shift)^;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc08     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PLongWord(data_ptr0+data_shift)^:=LongWord(data_write);
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc09     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PLongWord(data_ptr0+data_shift)^:=PLongWord(data_ptr1+data_shift)^;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc10     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PShortInt(data_ptr0+data_shift)^:=ShortInt(data_write);
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc11     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PShortInt(data_ptr0+data_shift)^:=PShortInt(data_ptr1+data_shift)^;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc12     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PSmallInt(data_ptr0+data_shift)^:=SmallInt(data_write);
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc13     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PSmallInt(data_ptr0+data_shift)^:=PSmallInt(data_ptr1+data_shift)^;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc14     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PLongInt(data_ptr0+data_shift)^:=LongInt(data_write);
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc15     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PLongInt(data_ptr0+data_shift)^:=PLongInt(data_ptr1+data_shift)^;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc16     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PSingle(data_ptr0+data_shift)^:=Single(data_write);
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc17     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PSingle(data_ptr0+data_shift)^:=PSingle(data_ptr1+data_shift)^;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc18     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PDouble(data_ptr0+data_shift)^:=Double(data_write);
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc19     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PDouble(data_ptr0+data_shift)^:=PDouble(data_ptr1+data_shift)^;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc20     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PAnsiString(data_ptr0+data_shift)^:=AnsiString(data_write);
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc21     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PAnsiString(data_ptr0+data_shift)^:=PAnsiString(data_ptr1+data_shift)^;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc22     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPosF(data_ptr0+data_shift)^.x:=TPtPosF(data_write).x;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc23     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPosF(data_ptr0+data_shift)^.x:=PPtPosF(data_ptr1+data_shift)^.x;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc24     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPosF(data_ptr0+data_shift)^.y:=TPtPosF(data_write).y;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc25     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPosF(data_ptr0+data_shift)^.y:=PPtPosF(data_ptr1+data_shift)^.y;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc26     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtRect(data_ptr0+data_shift)^.left:=TPtRect(data_write).left;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc27     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtRect(data_ptr0+data_shift)^.left:=PPtRect(data_ptr1+data_shift)^.left;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc28     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtRect(data_ptr0+data_shift)^.top:=TPtRect(data_write).top;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc29     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtRect(data_ptr0+data_shift)^.top:=PPtRect(data_ptr1+data_shift)^.top;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc30     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtRect(data_ptr0+data_shift)^.width:=TPtRect(data_write).width;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc31     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtRect(data_ptr0+data_shift)^.width:=PPtRect(data_ptr1+data_shift)^.width;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc32     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtRect(data_ptr0+data_shift)^.height:=TPtRect(data_write).height;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc33     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtRect(data_ptr0+data_shift)^.height:=PPtRect(data_ptr1+data_shift)^.height;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc34     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtRect(data_ptr0+data_shift)^.right:=TPtRect(data_write).right;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc35     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtRect(data_ptr0+data_shift)^.right:=PPtRect(data_ptr1+data_shift)^.right;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc36     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtRect(data_ptr0+data_shift)^.bottom:=TPtRect(data_write).bottom;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc37     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtRect(data_ptr0+data_shift)^.bottom:=PPtRect(data_ptr1+data_shift)^.bottom;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc38     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.arr[0]:=TPtPos3(data_write).arr[0];
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc39     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.arr[0]:=PPtPos3(data_ptr1+data_shift)^.arr[0];
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc40     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.arr[1]:=TPtPos3(data_write).arr[1];
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc41     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.arr[1]:=PPtPos3(data_ptr1+data_shift)^.arr[1];
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc42     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.arr[2]:=TPtPos3(data_write).arr[2];
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc43     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.arr[2]:=PPtPos3(data_ptr1+data_shift)^.arr[2];
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc44     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.arr[3]:=TPtPos3(data_write).arr[3];
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc45     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.arr[3]:=PPtPos3(data_ptr1+data_shift)^.arr[3];
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc46     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.arr[4]:=TPtPos3(data_write).arr[4];
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc47     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.arr[4]:=PPtPos3(data_ptr1+data_shift)^.arr[4];
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc48     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.arr[5]:=TPtPos3(data_write).arr[5];
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc49     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.arr[5]:=PPtPos3(data_ptr1+data_shift)^.arr[5];
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc50     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.obj_ind:=TPtPos3(data_write).obj_ind;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc51     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.obj_ind:=PPtPos3(data_ptr1+data_shift)^.obj_ind;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc52     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.pts_ind:=TPtPos3(data_write).pts_ind;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc53     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.pts_ind:=PPtPos3(data_ptr1+data_shift)^.pts_ind;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc54     (const data_write; data_shift:integer; data_ptr0          :pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.dup_pts_cnt:=TPtPos3(data_write).dup_pts_cnt;
end; {$endregion}
procedure   TSceneTree.WrtNodeDataProc55     (const data_write; data_shift:integer; data_ptr0,data_ptr1:pointer);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  PPtPos3(data_ptr0+data_shift)^.dup_pts_cnt:=PPtPos3(data_ptr1+data_shift)^.dup_pts_cnt;
end; {$endregion}
procedure   TSceneTree.WrtNodeData           (const data_write; data_shift:integer; proc0:TProc21;proc1:TProc22);                                                                          inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjProp;
  obj_inds_arr_ptr: PColor;
  sel_inds_arr_ptr: PColor;
  i               : integer;
begin
  if (sel_cnt=0) then
    Exit;
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  sel_inds_arr_ptr:=Unaligned(@sel_inds_arr[0]);
  for i:=0 to sel_cnt-1 do
    proc0(data_write,data_shift,PByte(obj_arr_ptr+(obj_inds_arr_ptr+(sel_inds_arr_ptr+i)^)^));
    proc1(data_write,data_shift,PByte(obj_arr_ptr+(obj_inds_arr_ptr+000000000000000000000)^),
                                PByte(obj_arr_ptr+(obj_inds_arr_ptr+000000000000000000001)^));
end; {$endregion}
// (Checks if another kind of object is available after selected object(from start_ind) in objects array(obj_arr)) Проверяет есть ли другой вид обьектов после выбранного(начиная с start_ind) в иерархии сцены(scene tree):
function    TSceneTree.IsAnotherObjKindAfter1(const koo:TKindOfObject; const start_ind:TColor=0): boolean;                                                                                 inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjProp;
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
function    TSceneTree.IsAnotherObjKindAfter2(                         const start_ind:TColor=0): boolean;                                                                                 inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjProp;
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
function    TSceneTree.IsAnotherObjKindAfter3(const koo:TKindOfObject; const start_ind:TColor=0): boolean;                                                                                 inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjProp;
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
function    TSceneTree.IsAnotherObjKindAfter4(const koo:TKindOfObject; const start_ind:TColor=0): boolean;                                                                                 inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjProp;
  obj_inds_arr_ptr: PColor;
  i               : integer;
begin
  Result          :=False;
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  for i:=start_ind to Length(obj_arr)-1 do
    if    (((obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.koo<>koo) and
      ((not (obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.abstract) and
          (((obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.obj_show  and %00000001)=1))) then
      begin
        Result:=True;
        Break;
      end;
end; {$endregion}
// (Calculate low and upper layer objects count) Подсчет количества обьектов "нижнего" и "верхнего" слоев:
function    TSceneTree.LowLrObjCntCalc1: TColor;                                                                                                                                           inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  obj_arr_ptr     : PObjProp;
  obj_inds_arr_ptr: PColor;
  i               : integer;
  p_s0            : TPtPosF;
  p_s1            : byte;
begin
  Result:=Length(obj_inds_arr);
  if (Result=1) then
    Exit;
  obj_arr_ptr     :=Unaligned(@obj_arr     [0]);
  obj_inds_arr_ptr:=Unaligned(@obj_inds_arr[0]);
  p_s0            :=obj_arr[obj_inds_arr[0]].parallax_shift;
  p_s1            :=obj_arr[obj_inds_arr[0]].obj_show;
  for i:=1 to Length(obj_arr)-1 do
    if      ((obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.anim_type<>ltStatic) or
      (not (((obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.parallax_shift.x=p_s0.x) and
            ((obj_arr_ptr+(obj_inds_arr_ptr+i)^)^.parallax_shift.y=p_s0.y))) then
      begin
        Result:=i;
        Break;
      end;
  low_lr_obj_cnt:=Result;
  upp_lr_obj_cnt:=obj_cnt-low_lr_obj_cnt;
end; {$endregion}
procedure   TSceneTree.LowLrObjCntCalc2;                                                                                                                                                   inline; {$ifdef Linux}[local];{$endif} {$region -fold}
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
function    TSceneTree.AreTwoObjKindEqual    (const obj_ind1,obj_ind2:TColor): boolean;                                                                                                    inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  Result:=(obj_arr[obj_ind1].koo=obj_arr[obj_ind2].koo);
end; {$endregion}
//
function    TSceneTree.Min9                  (const obj_inds_arr_:TColorArr; const arr:TEdgeArr; const max_item_val:TColor; const item_cnt:TColor): TColor;                                inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  Result:=max_item_val;
  for i:=0 to item_cnt-1 do
    if       (obj_arr[obj_inds_arr_[arr[i].obj_ind]].t_ind<=Result) then
      Result:=obj_arr[obj_inds_arr_[arr[i].obj_ind]].t_ind;
end; {$endregion}
function    TSceneTree.Min9                  (const obj_inds_arr_:TColorArr; const arr:TSlPtArr; const max_item_val:TColor; const item_cnt:TColor): TColor;                                inline; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  i: integer;
begin
  Result:=max_item_val;
  for i:=0 to item_cnt-1 do
    if       (obj_arr[obj_inds_arr_[arr[i].obj_ind]].t_ind<=Result) then
      Result:=obj_arr[obj_inds_arr_[arr[i].obj_ind]].t_ind;
end; {$endregion}
// (Bounding rectangle of points set) Ограничиваюший прямоугольник множества точек:
function    TSceneTree.PtsRngIndsRctCalc     (const pts:TPtPosFArr; const sel_pts_inds:TColorArr; const pts_cnt:TColor): TPtRectF;                                                         inline; {$ifdef Linux}[local];{$endif} {$region -fold}
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
//
constructor TRecInfo.Create;                                                                     {$region -fold}
begin

  SetLength(proc_arr,10);

  {Byte, Boolean, Word, LongWord, ShortInt, SmallInt, LongInt, Single, Double, Enum}
  SetLength(proc_arr[0],1);
  proc_arr[0][0]:=@Proc00;

  {AnsiString}
  SetLength(proc_arr[1],1);
  proc_arr[1][0]:=@Proc01;

  {TPtPosF}
  SetLength(proc_arr[2],2);
  proc_arr[2][0]:=@Proc02;
  proc_arr[2][1]:=@Proc03;

  {TPtRect}
  SetLength(proc_arr[3],6);
  proc_arr[3][0]:=@Proc04;
  proc_arr[3][1]:=@Proc05;
  proc_arr[3][2]:=@Proc06;
  proc_arr[3][3]:=@Proc07;
  proc_arr[3][4]:=@Proc08;
  proc_arr[3][5]:=@Proc09;

  {TPtPos3}
  SetLength(proc_arr[4],9);
  proc_arr[4][0]:=@Proc10;
  proc_arr[4][1]:=@Proc11;
  proc_arr[4][2]:=@Proc12;
  proc_arr[4][3]:=@Proc13;
  proc_arr[4][4]:=@Proc14;
  proc_arr[4][5]:=@Proc15;
  proc_arr[4][6]:=@Proc16;
  proc_arr[4][7]:=@Proc17;
  proc_arr[4][8]:=@Proc18;

  {PByte}
  SetLength(proc_arr[5],1);
  proc_arr[5][0]:=@Proc19;

  {PColor, PLongWord}
  SetLength(proc_arr[6],1);
  proc_arr[6][0]:=@Proc20;

  {PPtPosF}
  SetLength(proc_arr[7],2);
  proc_arr[7][0]:=@Proc21;
  proc_arr[7][1]:=@Proc22;

  {PPtRect}
  SetLength(proc_arr[8],6);
  proc_arr[8][0]:=@Proc23;
  proc_arr[8][1]:=@Proc24;
  proc_arr[8][2]:=@Proc25;
  proc_arr[8][3]:=@Proc26;
  proc_arr[8][4]:=@Proc27;
  proc_arr[8][5]:=@Proc28;

  {Bitpacked Byte}
  SetLength(proc_arr[9],8);
  proc_arr[9][0]:=@Proc29;
  proc_arr[9][1]:=@Proc29;
  proc_arr[9][2]:=@Proc29;
  proc_arr[9][3]:=@Proc29;
  proc_arr[9][4]:=@Proc29;
  proc_arr[9][5]:=@Proc29;
  proc_arr[9][6]:=@Proc29;
  proc_arr[9][7]:=@Proc29;

end; {$endregion}
destructor  TRecInfo.Destroy;                                                                    {$region -fold}
begin
  self.Free;
  inherited Destroy;
end; {$endregion}
procedure   TRecInfo.Proc00 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(CompareMem(pointer0,pointer1,fld_byte_size));
end; {$endregion}
procedure   TRecInfo.Proc01 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PAnsiString(pointer0)^=PAnsiString(pointer1)^);
end; {$endregion}
procedure   TRecInfo.Proc02 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtPosF(pointer0)^.x=PPtPosF(pointer1)^.x);
end; {$endregion}
procedure   TRecInfo.Proc03 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtPosF(pointer0)^.y=PPtPosF(pointer1)^.y);
end; {$endregion}
procedure   TRecInfo.Proc04 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtRect(pointer0)^.left=PPtRect(pointer1)^.left);
end; {$endregion}
procedure   TRecInfo.Proc05 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtRect(pointer0)^.top=PPtRect(pointer1)^.top);
end; {$endregion}
procedure   TRecInfo.Proc06 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtRect(pointer0)^.width=PPtRect(pointer1)^.width);
end; {$endregion}
procedure   TRecInfo.Proc07 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtRect(pointer0)^.height=PPtRect(pointer1)^.height);
end; {$endregion}
procedure   TRecInfo.Proc08 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtRect(pointer0)^.right=PPtRect(pointer1)^.right);
end; {$endregion}
procedure   TRecInfo.Proc09 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtRect(pointer0)^.bottom=PPtRect(pointer1)^.bottom);
end; {$endregion}
procedure   TRecInfo.Proc10 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtPos3(pointer0)^.arr[0]=PPtPos3(pointer1)^.arr[0]);
end; {$endregion}
procedure   TRecInfo.Proc11 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtPos3(pointer0)^.arr[1]=PPtPos3(pointer1)^.arr[1]);
end; {$endregion}
procedure   TRecInfo.Proc12 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtPos3(pointer0)^.arr[2]=PPtPos3(pointer1)^.arr[2]);
end; {$endregion}
procedure   TRecInfo.Proc13 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtPos3(pointer0)^.arr[3]=PPtPos3(pointer1)^.arr[3]);
end; {$endregion}
procedure   TRecInfo.Proc14 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtPos3(pointer0)^.arr[4]=PPtPos3(pointer1)^.arr[4]);
end; {$endregion}
procedure   TRecInfo.Proc15 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtPos3(pointer0)^.arr[5]=PPtPos3(pointer1)^.arr[5]);
end; {$endregion}
procedure   TRecInfo.Proc16 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtPos3(pointer0)^.obj_ind=PPtPos3(pointer1)^.obj_ind);
end; {$endregion}
procedure   TRecInfo.Proc17 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtPos3(pointer0)^.pts_ind=PPtPos3(pointer1)^.pts_ind);
end; {$endregion}
procedure   TRecInfo.Proc18 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte(PPtPos3(pointer0)^.dup_pts_cnt=PPtPos3(pointer1)^.dup_pts_cnt);
end; {$endregion}
procedure   TRecInfo.Proc19 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
var
  ptr0,ptr1: pointer;
begin
  ptr0   :=PByte(pointer0^);
  ptr1   :=PByte(pointer1^);
  if (ptr0=Nil) then
    begin
      if (ptr1=Nil) then
        res_var:=1;
    end
  else
    begin
      if (ptr1<>Nil) then
        res_var:=Byte(PByte(ptr0)^=
                      PByte(ptr1)^);
    end;
end; {$endregion}
procedure   TRecInfo.Proc20 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
var
  ptr0,ptr1: pointer;
begin
  ptr0   :=PColor(pointer0^);
  ptr1   :=PColor(pointer1^);
  if (ptr0=Nil) then
    begin
      if (ptr1=Nil) then
        res_var:=1;
    end
  else
    begin
      if (ptr1<>Nil) then
        res_var:=Byte(PColor(ptr0)^=
                      PColor(ptr1)^);
    end;
end; {$endregion}
procedure   TRecInfo.Proc21 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
var
  ptr0,ptr1: pointer;
begin
  ptr0   :=PPtPosF(pointer0^);
  ptr1   :=PPtPosF(pointer1^);
  if (ptr0=Nil) then
    begin
      if (ptr1=Nil) then
        res_var:=1;
    end
  else
    begin
      if (ptr1<>Nil) then
        res_var:=Byte(PPtPosF(ptr0)^.x=
                      PPtPosF(ptr1)^.x);
    end;
end; {$endregion}
procedure   TRecInfo.Proc22 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
var
  ptr0,ptr1: pointer;
begin
  ptr0   :=PPtPosF(pointer0^);
  ptr1   :=PPtPosF(pointer1^);
  if (ptr0=Nil) then
    begin
      if (ptr1=Nil) then
        res_var:=1;
    end
  else
    begin
      if (ptr1<>Nil) then
        res_var:=Byte(PPtPosF(ptr0)^.y=
                      PPtPosF(ptr1)^.y);
    end;
end; {$endregion}
procedure   TRecInfo.Proc23 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
var
  ptr0,ptr1: pointer;
begin
  ptr0   :=PPtRect(pointer0^);
  ptr1   :=PPtRect(pointer1^);
  if (ptr0=Nil) then
    begin
      if (ptr1=Nil) then
        res_var:=1;
    end
  else
    begin
      if (ptr1<>Nil) then
        res_var:=Byte(PPtRect(ptr0)^.left=
                      PPtRect(ptr1)^.left);
    end;
end; {$endregion}
procedure   TRecInfo.Proc24 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
var
  ptr0,ptr1: pointer;
begin
  ptr0   :=PPtRect(pointer0^);
  ptr1   :=PPtRect(pointer1^);
  if (ptr0=Nil) then
    begin
      if (ptr1=Nil) then
        res_var:=1;
    end
  else
    begin
      if (ptr1<>Nil) then
        res_var:=Byte(PPtRect(ptr0)^.top=
                      PPtRect(ptr1)^.top);
    end;
end; {$endregion}
procedure   TRecInfo.Proc25 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
var
  ptr0,ptr1: pointer;
begin
  ptr0   :=PPtRect(pointer0^);
  ptr1   :=PPtRect(pointer1^);
  if (ptr0=Nil) then
    begin
      if (ptr1=Nil) then
        res_var:=1;
    end
  else
    begin
      if (ptr1<>Nil) then
        res_var:=Byte(PPtRect(ptr0)^.width=
                      PPtRect(ptr1)^.width);
    end;
end; {$endregion}
procedure   TRecInfo.Proc26 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
var
  ptr0,ptr1: pointer;
begin
  ptr0   :=PPtRect(pointer0^);
  ptr1   :=PPtRect(pointer1^);
  if (ptr0=Nil) then
    begin
      if (ptr1=Nil) then
        res_var:=1;
    end
  else
    begin
      if (ptr1<>Nil) then
        res_var:=Byte(PPtRect(ptr0)^.height=
                      PPtRect(ptr1)^.height);
    end;
end; {$endregion}
procedure   TRecInfo.Proc27 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
var
  ptr0,ptr1: pointer;
begin
  ptr0   :=PPtRect(pointer0^);
  ptr1   :=PPtRect(pointer1^);
  if (ptr0=Nil) then
    begin
      if (ptr1=Nil) then
        res_var:=1;
    end
  else
    begin
      if (ptr1<>Nil) then
        res_var:=Byte(PPtRect(ptr0)^.right=
                      PPtRect(ptr1)^.right);
    end;
end; {$endregion}
procedure   TRecInfo.Proc28 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
var
  ptr0,ptr1: pointer;
begin
  ptr0   :=PPtRect(pointer0^);
  ptr1   :=PPtRect(pointer1^);
  if (ptr0=Nil) then
    begin
      if (ptr1=Nil) then
        res_var:=1;
    end
  else
    begin
      if (ptr1<>Nil) then
        res_var:=Byte(PPtRect(ptr0)^.bottom=
                      PPtRect(ptr1)^.bottom);
    end;
end; {$endregion}
procedure   TRecInfo.Proc29 (pointer0,pointer1:pointer; fld_byte_size:int64; b_sh:byte); inline; {$region -fold}
begin
  res_var:=Byte((PByte(pointer0)^ and (1<<b_sh))=(PByte(pointer1)^ and (1<<b_sh)));
end; {$endregion}
procedure   TRecInfo.Assign (const rec_info:PTypeInfo; const bitp_fld_arr:T1Byte1Arr  ); inline; {$region -fold}
var
  i: integer;
begin
  loaded_successfully:=True;
  if (not Assigned(rec_info)) or (rec_info^.Kind<>tkRecord) then
    begin
      loaded_successfully:=False;
      Exit;
    end;
  rec_data    :=GetTypeData(rec_info);
  rec_name    :=rec_info^.Name;
  rec_flds_cnt:=rec_data^.TotalFieldCount;
  rec_data_ptr:=Pointer(PByte(@rec_data^.TotalFieldCount)+SizeOf(rec_flds_cnt));
  SetLength(cmp_it_arr  ,rec_flds_cnt);
  SetLength(proc_ind_arr,rec_flds_cnt);
  SetLength(fld_size_arr,rec_flds_cnt);
  for i:=0 to rec_flds_cnt-2 do
    with (rec_data_ptr+i)^.TypeRef^ do
      begin
        // field is bitpacked byte:
        if (bitp_fld_arr[i]=1) then
          begin
            proc_ind_arr[i]:=9;
            SetLength(cmp_it_arr[i],8);
          end
        // field is enumeration:
        else
        if (Kind=tkEnumeration) then
          begin
            proc_ind_arr[i]:=0;
            SetLength(cmp_it_arr[i],1);
          end
        // field is of another kind:
        else
          case Name of
            'Byte','Boolean','Word','LongWord','ShortInt','SmallInt','LongInt','Single','Double':
              begin
                proc_ind_arr[i]:=0;
                SetLength(cmp_it_arr[i],1);
              end;
            'AnsiString'                                                                        :
              begin
                proc_ind_arr[i]:=1;
                SetLength(cmp_it_arr[i],1);
              end;
            'TPtPosF'                                                                           :
              begin
                proc_ind_arr[i]:=2;
                SetLength(cmp_it_arr[i],2);
              end;
            'TPtRect'                                                                           :
              begin
                proc_ind_arr[i]:=3;
                SetLength(cmp_it_arr[i],6);
              end;
            'TPtPos3'                                                                           :
              begin
                proc_ind_arr[i]:=4;
                SetLength(cmp_it_arr[i],9);
              end;
            'PByte'                                                                             :
              begin
                proc_ind_arr[i]:=5;
                SetLength(cmp_it_arr[i],1);
              end;
            'PColor','PLongWord'                                                                :
              begin
                proc_ind_arr[i]:=6;
                SetLength(cmp_it_arr[i],1);
              end;
            'PPtPosF'                                                                           :
              begin
                proc_ind_arr[i]:=7;
                SetLength(cmp_it_arr[i],2);
              end;
            'PPtRect'                                                                           :
              begin
                proc_ind_arr[i]:=8;
                SetLength(cmp_it_arr[i],6);
              end;
          end;
        fld_size_arr[i]:=(rec_data_ptr+i+1)^.FldOffset-
                         (rec_data_ptr+i+0)^.FldOffset;
      end;
end; {$endregion}
procedure   TRecInfo.MaskTo (const mask_val:T1Byte1Arr);                                 inline; {$region -fold}
begin
  SetLength(used_fld_inds_arr,NzBitCnt(mask_val,rec_flds_cnt));
  LinkArrIt(mask_val,used_fld_inds_arr);
end; {$endregion}
procedure   TRecInfo.CmpFil (const val:byte=1);                                          inline; {$region -fold}
var
  i: integer;
begin
  for i:=0 to Length(cmp_it_arr)-1 do
    FillByte(cmp_it_arr[i][0],Length(cmp_it_arr[i]),val);
end; {$endregion}
procedure   TRecInfo.CmpRec0(const rec_ptr:pointer; const rec_instance_size,start_ind,instance_cnt,arr_length:integer                                ); inline; {$region -fold}
var
  used_fld_inds_arr_ptr: PListItem;
  i,j                  : integer;
begin
  rec_src__ptr         :=rec_ptr;
  rec_dst__ptr         :=rec_ptr;
  used_fld_inds_arr_ptr:=@used_fld_inds_arr[0];
  while (used_fld_inds_arr_ptr<>Nil) do
    with used_fld_inds_arr_ptr^ do
      begin
        used_fld_inds_arr_ptr:=next_item_ptr;
        for j:=0 to Length(cmp_it_arr[ind])-1 do
          begin
            rec_src__ptr:=rec_ptr+start_ind*rec_instance_size;
            for i:=start_ind to Min(arr_length,start_ind+instance_cnt)-1 do
              begin
                rec_dst__ptr:=rec_ptr+i*rec_instance_size; // move to the next item of the record array;
                proc_arr[proc_ind_arr     [ind]][j]
               (rec_src__ptr+(rec_data_ptr+ind)^.FldOffset,
                rec_dst__ptr+(rec_data_ptr+ind)^.FldOffset,
                fld_size_arr              [ind],(j));
                    cmp_it_arr            [ind] [j]:=res_var;
                if (cmp_it_arr            [ind] [j]=0) then
                  Break;
              end;
          end;
      end;
end; {$endregion}
procedure   TRecInfo.CmpRec1(const rec_ptr:pointer; const rec_instance_size                                  :integer; const first_sel_node:TTreeNode); inline; {$region -fold}
var
  next_selected_node   : TTreeNode;
  used_fld_inds_arr_ptr: PListItem;
  j                    : integer;
begin
  rec_src__ptr         :=rec_ptr;
  rec_dst__ptr         :=rec_ptr;
  used_fld_inds_arr_ptr:=@used_fld_inds_arr[0];
  while (used_fld_inds_arr_ptr<>Nil) do
    with used_fld_inds_arr_ptr^ do
      begin
        used_fld_inds_arr_ptr:=next_item_ptr;
        for j:=0 to Length(cmp_it_arr[ind])-1 do
          begin
            next_selected_node:=first_sel_node;
            rec_src__ptr      :=rec_ptr+PNodeData(next_selected_node.Data)^.g_ind*rec_instance_size;
            while (next_selected_node<>Nil) do
              begin
                rec_dst__ptr  :=rec_ptr+PNodeData(next_selected_node.Data)^.g_ind*rec_instance_size; // move to the next item of the record array;
                proc_arr[proc_ind_arr     [ind]][j]
               (rec_src__ptr+(rec_data_ptr+ind)^.FldOffset,
                rec_dst__ptr+(rec_data_ptr+ind)^.FldOffset,
                fld_size_arr              [ind],(j));
                    cmp_it_arr            [ind] [j]:=res_var;
                if (cmp_it_arr            [ind] [j]<>0) then
                  next_selected_node:=next_selected_node.GetNextMultiSelected
                else
                  Break;
              end;
          end;
      end;
end; {$endregion}

end.

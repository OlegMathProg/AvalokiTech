(*
procedure TF_MainForm.CCB_2D_Operations_AutomaticSelect(Sender:TObject);
var
  i,j: integer;
  set_of_items_indices        : set of byte;
  array_of_items_indices_true : array of set of byte;
  array_of_items_indices_false: array of set of byte;
begin
  Setlength(array_of_items_indices_true,CCB_2D_Operations_Automatic.Items.Count);
  Setlength(array_of_items_indices_false,CCB_2D_Operations_Automatic.Items.Count);
  array_of_items_indices_true[0]:=[0];  // Список контролов для выбранной фичи
  array_of_items_indices_true[1]:=[1];  // ...
  array_of_items_indices_true[2]:=[2];
  array_of_items_indices_true[3]:=[3];
  array_of_items_indices_true[4]:=[4];
  array_of_items_indices_true[5]:=[5];
  array_of_items_indices_true[6]:=[6];
  array_of_items_indices_true[7]:=[7];
  array_of_items_indices_true[8]:=[8];
  array_of_items_indices_true[9]:=[9];
  for i:=0 to CCB_2D_Operations_Automatic.Items.Count-1 do
    begin
      set_of_items_indices:=[0,1,2,3,4,5,6,7,8,9,10,11];
      Exclude(set_of_items_indices,i);
      array_of_items_indices_false[i]:=set_of_items_indices;
        if CCB_2D_Operations_Automatic.ItemIndex=i then
          begin
            for j in array_of_items_indices_true[i] do
              P_2D_Operations_Automatic.Controls[j].Visible:=True;
            for j in array_of_items_indices_false[i] do
              P_2D_Operations_Automatic.Controls[j].Visible:=False;
          end;
    end;
  InvalidateRegion;
end;
*)

(*
procedure TTempCanvas.TempBmpPrepareDraw; {$ifdef Linux}[local];{$endif}
label
  {Texture}
  label11,label12,label13,label14,
  {Grid}
  label21,label22,label23,label24,
  {Spline}
  label31,label32,label33,label34,
  {Spline Points}
  label35,label36,label37,label38,label39,
  {Spline Edges}
  label40,label41,label42,label43,label44,
  {Snap Grid}
  label61,label62,label63,label64,label65,label66,label67,label68,label69,label70,label71,label72,
  {Unselect Pivot}
  unselect_pivot1,unselect_pivot2;
begin

  ;;;;;;;;;;;;;;;;;;;;;(Calculation Temporary Bitmap begin);;;;;;;;;;;;;;;;;;
  selected_pts_exp1:=(selected_pts_count>0);
  selected_pts_exp2:=(selected_pts_count<>spline_pts_count);
  selected_pts_exp3:=(spline_pts_count>0);
  {Change Visibility Tex}
  if change_visibility_tex then
    goto label14;
  {Change Visibility Grid}
  if change_visibility_grid then
    goto label24;
  {Change Visibility Spline}
  if change_visibility_spline then
    goto label34;
  {Change Visibility Spline Edges}
  if change_visibility_spline_pts then
    goto label40;
  {Change Visibility Spline Points}
  if change_visibility_spline_pts then
    goto label35;
  {Change Visibility Snap Grid}
  if change_visibility_snap_grid then
    goto label72;
  {Snap Grid Precision Button Enter}
  if pts_alignment_var.snap_grid_pr_ch_enter then
    goto label67;
  {Snap Grid Precision Change}
  if pts_alignment_var.snap_grid_precision_change then
    goto label64;
  {Calculation of Main Layer Rectangle}
  if temp_bmp_calc then
    TempBmpRectCalc;
  {Calculation of Main Layer}
  if temp_bmp_calc then
    TempBmpCalc;
  {Calculation of Grid}
  if show_grid then
    if grid_calc then
      GridCalc(tex_bmp_rect);
  {Calculation of Snap Grid}
  label64:
  if show_snap_grid then
    if pts_alignment_var.snap_grid_calc then
      pts_alignment_var.SnapGridCalc;
  if pts_alignment_var.snap_grid_precision_change then
    goto label65;
  {Align 2DPoints}
  if (F_MainForm.CCB_2D_Operations_Automatic.State[0]=cbChecked) then
    pts_alignment_var.Align2DPts(spline_pts,selected_pts_indices);
  {Select 2DPoints and Pivot}
  if selected_pts_exp3 then
    begin
      SplineCalc;
      if selected_pts_exp1 then
        begin
          if (not unselect_pivot) then
            begin
              SelectedPtsRectCalc;
              SelectedPtsCalc;
            end;
          SubgraphCalc;
          PivotCalc(spline_pts,selected_pts_indices,selected_pts_count);
        end;
    end;
  ;;;;;;;;;;;;;;;;;;;;;;(Calculation Temporary Bitmap end);;;;;;;;;;;;;;;;;;;

  ;;;;;;;;;;;;;;;;;;;;;;(Drawing to Temporary Bitmap begin);;;;;;;;;;;;;;;;;;;
  need_repaint:=True;

  {Unselect Pivot Buffer}
  if unselect_pivot then
    temp_canvas_var.TempBmpLowerLayerToTempBmp;

  label14:
  label24:
  label34:
  label40:
  label35:
  label67:
  label72:

  {Drawing Background}
  with temp_bmp.Canvas do
    begin
      Pen.Color:=background_color;
      FillRect(temp_bmp_layer1_tex_rect);
    end;

  {Drawing Texture}
  if show_tex then
    TexToBmp(tex_bmp_rect,temp_bmp.Canvas);

  {Drawing Grid}
  if show_grid then
    begin
      begin
        if change_visibility_tex then
          goto label11;
        if change_visibility_grid then
          goto label21;
        if change_visibility_spline then
          goto label31;
        if change_visibility_spline_edges then
          goto label41;
        if change_visibility_spline_pts then
          goto label36;
        if change_visibility_snap_grid then
          goto label61;
        if unselect_pivot then
          goto unselect_pivot1;
        if pts_alignment_var.snap_grid_pr_ch_enter then
          goto label68;
      end;
      LayerBackgroundDraw(temp_bmp_layer2_grid_rect,temp_bmp_layer2_grid.Canvas,temp_bmp_layer2_grid);
      GridToBmp(tex_bmp_rect,temp_bmp_layer2_grid.Canvas);
      begin
        label11:
        label21:
        label31:
        label41:
        label36:
        label61:
        unselect_pivot1:
        label68:
      end;
      BmpToBmp(temp_bmp_layer2_grid_rect,temp_bmp.Canvas,temp_bmp_layer2_grid.Canvas,SRCAND{MERGEPAINT});
    end;

  {Drawing Spline}
  if show_spline then
    if (not unselect_pivot) and
       (not add_spline)    then
      begin
        begin
          if change_visibility_tex then
            goto label12;
          if change_visibility_grid then
            goto label22;
          if change_visibility_spline then
            goto label32;
          if change_visibility_spline_edges then
            goto label42;
          if change_visibility_spline_pts then
            goto label37;
          if change_visibility_snap_grid then
            goto label62;
          if pts_alignment_var.snap_grid_pr_ch_enter then
            goto label69;
        end;
        if (not change_visibility_spline_pts) then
          begin
            {Spline Edges}
            LayerBackgroundDraw(temp_bmp_layer3_spline_rect,temp_bmp_layer3a_spline_edges.Canvas,temp_bmp_layer3a_spline_edges);
            {Spline Points}
            LayerBackgroundDraw(temp_bmp_layer3_spline_rect,temp_bmp_layer3b_spline_pts.Canvas,temp_bmp_layer3b_spline_pts);
            if (not spline_smpl_angle_change) then
              begin
                if show_spline_edges then
                  SplineEdgesToBmp(temp_bmp_layer3_spline_rect,temp_bmp_layer3a_spline_edges.Canvas);
                if show_spline_pts then
                  SplinePtsToBmp(temp_bmp_layer3_spline_rect,temp_bmp_layer3b_spline_pts.Canvas);
              end
            else
              begin
                if show_spline_edges then
                  SplineEdgesToBmp(temp_bmp_layer3_spline_rect,temp_bmp_layer3a_spline_edges.Canvas);
                if show_spline_pts then
                  SimplifiedSplinePtsToBmp(temp_bmp_layer3_spline_rect,temp_bmp_layer3b_spline_pts.Canvas);
              end;
          end;
        begin
          label12:
          label22:
          label32:
          label42:
          label37:
          label62:
          label69:
        end;
        {Spline Edges}
        if show_spline_edges then
          BmpToBmp(temp_bmp_layer3_spline_rect,temp_bmp.Canvas,temp_bmp_layer3a_spline_edges.Canvas,SRCAND{MERGEPAINT});
        {Spline Points}
        if show_spline_pts then
          BmpToBmp(temp_bmp_layer3_spline_rect,temp_bmp.Canvas,temp_bmp_layer3b_spline_pts.Canvas,SRCAND{MERGEPAINT});
      end;

  {Drawing Snap Grid}
  label65:
  if pts_alignment_var.snap_grid_pr_ch_enter then
    goto label70;
  if show_snap_grid then
    begin
      begin
        if change_visibility_tex then
          goto label13;
        if change_visibility_grid then
          goto label23;
        if change_visibility_spline then
          goto label33;
        if change_visibility_spline_edges then
          goto label43;
        if change_visibility_spline_pts then
          goto label38;
        if change_visibility_snap_grid then
          goto label63;
        if unselect_pivot then
          goto unselect_pivot2;
      end;
      if pts_alignment_var.snap_grid_draw then
        begin
          LayerBackgroundDraw(temp_bmp_layer2_grid_rect,temp_bmp_layer6_snap_grid.Canvas,temp_bmp_layer2_grid);
          pts_alignment_var.SnapGridToBmp(temp_bmp_layer6_snap_grid_rect,temp_bmp_layer6_snap_grid.Canvas);
        end;
      begin
        label13:
        label23:
        label33:
        label43:
        label38:
        label63:
        unselect_pivot2:
      end;
      BmpToBmp(temp_bmp_layer6_snap_grid_rect,temp_bmp.Canvas,temp_bmp_layer6_snap_grid.Canvas,SRCAND{MERGEPAINT});
    end;

  if change_visibility_spline_edges then
    goto label44;

  if change_visibility_spline_pts then
    goto label39;

  if pts_alignment_var.snap_grid_precision_change then
    goto label66;

  label70:
  {Drawing Texture Samples along Spline}
  if show_tex_on_spline then
    TexturesOnSplineToBmp;

  if pts_alignment_var.snap_grid_pr_ch_enter then
    goto label71;

  {Unselect Pivot}
  if unselect_pivot then
    begin
      if (selected_pts_count>0) then
        begin
          if show_spline_edges then
            UnselectPivotAndSplineEdgesToBmp(temp_bmp_layer3_spline_rect,temp_bmp_layer3a_spline_edges.Canvas);
          if show_spline_pts then
            UnselectPivotAndSplinePtsToBmp(temp_bmp_layer3_spline_rect,temp_bmp_layer3b_spline_pts.Canvas);
        end;
      if show_spline_edges then
        BmpToBmp(temp_bmp_layer3_spline_rect,temp_bmp.Canvas,temp_bmp_layer3a_spline_edges.Canvas,SRCAND);
      if show_spline_pts then
        BmpToBmp(temp_bmp_layer3_spline_rect,temp_bmp.Canvas,temp_bmp_layer3b_spline_pts.Canvas,SRCAND);
    end;

  {Add spline}
  if add_spline then
    begin
      AddSplineEdgesToBmp(temp_bmp_layer3_spline_rect,temp_bmp_layer3a_spline_edges.Canvas);
      AddSplinePtsToBmp(temp_bmp_layer3_spline_rect,temp_bmp_layer3b_spline_pts.Canvas);
      if show_spline_edges then
        BmpToBmp(temp_bmp_layer3_spline_rect,temp_bmp.Canvas,temp_bmp_layer3a_spline_edges.Canvas,SRCAND);
      if show_spline_pts then
        BmpToBmp(temp_bmp_layer3_spline_rect,temp_bmp.Canvas,temp_bmp_layer3b_spline_pts.Canvas,SRCAND);
    end;

  label71:
  {Drawing Temp Lower Layer}
  TempBmpLowerLayerToBmp;

  label44:
  label39:
  label66:
  InvalidateRegion;
  need_repaint:=False;
  ;;;;;;;;;;;;;;;;;;;;;;;(Drawing to Temporary Bitmap end);;;;;;;;;;;;;;;;;;;;

end;
*)

(*
function PivotToPointCalc(X,Y:integer; const pts:array of TPoint): boolean; {$ifdef Linux}[local];{$endif}
var
  i,m,v,inf,sup,ind_of_min: integer;
  b: boolean;
begin

  m:=circle_selection_var.circle_radius*
     circle_selection_var.circle_radius;
  inf:=0;
  sup:=m;
  ind_of_min:=0;

  for i:=0 to spline_pts_count-1 do
    begin
      v:=(pts[i].x-X)*(pts[i].x-X)+
         (pts[i].y-Y)*(pts[i].y-Y);
      if v<=m then
        begin
          if (not is_point_in_circle[i]) then
            begin
              is_point_in_circle[i]:=True;
              if (v<=sup-inf) then
                begin
                  inf:=sup-v;
                  ind_of_min:=i;
                end;
            end;
          if is_point_in_circle[i] then
            is_point_in_circle[i]:=False;
        end;
    end;

  b:=(pts[ind_of_min].x-X)*(pts[ind_of_min].x-X)+
     (pts[ind_of_min].y-Y)*(pts[ind_of_min].y-Y)<=m;

  if b then
    begin
      {if selected_pts_not_bmp then
        if pivot_pos_pred=pivot then
          begin}
            {SelectedPtsPositionCalc(pivot_pos_pred.x,pivot_pos_pred.y);}
            pivot.x:=pts[ind_of_min].x;
            pivot.y:=pts[ind_of_min].y;
            {SelectedPtsPositionCalc(pivot_pos_pred.x,pivot_pos_pred.y);}
    end

  else
    begin
      {if selected_pts_not_bmp then
        SelectedPtsPositionCalc(X,Y);}
      pivot.x:=X;
      pivot.y:=Y;
    end;

  {pivot_pos_pred:=pivot;}

  Result:=b;

  {F_MainForm.Memo1.Text:='pivot_pos_pred='+InttoStr(pivot_pos_pred.x)+#13+
                         'pivot='         +InttoStr(pivot.x)+#13;}

  {Collision Calc}
  {
  b:=(pts[ind_of_min].x-X)*(pts[ind_of_min].x-X)+
     (pts[ind_of_min].y-Y)*(pts[ind_of_min].y-Y)<=m;

  if b then
    begin
      if selected_pts_not_bmp then
        if pivot_pos_pred=pivot then
          begin
            SelectedPtsPositionCalc(pivot_pos_pred.x,pivot_pos_pred.y);
            pivot.x:=pts[ind_of_min].x;
            pivot.y:=pts[ind_of_min].y;
            UnselectedPtsCalc;
            pivot_pos_pred:=pivot;
          end;
    end
  else
    begin
      if selected_pts_not_bmp then
        SelectedPtsPositionCalc(X,Y);
      pivot.x:=X;
      pivot.y:=Y;
    end;

  Result:=b;

  F_MainForm.Memo1.Text:='pivot_pos_pred='+InttoStr(pivot_pos_pred.x)+#13+
                         'pivot='         +InttoStr(pivot.x)+#13;
  }

end;
*)

(*
procedure BrushSelection(X,Y:integer); inline; {$ifdef Linux}[local];{$endif}
var
  i,j,k,m1,m2,m3: integer;
begin
  m1:=circle_selection_var.circle_radius*
      circle_selection_var.circle_radius;
  m2:=Round(Screen.Width/2);
  m3:=Round(Screen.Height/2);
  for k:=0 to spline_pts_count-1 do
    if (spline_pts[k].x-X)*(spline_pts[k].x-X)+
       (spline_pts[k].y-Y)*(spline_pts[k].y-Y)<=m1 then
        if (not is_point_selected[k]) then
          begin
            is_point_selected[k]:=True;
            selected_pts_indices[selected_pts_count]:=k;
            Inc(selected_pts_count);
          end;
  with {temp_canvas_var.temp_bmp.Canvas,temp_canvas_var}F_MainForm.Canvas do
    begin
      Brush.Style:=bsSolid;
      Brush.Color:=clGreen;
      Pen.Mode   :=pmMergePenNot;
      Ellipse(Rect(X-circle_selection_var.circle_radius,
                   Y-circle_selection_var.circle_radius,
                   X+circle_selection_var.circle_radius,
                   Y+circle_selection_var.circle_radius));
      Pen.Mode:=pmCopy;


     { Pen.Mode:=pmCopy;
      for i:=0 to m2 do
        for j:=0 to m3 do
          if ((X-2*i)*(X-2*i)+(Y-2*j)*(Y-2*j)<=m1) then
            {$ifdef Windows}
            if (not (Pixels[2*i{-temp_bmp_rect.Left},2*j{-temp_bmp_rect.Top}]=clLime)) then
            {$endif}
              begin
                {$IFDEF Linux}
                Pen.Color:=clLime;
                DrawPoint(2*i{-temp_bmp_rect.Left},2*j{-temp_bmp_rect.Top});
                {$else}
                Pixels[2*i{-temp_bmp_rect.Left},2*j{-temp_bmp_rect.Top}]:=clLime;
                {$endif}
              end;}
    end;
end;
*)

(*
procedure TBrushSelection.BrushSelectionMode; inline; {$ifdef Linux}[local];{$endif}
{var
  i,v: integer;}
begin
  with F_MainForm.Canvas,circle_selection_var do
    begin
      Brush.Style:=bsDiagCross;
      Pen.Mode   :=pmNotXor;
      Brush.Color:=clGreen;
      Pen.Color  :=clTeal;
      Pen.Width  :=2;
      Ellipse(circle_selection);
      Pen.Width  :=1;
      {v:=Trunc(circle_radius/4);
      Line(circle_selection.Left+circle_radius-4*v-1,
           circle_selection.Top +circle_radius-Trunc(sqrt((circle_radius*circle_radius)-(16*v*v)))+1,
           circle_selection.Left+circle_radius-4*v-1,
           circle_selection.Top +circle_radius+Trunc(sqrt((circle_radius*circle_radius)-(16*v*v)))-1);
      Line(circle_selection.Left+circle_radius-Trunc(sqrt((circle_radius*circle_radius)-(16*v*v)))+1,
           circle_selection.Top +circle_radius-4*v-1,
           circle_selection.Left+circle_radius+Trunc(sqrt((circle_radius*circle_radius)-(16*v*v)))-1,
           circle_selection.Top +circle_radius-4*v-1);
      for i:=0 to v-1 do
        begin
          Line(circle_selection.Left+circle_radius-4*i-1,
               circle_selection.Top +circle_radius-Trunc(sqrt((circle_radius*circle_radius)-(16*i*i)))+1,
               circle_selection.Left+circle_radius-4*i-1,
               circle_selection.Top +circle_radius+Trunc(sqrt((circle_radius*circle_radius)-(16*i*i)))-1);
          Line(circle_selection.Left+circle_radius+4*(i+1)-1,
               circle_selection.Top +circle_radius-Trunc(sqrt((circle_radius*circle_radius)-(16*(i+1)*(i+1))))+1,
               circle_selection.Left+circle_radius+4*(i+1)-1,
               circle_selection.Top +circle_radius+Trunc(sqrt((circle_radius*circle_radius)-(16*(i+1)*(i+1))))-1);
          Line(circle_selection.Left+circle_radius-Trunc(sqrt((circle_radius*circle_radius)-(16*i*i)))+1,
               circle_selection.Top +circle_radius-4*i-1,
               circle_selection.Left+circle_radius+Trunc(sqrt((circle_radius*circle_radius)-(16*i*i)))-1,
               circle_selection.Top +circle_radius-4*i-1);
          Line(circle_selection.Left+circle_radius-Trunc(sqrt((circle_radius*circle_radius)-(16*(i+1)*(i+1))))+1,
               circle_selection.Top +circle_radius+4*(i+1)-1,
               circle_selection.Left+circle_radius+Trunc(sqrt((circle_radius*circle_radius)-(16*(i+1)*(i+1))))-1,
               circle_selection.Top +circle_radius+4*(i+1)-1);
        end;}
    end;
end;
*)

(*
SplineMarginOutOfRectCalc
 if (Left<F_MainForm.S_Border2.Left+10) then
   if (F_MainForm.S_Border2.Left+10-Left>margin_out_of_window) then
     Left:=F_MainForm.S_Border2.Left+10 -margin_out_of_window;
 if (Top<F_MainForm.P_Border6.Top+10) then
   if (F_MainForm.P_Border6.Top+10-Top>margin_out_of_window) then
     Top:=F_MainForm.P_Border6.Top+10 -margin_out_of_window;
 if (Right>F_MainForm.S_Border4.Left) then
   if (Right-F_MainForm.S_Border4.Left>margin_out_of_window) then
     Right :=F_MainForm.S_Border4.Left+margin_out_of_window;
 if (Bottom>F_MainForm.S_Border3.Top) then
   if (Bottom-F_MainForm.S_Border3.Top>margin_out_of_window) then
     Bottom :=F_MainForm.S_Border3.Top+margin_out_of_window;
*)


{Anti-Aliasing}
{if ((line_first_pt_ptr-arr_dst_width-1)^<>0) and ((arr_dst_ptr+arr_dst_width)^<>0) then
   begin
     if (arr_src[line_first_pt_ptr-arr_dst_left_ptr-1+arr_src_width*(rect_dst_top+y)]<>0) then
       arr_alpha_ptr^.line_kind:=0  // 0 - horizontal line: 2 points from left to right;
     else
       arr_alpha_ptr^.line_kind:=1; // 1 - horizontal line: 2 points from right to left;
   end
 else
 if ((line_first_pt_ptr+arr_dst_width-1)^<>0) and ((arr_dst_ptr-arr_dst_width)^<>0) then
   begin
     if (arr_src[line_first_pt_ptr-arr_dst_left_ptr-1+arr_src_width*(rect_dst_top+y)]<>0) then
       arr_alpha_ptr^.line_kind:=0  // 0 - horizontal line: 2 points from left to right;
     else
       arr_alpha_ptr^.line_kind:=1; // 1 - horizontal line: 2 points from right to left;
   end
 else
 if (((line_first_pt_ptr-arr_dst_width-1)^<>0) and ((arr_dst_ptr-arr_dst_width)^<>0)) then
   begin
     if (arr_src[line_first_pt_ptr-arr_dst_left_ptr-1+arr_src_width*(rect_dst_top+y)]<>0) then
       arr_alpha_ptr^.line_kind:=3  // 3 - horizontal line: inner line from middle to ends;
     else
       arr_alpha_ptr^.line_kind:=2; // 2 - horizontal line: outer line from ends to middle;
   end
 else
 if (((line_first_pt_ptr+arr_dst_width-1)^<>0) and ((arr_dst_ptr+arr_dst_width)^<>0)) then
   begin
     if (arr_src[line_first_pt_ptr-arr_dst_left_ptr-1+arr_src_width*(rect_dst_top+y)]<>0) then
       arr_alpha_ptr^.line_kind:=3  // 3 - horizontal line: inner line from middle to ends;
     else
       arr_alpha_ptr^.line_kind:=2; // 2 - horizontal line: outer line from ends to middle;
   end;}

unit Hot_Keys;

{$mode objfpc}{$H+}

interface

uses

  Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls, Classes, SysUtils;

type

  { TF_Hot_Keys }
  TF_Hot_Keys=class(TForm) {$region -fold}
    LV_Hot_Keys: TListView;
    procedure FormCreate           (sender:TObject);
    procedure FormShow             (sender:TObject);
    procedure FormHide             (sender:TObject);
    procedure LV_Hot_KeysMouseDown (sender:TObject; button:TMouseButton; shift:TShiftState; x,y:integer);
    procedure LV_Hot_KeysMouseEnter(sender:TObject);
    procedure LV_Hot_KeysMouseLeave(sender:TObject);

    private

    public

  end; {$endregion}

var

  F_Hot_Keys : TF_Hot_Keys;
  key_arr    : array of integer;
  key_alt_arr: array of integer;
  prev_key   : char='_';

implementation

uses

  Main;

{$R *.lfm}

{ TF_Hot_Keys }

procedure TF_Hot_Keys.FormCreate           (sender:TObject); {$region -fold}
var
  i: integer;
begin
  with LV_Hot_Keys do
    begin
      Sort;
      SetLength(key_arr    ,Items.Count);
      SetLength(key_alt_arr,Items.Count);
      for i:=0 to Items.Count-1 do
        key_arr[i]:=Ord(Items[i].SubItems[0][1]);
      for i:=0 to Items.Count-1 do
        if (Items[i].SubItems[1]<>'') then
          key_alt_arr[i]:=Ord(Items[i].SubItems[1][1]);
    end;
end; {$endregion}
procedure TF_Hot_Keys.FormShow             (sender:TObject); {$region -fold}
begin
  self.PopUpParent:=F_MainForm;
end; {$endregion}
procedure TF_Hot_Keys.FormHide             (sender:TObject); {$region -fold}
begin
  F_MainForm.MI_Hot_Keys.Checked:=False;
end; {$endregion}
procedure TF_Hot_Keys.LV_Hot_KeysMouseDown (sender:TObject; button:TMouseButton; shift:TShiftState; x,y:integer); {$region -fold}
var
  item_ind: integer;
begin
  with LV_Hot_Keys do
    begin
                    item_ind                                  :=GetItemAt(x,y).Index;
          Items    [item_ind]                     .SubItems[0]:=InputBox('Enter a key','base shortcut'     ,'');
          Items    [item_ind]                     .SubItems[1]:=InputBox('Enter a key','alternate shortcut','');
      if (Items    [item_ind]                     .SubItems[0]<>'') then
        key_arr    [item_ind]:=Ord(Items[item_ind].SubItems[0][1]);
      if (Items    [item_ind]                     .SubItems[1]<>'') then
        key_alt_arr[item_ind]:=Ord(Items[item_ind].SubItems[1][1]);
      Selected:=Nil;
    end;
end; {$endregion}
procedure TF_Hot_Keys.LV_Hot_KeysMouseEnter(sender:TObject); {$region -fold}
begin
  AlphaBlend:=False;
  move_with_child_form:=True;
end; {$endregion}
procedure TF_Hot_Keys.LV_Hot_KeysMouseLeave(sender:TObject); {$region -fold}
begin
  AlphaBlend:=True;
  AlphaBlendValue:=150;
end; {$endregion}

end.


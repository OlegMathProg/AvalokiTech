unit Image_Editor;

{$mode objfpc}{$H+}

interface

uses

  Classes, SysUtils, Forms, Controls, Graphics, Dialogs;



type

  { TF_Image_Editor }
  TF_Image_Editor=class(TForm) {$region -fold}
    procedure FormCreate(sender:TObject);
    procedure FormShow  (sender:TObject);
  private

  public

  end; {$endregion}



var

  F_Image_Editor: TF_Image_Editor;



implementation

uses

  Main;

{$R *.lfm}

{ TF_Image_Editor }

procedure TF_Image_Editor.FormCreate(sender:TObject); {$region -fold}
begin
end; {$endregion}
procedure TF_Image_Editor.FormShow  (sender:TObject); {$region -fold}
begin
  self.PopUpParent:=F_MainForm;
end; {$endregion}

end.


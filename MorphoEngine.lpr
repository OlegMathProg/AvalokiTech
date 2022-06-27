program MorphoEngine;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  cmem,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Main, model_viewer, lazopenglcontext, Hot_Keys;

{$R *.res}

begin
  Application.Scaled:=True;
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TF_MainForm,F_MainForm);
  Application.CreateForm(TF_3D_Viewer,F_3D_Viewer);
  Application.CreateForm(TF_Hot_Keys, F_Hot_Keys);
  Application.Run;
end.

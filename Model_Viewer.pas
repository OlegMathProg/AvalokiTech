unit Model_Viewer;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, Controls, ExtCtrls, OpenGLContext, GL, GLU;

type

  { TF_3D_Viewer }
  TF_3D_Viewer=class(TForm) {$region -fold}
    OpenGLControl1: TOpenGLControl;
    T_3DViewer_Timer: TTimer;
    procedure FormCreate(Sender:TObject);
    procedure FormShow(Sender:TObject);
    procedure FormHide(Sender:TObject);
    procedure FormDblClick(Sender:TObject);
    procedure T_3DViewer_TimerTimer(Sender:TObject);

    private

    public

  end; {$endregion}

var
  F_3D_Viewer: TF_3D_Viewer;

implementation

uses
  Main;

{$R *.lfm}

{ TF_3D_Viewer }

procedure TF_3D_Viewer.FormCreate(Sender:TObject);             {$region -fold}
begin
  //OpenGLControl1:=TOpenGLControl.Create(Self);
  {with OpenGLControl1 do begin
    Name:='OpenGLControl2';
    Align:=alClient;
    Parent:=F_3D_Viewer;
    Visible:=False;
  end;}
  //glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  {glEnable(GL_LINE_WIDTH);
  gllinewidth(2.0);}
  {gluPerspective(45,Width/Height,0.1,1000);
  glViewport(0,0,Width,Height);
  gluLookAt(0,0,1,0,0,0,0,1,0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glClearColor(1.0,0.0,0.0,1.0);}
end; {$endregion}
procedure TF_3D_Viewer.FormShow(Sender:TObject);               {$region -fold}
begin
  self.PopupParent:=F_MainForm;
end; {$endregion}
procedure TF_3D_Viewer.FormHide(Sender:TObject);               {$region -fold}
begin
  F_MainForm.MI_3D_Viewer.Checked:=False;
  OpenGLControl1         .Enabled:=False;
  T_3DViewer_Timer       .Enabled:=False;
end; {$endregion}
procedure TF_3D_Viewer.FormDblClick(Sender:TObject);           {$region -fold}
begin
  F_3D_Viewer.BorderStyle:=bsSizeable;
end; {$endregion}
procedure TF_3D_Viewer.T_3DViewer_TimerTimer(Sender:TObject);  {$region -fold}
var
  i: integer;
begin

  //glColor3f(0,0.5,0);
  {glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glBegin(GL_LINES);
  for i:=0 to 1000 do
    begin
      glVertex2f(-1,-1);
      glVertex2f(1,1);
    end;
  glEnd;}

  //VertexBufferObject
  //glDrawArrays;
  //glMultiDrawElementsIndirect;
  //glBufferData;
  {glBegin(GL_QUADS);
    glColor3f (0,1.0,0);
    glVertex2f(-0.5,0.5);
    glColor3f (0,1.0,0);
    glVertex2f(1,-1);
    glColor3f (0,1.0,0);
    glVertex2f(0.5,-0.5);
    glColor3f (0,1.0,0);
    glVertex2f(-0.5,-0.5);
  glEnd;}

  {glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  with srf_var do
    glDrawPixels(srf_bmp.width,srf_bmp.height,GL_RGB,GL_UNSIGNED_BYTE,srf_bmp_ptr);
  OpenGLControl1.SwapBuffers;} // Memory Leak

end; {$endregion}

end.

unit Fast_GL;

{$mode objfpc}{$H+}

interface

uses
  Controls, dglOpenGL, oglContext, oglShader, oglMatrix, OpenGLContext;



type

  TVertex3f    =array[0..2] of GLfloat;
  PVertex3f    =^TVertex3f;

  TFace        =array[0..2] of TVertex3f;
  PFace        =^TFace;

  TVB          =record {$region -fold}
    VAO,VBO: GLuint;
  end; {$endregion}
  PVB          =^TVB;

  TShaderObject=class  {$region -fold}
    public
      RotMatrix  : TMatrix;
      matrix_id  : GLint;
      color_id   : GLint;
      c___       : single;
      VBQuad     : TVB;
      shader     : TShader;
      gl_canvas  : TContext;
      use_shaders: boolean;
      constructor Create(sender:TWinControl);           {$ifdef Linux}[local];{$endif}
      destructor  Destroy;                    override; {$ifdef Linux}[local];{$endif}
      procedure   CreateGLContext;            inline;   {$ifdef Linux}[local];{$endif}
      procedure   InitGLContext;              inline;   {$ifdef Linux}[local];{$endif}
      procedure   DoneGLContext;              inline;   {$ifdef Linux}[local];{$endif}
      procedure   DrawShaders;                inline;   {$ifdef Linux}[local];{$endif}
  end; {$endregion}
  PShaderObject=^TShaderObject;



const

  quad      : array[0..1] of TFace=(((-0.8,-0.8, 0.0),
                                     (-0.8, 0.8, 0.0),
                                     ( 0.8, 0.8, 0.0)),
                                    ((-0.8,-0.8, 0.0),
                                     ( 0.8,-0.8, 0.0),
                                     ( 0.8, 0.8, 0.0)));
  step      : GLfloat=0.01;



var

  shader_var: TShaderObject;



implementation

constructor TShaderObject.Create(sender:TWinControl);         {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  use_shaders:=False;
  InitOpenGL;

  //gl_canvas:=TContext.Create(sender);
  //(gl_canvas as TOpenGLControl).MakeCurrent;

  (sender as TOpenGLControl).MakeCurrent;

  ReadExtensions;
  ReadOpenGLCore;
  ReadImplementationProperties;

  if use_shaders then
    begin
      CreateGLContext;
      InitGLContext;
    end;
end; {$endregion}
destructor  TShaderObject.Destroy;                            {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  DoneGLContext;
end; {$endregion}
procedure TShaderObject.CreateGLContext;              inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  shader   :=TShader.Create([FileToStr('Vertexshader.glsl'),FileToStr('Fragmentshader.glsl')]);
  shader.UseProgram;
  color_iD :=Shader.UniformLocation('col');
  matrix_iD:=Shader.UniformLocation('mat');
  RotMatrix.Identity;
  glGenVertexArrays(1,@VBQuad.VAO);
  glGenBuffers     (1,@VBQuad.VBO);
end; {$endregion}
procedure TShaderObject.InitGLContext;                inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  glClearColor(0.6,0.6,0.4,1.0);
  glBindVertexArray(VBQuad.VAO);
  glBindBuffer(GL_ARRAY_BUFFER,VBQuad.VBO);
  glBufferData(GL_ARRAY_BUFFER,sizeof(quad),@quad,GL_STATIC_DRAW);
  glEnableVertexAttribArray(10);
  glVertexAttribPointer(10,3,GL_FLOAT,False,0,Nil);
end; {$endregion}
procedure TShaderObject.DoneGLContext;                inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  shader.Free;
  glDeleteVertexArrays(1,@VBQuad.VAO);
  glDeleteBuffers     (1,@VBQuad.VBO);
end; {$endregion}
procedure TShaderObject.DrawShaders;                  inline; {$ifdef Linux}[local];{$endif} {$region -fold}
begin

      c___:=c___+0.1;
  if (c___>=10.0) then
      c___:=c___-10.0;

  RotMatrix.RotateC(step);

  glClear(GL_COLOR_BUFFER_BIT);
  Shader.UseProgram;
  RotMatrix.Uniform(matrix_id);
  glUniform1f(color_id,c___);
  glBindVertexArray(VBQuad.VAO);
  glDrawArrays(GL_TRIANGLES,0,Length(quad)*3);
end; {$endregion}

end.

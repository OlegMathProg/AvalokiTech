unit Game;

{
  This file contains some routines for fast 2D packing
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Fast_Primitives;

type
  TLevel=class
    obj_arr: array of TFastActor;
  end;

var
  level_arr: array of TLevel;

implementation


end.


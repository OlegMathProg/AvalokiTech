unit Game;

{
  This file contains some routines for fast 2D packing
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Fast_Primitives;

const
  LOGO1           ='Logo\Logo1.png';
  LOGO2           ='Logo\Logo2.png';
  START_GAME      ='UI\start_game.png';
  SETTINGS        ='UI\settings.png';
  SAVE_AND_EXIT   ='UI\save_and_exit.png';
  SELECTION_BORDER='UI\selection_border.png';
  MILITARY_HEAD   ='UI\military_head_.png';
  EGG_SHAKE       ='Sound\egg_shake.wav';
  EGG_EXPLOSION   ='Sound\egg_explosion.wav';
  DUCK_VOICE1     ='Sound\daffy_duck_hey_stupid.wav';
  LETTERS_DROP    ='Sound\letters_drop.wav';
  LOGO2_MUSIC     ='Sound\logo2.wav';
  SELECT_ITEM     ='Sound\select_item.wav';
  MENU_THEME      ='Sound\popl_uniy_orel.wav';
  INTRO_MOVIE     ='Intro\IntroMovie.avi';

var

  logo1_img              : TFastImage;
  logo2_img              : TFastImage;
  menu_img_arr           : array[0..2] of TFastImage;
  start_game_img         : TFastImage absolute menu_img_arr[0];
  settings_img           : TFastImage absolute menu_img_arr[1];
  save_and_exit_img      : TFastImage absolute menu_img_arr[2];
  selection_border_img   : TFastImage;
  military_head_img      : TFastImage;
  time_interval          : integer;
  menu_img_arr_cnt       : integer;
  main_char_pos_spawn_arr: array[0..5] of TPtPos=((x:-256; y:192),(x:032; y:032),(x:064; y:192),(x:416; y:-256),(x:576; y:224),(x:-480; y:448));
  main_char_pos          : TPtPos;
  main_char_speed        : TColor=16;

implementation

uses
  Main;

end.


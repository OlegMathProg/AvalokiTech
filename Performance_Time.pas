unit Performance_Time;

{
  Модуль performance_time содержит описание класса  TPerformanceTime, который
позволяет измерить время выполнения куска кода. Необходимо инициализировать
переменную типа TPerformanceTime, выполнить метод Start. проделать работу (код)
Выполнить метод Stop, после чего в св-ве Delay будет время выполнения кода
в секундах.
Пример:

  T:=TPerformanceTime.Create;
  T.Start;
  Sleep(1000);
  T.Stop;
  Caption:=FloatToStr(T.Delay);//покажет время равное 1 секунде +/- погрешность

  Так же в классе есть учет погрешности за счет вызова внутренних процедур класса.
За это отвечает параметр в конструкторе. если он True то будет учет погрешности
(задержка самого таймера, за счет вызова процедур)

  Примечание: Позволяет измерять время выполнения кода. Если код "быстрый" можно
использовать for I:=1 to N do (Код), после чего полученное время разделить
на N, При этом чем выше N тем меньше будет дисперсия.
Чем выше частота процессора, тем по идее точность должна быть выше, по крайней
мере в Windows.

  Среда разработки: Lazarus v0.9.29 beta и выше
  Компилятор:       FPC v 2.4.1 и выше
}

{$mode objfpc}{$H+}

interface

uses
  {$ifdef Windows}
  Windows,
  {$endif}
  {$ifdef Unix}
  Unix, BaseUnix;
  {$endif}
  Classes, SysUtils;

type
  TPerformanceTime=class {$region -fold}
    private
      fdelay     : real; // измеренное время в секундах
      timer_delay: real; // задержка (время) самого вычисления в секундах
      start_time : real; // время начала теста в секундах
    public
      constructor Create(enabledtimerdelay:boolean=True);
      property  Delay: real read fdelay;
      procedure Start;
      procedure Stop;
  end; {$endregion}

function  GetTimeInSec: real; inline; register; {$ifdef Linux}[local];{$endif} // вернет время в секундах, с начало работы ОС

implementation

function GetTimeInSec: real;      inline; register; {$ifdef Linux}[local];{$endif} {$region -fold}
var
  {$IFDEF windows}
  startcount,freq: int64;
  {$ENDIF}
  {$IFDEF UNIX}
  timelinux:timeval;
  {$ENDIF}
begin
  {$IFDEF windows}
   if QueryPerformanceCounter(startcount) then //возвращает текущее значение счетчика
    begin
      QueryPerformanceFrequency(freq);   //Кол-во тиков в секунду
      Result:=startcount/freq;           //Результат в секундах
    end
  else
    Result:=GetTickCount64*1000;         //*1000, т.к  GetTickCount вернет милиСекунды
  {$ENDIF}

  {$IFDEF UNIX}
   fpGetTimeOfDay(@TimeLinux,nil);
   Result:=timeLinux.tv_sec + TimeLinux.tv_usec/1000000;
  {$ENDIF}
end; {$endregion}
constructor TPerformanceTime.Create(enabledtimerdelay:boolean);                    {$region -fold}
var
  temp_time,temp_value: real;
begin
  timer_delay:=0;
  if enabledtimerdelay then
    begin
      temp_value :=GetTimeInSec; // Первый раз холостой, чтобы подгрузить нужные системные dll
                                 // Но за одно и записали в TempValue число.
      temp_time  :=GetTimeInSec; // Теперь уже записываем время.
      temp_value :=temp_value-GetTimeInSec-temp_time; // Тут пытаемся сделать работу подобной проц Stop
      timer_delay:=GetTimeInSec-temp_time;            // подсчитали потери(погрешность) самого таймера(по идее проц Stop)
    end;
end; {$endregion}
procedure TPerformanceTime.Start; inline; register; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
   start_time:=GetTimeInSec;
end; {$endregion}
procedure TPerformanceTime.Stop;  inline; register; {$ifdef Linux}[local];{$endif} {$region -fold}
begin
  fdelay:=GetTimeInSec-start_time-timer_delay;
end; {$endregion}

end.

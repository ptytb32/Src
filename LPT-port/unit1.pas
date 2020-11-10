unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  lNetComponents, lNet, ShellApi,Windows;

function Out32(PortAdr: word; Data: byte): byte; stdcall; external '/inpout32.dll';

type

  { TForm1 }

  TForm1 = class(TForm)
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure send();
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

const
  mb: array[0..7] of byte = (1, 2, 4, 8, 16, 32, 64, 128);


var
  Form1: TForm1;
  dd: array[0..7] of byte;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to 7 do
    dd[i] := mb[i];
  send();
end;




procedure TForm1.CheckBox1Change(Sender: TObject);
var
  indexPin: integer;
begin
  indexPin := StrToInt(TCheckBox(Sender).Hint);
  if TCheckBox(Sender).Checked then
    dd[indexPin] := 0
  else
    dd[indexPin] := mb[indexPin];
  send();
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  send;
end;

procedure TForm1.send();
begin
  Out32(888, dd[0] + dd[1] + dd[2] + dd[3] + dd[4] + dd[5] + dd[6] + dd[7]);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if (GetKeyState(VK_CONTROL) = -127) or (GetKeyState(VK_CONTROL) = -128) then
  begin
   if (GetKeyState(VK_NUMPAD1) = -127) or (GetKeyState(VK_NUMPAD1) = -128) then
      begin
        ShellExecute(0,nil,'defsound.exe','0 ALL','',SW_MINIMIZE)

      end;
    if (GetKeyState(VK_NUMPAD2) = -127) or (GetKeyState(VK_NUMPAD2) = -128) then
      begin
        ShellExecute(0,nil,'defsound.exe','1 ALL','',SW_MINIMIZE)

      end;
     if (GetKeyState(VK_NUMPAD3) = -127) or (GetKeyState(VK_NUMPAD3) = -128) then
      begin
        ShellExecute(0,nil,'defsound.exe','2 ALL','',SW_MINIMIZE)

      end;
  end;
end;

end.

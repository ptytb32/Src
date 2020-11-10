unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ValEdit, Merkury206, LazSerial;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnCurrentValue: TButton;
    btnTarifs: TButton;
    btnConnect: TButton;
    Button1: TButton;
    btnDateTime: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    lbW: TLabel;
    Label11: TLabel;
    lbT12: TLabel;
    lbT1: TLabel;
    Label3: TLabel;
    lbT2: TLabel;
    Label5: TLabel;
    lbV: TLabel;
    Label7: TLabel;
    lbA: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    ValueListEditor1: TValueListEditor;

    procedure btnCurrentValueClick(Sender: TObject);
    procedure btnTarifsClick(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnDateTimeClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private

  public

  end;


var
  Form1: TForm1;
  m: TM206;

implementation

{$R *.lfm}



{ TForm1 }

function HexToInt(inHex: string): int64;
begin
  Result := 0;
  if Length(inHex) > 0 then
  begin
    try
      Result := StrToInt64('$' + inHex);
    except
      Result := 0;
    end;
  end;
end;

procedure TForm1.btnConnectClick(Sender: TObject);
var i:integer;
begin

  if m = nil then
  begin
    m := TM206.Create('COM8', br__9600, Self); // br_38400
    btnConnect.Caption := 'DisConnect';
    if (ValueListEditor1.RowCount>1) and (ValueListEditor1.Keys[1]<>'') then
    begin
      for i:=1 to ValueListEditor1.RowCount-1 do
        m.AddDev(hextoint(ValueListEditor1.Values[ValueListEditor1.Keys[i]]))
    end;
    m.DevsToList(ValueListEditor1);
   {m.AddDev(strtoint('4116****'));
    m.AddDev(strtoint('4154****'));
    m.AddDev(strtoint('4154****'));
    m.AddDev(strtoint('4100****'));
    m.AddDev(strtoint('4121****'));
    m.AddDev(strtoint('4101****'));
    m.AddDev(strtoint('4154****'));
    m.AddDev(strtoint('3561****'));
    m.AddDev(strtoint('4119****'));
    m.AddDev(strtoint('4125****'));
    m.AddDev(strtoint('4179****'));
    m.AddDev(strtoint('4179****'));
    m.DevsToList(ValueListEditor1); }

    CheckBox1.Checked := True;
    btnCurrentValue.Enabled := True;
    btnDateTime.Enabled := True;
    btnTarifs.Enabled := True;
    Button2.Enabled := True;
    Button1.Enabled := True;
    Button6.Enabled := True;

  end
  else
  begin
    m.Destroy();
    m := nil;
    btnConnect.Caption := 'Connect';
    btnCurrentValue.Enabled := False;
    btnDateTime.Enabled := False;
    btnTarifs.Enabled := False;
    Button2.Enabled := False;
    Button1.Enabled := False;
    Button6.Enabled := False;
  end;

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  memo1.Lines.add(m.GetFreeAdres(ValueListEditor1.Row - 1, edit1.Text, CheckBox1.Checked));

end;

procedure TForm1.btnDateTimeClick(Sender: TObject);
var
  da: integer;
  t: ttime;
  d: tdate;
begin
  m.GetDateTime(ValueListEditor1.Row - 1, da, t, d);
  Label2.Caption := IntToStr(da) + ' ' + timetostr(t) + ' ' + datetostr(d);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  m.FindDevs(StrToInt(edit2.Text), StrToInt(edit3.Text));
  m.DevsToList(ValueListEditor1);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  m.AddDev(StrToInt(edit4.Text));
  m.DevsToList(ValueListEditor1);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  ValueListEditor1.SaveToFile('list.txt');
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  if not FileExists('list.txt') then exit;
  ValueListEditor1.LoadFromFile('list.txt');
  if m <> nil then
  m.DevsFromList(ValueListEditor1);
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  q1, q2,p1,p2,q11,q12: double;
begin
  m.GetValuesTarifM(ValueListEditor1.Row - 1, q1, q2, ComboBox1.ItemIndex);
  if ComboBox1.ItemIndex <> 0 then
    m.GetValuesTarifM(ValueListEditor1.Row - 1, q11, q12, ComboBox1.ItemIndex-1)
  else
    m.GetValuesTarifM(ValueListEditor1.Row - 1, q11, q12, 11);
  label15.Caption := floattostr(q1) + ' Wt';
  label16.Caption := floattostr(q2) + ' Wt';
  p1:=strtofloat(edit5.text)*(q1-q11);
  p2:=strtofloat(edit6.text)*(q2-q12);
  label20.Caption:=floattostr(p1+p2)+' Руб';

end;

procedure TForm1.Button7Click(Sender: TObject);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Button5Click(self);
end;

procedure TForm1.btnTarifsClick(Sender: TObject);
var
  q1, q2, q3: double;
begin
  m.GetValuesTarif(ValueListEditor1.Row - 1, q1, q2, q3);
  lbT1.Caption := floattostr(q1) + ' Wt';
  lbT2.Caption := floattostr(q2) + ' Wt';
  lbT12.Caption := floattostr(q3) + ' Wt';
end;

procedure TForm1.btnCurrentValueClick(Sender: TObject);
var
  q1, q2, q3: double;
begin
  m.GetCurrentValues(ValueListEditor1.Row - 1, q1, q2, q3);
  lbV.Caption := floattostr(q1) + ' V';
  lbA.Caption := floattostr(q2) + ' A';
  lbW.Caption := floattostr(q3) + ' Wh';
end;




end.

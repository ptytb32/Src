unit Merkury206;

{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, LazSerialPort, LazSerial,valedit;

type

  { TM206 }

  TM206 = class

    constructor Create(Port: string; speed: TBaudRate;
      Sender: TComponent);
    destructor destroy();
  private
    SerialNomer:array of string;
    LSerial: TLazSerial;
    function CRC16(HexData: ansistring): UInt16;
    function HexToInt(inHex: string): int64;
    procedure request(id:integer; d: string);
  public
    function AddDev(SN:integer):integer;
    procedure FindDevs(start,stop:integer);
    procedure GetCurrentValues(id:integer; var V, A, W: double);
    procedure GetValuesTarif(id:integer; var T1, T2, T12: double);
    procedure GetValuesTarifM(id:integer; var T1, T2: double; m:integer);
    procedure GetDateTime(id:integer; var dn:integer; var t:TTime; var d: TDate);
    function GetFreeAdres(id:integer; adres:string; clear:boolean=false):string;
    procedure DevsToList(list:TValueListEditor);
    procedure DevsFromList(list:TValueListEditor);
  end;

implementation

constructor TM206.Create(Port: string; speed: TBaudRate;
  Sender: TComponent);
begin
  LSerial := TLazSerial.Create(Sender);
  LSerial.Device := port;
  LSerial.BaudRate := speed;
  LSerial.Active := True;
  LSerial.Open;
end;

destructor TM206.destroy();
begin
  LSerial.Close;
  LSerial.Active := false;
  LSerial.Free;
end;

function TM206.CRC16(HexData: ansistring): UInt16;
var
  buffer: array of byte; // TArray<Byte>;
  CRC: UInt16;
  Mask,bu: UInt16;
  bb: PChar;
  I: integer;
  J: integer;
begin
  SetLength(buffer, Length(HexData) div 2);
  bb := PChar(buffer);
  HexToBin(PChar(HexData), bb, Length(buffer));
  CRC := $FFFF;
  for I := Low(buffer) to High(buffer) do
  begin
    CRC := CRC xor buffer[I];
    for J := 1 to 8 do
    begin
      Mask := 0;
      if ((CRC / 2) <> (CRC div 2)) then
      begin
        Mask := $A001;
      end;
      CRC := (CRC div 2) and $7FFF;
      CRC := CRC xor Mask;
    end;
  end;
  bu:=((CRC and $FF) shl 8) + (CRC shr 8);

  Result := bu;
end;

function TM206.HexToInt(inHex: string): int64;
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

function TM206.AddDev(SN:integer):integer;
Begin
 SetLength(SerialNomer,Length(SerialNomer)+1);
 SerialNomer[Length(SerialNomer)-1]:=IntToHex(SN,8);
 Result:=Length(SerialNomer);
end;

procedure TM206.FindDevs(start,stop:integer);
var
  bb: uint64;
  s, ss, mes, nmes,ad: string;
  I,j, c: integer;
Begin
for j:=start to stop do
begin
  ad:=inttohex(j,8);
  nmes := '';
  mes := ad + '2F';
  for I := Length(mes) div 2 downto 1 do
    nmes := nmes + mes[I * 2 - 1] + mes[I * 2];
  s := inttohex(Crc16(mes), 4);
  ss := s[3] + s[4] + s[1] + s[2];
  bb := HexToInt(ss + nmes);
  c := Length(IntToStr(bb));
  LSerial.WriteBuffer(bb, c div 2);
  sleep(100);
  s := LSerial.ReadData;
  if s <> '' then
  begin
    AddDev(j);
  end;
end;

end;

procedure TM206.request(id:integer; d: string);
var
  bb: uint64;
  s, ss, mes, nmes: string;
  I, c: integer;
begin
  nmes := '';
  mes := SerialNomer[id] + d;
  for I := Length(mes) div 2 downto 1 do
    nmes := nmes + mes[I * 2 - 1] + mes[I * 2];
  s := inttohex(Crc16(mes), 4);
  ss := s[3] + s[4] + s[1] + s[2];
  bb := HexToInt(ss + nmes);
  c := Length(ss + nmes);
  LSerial.WriteBuffer(bb, c div 2);
end;

procedure TM206.GetCurrentValues(id:integer; var V, A, W: double);
var
  otv, Line, s, s1, s2, s3: string;
  i: integer;
begin
  request(id,'63');
  sleep(100);
  s := LSerial.ReadData;
  otv := s;
  while s <> '' do
  begin
    s := LSerial.ReadData;
    otv := otv + s;
  end;
  Line := '';
  for i := 0 to Length(otv) - 1 do
    Line := Line + ' ' + IntToHex(Ord(otv[i + 1]), 2);
  s := Line;
  s := StringReplace(s, ' ', '', [rfReplaceAll]);
  if (s <> '') and (length(s)>10) then
  if s[9] + s[10] = '63' then
  begin
    s1 := s[11] + s[12] + s[13] + s[14];
    try
      s1 := floattostr(strtofloat(s1)/10);
    except
      s1 := '0';
    end;
    s2 := s[15] + s[16] + s[17] + s[18];
    try
      s2 := floattostr(strtofloat(s2)/100);
    except
      s2 := '0';
    end;
    s3 := s[19] + s[20] + s[21] + s[22] + s[23] + s[24];
    try
      s3 := floattostr(strtofloat(s3));
    except
      s3 := '0';
    end;
    v := strtofloat(s1);
    A := strtofloat(s2);
    W := strtofloat(s3);
  end;
end;

procedure TM206.GetValuesTarif(id:integer; var T1, T2, T12: double);
var
  otv, s, s1, s2, s3, line: string;
  i: integer;
begin
  request(id,'27');
  sleep(100);
  s := LSerial.ReadData;
  otv := s;
  while s <> '' do
  begin
    s := LSerial.ReadData;
    otv := otv + s;
  end;
  Line := '';
  for i := 0 to Length(otv) - 1 do
    Line := Line + ' ' + IntToHex(Ord(otv[i + 1]), 2);
  s := Line;
  s := StringReplace(s, ' ', '', [rfReplaceAll]);
  if (s <> '') and (length(s)>10) then
  if s[9] + s[10] = '27' then
  begin
    s1 := s[11] + s[12] + s[13] + s[14] + s[15] + s[16] + s[17] + s[18];
    try
      s1 := floattostr(strtofloat(s1)/100);
    except
      s1 := '0';
    end;
    s2 := s[19] + s[20] + s[21] + s[22] + s[23] + s[24] + s[25] + s[26];
    try
      s2 := floattostr(strtofloat(s2)/100);
    except
      s2 := '0';
    end;
    s3 := floattostr(strtofloat(s1) + strtofloat(s2));
    try
      s3 := floattostr(strtofloat(s3));
    except
      s3 := '0';
    end;
    T1 := strtofloat(s1);
    T2 := strtofloat(s2);
    T12 := strtofloat(s3);
  end;
end;

procedure TM206.GetValuesTarifM(id: integer; var T1, T2: double; m: integer);
var nm:string;
  otv, s, s1, s2, line: string;
  i: integer;
begin
case m of
  10: nm:='0A';
  11: nm:='0B';
else
  nm:='0'+inttostr(m);
end;
 request(id,'32'+nm);
  sleep(100);
  s := LSerial.ReadData;
  otv := s;
  while s <> '' do
  begin
    s := LSerial.ReadData;
    otv := otv + s;
  end;
  Line := '';
  for i := 0 to Length(otv) - 1 do
    Line := Line + ' ' + IntToHex(Ord(otv[i + 1]), 2);
  s := Line;
  s := StringReplace(s, ' ', '', [rfReplaceAll]);
  if (s <> '') and (length(s)>10) then
  if s[9] + s[10] = '32' then
  begin
    s1 := s[13] + s[14] + s[15] + s[16] + s[17] + s[18] + s[19] + s[20];
    try
      s1 := floattostr(strtofloat(s1)/10000);
    except
      s1 := '0';
    end;
    s2 := s[21] + s[22] + s[23] + s[24] + s[25] + s[26] + s[27] + s[28];
    try
      s2 := floattostr(strtofloat(s2)/10000);
    except
      s2 := '0';
    end;
    T1 := strtofloat(s1);
    T2 := strtofloat(s2);
  end;
end;

function TM206.GetFreeAdres(id:integer; adres:string; clear:boolean=false):string;
var s,otv,line:string; i:integer;
Begin
  request(id, adres);
  sleep(560);
  s := LSerial.ReadData;
  otv := s;
  Line := '';
  for i := 0 to Length(otv) - 1 do
    Line := Line + IntToHex(Ord(otv[i + 1]), 2);
  if clear then
  begin
    delete(line,1,10);
    delete(line,Length(line)-4,4);
  end;
  Result := Line;
end;

procedure TM206.GetDateTime(id:integer;var dn:integer; var t:TTime; var d: TDate);
var s,otv,line,s1,s2,s3:string; i:integer;
Begin
  request(id,'21');
  sleep(100);
  s := LSerial.ReadData;
  otv := s;
  while s <> '' do
  begin
    s := LSerial.ReadData;
    otv := otv + s;
  end;
  Line := '';
  for i := 0 to Length(otv) - 1 do
    Line := Line + IntToHex(Ord(otv[i + 1]), 2);
  s := Line;
  s := StringReplace(s, ' ', '', [rfReplaceAll]);
  if (s <> '') and (length(s)>10) then
  if s[9] + s[10] = '21' then
  begin
    s1 := s[11] + s[12];
    try
      dn := strtoint(s1);
    except
      dn := 0;
    end;
    s2 := s[13] + s[14] +':'+ s[15] + s[16]+':'+s[17] + s[18];
    try
      t := StrToTime(s2);
    except
      t := StrToTime('00:00:01');
    end;
    s3 := s[19] + s[20] +'.'+ s[21] + s[22] +'.'+ s[23] + s[24];
    try
      d := StrToDate(s3);
    except
      d := StrToDate('01.01.2000');
    end;
  end;
end;

procedure TM206.DevsToList(list:TValueListEditor);
var
  i : integer;
Begin
 list.RowCount:=Length(SerialNomer)+1;
 for i:=0 to Length(SerialNomer)-1 do
 begin
  list.Cells[0,i+1]:=inttostr(i);
  list.Cells[1,i+1]:=SerialNomer[i];
 end;
end;

procedure TM206.DevsFromList(list:TValueListEditor);
var
  i : integer;
Begin
 for i:=1 to list.RowCount-1 do
 begin
  SetLength(SerialNomer,Length(SerialNomer)+1);
  SerialNomer[Length(SerialNomer)-1]:=list.Cells[1,i];
 end;
end;

end.

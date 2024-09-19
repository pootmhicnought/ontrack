unit OnTrackClasses;

interface

uses SysUtils, System.Generics.Collections, Classes;

const
  LineBreak = '||';
  CRLF : String = #$0D + #$0A;

type
  TInfoItem = record
    Number: Integer;
    Text: String;
    Completed: Integer;
    procedure FromText(InString: String);
    function ToText: String;
  end;

  TInfoList = Class(TList<TInfoItem>)
  public
    procedure FromStrings(InStrings: TStrings);
    function ToString: String; override;
  end;


implementation

{ TInfoItem }

procedure TInfoItem.FromText(InString: String);
var Index: Integer;
begin
  Completed := 0;
  InString := Trim(InString);
  Index := Pos(' ', InString);
  if (Index > 0) then begin
    Number := StrToIntDef(Copy(InString, 1, Index - 1), -1);
    if Number > -1 then
      System.Delete(InString, 1, Index);
  end
  else Number := 0;
  Text := Trim(InString);
end;

function TInfoItem.ToText: String;
begin
  Result := IntToStr(Number) + ' ' + Text;
end;

{ TInfoList }

procedure TInfoList.FromStrings(InStrings: TStrings);
var ThisLine: String;
    ThisItem: TInfoItem;
begin
  for ThisLine in InStrings do begin
    ThisItem.FromText(ThisLine);
    if ThisItem.Text <> '' then
     Self.Add(ThisItem);
  end;
end;

function TInfoList.ToString: String;
var ThisItem: TInfoItem;
begin
  Result := '';
  for ThisItem in Self do begin
    if Trim(ThisItem.Text) <> ''
    then Result := Result + ThisItem.ToText + CRLF;
  end;
end;

end.

unit OnTrackClasses;

interface

uses SysUtils,
     System.Generics.Collections,
     System.Generics.Defaults,
     Classes;

const
  LineBreak = '||';
  CRLF : String = #$0D + #$0A;

type
  TInfoItem = class
    Number: Integer;
    Text: String;
    Completed: Integer;
    procedure FromText(InString: String);
    function ToText: String;
  end;

  TInfoList = Class(TObjectList<TInfoItem>)
  public
    procedure FromStrings(InStrings: TStrings);
    function ToString: String; override;
    procedure NameSort;
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
      System.Delete(InString, 1, Index)
    else
      Number := 0;
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
    ThisItem := TInfoItem.Create;
    ThisItem.FromText(ThisLine);
    if ThisItem.Text <> '' then
      Self.Add(ThisItem)
    else
      ThisItem.Free;

  end;
end;

procedure TInfoList.NameSort;
begin
  Sort(TComparer<TInfoItem>.Construct(
    function (const L, R: TInfoItem): integer
    begin
       if (L.Text = R.Text)
       then Result:=0
       else if (L.Text < R.Text)
       then Result:=-1
       else Result:=1;
    end));
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

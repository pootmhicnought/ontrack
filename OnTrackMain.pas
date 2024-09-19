unit OnTrackMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.TabControl,
  FMX.StdCtrls, FMX.Gestures, FMX.Memo.Types, FMX.DateTimeCtrls, FMX.ScrollBox,
  FMX.Memo, FMX.Edit, FMX.Controls.Presentation, OnTrackClasses, FMX.Ani;

type
  TformOntrackMain = class(TForm)
    HeaderToolBar: TToolBar;
    ToolBarLabel: TLabel;
    tabControl1: TTabControl;
    tiSettings: TTabItem;
    tiClass: TTabItem;
    GestureManager1: TGestureManager;
    edClassName: TEdit;
    memoAgenda: TMemo;
    timeditStartTime: TTimeEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblTimer: TLabel;
    btnPause: TButton;
    btnStart: TButton;
    lblPrevious: TLabel;
    lblCurrent: TLabel;
    lblUpcoming: TLabel;
    memoStudents: TMemo;
    Label4: TLabel;
    StyleBook1: TStyleBook;
    Timer1: TTimer;
    ColorAnimation1: TColorAnimation;
    btnCancel: TButton;
    lblCompleted: TLabel;
    gbStudentPicker: TGroupBox;
    lblStudent: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
      var Handled: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure tabControl1Change(Sender: TObject);
    procedure lblCurrentClick(Sender: TObject);
    procedure gbStudentPickerClick(Sender: TObject);
  private
    { Private declarations }
    AgendaList,
    StudentList: TInfoList;
    StartTime: TTime;
    function BreaksToCRLF(InString: String) : String;
    function CRLFtoBreaks(InString: String) : String;
    procedure UpdateAgenda;
    function ElapsedSeconds(Start: TDateTime; Finish: TDateTime = 0): Integer;
  public
    { Public declarations }
  end;

var
  formOntrackMain: TformOntrackMain;

implementation

uses IniFiles, Math;


{$R *.fmx}

function TformOntrackMain.BreaksToCRLF(InString: String): String;
begin
  Result := StringReplace(InString, LineBreak, CRLF, [rfReplaceAll]);
end;

procedure TformOntrackMain.btnCancelClick(Sender: TObject);
begin
  Timer1.Enabled := FALSE;
  StartTime := 0.00;
end;

procedure TformOntrackMain.btnPauseClick(Sender: TObject);
begin
  Timer1.Enabled := FALSE;
end;

procedure TformOntrackMain.btnStartClick(Sender: TObject);
begin
  if StartTime = 0.00 then StartTime := NOW;
  Timer1.Enabled := TRUE;
  UpdateAgenda;
end;

function TformOntrackMain.CRLFtoBreaks(InString: String): String;
begin
  Result := StringReplace(InString, CRLF, LineBreak, [rfReplaceAll]);
end;

function TformOntrackMain.ElapsedSeconds(Start, Finish: TDateTime): Integer;
begin
  if (Finish = 0)
  then Finish := Now;
  Result := Max(0, Trunc((Finish - Start) * 24 * 60 * 60));
end;

procedure TformOntrackMain.FormCreate(Sender: TObject);
var IniFile: TIniFile;
begin
  TabControl1.ActiveTab := tiSettings;
  IniFile :=  TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  memoAgenda.Lines.Text := BreaksToCRLF(IniFile.ReadString('Settings', 'Agenda', ''));
  memoStudents.Lines.Text := BreaksToCRLF(IniFile.ReadString('Settings', 'Students', ''));
  edClassName.Text := IniFile.ReadString('Settings', 'ClassName', '');
  timeditStartTime.Time := Frac(IniFile.ReadDateTime('Settings', 'StartTime', 0.0));
end;

procedure TformOntrackMain.FormDestroy(Sender: TObject);
var IniFile: TIniFile;
begin
  if not Assigned(StudentList) then begin
    StudentList := TInfoList.Create;
    StudentList.FromStrings(memoStudents.Lines);
  end;
  if not Assigned(AgendaList) then begin
    AgendaList  := TInfoList.Create;
    AgendaList.FromStrings(memoAgenda.Lines);
  end;

  IniFile :=  TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  memoAgenda.Lines.Text := AgendaList.ToString;
  memoStudents.Lines.Text := StudentList.ToString;
  IniFile.WriteString('Settings', 'Agenda', CRLFToBreaks(memoAgenda.Lines.Text));
  IniFile.WriteString('Settings', 'Students', CRLFToBreaks(memoStudents.Lines.Text));
  IniFile.WriteString('Settings', 'ClassName', edClassName.Text);
  IniFile.WriteDateTime('Settings', 'StartTime', timeditStartTime.Time);
  FreeAndNil(AgendaList);
  FreeAndNil(StudentList);
end;

procedure TformOntrackMain.FormGesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
{$IFDEF ANDROID}
  case EventInfo.GestureID of
    sgiLeft:
    begin
      if TabControl1.ActiveTab <> TabControl1.Tabs[TabControl1.TabCount-1] then
        TabControl1.ActiveTab := TabControl1.Tabs[TabControl1.TabIndex+1];
      Handled := True;
    end;

    sgiRight:
    begin
      if TabControl1.ActiveTab <> TabControl1.Tabs[0] then
        TabControl1.ActiveTab := TabControl1.Tabs[TabControl1.TabIndex-1];
      Handled := True;
    end;
  end;
{$ENDIF}
end;

procedure TformOntrackMain.gbStudentPickerClick(Sender: TObject);
var RandomStudentPickerList: TInfoList;
    ThisItem, NewItem: TInfoItem;
    TotalNumber: Integer;
    Choice : Integer;
    Index: Integer;
begin
  Randomize;
  RandomStudentPickerList := TInfoList.Create;
  try
    TotalNumber := 0;
    for ThisItem in StudentList do begin
      NewItem.FromText(ThisItem.ToText);
      NewItem.Number := 10 - NewItem.Number;
      TotalNumber := TotalNumber + NewItem.Number;
      RandomStudentPickerList.Add(NewItem);
    end;
    Choice := Random(TotalNumber) + 1;
    TotalNumber := 0;
    for NewItem in RandomStudentPickerList do begin
      TotalNumber := TotalNumber + NewItem.Number;
      if TotalNumber >= Choice then begin
        lblStudent.Text := NewItem.Text;
        break;
      end;
    end;

    Index := 0;
    while Index < StudentList.Count do begin
      ThisItem := StudentList[Index];
      if ThisItem.Text = NewItem.Text then begin
        ThisItem.Number := ThisItem.Number + 1;
        StudentList.Delete(Index);
        StudentList.Add(ThisItem);
        break;
      end;
      Inc(Index);
    end;

  finally
    FreeAndNil(RandomStudentPickerList);
  end;

  //
end;

procedure TformOntrackMain.lblCurrentClick(Sender: TObject);
var ThisItem: TInfoItem;
begin
  ThisItem := AgendaList[lblCurrent.Tag];
  ThisItem.Completed := ElapsedSeconds(StartTime);
  AgendaList[lblCurrent.Tag] := ThisItem;
  UpdateAgenda;
end;

procedure TformOntrackMain.tabControl1Change(Sender: TObject);
begin
  if tabControl1.ActiveTab = tiClass then begin
    if Assigned(StudentList) then FreeAndNil(StudentList);
    if Assigned(AgendaList) then FreeAndNil(AgendaList);
    StudentList := TInfoList.Create;
    AgendaList  := TInfoList.Create;
    StudentList.FromStrings(memoStudents.Lines);
    AgendaList.FromStrings(memoAgenda.Lines);
    lblPrevious.Text := '';
    lblCurrent.Text := '';
    lblUpcoming.Text := '';
    ToolBarLabel.Text := edClassName.Text;
  end;
end;

procedure TformOntrackMain.Timer1Timer(Sender: TObject);
begin
  lblTimer.Text := FormatDateTime('HH:NN:SS', Now - StartTime);
  UpdateAgenda;
end;

procedure TformOntrackMain.UpdateAgenda;
var ThisItem: TInfoItem;
    TotalSeconds: Integer;
    AgendaMinutes: Integer;
    CompletedMinutes: Integer;
    ES: Integer;
    Index: Integer;
    SchedDeltaSeconds: Integer;
begin
  ES := ElapsedSeconds(StartTime);
  TotalSeconds := 0;
  AgendaMinutes := 0;
  CompletedMinutes := 0;
  Index := 0;
  while Index < AgendaList.Count do begin
    ThisItem := AgendaList[Index];
    Inc(Index);
    TotalSeconds := TotalSeconds + ThisItem.Completed;
    AgendaMinutes := AgendaMinutes + ThisItem.Number;
    if ThisItem.Completed > 0 then begin
      CompletedMinutes := CompletedMinutes + ThisItem.Number;
      continue;
    end;
    if Index > 1 then lblPrevious.Text := AgendaList[Index - 2].Text
    else lblPrevious.Text := '';
    // Seconds available to complete task.
    SchedDeltaSeconds := (CompletedMinutes * 60) - ES + (ThisItem.Number * 60);
    if (SchedDeltaSeconds > (ThisItem.Number * 60)) then begin
      lblCurrent.Text := ThisItem.Text + ' - '
        + IntToStr(ThisItem.Number) + ' +'
        + IntToStr(Round((SchedDeltaSeconds - (ThisItem.Number * 60)) / 60));
      lblCurrent.FontColor := TAlphaColorRec.Green;
    end
    else begin
      lblCurrent.Text := ThisItem.Text + ' - '
        + IntToStr(AgendaMinutes - Trunc(ES / 60));
      lblCurrent.FontColor := TAlphaColorRec.White;
    end;
    lblCurrent.Tag  := Index - 1;
    if (Index < AgendaList.Count) then lblUpcoming.Text := AgendaList[Index].Text;
    Break;
  end;
  lblCompleted.Text := IntToStr(CompletedMinutes div 60) + ':' + IntToStr(CompletedMinutes mod 60);
end;

end.

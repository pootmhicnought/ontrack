unit OnTrackMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.TabControl,
  FMX.StdCtrls, FMX.Gestures, FMX.Memo.Types, FMX.DateTimeCtrls, FMX.ScrollBox,
  FMX.Memo, FMX.Edit, FMX.Controls.Presentation;

type
  TformOntrackMain = class(TForm)
    HeaderToolBar: TToolBar;
    ToolBarLabel: TLabel;
    V: TTabControl;
    tiSettings: TTabItem;
    tiClass: TTabItem;
    GestureManager1: TGestureManager;
    edClassName: TEdit;
    Memo1: TMemo;
    TimeEdit1: TTimeEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblTimer: TLabel;
    Button1: TButton;
    Button2: TButton;
    lblPrevious: TLabel;
    lblNext: TLabel;
    lblCurrent: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
      var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formOntrackMain: TformOntrackMain;

implementation

{$R *.fmx}

procedure TformOntrackMain.FormCreate(Sender: TObject);
begin
  { This defines the default active tab at runtime }
  TabControl1.ActiveTab := TabItem1;
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

end.

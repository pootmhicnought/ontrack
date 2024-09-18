program OnTrack;

uses
  System.StartUpCopy,
  FMX.Forms,
  OnTrackMain in 'OnTrackMain.pas' {formOntrackMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TformOntrackMain, formOntrackMain);
  Application.Run;
end.

program OnTrack;

uses
  System.StartUpCopy,
  FMX.Forms,
  OnTrackMain in 'OnTrackMain.pas' {formOntrackMain},
  OnTrackClasses in 'OnTrackClasses.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TformOntrackMain, formOntrackMain);
  Application.Run;
end.

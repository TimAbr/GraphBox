program Project1;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {FormMain},
  UStart in 'UStart.pas' {FormStart},
  HelpTypes in 'HelpTypes.pas',
  UEditBlocks in 'UEditBlocks.pas' {FrameEditBlocks: TFrame},
  UEditLines in 'UEditLines.pas' {FrameEditLines: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormStart, FormStart);
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.

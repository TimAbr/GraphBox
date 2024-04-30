program Project1;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {FormMain},
  UStart in 'UStart.pas' {FormStart},
  HelpTypes in 'HelpTypes.pas',
  UEditBlocks in 'UEditBlocks.pas' {FrameEditBlocks: TFrame},
  Unit2 in 'Unit2.pas' {Frame2: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormStart, FormStart);
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.

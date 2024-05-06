unit UEditLines;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, HelpTypes;

type
  TFrameEditLines = class(TFrame)
    EditHeight: TEdit;
    LabelHeight: TLabel;
    UpDownVertical: TUpDown;
    LabelWidth: TLabel;
    EditWidth: TEdit;
    UpDownHorizontal: TUpDown;
    procedure UpDownChanging(Sender: TObject; var AllowChange: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation
Uses UMain;

{$R *.dfm}


procedure TFrameEditLines.UpDownChanging(Sender: TObject; var AllowChange: Boolean);
begin
  FormMain.PaintField.Invalidate();
end;


end.

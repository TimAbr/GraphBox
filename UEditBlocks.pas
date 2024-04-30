unit UEditBlocks;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, HelpTypes, UMain;

type
  TFrameEditBlocks = class(TFrame)
    EditHeight: TEdit;
    LabelHeight: TLabel;
    UpDownHeight: TUpDown;
    LabelWidth: TLabel;
    EditWidth: TEdit;
    UpDownWidth: TUpDown;
    LabelScale: TLabel;
    EditScale: TEdit;
    TrackBarScale: TTrackBar;
    procedure UpDownChanging(Sender: TObject; var AllowChange: Boolean);
    procedure ReSizeTree(bl: pCombinedBlock; w, h: Integer);

  private
    { Private declarations }
  public
    { Public declarations }
  end;
  procedure ReSizeAll(w, h: Integer);

implementation

{$R *.dfm}

procedure TFrameEditBlocks.UpDownChanging(Sender: TObject; var AllowChange: Boolean);
var
  temp: pAllBlocks;
begin
  temp := Blocks;
  ReSizeAll(UpDownWidth.Position, UpDownHeight.Position);
end;

procedure ReSizeAll(w, h: Integer);
var
  temp: pAllBlocks;
begin
  temp := Blocks;
  while temp.Next <> Nil do
  begin
    temp := temp.Next;
    ReSizeTree(temp.Block, w, h);
  end;

end;

procedure ReSizeTree(bl: pCombinedBlock; w, h: Integer);
var
  temp: pCombinedBlock;
begin
  if bl <> nil then
  begin
    bl.Form.Height := h;
    bl.Text.Height := h;

    bl.Form.Width := w;
    bl.Text.Width := w;

    temp := bl;
    for var i := 0 to High(temp.Next) do
    begin
      temp := bl.Next[i];
      ReSizeTree(temp, w, h);
    end;
  end;
end;

end.

unit UEditBlocks;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, HelpTypes;

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


  private
    { Private declarations }
  public
    { Public declarations }
  end;
  procedure ReSizeAll(w, h: Integer);
  procedure ReSizeTree(bl: pBlock; w, h: Integer);

implementation

Uses UMain;

{$R *.dfm}

procedure TFrameEditBlocks.UpDownChanging(Sender: TObject; var AllowChange: Boolean);
var
  temp: pAllBlocks;
begin
  temp := Blocks;
  ReSizeAll(UpDownWidth.Position, UpDownHeight.Position);
  FormMain.PaintField.Invalidate();
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

procedure ReSizeTree(bl: pBlock; w, h: Integer);
var
  temp: pBlock;
begin
  if bl <> nil then
  begin
    bl.h := h;

    bl.w := w;

    temp := bl;
    for var i := 0 to High(temp.Next) do
    begin
      temp := bl.Next[i];
      ReSizeTree(temp, w, h);
    end;
  end;
end;


end.

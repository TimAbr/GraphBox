unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus,
  Vcl.ComCtrls, Vcl.ToolWin, Vcl.Imaging.pngimage, Vcl.CheckLst, Vcl.Buttons,
  HelpTypes, UEditBlocks, UEditLines;

type

  TFormMain = class(TForm)
    MainMenu1: TMainMenu;
    Edit2: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;

    Panel1: TPanel;
    Button1: TButton;
    MenuPanel: TPanel;
    EditFontSize: TEdit;
    Label1: TLabel;
    Image1: TImage;
    UpDown1: TUpDown;
    Field: TScrollBox;
    ChangeFontStyle: TComboBox;
    SaveDialog1: TSaveDialog;
    InstrumentPanel: TPanel;
    Label2: TLabel;
    ShapePanel: TPanel;
    PaintField: TPaintBox;
    FrameEditBlocks: TFrameEditBlocks;
    ButtonBlocks: TSpeedButton;
    ButtonLines: TSpeedButton;
    FrameEditLines: TFrameEditLines;

    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BlockMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BlockMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BlockMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure StartBlockDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure StartBlockDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure PaintFieldPaint(Sender: TObject);
    procedure BlockStartDrag(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonBlocksClick(Sender: TObject);
    procedure ButtonLinesClick(Sender: TObject);
    procedure PaintFieldDblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);

  private


  public
    { Public declarations }
  end;

procedure MoveAllBlocks(bl: pBlock; X, Y: Integer);
function FindMinDist(X, Y: Integer; main: pointer): pBlock;
procedure FindMinDistInTree(bl: pBlock; X, Y: Integer; var Min: Real;
  var res: pBlock; main: pBlock);


var
  FormMain: TFormMain;
  Blocks: pAllBlocks;
  EditText: TProEdit;
  CurHighLightedBlock, HighLightBlock: pBlock;
  x0, y0: Integer;
  curBlock: pBlock;
  flag: Boolean;
  HighLightColor, DefaultColor:Integer;


implementation

{$R *.dfm}

Uses UStart;

// initialisation of the form
procedure TFormMain.FormCreate(Sender: TObject);
var
  StartBlock: TStartBlock;
begin
  FormMain.Hide;
  FormStart.Show;
  flag := False;
  new(Blocks);
  Blocks.Next := nil;
  Blocks.Block := Nil;

  CurBlock:=nil;

  EditText := TProEdit.Create(FormMain);
  EditText.Parent := Field;
  EditText.Hide;

  FrameEditBlocks.UpDownHeight.Position := 75;
  FrameEditBlocks.UpDownWidth.Position := 75;
  FrameEditLines.UpDownHorizontal.Position:=50;
  FrameEditLines.UpDownVertical.Position:=50;

  PaintField.width:=Field.Width;
  PaintField.height:=Field.Height;

  New(HighLightBlock);
  CurHighLightedBlock := nil;
  HighLightColor:=clHighLight;
  DefaultColor:=clBlack;

  for var i := 0 to 3 do
  begin

    StartBlock := TStartBlock.Create(ShapePanel);

    with StartBlock do
    begin

      Parent := ShapePanel;
      Shape := TShapeType(i);

      Width := ShapePanel.Width - 50;
      Height := Width;
      Left := 25;
      Top := 60 + (Width + 20) * i;

      dragMode := dmManual;
      onMouseDown:=BlockStartDrag;
    end;

  end;
end;

procedure TFormMain.FormResize(Sender: TObject);
begin
  PaintField.Invalidate();
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FormStart.Show();
end;


procedure IsInNext(cur, source: pBlock;var Flag: Boolean);
var
  temp: pBlock;
begin
  if (cur <> nil) and (not Flag) then
  begin
    if cur=source then
      Flag:=True;

    temp := cur;
    for var i := 0 to High(temp.Next) do
    begin
      temp := cur.Next[i];
      IsInNext(temp, source, Flag);
    end;
  end;
end;


procedure MoveAllBlocks(bl: pBlock; X, Y: Integer);
var
  temp: pBlock;
begin
  if bl <> nil then
  begin
    bl.y := bl.y - y0 + Y;
    bl.x := bl.x - x0 + X;

    temp := bl;
    for var i := 0 to High(temp.Next) do
    begin
      temp := bl.Next[i];
      MoveAllBlocks(temp, X, Y);
    end;
  end;
end;



procedure DrawTree(bl: pBlock; var maxx, maxy: Integer);
var
  temp: pBlock;
  num: Integer;
begin
  if bl <> nil then
  begin
    DrawBlock(bl);
    if bl.y+bl.h>maxy then
      maxy:=bl.y+bl.h;
    if bl.x+bl.w>maxx then
      maxx:=bl.x+bl.w;

    if bl.Prev<>nil then
    begin
      num:=0;
      while bl.Prev.Next[num]<>bl do
        inc(num);
      case bl.Prev.Shape of
      stRectangle:
      begin
        case num of
        0:
        begin
          bl.ownCanvas.moveto(bl.Prev.x+bl.Prev.w div 2,bl.Prev.y+bl.Prev.h);
          bl.ownCanvas.lineto(bl.x+bl.w div 2,bl.y);
        end;
        1:
        begin
          bl.ownCanvas.moveto(bl.Prev.x+bl.Prev.w,bl.Prev.y+bl.Prev.h div 2);
          bl.ownCanvas.lineto(bl.x+bl.w div 2,bl.Prev.y+bl.Prev.h div 2);
          bl.ownCanvas.lineto(bl.x+bl.w div 2, bl.y);
        end;
        end;

      end;
      stDecision:
      begin
        case num of
        0:
        begin
          bl.ownCanvas.moveto(bl.Prev.x+bl.Prev.w div 2,bl.Prev.y+bl.Prev.h);
          bl.ownCanvas.lineto(bl.x+bl.w div 2,bl.y);
        end;
        1:
        begin
          bl.ownCanvas.moveto(bl.Prev.x+(bl.Prev.w*3) div 4,bl.Prev.y+(bl.Prev.h) div 4);
          bl.ownCanvas.lineto(bl.Prev.x+bl.Prev.w+10,bl.Prev.y-10);
          bl.ownCanvas.lineto(bl.x+bl.w div 2,bl.Prev.y-10);
          bl.ownCanvas.lineto(bl.x+bl.w div 2, bl.y);
        end;
        2:
        begin
          bl.ownCanvas.moveto(bl.Prev.x+(bl.Prev.w*3) div 4,bl.Prev.y+(bl.Prev.h*3) div 4);
          bl.ownCanvas.lineto(bl.Prev.x+bl.Prev.w+10,bl.Prev.y+bl.Prev.h+10);
          bl.ownCanvas.lineto(bl.x+bl.w div 2,bl.Prev.y+bl.Prev.h+10);
          bl.ownCanvas.lineto(bl.x+bl.w div 2, bl.y);
        end;
        end;
      end;
      stCycle:
      begin

      end;
      stCircle:
      begin

      end;

      end;
    end;

    temp := bl;
    for var i := 0 to High(temp.Next) do
    begin
      temp := bl.Next[i];
      DrawTree(temp,maxx, maxy);
    end;
  end;
end;

procedure DrawAllBlocks();
var
  temp: pAllBlocks;
  maxx, maxy: Integer;
begin
  temp := Blocks;
  maxx:=0;
  maxy:=0;
  while temp.Next <> Nil do
  begin
    temp := temp.Next;
    DrawTree(temp.Block, maxx, maxy);
  end;
  if (CurBlock<>nil) and Flag then
    DrawTree(CurBlock, maxx, maxy);

  if maxx+100>=FormMain.PaintField.width then
    FormMain.PaintField.width:=maxx+100
  else
    FormMain.PaintField.width:=FormMain.Field.width;

  if maxy+100>=FormMain.PaintField.height then
    FormMain.PaintField.height:=maxy+100
  else
    FormMain.PaintField.Height:=FormMain.Field.Height;

  if CurHighLightedBlock<>nil then
  begin
    HighLightBlock.ownCanvas:=CurHighLightedBlock.ownCanvas;
    HighLightBlock.Pen:=CurHighLightedBlock.Pen;
    HighLightBlock.Pen.Color:=HighLightColor;
    HighLightBlock.Brush:=CurHighLightedBlock.Brush;
    DrawBlock(HighLightBlock);
    HighLightBlock.Pen.Color:=DefaultColor;
  end;

end;


procedure TFormMain.PaintFieldDblClick(Sender: TObject);
begin
  EditText.Show;

  EditText.Left := CurBlock.x;
  EditText.Top := CurBlock.y;
  EditText.Height := CurBlock.h;
  EditText.Width := CurBlock.h;

  EditText.prev := CurBlock;

  EditText.Text := CurBlock.Text;
  Flag:=False;
  CurBlock:=nil;
end;

procedure TFormMain.PaintFieldPaint(Sender: TObject);
begin
  DrawAllBlocks();
end;



Function ConnectBlocks(blmain,bl:pBlock; var movx, movy:Integer): Integer;

begin

  case blMain.Shape of
  stRectangle, stCycle:
  begin
    if (bl.x-blmain.x>bl.y-blmain.y) or ((blmain.y+blmain.h div 2)>=(bl.y+bl.h div 2)) then
    begin
      movx:=blmain.w+FormMain.FrameEditLines.UpDownHorizontal.Position;
      Result:=1;
      movy:=blmain.h+FormMain.FrameEditLines.UpDownVertical.Position;

    end
    else
    begin
      movy:=blmain.h+FormMain.FrameEditLines.UpDownVertical.Position;
      movx:=(blmain.w-bl.w) div 2;
      Result:=0;
    end
  end;
  stDecision:
  if ((blmain.y+blmain.h div 2)>=(bl.y+bl.h div 2)) then
  begin
    movx:=blmain.w+FormMain.FrameEditLines.UpDownHorizontal.Position;
    movy:=0;
    Result:=1;
  end
  else if (bl.x-blmain.x>bl.y-blmain.y) then
  begin
    movx:=blmain.w+FormMain.FrameEditLines.UpDownHorizontal.Position;
    movy:=blmain.h+FormMain.FrameEditLines.UpDownVertical.Position;
    Result:=2;
  end
  else
  begin
    movy:=blmain.h+FormMain.FrameEditLines.UpDownVertical.Position;
    movx:=(blmain.w-bl.w) div 2;
    Result:=0;
  end;

  end;
end;



procedure TFormMain.Button1Click(Sender: TObject);
begin
  close;
end;

procedure TFormMain.ButtonBlocksClick(Sender: TObject);
begin
  FrameEditBlocks.Show;
  FrameEditLines.Hide;
end;

procedure TFormMain.ButtonLinesClick(Sender: TObject);
begin
  FrameEditBlocks.Hide;
  FrameEditLines.Show;
end;



procedure FindBlockInTree(bl: pBlock; x, y: Integer; var res: pBlock);
var
  temp: pBlock;
begin
  if (bl <> nil) and (res=nil) then
  begin
    case bl.Shape of

      stRectangle..stCycle:
      begin
        if (bl.x<=x) and (bl.y<=y) and (x<=bl.x+bl.w) and (y<=bl.y+bl.h) then
          res:=bl;
      end;

    end;
    if res=nil then
    begin
      temp := bl;
      for var i := 0 to High(temp.Next) do
      begin
        temp := bl.Next[i];
        FindBlockInTree(temp,x,y,res);
      end;
    end;
  end;
end;

function FindBlock(x,y:Integer):  pBlock;
var
  temp: pAllBlocks;
begin
  temp := Blocks;
  Result:=nil;
  while (temp.Next <> Nil) and (Result=nil) do
  begin
    temp := temp.Next;
    FindBlockInTree(temp.Block, x, y, Result);
  end;
end;



function FindMinDist(X, Y: Integer; main: pointer): pBlock;
var
  temp: pAllBlocks;
  curMin: Real;
begin
  curMin := MaxInt;
  temp := Blocks;
  Result := Nil;
  while temp.Next <> Nil do
  begin
    temp := temp.Next;
    FindMinDistInTree(temp.Block, X, Y, curMin, Result, main);
  end;

end;

procedure FindMinDistInTree(bl: pBlock; X, Y: Integer; var Min: Real;
  var res: pBlock; main: pBlock);
var
  temp: pBlock;
  tempDist: Real;
  Flag:Boolean;
begin
  if bl <> nil then
  begin
    Flag:=False;
    isInNext(main,bl,Flag);

    if not Flag then
      begin
      tempDist := sqrt(sqr(X - bl.x) + sqr(Y - bl.y));

      if (tempDist < Min) and (x < FormMain.FrameEditLines.UpDownHorizontal.Position+bl.x+bl.w+10) and (y < FormMain.FrameEditLines.UpDownVertical.Position+bl.y+bl.h+10) then
      begin
        if (bl.x-10<=x) then
        begin
          Min := tempDist;
          res := bl;
        end;
      end;

      temp := bl;
      for var i := 0 to High(temp.Next) do
      begin
        temp := bl.Next[i];
        FindMinDistInTree(temp, X, Y, Min, res, main);
      end;
    end;
  end;
end;


procedure TFormMain.BlockStartDrag(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  CurHighLightedBlock:=nil;
  CurBlock:=nil;
  New(CurBlock);
  CurBlock.Shape:=(Sender as TStartBlock).Shape;
  CurBlock.W:=FrameEditBlocks.UpDownWidth.Position;
  CurBlock.h:=FrameEditBlocks.UpDownHeight.Position;
  SetLength(CurBlock.Next,1);
  CurBlock.Next[0]:=nil;
  CurBlock.Prev:=nil;
  if button=mbleft then
    TStartBlock(Sender).BeginDrag(True);
end;


procedure TFormMain.StartBlockDragDrop(Sender, Source: TObject; X, Y: Integer);
Var
  AllDiagrams: pAllBlocks;
  temp:pBlock;
  movx, movy, num: Integer;

begin
  Dispose(CurBlock);
  CurBlock:=nil;

  if CurHighLightedBlock = nil then
  begin
    AllDiagrams := Blocks;

    while AllDiagrams.Next <> nil do
      AllDiagrams := AllDiagrams.Next;

    new(AllDiagrams.Next);

    AllDiagrams := AllDiagrams.Next;
    AllDiagrams.Next := Nil;

    New(AllDiagrams.Block);

    temp:=AllDiagrams.Block;
    temp.Prev:=nil;

    temp.x := X;
    temp.y := Y;

  end
  else
  begin
    temp:=nil;
    New(temp);

    temp.x:=x;
    temp.y:=y;
    temp.w:=FrameEditBlocks.UpDownWidth.Position;
    temp.h:=FrameEditBlocks.UpDownHeight.Position;

    num:=ConnectBlocks(CurHighLightedBlock, temp, movx, movy);

    if CurHighLightedBlock.Next[num]=nil then
    begin
      CurHighLightedBlock.Next[num]:=temp;
      CurHighLightedBlock.Next[num].Prev:=CurHighLightedBlock;
      moveAllBlocks(temp,movx-(temp.x-temp.prev.x)+x0, movy-(temp.y-temp.prev.y)+y0);
    end
    else
    begin
      AllDiagrams := Blocks;

      while AllDiagrams.Next <> nil do
        AllDiagrams := AllDiagrams.Next;

      new(AllDiagrams.Next);

      AllDiagrams := AllDiagrams.Next;
      AllDiagrams.Next := Nil;
      AllDiagrams.Block:=temp;
      temp.prev:=nil;
    end;
  end;

  with AllDiagrams^ do
  begin

    temp.Shape := (Source as TStartBlock).Shape;

    case temp.Shape of
      stRectangle, stCycle:
        begin
          SetLength(Temp.Next, 2);
        end;
      stDecision:
        begin
          SetLength(Temp.Next, 3);
        end;

    end;

    for var i := 0 to High(Temp.Next) do
      Temp.Next[i] := nil;

    with temp^ do
    begin
      W := FrameEditBlocks.UpDownWidth.Position;
      H := FrameEditBlocks.UpDownHeight.Position;
      ownCanvas:= (Sender as TPaintBox).Canvas;
      Pen:=ownCanvas.Pen;
      Brush:=ownCanvas.Brush;
      Brush.Color:=clWhite;
      Pen.Color:=clBlack;
    end;

  end;

  temp.Text := 'Hello';

  with (Source as TStartBlock) do
  begin
    Left := 25;
    Top := 60 + (Ord(Shape)) * (Width + 20);
    flag := False;
    (Source as TStartBlock).Parent := ShapePanel;
  end;

  PaintField.EndDrag(True);
  PaintField.Invalidate();
end;

procedure TFormMain.StartBlockDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);

Var
  num, movx, movy:Integer;
begin
  if Sender = PaintField then
  begin
    Accept := True;
    CurBlock.x:=x;
    CurBlock.y:=y;

    if FindMinDist(X, Y, nil) <> nil then
    begin
      CurHighLightedBlock := FindMinDist(X, Y, nil);

      num:=ConnectBlocks(CurHighLightedBlock, CurBlock, movx, movy);

      if CurHighLightedBlock.Next[num]=nil then
      begin
        HighLightBlock.Shape:=CurHighLightedBlock.Shape;
        HighLightBlock.H := CurHighLightedBlock.H+2;
        HighLightBlock.W := CurHighLightedBlock.W+2;
        HighLightBlock.y := CurHighLightedBlock.y-1;
        HighLightBlock.x := CurHighLightedBlock.x-1;

      end
      else
      begin
        CurHighLightedBlock := nil;
      end;

    end
    else
    begin
      CurHighLightedBlock := nil;
    end;
    PaintField.Invalidate();
  end;

end;


procedure TFormMain.BlockMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  num: Integer;
begin
  flag:=False;

  curblock:=findBlock(x,y);

  if (EditText.Visible) and (curBlock<>EditText.Prev) then
  begin
    EditText.prev.text := EditText.Text;
    EditText.Hide;
  end;

  if (CurHighLightedBlock <> Nil) then
  begin
    CurHighLightedBlock := Nil;
  end;

  if CurBlock<>nil then
  begin
    flag := True;
    x0 := X;
    y0 := Y;
    if CurBlock.Prev<>nil then
    begin
      num:=0;
      while CurBlock.Prev.Next[num]<>CurBlock do
        inc(num);

      CurBlock.Prev.Next[num]:=nil;
      CurBlock.Prev:=nil;
    end;
  end;

end;

procedure TFormMain.BlockMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  num, movx, movy: Integer;

begin

  if flag then
  begin
    MoveAllBlocks(CurBlock, X, Y);
    y0:=y;
    x0:=x;
    CurHighLightedBlock := FindMinDist(CurBlock.x, CurBlock.y, CurBlock);

    if CurHighLightedBlock<>nil then
    begin
      num:=ConnectBlocks(CurHighLightedBlock, CurBlock, movx, movy);

      if CurHighLightedBlock.Next[num]=nil then
      begin
        HighLightBlock.Shape:=CurHighLightedBlock.Shape;
        HighLightBlock.H := CurHighLightedBlock.H+2;
        HighLightBlock.W := CurHighLightedBlock.W+2;
        HighLightBlock.y := CurHighLightedBlock.y-1;
        HighLightBlock.x := CurHighLightedBlock.x-1;
      end
      else
      begin
        CurHighLightedBlock := nil;
      end;
    end
    else
    begin
      CurHighLightedBlock := nil;
    end;

    PaintField.Invalidate();
  end;

end;

procedure TFormMain.BlockMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

var
  allDiagrams, nextDiag:pAllBlocks;
  num, movx, movy: Integer;

begin

  if Flag then
  begin
    flag := False;
    AllDiagrams:=Blocks;
    if CurHighLightedBlock <> nil then
    begin

      num:=ConnectBlocks(CurHighLightedBlock, CurBlock, movx, movy);

      if CurHighLightedBlock.Next[num]=nil then
      begin
        CurHighLightedBlock.Next[num] := CurBlock;
        CurBlock.prev := CurHighLightedBlock;
        moveAllBlocks(CurBlock,movx-(CurBlock.x-CurBlock.prev.x)+x0, movy-(CurBlock.y-CurBlock.prev.y)+y0);
      end;


      while (AllDiagrams.Next<>nil) and (AllDiagrams.Next.Block<>CurBlock) do
        AllDiagrams:=AllDiagrams.Next;

      if AllDiagrams.Next<>nil then
      begin
        nextDiag:=AllDiagrams.Next.Next;
        Dispose(AllDiagrams.Next);

        AllDiagrams.Next := NextDiag;
      end;

    end
    else
    begin
      while (AllDiagrams.Next<>nil) and (AllDiagrams.Next.Block<>CurBlock) do
        AllDiagrams:=AllDiagrams.Next;

      if AllDiagrams.Next=nil then
      begin

        new(AllDiagrams.Next);

        AllDiagrams := AllDiagrams.Next;
        AllDiagrams.Next := Nil;

        AllDiagrams.Block:=CurBlock;
      end;
    end;
    CurHighLightedBlock := CurBlock;
    HighLightBlock.Shape:=CurHighLightedBlock.Shape;
    HighLightBlock.H := CurHighLightedBlock.H+2;
    HighLightBlock.W := CurHighLightedBlock.W+2;
    HighLightBlock.y := CurHighLightedBlock.y-1;
    HighLightBlock.x := CurHighLightedBlock.x-1;

    PaintField.Invalidate;
  end;
end;

end.

unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus,
  Vcl.ComCtrls, Vcl.ToolWin, Vcl.Imaging.pngimage, Vcl.CheckLst, Vcl.Buttons,
  HelpTypes, UEditBlocks, UEditLines, UFiles;

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
    procedure FieldMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

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
  CurHighLightedBlock, HighLightBlock, HintBlock: pBlock;
  x0, y0, ConnectNum: Integer;
  curBlock: pBlock;
  flag: Boolean;
  HighLightColor, DefaultColor, HintBlockColor:Integer;
  HintBlockStyle: TPenStyle;
  Compact:Boolean;


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
  Compact:=True;

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

  HintBlock:=nil;
  New(HintBlock);
  HintBlock.Prev:=nil;

  HintBlock.ownCanvas:=FormMain.PaintField.Canvas;
  HintBlock.Pen:=FormMain.PaintField.Canvas.Pen;
  HintBlock.Brush:=FormMain.PaintField.Canvas.Brush;
  HintBlock.w:=FormMain.FrameEditBlocks.UpDownWidth.Position;
  HintBlock.h:=FormMain.FrameEditBlocks.UpDownHeight.Position;

  HintBlockStyle:=psDash;
  HintBlockColor:=clGrayText;

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

procedure TFormMain.FieldMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

Var
  ScrollBar: TControlScrollBar;
  delta:Integer;
begin
  if ssShift in shift then
    ScrollBar:=Field.HorzScrollBar
  else
    ScrollBar:=Field.VertScrollBar;
  if WheelDelta>0 then
    delta:=-ScrollBar.Increment
  else
    delta:=ScrollBar.Increment;
  ScrollBar.Position:=ScrollBar.Position+delta;
end;


procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FormStart.Show();
end;


procedure IsInNext(cur, source: pBlock; var Flag: Boolean);
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

procedure DrawLine(bl: pBlock; num: Integer);
begin
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
    2:
    begin
      bl.ownCanvas.moveto(bl.Prev.x+(bl.Prev.w*3) div 4,bl.Prev.y+(bl.Prev.h) div 4);
      bl.ownCanvas.lineto(bl.Prev.x+bl.Prev.w+FormMain.FrameEditLines.UpDownHorizontal.Position div 2,bl.Prev.y-FormMain.FrameEditLines.UpDownVertical.Position div 2);
      bl.ownCanvas.lineto(bl.x+bl.w div 2,bl.Prev.y-FormMain.FrameEditLines.UpDownVertical.Position div 2);
      bl.ownCanvas.lineto(bl.x+bl.w div 2, bl.y);
    end;
    1:
    begin
      bl.ownCanvas.moveto(bl.Prev.x+(bl.Prev.w*3) div 4,bl.Prev.y+(bl.Prev.h*3) div 4);
      bl.ownCanvas.lineto(bl.Prev.x+bl.Prev.w+10,bl.y - FormMain.FrameEditLines.UpDownVertical.Position div 2);
      bl.ownCanvas.lineto(bl.x+bl.w div 2,bl.y - FormMain.FrameEditLines.UpDownVertical.Position div 2);
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
      DrawLine(bl, num);
    end;

    temp := bl;
    for var i := 0 to High(temp.Next) do
    begin
      temp := bl.Next[i];
      DrawTree(temp,maxx, maxy);
    end;
  end;
end;

Procedure ShowHintBlock(num: Integer);

begin
  HintBlock.Pen.Style:=HintBlockStyle;
  HintBlock.Pen.Color:=HintBlockColor;


  case num of
  0:
  begin
    HintBlock.y:=HintBlock.prev.y+HintBlock.prev.h+FormMain.FrameEditLines.UpDownVertical.Position;
    HintBlock.x:=HintBlock.Prev.x + (HintBlock.Prev.w-HintBlock.w) div 2;
  end;

  1:
  begin
    HintBlock.x:=HintBlock.Prev.x + HintBlock.Prev.w + FormMain.FrameEditLines.UpDownHorizontal.Position;
    HintBlock.y:=HintBlock.prev.y + HintBlock.prev.h + FormMain.FrameEditLines.UpDownVertical.Position;
  end;

  2:
  begin
    HintBlock.x:=HintBlock.Prev.x + HintBlock.Prev.w + FormMain.FrameEditLines.UpDownHorizontal.Position;
    HintBlock.y:=HintBlock.Prev.y;
  end;

  end;

  DrawLine(HintBlock,num);
  DrawBlock(HintBlock);

  HintBlock.Pen.Style:=psSolid;
  HintBlock.Pen.Color:=HintBlockColor;
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

  if HintBlock.Prev<>nil then
    ShowHintBlock(ConnectNum);


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


procedure FindBlockInTree(bl: pBlock; x, y: Integer; var res: pBlock);
var
  temp: pBlock;
begin
  if (bl <> nil) and (res=nil) then
  begin
    case bl.Shape of

      stRectangle..stCycle:
      begin
        if (bl.x<=x) and (bl.y<=y) and (x<=bl.x+bl.w) and (y<=bl.y+bl.h)then
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


procedure IsBeforeInTree(bl, check, root: pBlock; var res, ex: Boolean);
var
  temp: pBlock;
begin
  if bl=root then
    ex:=True;

  if ex then
    exit;

  if (bl <> nil) and (res=False) then
  begin
    if bl=check then
      res:=True;

    if res=False then
    begin
      temp := bl;
      for var i := high(temp.Next) downto Low(temp.Next) do
      begin
        temp := bl.Next[i];
        IsBeforeInTree(temp,check,root,res,ex);
        if Res=True then
          exit;
      end;
    end;
  end;
end;

function IsBefore(check,root: pBlock):  Boolean;
var
  tempTree: pAllBlocks;
  bl: pBlock;
  exitCond: Boolean;
begin
  tempTree := Blocks;
  bl:=root;
  while bl.Prev<>nil do
    bl:=bl.Prev;

  Result:=False;
  ExitCond:=False;

  IsBeforeInTree(bl, check, root, Result, ExitCond);
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



Function ConnectBlocks(blmain,bl:pBlock): Integer;

begin

  case blMain.Shape of
  stRectangle, stCycle:
    if (bl.x-blmain.x>=bl.y-blmain.y) or ((blmain.y+blmain.h div 2)>=(bl.y+bl.h div 2)) then
      Result:=1
    else
      Result:=0;

  stDecision:
    if ((blmain.y+blmain.h div 2)>=(bl.y+bl.h div 2)) then
      Result:=2
    else if (bl.x-blmain.x>=bl.y-blmain.y) then
      Result:=1
    else
      Result:=0;

  end;
end;

procedure SetDefaultCoordsInTree(bl:pBlock; x, y: Integer);
begin
  if (bl<>nil) then
  begin
    if (bl.Prev<>nil) then
    begin
      bl.x:=x;
      bl.y:=y;
    end;
    for var i := High(bl.Next) downto Low(bl.Next) do
      SetDefaultCoordsInTree(bl.Next[i],x,y);
  end;
end;

Procedure SetDefaultCoords(x,y:Integer);
var
  temp: pAllBlocks;
begin
  temp := Blocks;
  while (temp.Next <> Nil) do
  begin
    temp := temp.Next;
    SetDefaultCoordsInTree(temp.Block,x,y);
  end;
end;



Procedure StructuriseBlocksInTree(bl:pBlock; Var dist: Integer; num, level: Integer);
var
  ContinueCompacting, temp1, temp2: Boolean;
  tempBlock: pBlock;
begin
  if (bl<>nil) then
  begin
    if bl.Prev<>nil then
    begin
      case num of
      0:
      begin
        bl.y:=dist+FormMain.FrameEditLines.UpDownVertical.Position;
        bl.x:=bl.Prev.x + (bl.Prev.w-bl.w) div 2;

      end;

      1:
      begin
        bl.x:=bl.Prev.x + bl.Prev.w + FormMain.FrameEditLines.UpDownHorizontal.Position;
        bl.y:=dist + FormMain.FrameEditLines.UpDownVertical.Position;
      end;

      2:
      begin
        bl.x:=bl.Prev.x + bl.Prev.w + FormMain.FrameEditLines.UpDownHorizontal.Position;
        bl.y:=bl.Prev.y;
      end;

      end;

      if ((Num = 0) or (num = 1)) and Compact and (level <> 1) then
      begin
        continueCompacting:=True;
        while ContinueCompacting do
        begin
          tempBlock:=findBlock(bl.x+bl.w div 2, bl.y-FormMain.FrameEditLines.UpDownVertical.Position-5);
          ContinueCompacting:=(tempBlock = nil);

          if length(bl.Next)=3 then
            temp1 := (bl.Next[1] = nil) and (bl.Next[2] = nil)
          else if length(bl.Next)=2 then
            temp1 := (bl.Next[1] = nil)
          else
            temp1:=True;

          tempBlock:=findBlock(bl.x+bl.w+FormMain.FrameEditLines.UpDownHorizontal.Position + 5, bl.y-FormMain.FrameEditLines.UpDownVertical.Position-5);
          ContinueCompacting:=ContinueCompacting and (temp1 or (tempBlock = nil));

          ContinueCompacting:=ContinueCompacting and (bl.y>bl.Prev.y+bl.prev.h+FormMain.FrameEditLines.UpDownVertical.Position*2);

          if ContinueCompacting then
            bl.y:=bl.y-(bl.h+FormMain.FrameEditLines.UpDownVertical.Position);
        end;
      end;

    end;

    if dist<=bl.y+bl.h then
      dist:=bl.y+bl.h;

    for var i := High(bl.Next) downto Low(bl.Next) do
    if i=0 then
      StructuriseBlocksInTree(bl.Next[i],dist, i,level)
    else
      StructuriseBlocksInTree(bl.Next[i],dist, i,level+1);
  end;
end;

Procedure StructuriseBlocks();
var
  temp: pAllBlocks;
  dist: Integer;
begin
  temp := Blocks;
  dist:=0;

  SetDefaultCoords(-1000,-1000);
  while (temp.Next <> Nil) do
  begin
    temp := temp.Next;
    StructuriseBlocksInTree(temp.Block, dist, 0, 1);
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

      if (tempDist < Min) and (x < FormMain.FrameEditLines.UpDownHorizontal.Position+bl.x+bl.w+210) and (y < FormMain.FrameEditLines.UpDownVertical.Position+bl.y+bl.h+210) then
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
  HintBlock.Prev:=0;
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

    num:=ConnectBlocks(CurHighLightedBlock, temp);

    if CurHighLightedBlock.Next[num]=nil then
    begin
      CurHighLightedBlock.Next[num]:=temp;
      CurHighLightedBlock.Next[num].Prev:=CurHighLightedBlock;
      //moveAllBlocks(temp,movx-(temp.x-temp.prev.x)+x0, movy-(temp.y-temp.prev.y)+y0);
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
  StructuriseBlocks();

  CurHighLightedBlock := temp;
  HighLightBlock.Shape:=CurHighLightedBlock.Shape;
  HighLightBlock.H := CurHighLightedBlock.H+2;
  HighLightBlock.W := CurHighLightedBlock.W+2;
  HighLightBlock.y := CurHighLightedBlock.y-1;
  HighLightBlock.x := CurHighLightedBlock.x-1;

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
    HintBlock.prev:=nil;
    if FindMinDist(X, Y, nil) <> nil then
    begin
      CurHighLightedBlock := FindMinDist(X, Y, nil);

      num:=ConnectBlocks(CurHighLightedBlock, CurBlock);

      if CurHighLightedBlock.Next[num]=nil then
      begin
        HighLightBlock.Shape:=CurHighLightedBlock.Shape;
        HighLightBlock.H := CurHighLightedBlock.H+2;
        HighLightBlock.W := CurHighLightedBlock.W+2;
        HighLightBlock.y := CurHighLightedBlock.y-1;
        HighLightBlock.x := CurHighLightedBlock.x-1;
        HintBlock.Prev:=CurHighLightedBlock;
        HintBlock.Shape:=CurBlock.Shape;
        ConnectNum:=num;
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

    CurBlock.PrevX:=X;
    CurBlock.PrevY:=Y;
    if CurBlock.Prev<>nil then
    begin
      num:=0;
      while CurBlock.Prev.Next[num]<>CurBlock do
        inc(num);

      CurHighLightedBlock:=CurBlock.prev;
      HighLightBlock.Shape:=CurHighLightedBlock.Shape;
      HighLightBlock.H := CurHighLightedBlock.H+2;
      HighLightBlock.W := CurHighLightedBlock.W+2;
      HighLightBlock.y := CurHighLightedBlock.y-1;
      HighLightBlock.x := CurHighLightedBlock.x-1;

      //PaintField.Invalidate();

      CurBlock.Prev.Next[num]:=nil;
      CurBlock.Prev:=nil;
    end;
  end;

end;

procedure TFormMain.BlockMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  num: Integer;

begin

  if flag then
  begin
    MoveAllBlocks(CurBlock, X, Y);

    y0:=y;
    x0:=x;

    CurBlock.PrevX:=MaxInt;
    CurBlock.PrevY:=MaxInt;

    CurHighLightedBlock := FindMinDist(CurBlock.x, CurBlock.y, CurBlock);
    HintBlock.Prev:=nil;

    if CurHighLightedBlock<>nil then
    begin
      num:=ConnectBlocks(CurHighLightedBlock, CurBlock);

      if CurHighLightedBlock.Next[num]=nil then
      begin
        HighLightBlock.Shape:=CurHighLightedBlock.Shape;
        HighLightBlock.H := CurHighLightedBlock.H+2;
        HighLightBlock.W := CurHighLightedBlock.W+2;
        HighLightBlock.y := CurHighLightedBlock.y-1;
        HighLightBlock.x := CurHighLightedBlock.x-1;
        HintBlock.Prev := CurHighLightedBlock;
        HintBlock.Shape:=CurBlock.Shape;
        ConnectNum:=num;
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
  num: Integer;

begin

  if Flag then
  begin
    flag := False;
    AllDiagrams:=Blocks;
    HintBlock.Prev:=nil;

    if CurHighLightedBlock <> nil then
    begin

      num:=ConnectBlocks(CurHighLightedBlock, CurBlock);

      if CurHighLightedBlock.Next[num]=nil then
      begin
        CurHighLightedBlock.Next[num] := CurBlock;
        CurBlock.prev := CurHighLightedBlock;
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

    StructuriseBlocks();

    CurHighLightedBlock := CurBlock;
    HighLightBlock.Shape:=CurHighLightedBlock.Shape;
    HighLightBlock.H := CurHighLightedBlock.H+2;
    HighLightBlock.W := CurHighLightedBlock.W+2;
    HighLightBlock.y := CurHighLightedBlock.y-1;
    HighLightBlock.x := CurHighLightedBlock.x-1;


  end;

  PaintField.Invalidate;
end;

end.

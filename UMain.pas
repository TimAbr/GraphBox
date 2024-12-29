unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus,
  Vcl.ComCtrls, Vcl.ToolWin, Vcl.Imaging.pngimage, Vcl.CheckLst, Vcl.Buttons,
  HelpTypes, UEditBlocks, UEditLines, UFiles, System.Actions, Vcl.ActnList,
  System.ImageList, Vcl.ImgList, Vcl.ActnMan, Vcl.ActnCtrls, clipBrd, iniFiles,
  Vcl.ControlList;

type

  TFormMain = class(TForm)
    MainMenu1: TMainMenu;
    Edit2: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    BottomPnl: TPanel;
    Button1: TButton;
    MenuPanel: TPanel;
    FileName: TLabel;
    Field: TScrollBox;
    ChangeFontStyle: TComboBox;
    SaveDialog: TSaveDialog;
    InstrumentPanel: TPanel;
    Label2: TLabel;
    ShapePanel: TPanel;
    PaintField: TPaintBox;
    FrameEditBlocks: TFrameEditBlocks;
    ButtonBlocks: TSpeedButton;
    ButtonLines: TSpeedButton;
    FrameEditLines: TFrameEditLines;
    ActionList: TActionList;
    Save: TAction;
    SaveAs: TAction;
    Open: TAction;
    NewFile: TAction;
    ExportAsPng: TAction;
    ImageList1: TImageList;
    Saveas1: TMenuItem;
    N1: TMenuItem;
    ExportAsPng1: TMenuItem;
    OpenDialog: TOpenDialog;
    tbMain: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    SaveImageDialog: TSaveDialog;
    FilesPB: TPaintBox;
    CopyImage: TAction;
    Copy1: TMenuItem;
    Undo: TAction;
    Undo1: TMenuItem;
    EditHorAl: TComboBox;
    EditVertAl: TComboBox;
    EditFontSize: TComboBox;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;

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
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SaveAsExecute(Sender: TObject);
    procedure SaveAsUpdate(Sender: TObject);
    procedure OpenExecute(Sender: TObject);
    procedure OpenUpdate(Sender: TObject);
    procedure ExportAsPngExecute(Sender: TObject);
    procedure ExportAsPngUpdate(Sender: TObject);
    procedure NewFileExecute(Sender: TObject);
    procedure FieldClick(Sender: TObject);
    procedure FilesPBPaint(Sender: TObject);
    procedure FilesPBMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SaveExecute(Sender: TObject);
    procedure SaveUpdate(Sender: TObject);
    procedure CopyImageExecute(Sender: TObject);
    procedure CopyImageUpdate(Sender: TObject);
    procedure ShapePanelDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure UndoExecute(Sender: TObject);
    procedure UndoUpdate(Sender: TObject);
    Procedure SetDefaultValues();
    procedure setDefEdits();
    procedure EditFontSizeChange(Sender: TObject);

  private

  public
    { Public declarations }
  end;

procedure MoveAllBlocks(bl: pBlock; X, Y: Integer);
function FindMinDist(X, Y: Integer; main: pointer): pBlock;
procedure FindMinDistInTree(bl: pBlock; X, Y: Integer; var Min: Real;
  var res: pBlock; main: pBlock);
procedure StructuriseBlocks(Blocks: pAllBlocks);
procedure DrawAllBlocks(ownCanvas: TCanvas);
Procedure CreateFileBlock(F: pFilesArr);


var
  FormMain: TFormMain;
  Blocks: pAllBlocks;
  Files: pFilesArr;
  EditText: TProEdit;
  CurHighLightedBlock, HighLightBlock, HintBlock: pBlock;
  x0, y0, ConnectNum: Integer;
  curBlock: pBlock;
  flag: Boolean;
  HighLightColor, DefaultColor, HintBlockColor:Integer;
  HintBlockStyle: TPenStyle;
  Compact:Boolean;
  CurFile: pFilesArr;


implementation

{$R *.dfm}

Uses UStart;

//sets default values to the edit fields of the form
//according to the diagram
procedure TFormMain.setDefEdits();
var
  f: TIniFile;
  temp: pBlock;
begin
  //open the file with default settings
  f:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'\Settings.ini');

  //if the diag is empty
  if Blocks.Next=nil then
  begin
    //then input default values

    //text chracteristics
    EditFontSize.ItemIndex:=4;
    ChangeFontStyle.ItemIndex:=0;
    EditHorAl.ItemIndex:=1;
    EditVertAl.ItemIndex:=1;

    //size characteristics
    FrameEditBlocks.UpDownHeight.Position := f.ReadInteger('Main','Block Height',60);
    FrameEditBlocks.UpDownWidth.Position := f.ReadInteger('Main','Block width',130);

    //lines characteristics
    FrameEditLines.UpDownHorizontal.Position:=f.ReadInteger('Main','Horizotal distance',50);
    FrameEditLines.UpDownVertical.Position:=f.ReadInteger('Main','Vertical distance',50);
  end
  else
  begin
    //else take values from the diag

    //values from the first block about its size
    FrameEditBlocks.UpDownHeight.Position := Blocks.Next.Block.H;
    FrameEditBlocks.UpDownWidth.Position := Blocks.Next.Block.w;

    //text characteristics
    EditFontSize.ItemIndex:=Blocks.Next.Block.FontSize;
    ChangeFontStyle.ItemIndex:=Blocks.Next.Block.FontStyle;
    EditHorAl.ItemIndex:=ord(Blocks.Next.Block.TextHorAllign);
    EditVertAl.ItemIndex:=ord(Blocks.Next.Block.TextVertAllign);

    temp:=Blocks.Next.Block;

    //lines chracteristics
    while (temp.Next[0]<>nil) and ((length(temp.Next)=1) or (temp.Next[1]=nil)) do
    begin
      temp:=temp.Next[0];
    end;
    if (length(temp.Next)>1) and (temp.Next[1]<>nil) then
    begin
      FrameEditLines.UpDownHorizontal.Position:=temp.Next[1].x-(temp.x+temp.w);
      FrameEditLines.UpDownVertical.Position:=temp.Next[1].y-(temp.y+temp.h);
    end
    else
    begin
      FrameEditLines.UpDownHorizontal.Position:=f.ReadInteger('Main','Horizotal distance',50);
      FrameEditLines.UpDownVertical.Position:=f.ReadInteger('Main','Vertical distance',50);
    end;
  end;

  //resize the diagram according to the values
  ReSizeAll(FrameEditBlocks.UpDownWidth.Position, FrameEditBlocks.UpDownHeight.Position);
  StructuriseBlocks(Blocks);

  //redraw the diagram
  PaintField.Invalidate;
  f.Free;
end;


//Initialisation of a new file
Procedure CreateFileBlock(F: pFilesArr);
begin
  with F^ do
  begin
    New(Form);
    Form.H:=FormMain.FilesPB.Height;
    Form.W:=110;
    Form.Shape:=stRectangle;
    Form.TextVertAllign:=vCenter;
    Form.TextHorAllign:=hLeft;
    Form.Text:='New file';
    Next:=nil;
    Form.BorderColor:=clMedGray;
    Form.FontSize:=1;
    Form.FontStyle:=1;
    New(UndoList);
    UndoList.Next:=nil;
  end;
end;

//default values of an opened file
Procedure TFormMain.SetDefaultValues();
var
  f: TIniFile;
begin
  //open file with settings
  f:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'\Settings.ini');

  //set default values to the fields
  FrameEditBlocks.UpDownHeight.Position := f.ReadInteger('Main','Block Height',60);
  FrameEditBlocks.UpDownWidth.Position := f.ReadInteger('Main','Block width',130);

  FrameEditLines.UpDownHorizontal.Position:=f.ReadInteger('Main','Horizotal distance',50);
  FrameEditLines.UpDownVertical.Position:=f.ReadInteger('Main','Vertical distance',50);

  HintBlockColor:=f.ReadInteger('Main','Hint color',clGrayText);
  HintBlock.BorderColor:=HintBlockColor;
  HintBlock.FillColor:=clWhite;

  HighLightColor:=f.ReadInteger('Main','Highlight color',clHighLight);
  HighLightBlock.BorderColor:=HighLightColor;
  HighLightBlock.FillColor:=clWhite;

  //close file
  f.free;
end;

// initialisation of the form
procedure TFormMain.FormCreate(Sender: TObject);
var
  StartBlock: TStartBlock;

begin
  //drag flag
  flag := False;

  //main diagram
  new(Blocks);
  Blocks.Next := nil;
  Blocks.Block := Nil;

  //list of files
  new(Files);
  Files.Form:=nil;

  //the first empty file
  New(Files.Next);
  CreateFileBlock(Files.Next);
  Files.Next.Diag:=Blocks;
  Files.Next.FName:='New file';

  //choosing the current file
  CurFile:=Files.Next;

  //current moving block
  CurBlock:=nil;

  //style of the diagram
  Compact:=True;

  //text editing filed
  EditText := TProEdit.Create(FormMain);
  EditText.Parent := Field;
  EditText.Hide;

  //default size of a drawing filed
  PaintField.width:=200;
  PaintField.height:=200;

  //create a highlight block
  New(HighLightBlock);
  CurHighLightedBlock := nil;

  //initialisation of HLBlock
  HighLightBlock.Text:='';

  //Color of the diagram
  DefaultColor:=clBlack;

  //Create HintBlock
  HintBlock:=nil;
  New(HintBlock);
  HintBlock.Prev:=nil;

  //Set place of a drawing field
  PaintField.left:=0;
  PaintField.Top:=0;

  //initiaisation of hintBlocks
  HintBlock.w:=130;
  HintBlock.h:=60;
  HintBlockStyle:=psDash;

  SetDefaultValues();

  //Create start blocks
  for var i := 0 to 4 do
  begin

    StartBlock := TStartBlock.Create(ShapePanel);

    with StartBlock do
    begin
      //shape of a start block
      Parent := ShapePanel;
      Shape := TShapeType(i);

      //size of a start block
      Width := ShapePanel.Width - 24;

      Height := Width div 3;
      Height:=Height*2;

      //position of a start block
      Left := 12;
      Top := 70 + (Height + 30) * i;

      StartBlock.onMouseDown:=BlockStartDrag;

      Hint:='Pull me';
      ShowHint:=True;
    end;

  end;
  FileName.Caption:='';

  setDefEdits();

  //add value to the undoo stack
  addUndo(CurFile);
  FilesPB.Invalidate;
end;


procedure TFormMain.FilesPBMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Start, temp: pFilesArr;
  n, selBtn: Integer;
  IsCur: Boolean;
begin
  Start:=Files;
  n:=0;
  CurHighLightedBlock := Nil;
  while Files.Next<>nil do
  begin
    inc(n);
    with Files.Next^ do
    begin
      if (x>=Form.x) and (x<=Form.x+Form.w) and (y>=Form.y) and (y<=Form.y+Form.h) then
      begin
        if ((x>=Form.x+Form.w-Form.H+9) and (x<=Form.x+Form.w-9) and (y>=Form.y+9) and (y<=Form.y+Form.h-9))
            and (not (n=1) or (Next<>nil)) then
        begin
          if Blocks.Next<>nil then
          begin
            selBtn:=MessageBox(handle,'Save changes?','Close file',mb_YesNoCancel+mb_IconQuestion);
            if selBtn = mrYes then
            begin
              if CurFile.FName='New file' then
                SaveAsExecute(ActionList)
              else
                SaveExecute(ActionList);
            end;

          end;
          if selBtn<>mrCancel then
          begin
            temp:=Next;

            isCur:= Files.Next = CurFile;

            DestroyAll(Diag);
            Dispose(Form);
            Dispose(Files.Next);
            Files.Next:=temp;
            if IsCur then
            begin
              Files:=Start;

              while Files.Next<>temp do
                Files:=Files.Next;

              if Files.Form<>nil then
                CurFile:=Files
              else
                CurFile:=temp;
            end;
            Blocks:=CurFile.Diag;
          end;
        end
        else
        begin
          Blocks:=Diag;
          CurFile:=Files.Next;
          setDefEdits();
        end;
        break;
      end;
      Files:=Files.Next;
    end;

  end;
  CurHighLightedBlock:=nil;
  FilesPB.Invalidate();
  PaintField.Invalidate();
  Files:=Start;
end;

procedure TFormMain.FilesPBPaint(Sender: TObject);
var
  Start: pFilesArr;
begin
  Start:=Files;

  Files:=Files.Next;

  Files.Form.x:=ShapePanel.Width;
  Files.Form.y:=0;
  if Files = curFile then
    Files.Form.FillColor:=clBtnHighLight
  else
    Files.Form.FillColor:=clBtnFace;

  DrawBlock(Files.Form, FilesPB.Canvas);

  if Files.Next<>nil then
  begin

    with FilesPB.Canvas do
    begin
      Pen.Color:=clMedGray;
      with Files.Form^ do
      begin
        moveto(x+w-h+10,y+10);
        lineto(x+w-9,y+h-9);
        moveto(x+w-10,y+10);
        lineto(x+w-h+9,y+h-9);
      end;
    end;

    while Files.Next<>nil do
    begin
      Files.Next.Form.x:=Files.Form.x+ Files.Form.w;
      Files.Next.Form.y:=0;

      Files:=Files.Next;

      if Files = curFile then
        Files.Form.FillColor:=clBtnHighLight
      else
        Files.Form.FillColor:=clBtnFace;

      DrawBlock(Files.Form, FilesPB.Canvas);

      with FilesPB.Canvas do
      begin
        Pen.Color:=clMedGray;
        with Files.Form^ do
        begin
          moveto(x+w-h+10,y+10);
          lineto(x+w-9,y+h-9);
          moveto(x+w-10,y+10);
          lineto(x+w-h+9,y+h-9);
        end;
      end;

    end
  end;

  Files:=Start;
end;



procedure TFormMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  num:Integer;
  AllDiagrams, nextDiag:pAllBlocks;
begin

 if (Key=$2e) and (CurhighLightedBlock<>nil) and not flag then
  begin
    AllDiagrams:=Blocks;

    while (AllDiagrams.Next<>nil) and (AllDiagrams.Next.Block<>CurHighLightedBlock) do
      AllDiagrams:=AllDiagrams.Next;

    if AllDiagrams.Next<>nil then
    begin
      nextDiag:=AllDiagrams.Next.Next;
      Dispose(AllDiagrams.Next);

      AllDiagrams.Next := NextDiag;
    end
    else
    begin
      num:=0;

      while CurHighLightedBlock.Prev.Next[num]<>CurHighLightedBlock do
        inc(num);

      CurHighLightedBlock.Prev.Next[num]:=nil;
    end;

    while (AllDiagrams.Next<>nil) do
      AllDiagrams:=AllDiagrams.Next;

    for num := Low(CurHighLightedBlock.Next) to High(CurHighLightedBlock.Next) do
    begin
      if CurHighLightedBlock.Next[num]<>nil then
      begin
        New(AllDiagrams.Next);
        AllDiagrams:=AllDiagrams.Next;
        AllDiagrams.Next:=nil;
        AllDiagrams.Block:=CurHighLightedBlock.Next[num];
        CurHighLightedBlock.Next[num].Prev:=nil;
        CurHighLightedBlock.Next[num]:=nil;
      end;
    end;
    Dispose(CurHighLightedBlock);
    CurHighLightedBlock:=nil;
    StructuriseBlocks(Blocks);
    PaintField.Invalidate;
  end;

end;

procedure TFormMain.FormResize(Sender: TObject);
begin
  PaintField.Invalidate();
end;



procedure TFormMain.NewFileExecute(Sender: TObject);
var
  Start: pFilesArr;
begin

  Blocks:=nil;
  New(Blocks);
  Blocks.Next:=nil;
  Blocks.Block:=nil;

  Start:=Files;

  while files.Next<>nil do
    Files:=Files.Next;

  New(Files.Next);
  CreateFileBlock(Files.Next);
  Files.Next.Diag:=Blocks;
  CurFile:=Files.Next;
  CurFile.FName:='New file';

  PaintField.Invalidate;
  FilesPB.Invalidate;

  SetDefaultValues();

  Files:=Start;

  addUndo(CurFile);

  setDefEdits()
end;

procedure TFormMain.OpenExecute(Sender: TObject);
var
  Arr: TArrBlocks;
  ArrPrev, ArrPos: TArrInt;
  len, n, ls, i, defaultWidth, defaultHeight:Integer;
  FName: String;
  temp: String[255];
  f:File;
  Start:pAllBlocks;
  StartFiles: pFilesArr;
begin
  if (OpenDialog.Execute) then
  begin
    FName := OpenDialog.FileName;

    StartFiles:=Files;

    while (Files.Next<>nil) and ((Files.Next.Form.text <> 'New file') or (Files.Next.Diag.Next <> nil)) do
      Files:=Files.Next;

    if Files.Next = nil then
    begin
      New(Files.Next);
      Files:=Files.Next;
      CreateFileBlock(Files);
      New(Files.Diag);
      Files.Diag.Next:=nil;
    end
    else
    begin
      Files:=Files.Next;
    end;

    Blocks:=Files.Diag;
    Files.FName:=FName;
    i:=length(FName);
    Files.Form.text:='';
    while (i>=1) and (FName[i]<>'\') do
    begin
      Files.Form.text:=FName[i]+Files.Form.text;
      dec(i);
    end;
    CurFile:=Files;

    Files:=StartFiles;

    CurHighLightedBlock:=nil;
    FilesPB.Invalidate();

    AssignFile(f,FName);
    Reset(f,1);

    FileName.Caption:=Copy(FName,1,length(FName)-3);

    DestroyAll(Blocks);

    Blocks:=nil;
    New(Blocks);
    Blocks.Next:=nil;

    BlockRead(f,n,4);
    Start:=Blocks;

    for var k := 1 to n do
    begin
      BlockRead(f,len,4);

      setlength(Arr,len);
      setlength(ArrPrev,len);
      setlength(ArrPos,len);

      for i := 0 to len-1 do
      begin
        New(Arr[i]);
        BlockRead(f, Arr[i]^, sizeOf(TBlock));
      end;

      for i := 0 to len-1 do
        BlockRead(f, ArrPrev[i], 4);

      for i := 0 to len-1 do
        BlockRead(f, ArrPos[i], 4);

      for i := 0 to len-1 do
      begin
        BlockRead(f,ls,4);
        setlength(temp,ls);
        BlockRead(f, temp, ls*2);

        Arr[i].Text:=temp;
      end;

      New(Blocks.Next);
      Blocks:=Blocks.Next;
      Blocks.Block:=ConverteToTree(Arr,ArrPrev,ArrPos);
      Blocks.Next:=nil;
    end;
    Blocks:=Start;

    DefaultWidth:=Blocks.Next.Block.w;
    DefaultHeight:=Blocks.Next.Block.h;

    FrameEditBlocks.UpDownHeight.Position:=DefaultHeight;
    FrameEditBlocks.EditHeight.Text:=IntToStr(DefaultHeight);
    FrameEditBlocks.UpDownWidth.Position:=DefaultWidth;
    FrameEditBlocks.EditWidth.Text:=IntToStr(DefaultWidth);

    ReSizeAll(DefaultWidth, DefaultHeight);
    StructuriseBlocks(Blocks);
    PaintField.Invalidate();

    if CurFile.UndoList.Next<>nil then
    begin
      DestroyAll(CurFile.UndoList.Next.Cur);
      Dispose(CurFile.UndoList.Next);
      CurFile.UndoList.Next:=nil;
    end;

    addUndo(CurFile);
    setDefEdits();
  end;
end;

procedure TFormMain.OpenUpdate(Sender: TObject);
begin
  Open.Enabled:=True;
end;

procedure TFormMain.SaveAsExecute(Sender: TObject);
var
  Arr: TArrBlocks;
  ArrPrev, ArrPos: TArrInt;
  len, n, ls, i:Integer;
  FName: String;
  f:File;
  tempBlock:pAllBlocks;
  temp:String[255];
  tempArr: TNextArr;

begin
  if saveDialog.Execute then
  begin
    FName := SaveDialog.FileName;

    if LowerCase(Copy(FName,length(FName)-2))<>'.gb' then
      FName:=FName+'.gb';

    CurFile.FName:=FName;

    CurFile.Form.text:='';

    i:=length(FName);
    while (i>=1) and (FName[i]<>'\') do
    begin
      CurFile.Form.text:=FName[i]+CurFile.Form.text;
      dec(i);
    end;

    AssignFile(f,FName);
    FileName.Caption:=FName;

    Rewrite(f,1);

    tempBlock:=Blocks;
    n:=0;

    while tempBlock.Next<>nil do
    begin
      tempBlock:=tempBlock.Next;
      inc(n);
    end;

    BlockWrite(f, n, 4);
    tempBlock:=Blocks;

    for var k := 1 to n do
    begin
      tempBlock:=tempBlock.Next;

      len:=0;
      ConverteToMas(tempBlock.Block, Arr, ArrPrev,ArrPos,len);
      inc(len);

      BlockWrite(f, len, 4);

      for i := 0 to len-1 do
      begin
        temp:=Arr[i].Text;
        ls:=length(Arr[i].Text);

        Arr[i].Text:='';

        tempArr:=Arr[i].Next;
        Arr[i].Next:=nil;

        BlockWrite(f, Arr[i]^, sizeOf(TBlock));

        Arr[i].Next:=tempArr;
        Arr[i].text:=temp;
      end;

      for i := 0 to len-1 do
        BlockWrite(f, ArrPrev[i], 4);

      for i := 0 to len-1 do
        BlockWrite(f, ArrPos[i], 4);

      for i := 0 to len-1 do
      begin
        ls:=length(Arr[i].Text);
        BlockWrite(f, ls, 4);
        temp:=Arr[i].Text;
        BlockWrite(f, temp, ls*2);
      end;

    end;
    closefile(f);
    FilesPB.Invalidate();
  end;
end;

procedure TFormMain.SaveAsUpdate(Sender: TObject);
begin
  SaveAs.Enabled:=Blocks.Next<>nil;
end;

procedure TFormMain.SaveExecute(Sender: TObject);
var
  Arr: TArrBlocks;
  ArrPrev, ArrPos: TArrInt;
  len, n, ls, i:Integer;
  FName: String;
  f:File;
  tempBlock:pAllBlocks;
  temp:String[255];
  tempArr: TNextArr;

begin
  FName:=CurFile.FName;
  AssignFile(f,FName);
  FileName.Caption:=FName;

  Rewrite(f,1);

  tempBlock:=Blocks;
  n:=0;

  while tempBlock.Next<>nil do
  begin
    tempBlock:=tempBlock.Next;
    inc(n);
  end;

  BlockWrite(f, n, 4);
  tempBlock:=Blocks;

  for var k := 1 to n do
  begin
    tempBlock:=tempBlock.Next;

    len:=0;
    ConverteToMas(tempBlock.Block, Arr, ArrPrev,ArrPos,len);
    inc(len);

    BlockWrite(f, len, 4);

    for i := 0 to len-1 do
    begin
      temp:=Arr[i].Text;
      ls:=length(Arr[i].Text);

      Arr[i].Text:='';

      tempArr:=Arr[i].Next;
      Arr[i].Next:=nil;

      BlockWrite(f, Arr[i]^, sizeOf(TBlock));

      Arr[i].Next:=tempArr;
      Arr[i].text:=temp;
    end;

    for i := 0 to len-1 do
      BlockWrite(f, ArrPrev[i], 4);

    for i := 0 to len-1 do
      BlockWrite(f, ArrPos[i], 4);

    for i := 0 to len-1 do
    begin
      ls:=length(Arr[i].Text);
      BlockWrite(f, ls, 4);
      temp:=Arr[i].Text;
      BlockWrite(f, temp, ls*2);
    end;

  end;
  closefile(f);
end;


procedure TFormMain.SaveUpdate(Sender: TObject);
begin
  Save.Enabled:=(Blocks.Next<>nil) and (CurFile.FName<> 'New file');
end;

procedure TFormMain.ShapePanelDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept:=False;
  PaintField.Invalidate;
end;

procedure changeTextTree(bl:pBlock);
begin
  if bl<>nil then
  begin
    bl.FontSize:=FormMain.EditFontSize.ItemIndex;
    bl.FontStyle:=FormMain.ChangeFontStyle.ItemIndex;
    bl.TextHorAllign:=THorAllign(FormMain.EditHorAl.ItemIndex);
    bl.TextVertAllign:=TVertAllign(FormMain.EditVertAl.ItemIndex);

    for var i := Low(bl.Next) to High(bl.Next) do
      changeTextTree(bl.Next[i])
  end;
end;

procedure TFormMain.EditFontSizeChange(Sender: TObject);
var
  temp:pAllBlocks;
begin
  temp:=Blocks;
  while temp.Next<>nil do
  begin
    temp:=temp.Next;
    changeTextTree(temp.Block);
  end;
  PaintField.Invalidate;
end;

procedure TFormMain.ExportAsPngExecute(Sender: TObject);
var
  FName: String;
  BitMap: TBitMap;
  PNG: TPNGObject;
begin
  if saveImageDialog.Execute then
  begin
    BitMap:=TBitMap.Create;
    PNG:=TPNGObject.Create;
    BitMap.Height:=PaintField.Height;
    BitMap.width:=PaintField.width;


    DrawAllBlocks(BitMap.Canvas);

    PNG.Assign(BitMap);

    FName := SaveImageDialog.FileName;
    if LowerCase(Copy(FName,length(FName)-2))<>'.png' then
      FName:=FName+'.png';

    PNG.SaveToFile(FName);
    BitMap.Free;
    PNG.Free;
  end;
end;

procedure TFormMain.ExportAsPngUpdate(Sender: TObject);
begin
  ExportAsPng.Enabled:=Blocks.Next<>nil;
end;



procedure TFormMain.CopyImageExecute(Sender: TObject);
var
  BitMap: TBitMap;
  PNG: TPNGObject;
begin

  BitMap:=TBitMap.Create;
  PNG:=TPNGObject.Create;
  BitMap.Height:=PaintField.Height;
  BitMap.width:=PaintField.width;


  DrawAllBlocks(BitMap.Canvas);

  PNG.Assign(BitMap);

  ClipBoard.Assign(PNG);
  BitMap.Free;
  PNG.Free;
end;


procedure TFormMain.CopyImageUpdate(Sender: TObject);
begin
  CopyImage.Enabled:=Blocks.Next<>nil;
end;

procedure TFormMain.FieldClick(Sender: TObject);
begin
  if (EditText.Visible) then
  begin
    EditText.prev.text := EditText.Text;
    EditText.Hide;
    addUndo(CurFile);
  end;

  if (CurHighLightedBlock <> Nil) then
  begin
    CurHighLightedBlock := Nil;
  end;

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
var
  selBtn: Integer;
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

procedure DrawLine(bl: pBlock; num: Integer; ownCanvas: TCanvas);
begin
  case bl.Prev.Shape of
  stRectangle, stCircle, stTerminator:
  begin
    case num of
    0:
    begin
      ownCanvas.moveto(bl.Prev.x+bl.Prev.w div 2,bl.Prev.y+bl.Prev.h);
      ownCanvas.lineto(bl.x+bl.w div 2,bl.y);
    end;
    1:
    begin
      ownCanvas.moveto(bl.Prev.x+bl.Prev.w,bl.Prev.y+bl.Prev.h div 2);
      ownCanvas.lineto(bl.x+bl.w div 2,bl.Prev.y+bl.Prev.h div 2);
      ownCanvas.lineto(bl.x+bl.w div 2, bl.y);
    end;
    end;

  end;
  stDecision:
  begin
    case num of
    0:
    begin
      ownCanvas.moveto(bl.Prev.x+bl.Prev.w div 2,bl.Prev.y+bl.Prev.h);
      ownCanvas.lineto(bl.x+bl.w div 2,bl.y);
    end;
    2:
    begin
      ownCanvas.moveto(bl.Prev.x+(bl.Prev.w*3) div 4,bl.Prev.y+(bl.Prev.h) div 4);
      ownCanvas.lineto(bl.Prev.x+bl.Prev.w+FormMain.FrameEditLines.UpDownHorizontal.Position div 2,bl.Prev.y-FormMain.FrameEditLines.UpDownVertical.Position div 2);
      ownCanvas.lineto(bl.x+bl.w div 2,bl.Prev.y-FormMain.FrameEditLines.UpDownVertical.Position div 2);
      ownCanvas.lineto(bl.x+bl.w div 2, bl.y);
    end;
    1:
    begin

      ownCanvas.moveto(bl.Prev.x+(bl.Prev.w*3) div 4,bl.Prev.y+(bl.Prev.h*3) div 4);
      ownCanvas.lineto(bl.Prev.x+bl.Prev.w+FormMain.FrameEditLines.UpDownHorizontal.Position div 2,bl.Prev.y+bl.Prev.h + FormMain.FrameEditLines.UpDownVertical.Position div 2);
      ownCanvas.lineto(bl.Prev.x+bl.Prev.w+FormMain.FrameEditLines.UpDownHorizontal.Position div 2,bl.y - FormMain.FrameEditLines.UpDownVertical.Position div 2);
      ownCanvas.lineto(bl.Prev.x+bl.Prev.w+FormMain.FrameEditLines.UpDownHorizontal.Position div 2,bl.y - FormMain.FrameEditLines.UpDownVertical.Position div 2);
      ownCanvas.lineto(bl.x+bl.w div 2,bl.y - FormMain.FrameEditLines.UpDownVertical.Position div 2);
      ownCanvas.lineto(bl.x+bl.w div 2, bl.y);
    end;
    end;
  end;
  stCycle:
  begin
    case num of
    0:
    begin
      ownCanvas.moveto(bl.Prev.x+bl.Prev.w div 2,bl.Prev.y+bl.Prev.h);
      ownCanvas.lineto(bl.x+bl.w div 2,bl.y);
    end;
    2:
    begin
      ownCanvas.moveto(bl.Prev.x+(bl.Prev.w*7) div 8,bl.Prev.y+(bl.Prev.h) div 4);
      ownCanvas.lineto(bl.Prev.x+bl.Prev.w+FormMain.FrameEditLines.UpDownHorizontal.Position div 2,bl.Prev.y-FormMain.FrameEditLines.UpDownVertical.Position div 2);
      ownCanvas.lineto(bl.x+bl.w div 2,bl.Prev.y-FormMain.FrameEditLines.UpDownVertical.Position div 2);
      ownCanvas.lineto(bl.x+bl.w div 2, bl.y);
    end;
    1:
    begin

      ownCanvas.moveto(bl.Prev.x+(bl.Prev.w*7) div 8,bl.Prev.y+(bl.Prev.h*3) div 4);
      ownCanvas.lineto(bl.Prev.x+bl.Prev.w+FormMain.FrameEditLines.UpDownHorizontal.Position div 2,bl.Prev.y+bl.Prev.h + FormMain.FrameEditLines.UpDownVertical.Position div 2);
      ownCanvas.lineto(bl.Prev.x+bl.Prev.w+FormMain.FrameEditLines.UpDownHorizontal.Position div 2,bl.y - FormMain.FrameEditLines.UpDownVertical.Position div 2);
      ownCanvas.lineto(bl.Prev.x+bl.Prev.w+FormMain.FrameEditLines.UpDownHorizontal.Position div 2,bl.y - FormMain.FrameEditLines.UpDownVertical.Position div 2);
      ownCanvas.lineto(bl.x+bl.w div 2,bl.y - FormMain.FrameEditLines.UpDownVertical.Position div 2);
      ownCanvas.lineto(bl.x+bl.w div 2, bl.y);
    end;
    end;
  end;

  end;
end;

procedure DrawTree(bl: pBlock; var maxx, maxy: Integer; ownCanvas: TCanvas);
var
  temp: pBlock;
  num: Integer;
begin
  if bl <> nil then
  begin
    DrawBlock(bl,ownCanvas);
    if bl.y+bl.h>maxy then
      maxy:=bl.y+bl.h;
    if bl.x+bl.w>maxx then
      maxx:=bl.x+bl.w;

    if bl.Prev<>nil then
    begin

      num:=0;
      while (bl.Prev.Next[num]<>bl) and (num<length(bl.Prev.Next)) do
        inc(num);
      if Num>=length(bl.Prev.Next) then
      begin
        num:=bl.h-FormMain.FrameEditBlocks.UpDownHeight.Position;
        bl.Prev.Next[num]:=bl;
      end;

      DrawLine(bl, num, ownCanvas);
    end;

    temp := bl;
    for var i := 0 to High(temp.Next) do
    begin
      temp := bl.Next[i];
      DrawTree(temp,maxx, maxy, ownCanvas);
    end;
  end;
end;

Procedure ShowHintBlock(num: Integer; ownCanvas: TCanvas);

begin
  ownCanvas.Pen.Style:=HintBlockStyle;
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

  DrawBlock(HintBlock, ownCanvas);
  DrawLine(HintBlock,num,ownCanvas);

  ownCanvas.Pen.Style:=psSolid;
end;

procedure DrawAllBlocks(ownCanvas: TCanvas);
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
    DrawTree(temp.Block, maxx, maxy, ownCanvas);
  end;

  if (CurBlock<>nil) then
  begin

    if CurBlock.y+200>maxy then
      maxy:=CurBlock.y+200;
    if CurBlock.x+200>maxx then
      maxx:=CurBlock.x+200;

    if Flag then
    begin
      DrawTree(CurBlock,maxx, maxy, ownCanvas);
    end;
  end;

  if ownCanvas=FormMain.PaintField.Canvas then
  begin
    FormMain.PaintField.width:=maxx+200;
    FormMain.PaintField.height:=maxy+200;
  end;

  if CurHighLightedBlock<>nil then
  begin
    ownCanvas.Pen.Width:=2;
    HighLightBlock.Shape:=CurHighLightedBlock.Shape;
    HighLightBlock.H := CurHighLightedBlock.H+1;
    HighLightBlock.W := CurHighLightedBlock.W+1;
    HighLightBlock.y := CurHighLightedBlock.y;
    HighLightBlock.x := CurHighLightedBlock.x;

    OwnCanvas.Brush.Style:=bsClear;
    DrawBlock(HighLightBlock,ownCanvas);
    OwnCanvas.Brush.Style:=bsSolid;
    ownCanvas.Pen.Width:=1;
  end;

  if HintBlock.Prev<>nil then
    ShowHintBlock(ConnectNum,ownCanvas);
end;


procedure TFormMain.PaintFieldDblClick(Sender: TObject);
var
  num: Integer;
begin
  if CurHighLightedBlock<>nil then
  begin
    EditText.Show;

    EditText.Left := CurHighLightedBlock.x - (Field.HorzScrollBar.Position);
    EditText.Top := CurHighLightedBlock.y - (Field.VertScrollBar.Position);
    EditText.Height := CurHighLightedBlock.h;
    EditText.Width := CurHighLightedBlock.w;


    EditText.prev := CurHighLightedBlock;

    EditText.Alignment:=taCenter;
    EditText.Font.Size:=StrToInt(EditFontSize.Items[EditText.prev.FontSize]);
    EditText.Font.Name:=ChangeFontStyle.Items[EditText.prev.FontStyle];
    EditText.Text := CurHighLightedBlock.Text;
  end;
end;

procedure TFormMain.PaintFieldPaint(Sender: TObject);
begin
  DrawAllBlocks(PaintField.Canvas);
end;


procedure FindBlockInTree(bl: pBlock; x, y: Integer; var res: pBlock);
var
  temp: pBlock;
begin
  if (bl <> nil) and (res=nil) then
  begin
    case bl.Shape of

      stRectangle..stTerminator:
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

  stCircle, stTerminator:
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
  ContinueCompacting, temp1: Boolean;
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

Procedure StructuriseBlocks(Blocks: pAllBlocks);
var
  temp: pAllBlocks;
  dist: Integer;
begin
  temp := Blocks;
  SetDefaultCoords(-1000,-1000);
  while (temp.Next <> Nil) do
  begin
    temp := temp.Next;
    dist:=0;
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
      tempDist := sqrt(sqr(X - (bl.x+bl.w div 2)) + sqr(Y - (bl.y+bl.h div 2)));

      if (tempDist < Min) and (x < FormMain.FrameEditLines.UpDownHorizontal.Position+bl.x+bl.w +210)
         and (y < FormMain.FrameEditLines.UpDownVertical.Position+bl.y+bl.h+210) then
      begin
        if (bl.x-10<=x) and (y>=bl.y-FormMain.FrameEditLines.UpDownVertical.Position-210) then
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


function FindMinDist(X, Y: Integer; main: pointer): pBlock;
var
  temp: pAllBlocks;
  curMin: Real;
begin
  curMin := MaxInt;
  temp := Blocks;
  Result := Nil;
  if main<>nil then
  begin
    x:=x+pBlock(main).w div 2;
    y:=y+pBlock(main).h div 2;
  end;
  while temp.Next <> Nil do
  begin
    temp := temp.Next;
    FindMinDistInTree(temp.Block, X, Y, curMin, Result, main);
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
  num: Integer;

begin

  Dispose(CurBlock);
  CurBlock:=nil;
  HintBlock.Prev:=nil;
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

  temp.Shape := (Source as TStartBlock).Shape;

  case temp.Shape of
    stRectangle, stCycle:
        SetLength(Temp.Next, 2);

    stDecision:
        SetLength(Temp.Next, 3);

    stCircle, stTerminator:
        SetLength(Temp.Next, 1);
  end;

  for var i := 0 to High(Temp.Next) do
    Temp.Next[i] := nil;

  with temp^ do
  begin
    W := FrameEditBlocks.UpDownWidth.Position;
    H := FrameEditBlocks.UpDownHeight.Position;
    FillColor:=clWhite;
    BorderColor:=clBlack;
    FontSize:=EditFontSize.ItemIndex;
    FontStyle:=ChangeFontStyle.ItemIndex;
  end;

  temp.Text := 'Hello';
  temp.TextHorAllign:=THorAllign(EditHorAl.ItemIndex);
  temp.TextInterval:=4;
  temp.TextVertAllign:=TVertAllign(EditVertAl.ItemIndex);

  flag := False;
  PaintField.EndDrag(True);
  StructuriseBlocks(Blocks);

  CurHighLightedBlock := temp;
  HighLightBlock.Shape:=CurHighLightedBlock.Shape;
  HighLightBlock.H := CurHighLightedBlock.H+2;
  HighLightBlock.W := CurHighLightedBlock.W+2;
  HighLightBlock.y := CurHighLightedBlock.y-1;
  HighLightBlock.x := CurHighLightedBlock.x-1;

  addUndo(CurFile);

  PaintField.Invalidate();
end;

procedure TFormMain.StartBlockDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);

var
  Connect: Boolean;

Var
  num:Integer;
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

      Connect:=(CurHighLightedBlock.Next[num]=nil);

      if (CurHighLightedBlock.Shape in [stCircle, stTerminator]) and (CurHighLightedBlock.Prev<>nil) then
        Connect:=False;

      if (CurBlock.Shape in [stCircle, stTerminator]) and (CurBlock.Next[0]<>nil) then
        Connect:=False;

      if Connect then
      begin
        HighLightBlock.Shape:=CurHighLightedBlock.Shape;
        HighLightBlock.H := CurHighLightedBlock.H+2;
        HighLightBlock.W := CurHighLightedBlock.W+2;
        HighLightBlock.y := CurHighLightedBlock.y-1;
        HighLightBlock.x := CurHighLightedBlock.x-1;
        HintBlock.Prev:=CurHighLightedBlock;
        HintBlock.Shape:=CurBlock.Shape;
        HintBlock.w:=CurBlock.w;
        HintBlock.h:=CurBlock.H;
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

  end;
  PaintField.Invalidate();

end;

procedure TFormMain.UndoExecute(Sender: TObject);
begin
  getUndo(CurFile);
  Blocks:=curFile.Diag;
  CurHighLightedBlock := Nil;
  paintField.Invalidate();
end;

procedure TFormMain.UndoUpdate(Sender: TObject);
begin
  Undo.Enabled:=CurFile.UndoList.Next.Next<>nil;
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
    addUndo(CurFile);
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

      CurHighLightedBlock:=CurBlock.prev;
      HighLightBlock.Shape:=CurHighLightedBlock.Shape;
      HighLightBlock.H := CurHighLightedBlock.H+2;
      HighLightBlock.W := CurHighLightedBlock.W+2;
      HighLightBlock.y := CurHighLightedBlock.y-1;
      HighLightBlock.x := CurHighLightedBlock.x-1;

      CurBlock.Prev.Next[num]:=nil;
      CurBlock.h:=CurBlock.H+num;
      //CurBlock.Prev:=nil;
    end;
  end;

end;

procedure TFormMain.BlockMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  num: Integer;
  Connect:Boolean;

begin

  if flag then
  begin

    MoveAllBlocks(CurBlock, X, Y);

    if (x<>x0) or (y<>y0) then
      CurBlock.Prev:=nil;

    y0:=y;
    x0:=x;

    if CurBlock.Prev = nil then
    begin
      CurHighLightedBlock := FindMinDist(CurBlock.x, CurBlock.y, CurBlock);
      HintBlock.Prev:=nil;

      if CurHighLightedBlock<>nil then
      begin
        num:=ConnectBlocks(CurHighLightedBlock, CurBlock);

        Connect:=(CurHighLightedBlock.Next[num]=nil);

        if (CurHighLightedBlock.Shape in [stCircle, stTerminator]) and (CurHighLightedBlock.Prev<>nil) then
          Connect:=False;

        if (CurBlock.Shape in [stCircle, stTerminator]) and (CurBlock.Next[0]<>nil) then
          Connect:=False;

        if Connect then
        begin
          HighLightBlock.Shape:=CurHighLightedBlock.Shape;
          HighLightBlock.H := CurHighLightedBlock.H+2;
          HighLightBlock.W := CurHighLightedBlock.W+2;
          HighLightBlock.y := CurHighLightedBlock.y-1;
          HighLightBlock.x := CurHighLightedBlock.x-1;
          HintBlock.Prev := CurHighLightedBlock;
          HintBlock.Shape:=CurBlock.Shape;
          HintBlock.w:=CurBlock.w;
          HintBlock.h:=CurBlock.H;
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


end;

procedure TFormMain.BlockMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

var
  allDiagrams, nextDiag:pAllBlocks;
  num: Integer;

begin

  if Flag then
  begin
    num:=CurBlock.h-FrameEditBlocks.UpDownHeight.Position;
    CurBlock.h:=CurBlock.h-num;
    flag := False;
    AllDiagrams:=Blocks;
    HintBlock.Prev:=nil;
    if CurBlock.Prev<>nil then
    begin
      CurBlock.Prev.Next[num]:=CurBlock;
    end
    else
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

    StructuriseBlocks(Blocks);

    CurHighLightedBlock := CurBlock;

    FrameEditBlocks.EditWidth.Enabled:=True;

    FrameEditBlocks.EditWidth.Text:=IntToStr(CurBlock.w);

    FrameEditBlocks.UpDownWidth.Position:=CurBlock.w;

    CurBlock:=nil;

    addUndo(CurFile);
  end;

  PaintField.Invalidate;
end;

end.
